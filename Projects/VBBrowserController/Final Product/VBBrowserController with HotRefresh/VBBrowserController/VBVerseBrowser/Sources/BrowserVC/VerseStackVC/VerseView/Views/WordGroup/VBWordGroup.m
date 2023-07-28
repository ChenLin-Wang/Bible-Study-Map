//
//  VBWordGroup.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBWordGroup.h"

@interface VBWordGroup()

@property NSMutableArray<VBWordCard *> * wordCards_Private;

@end

@implementation VBWordGroup
@synthesize contentRect = contentRect;

- (instancetype)init {
    self = [super init];
    self.wordCards_Private = [NSMutableArray new];
    self->contentRect = NSMakeRect(0, 0, 0, 0);
    return self;
}

- (instancetype)initRefGroupWithWordCard:(VBWordCard *)wordCard initPoint:(NSPoint)point {
    self = [self init];
    [self appendWordCard:wordCard];
    self->contentRect = NSMakeRect(point.x, point.y, VBWordCard.fixedSize.width, VBWordCard.fixedSize.height);
    return self;
}

- (void)appendWordCard:(VBWordCard *)wordCard {
    if (self.wordCards.count != 0 && ![self.wordCards.lastObject.word isNextWord:wordCard.word]) { NSLog(@"WordGroup 增加失败"); return;}
    if (wordCard.belongedGroup) {  NSLog(@"合并 group 出现冲突，虽然可正常运行，但仍需排查"); }
    wordCard.belongedGroup = self;
    
    if (self.wordCards.count == 0) {
        wordCard.word.linerPoint = wordCard.layoutFrame.origin;
        self->contentRect = NSMakeRect(wordCard.frame.origin.x, wordCard.frame.origin.y, VBWordCard.fixedSize.width, VBWordCard.fixedSize.height);
    } else {
        CGFloat spacing = wordCard.word.linerPoint.y == 0 ? VB_CARD_SPACING : wordCard.word.linerPoint.y;
        [wordCard changeOrigin:NSMakePoint(self.contentRect.origin.x, self.contentRect.origin.y + self.contentRect.size.height + spacing)];
        self->contentRect = NSMakeRect(self.contentRect.origin.x, self.contentRect.origin.y, VBWordCard.fixedSize.width, self.contentRect.size.height + VBWordCard.fixedSize.height + spacing);
    }
    
    [self.wordCards_Private addObject:wordCard];
}

- (void)removeWordCardWithMode:(BOOL)isRemoveHead {
    if (self.wordCards.count == 0) return;
    
    VBWordCard * wordCard = isRemoveHead ? self.wordCards.firstObject : self.wordCards.lastObject;
    
    if (self->contentRect.size.height == 0 || !wordCard.belongedGroup) { NSLog(@"删除失败"); return; }
    wordCard.belongedGroup = nil;
    
    if (isRemoveHead) {
        CGFloat spacing = self.wordCards.count == 1 ? 0 : (self.wordCards[1].word.linerPoint.y == 0 ? VB_CARD_SPACING : wordCard.word.linerPoint.y);
        self->contentRect = NSMakeRect( self.contentRect.origin.x, self.contentRect.origin.y, VBWordCard.fixedSize.width, self.contentRect.size.height - VBWordCard.fixedSize.height - spacing );
        [self.wordCards_Private removeObjectAtIndex:0];
    } else {
        CGFloat spacing = self.wordCards.count == 1 ? 0 : (wordCard.word.linerPoint.y == 0 ? VB_CARD_SPACING : wordCard.word.linerPoint.y);
        self->contentRect = NSMakeRect( self.contentRect.origin.x, self.contentRect.origin.y, VBWordCard.fixedSize.width, self.contentRect.size.height - VBWordCard.fixedSize.height - spacing );
        [self.wordCards_Private removeLastObject];
    }
    
}

- (void)changeOrigin:(NSPoint)origin {
    self->contentRect = NSMakeRect(origin.x, origin.y, self->contentRect.size.width, self->contentRect.size.height);
    NSPoint curOrigin = origin;
    
    NSInteger i = 0;
    for (VBWordCard * curCard in self.wordCards) {
        if (i > 0) curOrigin = NSMakePoint(curOrigin.x, curOrigin.y + VBWordCard.fixedSize.height + (curCard.word.linerPoint.y <= 0 ? VB_CARD_SPACING : curCard.word.linerPoint.y));
        [curCard changeOrigin:curOrigin];
        i ++;
    }
    
    self.wordCards.firstObject.word.linerPoint = origin;
}

- (NSRect)contentRect {
    return self->contentRect;
}

- (void)removeAll {
    for(NSInteger i = self.wordCards.count - 1; i >= 0; i--) {
        [self removeWordCardWithMode:NO];
    }
}

- (NSArray<VBWordCard *> *)wordCards { return self.wordCards_Private; }

- (BOOL)isEmpty { return self.wordCards.count == 0; }

@end



#import <objc/runtime.h>

static const NSString * belongedGroup_Key = @"VBBrowserController.VBVerseView.Property.Key.belongedGroup";

@implementation VBWordCard(GroupExtension)

- (VBWordGroup *)belongedGroup {
    return objc_getAssociatedObject(self, &belongedGroup_Key);
}

- (void)setBelongedGroup:(VBWordGroup *)belongedGroup {
    objc_setAssociatedObject(self, &belongedGroup_Key, belongedGroup, OBJC_ASSOCIATION_ASSIGN);
}

@end
