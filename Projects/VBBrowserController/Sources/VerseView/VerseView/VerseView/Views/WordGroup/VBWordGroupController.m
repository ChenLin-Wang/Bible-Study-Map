//
//  VBWordGroupController.m
//  VerseView
//
//  Created by CL Wang on 4/6/23.
//

#import "VBWordGroupController.h"

@interface VBWordGroupController()
@property NSMutableArray <VBWordGroup *> * wordGroups;
@property (readonly) NSSize toleranceDragSize;
@end

@implementation VBWordGroupController

- (instancetype)init {
    self = [super init];
    self.wordGroups = [NSMutableArray new];
    return self;
}

- (NSSize)toleranceDragSize { return NSMakeSize(30, 30); }

- (void)remakeWithWords:(NSArray<VBWord *> *)words cardDelegate:(id<VBGraphicPositionDelegate>)cardDelegate {
    [self.wordGroups removeAllObjects];
    
    VBWordGroup * curGroup;
    
    NSInteger i = 0;
    for (VBWord * curWord in words) {
        VBWordCard * curWordCard = [[VBWordCard alloc] initWithWord:curWord layoutDelegate:cardDelegate];
        
        if (i == 0 || curWord.linerPoint.x != 0 || ![curGroup.wordCards.lastObject.word isNextWord:curWord]) {
            // 绝对坐标，创建新组
            curGroup = [VBWordGroup new];
            [self.wordGroups addObject:curGroup];
            [curWordCard changeOrigin:curWord.linerPoint];
        } // else {} <- 非绝对坐标，要依附于上一条经文卡片，所以不用从新分组
        
        [curGroup appendWordCard:curWordCard];
        i ++;
    }
}

- (VBCardsMoveResult)wordCardsDidMove:(NSArray<VBWordCard *> *)cards offset:(NSSize)offset {
    VBCardsMoveResult result;
    result.isCombined = false;
    if (cards.count == 0 || NSEqualSizes(NSZeroSize, self.toleranceDragSize)) return result;
    
    NSArray<NSArray<__kindof VBSelectableCard *> *> * filteredCards = [self filterCardArray:cards];
    NSArray<VBWordCard *> * wordCards = [self sortWordCards:filteredCards[0]];
    
    NSMutableArray<VBWordGroup *> * newGroups = [NSMutableArray new];
    NSMutableArray<VBWordCard *> * effectedWordCards = [NSMutableArray new];
    
    // 为 wordcards 重新分割分组，并将其放在 newGroups 数组中，所以 newGroups 数组中包括了所有的 wordcards，都内嵌在其 group 中
    for (VBWordGroup * curGroup in self.groups) {
        VBWordGroup * newGroup;
        for (VBWordCard * curCard in wordCards) {
            if (!curCard.belongedGroup) continue;
            if (curCard.belongedGroup == curGroup) {
                
                newGroup = [VBWordGroup new];
                
                NSArray<VBWordCard *> * curBelongedWordCards = curCard.belongedGroup.wordCards;
                NSInteger curCardIndex = [curBelongedWordCards indexOfObject:curCard];
                NSMutableArray<VBWordCard *> * temp = [NSMutableArray new];
                
                // 先将 wordcards 从原组中删除
                for(NSInteger i2 = curBelongedWordCards.count - 1; i2 >= curCardIndex; i2--) {
                    VBWordCard * curWC = curBelongedWordCards[i2];
                    [curCard.belongedGroup removeWordCardWithMode:NO];
                    [temp insertObject:curWC atIndex:0];
                }
                
                // 将这些 wordcards 放到新组中，同时将这些 wordcards 记录到受影响清单
                for (VBWordCard * curWC in temp) {
                    [newGroup appendWordCard:curWC];
                    [effectedWordCards addObject:curWC]; // <- 记录到受影响清单中
                }
                
                break;
            }
        }
        
        if (!curGroup.isEmpty) [newGroups addObject:curGroup];
        if (newGroup) [newGroups addObject:newGroup];
    }
    
    [self recorrectFramesWithGroups:newGroups];

    result.effectedCards = [filteredCards[1] arrayByAddingObjectsFromArray:effectedWordCards];
    // 对 newGroups 进行合并动作(如果有其中有 group 符合合并的条件)
    result.isCombined = [self combineGroupsIfPossible:newGroups];
    
    [self.wordGroups removeAllObjects];
    [self.wordGroups addObjectsFromArray:newGroups];
    
    return result;
}

- (BOOL)combineGroupsIfPossible:(NSMutableArray<VBWordGroup *> *)groups {
    
    BOOL isCombined = false;
    
    for(NSInteger i = groups.count - 2; i >= 0; i--) {
        VBWordGroup * curGroup = groups[i];
        VBWordGroup * nextGroup = groups[i + 1];
        
        // 通过判断原点的 x 坐标来确定相邻两组是否可以被合并，如果两组不相邻，则不可合并
        //
        //      |-----------|                                                        |---|
        //      | nextGroup |   M is leftBottomCornPoint, used to make deterFrame -> | M |
        //      M-----------|                                                        |---|
        //    /
        //  v
        //  o-----------|
        //  | curGroup  |       o is leftTopCornPoint
        //  |-----------|
        
        NSPoint leftTopCornPoint = NSMakePoint(curGroup.contentRect.origin.x, curGroup.contentRect.origin.y + curGroup.contentRect.size.height);
        NSPoint leftBottomCornPoint = (nextGroup.wordCards.firstObject.word.linerPoint.x == 0) ? NSMakePoint(nextGroup.contentRect.origin.x, nextGroup.contentRect.origin.y - nextGroup.wordCards.firstObject.word.linerPoint.y) : nextGroup.contentRect.origin;
        
        NSRect deterFrame = NSMakeRect(leftTopCornPoint.x - self.toleranceDragSize.width, leftTopCornPoint.y - self.toleranceDragSize.height, self.toleranceDragSize.width * 2, self.toleranceDragSize.height * 2);
        
        if ([curGroup.wordCards.lastObject.word isNextWord:nextGroup.wordCards.firstObject.word])
            if ((leftBottomCornPoint.x - deterFrame.origin.x) >= 0 && (leftBottomCornPoint.x - deterFrame.origin.x) <= deterFrame.size.width) {
                // 进行 combine
                isCombined = true;
                // 将两组进行合并，不用再进行任何判断了
                [self combineGroup:nextGroup toGroup:curGroup];
                [groups removeObjectAtIndex:i + 1];
            }
    }
    
    return isCombined;
}

- (void)combineGroup:(VBWordGroup *)group toGroup:(VBWordGroup *)superGroup {
    if (group.wordCards.count == 0 || superGroup.wordCards.count == 0) { NSLog(@"合并失败1"); return; }
    
    NSInteger curIndex = 0;
    for (NSInteger i = group.wordCards.count - 1; i >= 0; i--) {
        VBWordCard * curCard = group.wordCards[0];
        [group removeWordCardWithMode:YES];
        if (curIndex == 0) {
            CGFloat linerY = curCard.layoutFrame.origin.y - superGroup.wordCards.lastObject.layoutFrame.origin.y - VBWordCard.fixedSize.height;
            curCard.word.linerPoint = NSMakePoint(0, (linerY < VB_CARD_SPACING) ? VB_CARD_SPACING : linerY);
        }
        [superGroup appendWordCard:curCard];
        curIndex++;
    }
    
    [self.wordGroups removeObject:group];
}

- (NSArray<VBWordCard *> *)selectedCardsAtMultiSelectionRect:(NSRect)rect {
    
    NSMutableArray * result = [NSMutableArray new];
    
    for (VBWordGroup * curGroup in self.groups) {
        if (!NSIntersectsRect(rect, curGroup.contentRect)) continue;
        for (VBWordCard * curWordCard in curGroup.wordCards) {
            if (!NSIntersectsRect(rect, curWordCard.frame)) continue;
            [result addObject:curWordCard];
        }
    }
    
    return result;
}

- (NSArray<NSArray <__kindof VBSelectableCard *> *> *)filterCardArray:(NSArray<__kindof VBSelectableCard *> *)array {
    NSMutableArray <VBWordCard *>* filteredArray = [NSMutableArray new];
    NSMutableArray <__kindof VBSelectableCard *>* filteredArray_2 = [NSMutableArray new];
    
    for (__kindof VBSelectableCard * curCard in array) {
        if ([curCard isKindOfClass:VBWordCard.class]) {
            [filteredArray addObject:curCard];
        } else {
            [filteredArray_2 addObject:curCard];
        }
    }
    
    return @[filteredArray, filteredArray_2];
}

- (NSArray<VBWordCard *> *)sortWordCards:(NSArray<VBWordCard *> *)wordCards {
    return [wordCards sortedArrayUsingComparator:^NSComparisonResult(VBWordCard *  obj1, VBWordCard * obj2) {
        return [obj1.word.BPVWNumber compare:obj2.word.BPVWNumber];
    }];
}

- (void)clearAllGroups {
    for (VBWordGroup * curGroup in self.groups) {
        [curGroup removeAll];
    }
    [self.wordGroups removeAllObjects];
}

- (BOOL)recorrectFramesWithGroups:(NSArray<VBWordGroup *> *)groups {
    BOOL isRecorrected = false;
    for (VBWordGroup * group in groups) {
        if (group.contentRect.origin.x < VB_SPACING_OVERAGE || group.contentRect.origin.y < VB_SPACING_OVERAGE) {
            isRecorrected = true;
            [group changeOrigin:NSMakePoint(group.contentRect.origin.x < VB_SPACING_OVERAGE ? VB_SPACING_OVERAGE : group.contentRect.origin.x , group.contentRect.origin.y < VB_SPACING_OVERAGE ? VB_SPACING_OVERAGE : group.contentRect.origin.y)];
        }
    }
    return isRecorrected;
}

- (BOOL)recorrectFrames {
    return [self recorrectFramesWithGroups:self.groups];
}




- (NSArray<VBWordGroup *> *)groups {
    return self.wordGroups;
}

- (NSArray<VBWordCard *> *)allcards {
    NSMutableArray<VBWordCard *> * allCards = [NSMutableArray new];
    for (VBWordGroup * curGroup in self.groups) {
        [allCards addObjectsFromArray:curGroup.wordCards];
    }
    return allCards;
}

@end
