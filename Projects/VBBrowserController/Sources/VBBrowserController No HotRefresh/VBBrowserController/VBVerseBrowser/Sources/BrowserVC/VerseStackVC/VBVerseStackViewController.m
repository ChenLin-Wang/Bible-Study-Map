//
//  VBVerseStackViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBVerseStackViewController.h"
#import "VBTableView.h"
#import "VBVerseStackViewController-Categories.m"
#import "VBVerseViewController.h"
#import "VBVerseViewController+addtions.h"

#define VERSE_VIEW_DEFAULT_HEIGHT 200
#define VERSE_VIEW_DEFAULT_WIDTH 100
#define REMAINING_WIDTH_MULTIPLY 2
#define ROW_NUMBER 1

@interface VBVerseStackViewController () {
    CGFloat _remainingWidth;
    CGFloat _p_leading;
    CGFloat _p_trailing;
    CGFloat _p_totalWidth;
    BOOL _p_isBusy;
}

@property (readonly) VBTableView * contentView;
@property NSMutableArray<VBVerseViewController *> * verseVCs;
@property CGFloat maxHeight;
@property (weak) id verseDataProvider;
@property CGFloat minimumRemainingWidth;
@property CGFloat remainingWidth;

@end

@implementation VBVerseStackViewController

- (void)prepareWithVerseDataProvider:(id)verseDataProvider {
    self.verseVCs = [NSMutableArray new];
    self.maxHeight = 0;
    self.verseDataProvider = verseDataProvider;
    self->_p_leading = -1;
    self->_p_trailing = -1;
    self->_p_totalWidth = 0;
    self->_p_isBusy = NO;
    self.remainingWidth = 2000;
    self.minimumRemainingWidth = NSScreen.mainScreen.frame.size.width / 2;
}

- (CGFloat)remainingWidth {
    return self->_remainingWidth;
}

- (void)setRemainingWidth:(CGFloat)remainingWidth {
    if (remainingWidth < self.minimumRemainingWidth) self->_remainingWidth = self.minimumRemainingWidth;
    else self->_remainingWidth = remainingWidth;
}

- (NSNumber * __nullable)limitStreamWithBlock:(NSNumber * __nullable (^)(void))callBack {
    if (self.isBusy) {
        NSLog(@"一个操作被禁止，因为操作过于繁忙");
        return NULL;
    }
    self->_p_isBusy = YES;
    id result = callBack();
    self->_p_isBusy = NO;
    return result;
}

- (CGFloat)updateWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs browserWindowWidth:(CGFloat)width {
    return [self limitStreamWithBlock:^id _Nullable{
        self.remainingWidth = width * REMAINING_WIDTH_MULTIPLY;
        
        // 通过 verseRefs 确定 verseVCs 数组中的 VBVerseViewController s。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
        [self verifyVerseVCsWithVerseRefs:verseRefs];
        
        CGFloat removedWidth = 0;
        
        NSInteger lastColumnsNumShouldRemove = [self calculateItemCountsShouldRemoveWithBrowserWidth:width shouldRemoveWidth:&removedWidth removeFirst:NO];
        
        for (NSInteger i = 0; i < lastColumnsNumShouldRemove; i++) [self.verseVCs removeLastObject];
        
        [self calculateTotalWidthAndMonitorSpaces];
        
        // 更新 stackView 的列数
        [self.contentView updateColumnNums:verseRefs.count - lastColumnsNumShouldRemove];
        
        // 刷新所有数据并更新所有列的宽度
        [self.contentView reloadDisplay];
        [self updateAllVCsWidths];
        [self updateMaxHeight];
        
        return @(removedWidth);
    }].floatValue;
}

- (CGFloat)appendVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction browserWindowWidth:(CGFloat)width {
    
    return [self limitStreamWithBlock:^id _Nullable{
        self.remainingWidth = width * REMAINING_WIDTH_MULTIPLY;
        
        // 这一步，处理追加事件，为 verseVCs 数组的内容进行追加。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
        [self handleAppendEventWithVerseRef:verseRef direction:direction];
        
        // 向 stackView 追加列
        [self.contentView appendColumnWithDirection:direction];
        
        CGFloat removedWidth = 0;
        BOOL fallthrough = NO;
        
        NSInteger columnsNumShouldRemove = (direction == VBViewAppendDirectionLeft) ?
        [self calculateItemCountsShouldRemoveWithBrowserWidth:width shouldRemoveWidth:&removedWidth removeFirst:NO] :
        [self calculateItemCountsShouldRemoveWithBrowserWidth:width shouldRemoveWidth:&removedWidth removeFirst:YES];
        
    //    NSLog(@"Removed Width: %f, Removed Columns: %ld", removedWidth, columnsNumShouldRemove);
        
        switch (direction) {
                
            case VBViewAppendDirectionRight:
                
                for (NSInteger i = 0; i < columnsNumShouldRemove; i++) {
                    [self.verseVCs removeObjectAtIndex: 0];
                    [self.contentView removeFirstColumn];
                }
                if (!columnsNumShouldRemove) {
                    
                    [self.contentView reloadLastColumn];
                    [self updateLastVCWidth];
                    [self updateMaxHeightByDeterHeight:self.verseVCs.lastObject.contentSize.height oldHeight:0];
                    break;
                }
                fallthrough = YES;
                
            case VBViewAppendDirectionLeft:
                
                if (!fallthrough)
                    for (NSInteger i = 0; i < columnsNumShouldRemove; i++) {
                        [self.verseVCs removeLastObject];
                        [self.contentView removeLastColumn];
                    }
                
                
                [self.contentView reloadDisplay];
                [self updateAllVCsWidths];
                [self updateMaxHeight];
                break;
                
            default: break;
        }
        
        [self calculateTotalWidthAndMonitorSpaces];
        
//        NSLog(@"RemoveWidth: %f, count: %ld", removedWidth, columnsNumShouldRemove);
        return @(removedWidth);
        
    }].floatValue;
}

- (void)checkLayoutWithBrowserWindowWidth:(CGFloat)width {
    /*
    [self limitStreamWithBlock:^NSNumber * _Nullable{
        self.remainingWidth = width * REMAINING_WIDTH_MULTIPLY;

        NSInteger lastVCsShouldRemoveNum = [self calculateItemCountsShouldRemoveWithBrowserWidth:width shouldRemoveWidth:NULL removeFirst:NO];

        for (NSInteger i = 0; i < lastVCsShouldRemoveNum; i++) {
            [self.verseVCs removeLastObject];
            [self.contentView removeLastColumn];
        }

        return NULL;
    }];
     */
}

- (VBTableView *)contentView {
    return ((VBTableView *)self.view);
}

- (CGFloat)totalWidth { return _p_totalWidth; }
- (CGFloat)leading { return _p_leading; }
- (CGFloat)trailing { return _p_trailing; }

- (VBVerseReference *)leftestVerseRef {
    if (self.verseVCs.count <= 0) return NULL;
    return self.verseVCs.firstObject.verseReference;
}

- (VBVerseReference *)rightestVerseRef {
    if (self.verseVCs.count <= 0) return NULL;
    return self.verseVCs.lastObject.verseReference;
}

- (BOOL)isBusy {
    return self->_p_isBusy;
}

- (CGFloat)firstVerseViewWidth {
    return (self.verseVCs.count >= 1) ? self.verseVCs[0].contentSize.width : 0;
}

@end


@implementation VBVerseStackViewController(additions)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentView.superAppendable = self;
    [self.contentView prepareWithVerseViewProvider:self];
}

@end


@implementation VBVerseStackViewController(dataHandler)

- (void)verifyVerseVCsWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs {
    
    NSMutableArray * newVerseVCs = [NSMutableArray new];
    
    NSInteger i = 0;
    for (VBVerseReference * curVerseRef in verseRefs) {
        VBVerseViewController * resultVC = NULL;
        for (VBVerseViewController * curVerseVC in self.verseVCs) {
            if ([curVerseVC.verseReference isEqualToVerseRef:curVerseRef]) {
                resultVC = curVerseVC;
                break;
            }
        }
        if (resultVC) {
            // 从原数组中移除 curVerseVC，防止在 newVerseVCs 中存入重复项
            [self.verseVCs removeObject:resultVC];
        } else {
            // 未在旧数组中找到，新增 VerseVC
            resultVC = [self makeNewVerseVCWithVerseRef:curVerseRef];
        }
        
        [newVerseVCs addObject:resultVC];
        i += 1;
    }
    
    // 使用 newVerseVCs 替换掉旧的 verseVCs，但保险起见，还是不要直接修改指针，而是软替换
    [self.verseVCs removeAllObjects];
    [self.verseVCs addObjectsFromArray:newVerseVCs];
}

- (void)handleAppendEventWithVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction {
    
    VBVerseViewController * newVerseVC = [self makeNewVerseVCWithVerseRef:verseRef];
    
    switch (direction) {
        case VBViewAppendDirectionLeft: [self.verseVCs insertObject:newVerseVC atIndex:0]; break;
        case VBViewAppendDirectionRight: [self.verseVCs addObject:newVerseVC]; break;
        default: break;
    }
    
}

- (VBVerseViewController *)makeNewVerseVCWithVerseRef:(VBVerseReference *)verseRef {
    VBVerseViewController * newVC = [VBVerseViewController newVerseViewControllerWithDataProvider:self.verseDataProvider layoutDelegate:self];
    // 为新 VC 设置 verseReference
    newVC.verseReference = verseRef;
    [self configTheNewVerseVC:newVC];
    return newVC;
}

- (void)configTheNewVerseVC:(VBVerseViewController *)verseVC {
    verseVC.contentSize = NSMakeSize(VERSE_VIEW_DEFAULT_WIDTH, VERSE_VIEW_DEFAULT_HEIGHT);
    verseVC.isNewVC = YES;
    [verseVC viewShouldPrepare];
    verseVC.isNewVC = NO;
}

@end


@implementation VBVerseStackViewController(layout)

- (void)reLayoutWithContentSize:(NSSize)size verseVC:(VBVerseViewController *)verseVC {
    
    if (!verseVC.isNewVC) {
        NSInteger index = [self.verseVCs indexOfObject:verseVC];
        
        if (index < 0) return;
        
        if (verseVC.contentSize.width != size.width) {
            [self calculateTotalWidthAndMonitorSpaces];
            [self.contentView changeWidthOfColumnWithIndex:index width:size.width];
        }
        
        CGFloat oldHeight = verseVC.contentSize.height;
        verseVC.contentSize = size;
        if (oldHeight != size.height) {
            [self updateMaxHeightByDeterHeight:size.height oldHeight:oldHeight];
        }
    } else verseVC.contentSize = size;
}

- (void)updateAllVCsWidths {
    NSInteger i = 0;
    for (VBVerseViewController * curVC in self.verseVCs) {
        [self.contentView changeWidthOfColumnWithIndex:i width:curVC.contentSize.width];
        i += 1;
    }
}


- (NSInteger)calculateItemCountsShouldRemoveWithBrowserWidth:(CGFloat)w
                                           shouldRemoveWidth:(CGFloat * __nullable)widthShouldRemove
                                                 removeFirst:(BOOL)removeFirst {
 
/*
     
    if (self.verseVCs.count <= 0) return 0;
    
    CGFloat bodyWidth = 0;
    BOOL calculateRemaining = NO;
    CGFloat curRemainingWidth = 0;
    BOOL splitItemDidFound = NO;
    NSInteger remainingItemsCount = removeFirst ? 0 : self.verseVCs.count - 1;
    CGFloat widthShouldRm = 0;

    for (
         NSInteger i = removeFirst ? (self.verseVCs.count - 1) : 0;
         removeFirst ? (i >= 0) : (i < self.verseVCs.count);
         removeFirst ? i-- : i++ )
    {
        VBVerseViewController * curVC = self.verseVCs[i];

        if (calculateRemaining) {

            if (!splitItemDidFound) {
                curRemainingWidth += curVC.contentSize.width;
            }

            if (curRemainingWidth > self.remainingWidth && !splitItemDidFound) {
                splitItemDidFound = YES;
                remainingItemsCount = i;
                if (!widthShouldRemove) break;
                continue;
            }

            if (splitItemDidFound) {
                widthShouldRm += curVC.contentSize.width;
            }

        }
        else bodyWidth += curVC.contentSize.width;

        if (bodyWidth >= w && !calculateRemaining) calculateRemaining = YES;
    }

    remainingItemsCount = removeFirst ? remainingItemsCount : (self.verseVCs.count - remainingItemsCount - 1);
 ***   if (widthShouldRemove) *widthShouldRemove = widthShouldRm;
    NSLog(@"total: %f, sum: %f, body: %f, remain: %f, remo: %f", self.totalWidth, bodyWidth + curRemainingWidth + widthShouldRm, bodyWidth, curRemainingWidth, bodyWidth);
    
 ***    return remainingItemsCount;
     */
    
    return 0;
}

- (void)updateLastVCWidth {
    [self.contentView changeWidthOfColumnWithIndex:self.verseVCs.count - 1 width:self.verseVCs.lastObject.contentSize.width];
}

- (void)updateMaxHeight {
    CGFloat curMaxHeight = [self recalculateMaxHeight];
    self.maxHeight = curMaxHeight;
    [self.contentView changeMaxHeight:self.maxHeight];
}

- (void)updateMaxHeightByDeterHeight:(CGFloat)height oldHeight:(CGFloat)oldHeight {
    if (self.maxHeight < height) {
        self.maxHeight = height;
        [self.contentView changeMaxHeight:self.maxHeight];
    }
    
    if (self.maxHeight == oldHeight) {
        CGFloat newHeight = [self recalculateMaxHeight];
        self.maxHeight = newHeight;
        [self.contentView changeMaxHeight:newHeight];
    }
}

- (CGFloat)recalculateMaxHeight {
    CGFloat maxHeight = 0;
    
    for (VBVerseViewController * curVC in self.verseVCs) {
        
        CGFloat curHeight = curVC.contentSize.height;
        if (curHeight > maxHeight) {
            maxHeight = curHeight;
        }
    }
    
    return maxHeight;
}

- (void)calculateTotalWidthAndMonitorSpaces {
    CGFloat curWidth = 0;
    for (VBVerseViewController * curVC in self.verseVCs) {
        curWidth += curVC.contentSize.width;
    }
    self->_p_totalWidth = curWidth;
    
    if (curWidth < self.remainingWidth) {
        self->_p_leading = -1;
        self->_p_trailing = -1;
        return;
    }
    
    CGFloat oneSideRemaining = self.remainingWidth / 2;
    
    CGFloat curLeadingSpace = 0, curTrailingSpace = 0;
    
    for (NSInteger i = 0; i < self.verseVCs.count; i ++) {
        VBVerseViewController * curVC = self.verseVCs[i];
        if (curLeadingSpace + curVC.contentSize.width > oneSideRemaining) break;
        curLeadingSpace += curVC.contentSize.width;
    }
    
    self->_p_leading = curLeadingSpace;
    
    for (NSInteger i = self.verseVCs.count - 1; i >= 0; i --) {
        VBVerseViewController * curVC = self.verseVCs[i];
        if (curTrailingSpace + curVC.contentSize.width > oneSideRemaining) break;
        curTrailingSpace += curVC.contentSize.width;
    }
    
    self->_p_trailing = curTrailingSpace;
    
    NSLog(@"TotalWidth: %f, leading: %f, trailing: %f", self.totalWidth, self.leading, self.trailing);
    
}

@end


@implementation VBVerseStackViewController(verseViewProvider)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return ROW_NUMBER;
    
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    VBVerseViewController * curVC = self.verseVCs[[tableView.tableColumns indexOfObject:tableColumn]];
    [curVC viewWillAttachToStackView];
    return curVC.view;
}

@end


@implementation VBVerseStackViewController(viewAppendable)

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading
                                                trailingSpace:(CGFloat)trailing
                                                  leftLimited:(BOOL)leftLimited
                                                 rightLimited:(BOOL)rightLimited
{
    if (leftLimited && rightLimited) return VBViewAppendDirectionNone;
    if (self.verseVCs.count <= 0) return rightLimited ? VBViewAppendDirectionRight : VBViewAppendDirectionLeft;
    if (self.leading <= 0 || self.trailing <= 0) return rightLimited ? VBViewAppendDirectionRight : VBViewAppendDirectionLeft;
    if (self.leading > leading && self.trailing > trailing) return rightLimited ? VBViewAppendDirectionRight : VBViewAppendDirectionLeft;
    
    if (self.trailing > trailing && !rightLimited) {
        return VBViewAppendDirectionRight;
    } else if (self.leading > leading && !leftLimited) {
        return VBViewAppendDirectionLeft;
    }
    
    return VBViewAppendDirectionNone;
}

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing {
    if (self.verseVCs.count <= 0) return VBViewAppendDirectionError;
    if (self.leading <= 0 || self.trailing <= 0) return VBViewAppendDirectionError;
    
//    NSLog(@"leading: %f, trailing: %f", leading, trailing);
    
    if (self.leading > leading && self.trailing > trailing) return VBViewAppendDirectionError;
    
    if (self.leading > leading) {
        return VBViewAppendDirectionLeft;
    } else if (self.trailing > trailing) {
        return VBViewAppendDirectionRight;
    }
    
    return VBViewAppendDirectionNone;
}

- (VBViewAppendDirection)isAtEdgeWithLeadingSpace:(CGFloat)leading windowWidth:(CGFloat)windowWidth {
    return VBViewAppendDirectionNone;
}

@end
