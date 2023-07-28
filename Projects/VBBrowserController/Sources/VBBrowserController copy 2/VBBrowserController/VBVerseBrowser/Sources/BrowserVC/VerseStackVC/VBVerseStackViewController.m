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
#define ROW_NUMBER 1

@interface VBVerseStackViewController ()

@property (readonly) VBTableView * contentView;
@property NSMutableArray<VBVerseViewController *> * verseVCs;
@property CGFloat maxHeight;
@property (weak) id verseDataProvider;
@property NSInteger remainingItemCount;

@end

@implementation VBVerseStackViewController

- (IBAction)testButton:(NSButton *)sender {
    
    [self appendVerseRef:[[VBVerseReference alloc] initWithVersionMarks:@[@"test"] verseIndex:@(random())] direction:VBViewAppendDirectionLeft browserWindowWidth:1300];
    
}



- (void)prepareWithVerseDataProvider:(id)verseDataProvider {
    self.verseVCs = [NSMutableArray new];
    self.maxHeight = 0;
    self.verseDataProvider = verseDataProvider;
    self.remainingItemCount = 6;
}

- (CGFloat)updateWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs browserWindowWidth:(CGFloat)width {
    // 更新 stackView 的列数
    [self.contentView updateColumnNums:verseRefs.count];
    
    // 通过 verseRefs 确定 verseVCs 数组中的 VBVerseViewController s。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
    [self verifyVerseVCsWithVerseRefs:verseRefs];
    
    NSInteger lastColumnsNumShouldRemove = [self shouldRemoveLastVCsWithBrowserWidth:width];
    
    CGFloat removedWidth = 0;
    
    for (NSInteger i = 0; i < lastColumnsNumShouldRemove; i++) {
        removedWidth += self.verseVCs.lastObject.contentSize.width;
        [self.verseVCs removeLastObject];
        [self.contentView removeLastColumn];
    }
    
    // 刷新所有数据并更新所有列的宽度
    [self.contentView reloadDisplay];
    [self updateAllVCsWidths];
    [self updateMaxHeight];
    
    NSLog(@"%ld", lastColumnsNumShouldRemove);
    
    return removedWidth;
}

- (CGFloat)appendVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction browserWindowWidth:(CGFloat)width {
    
    // 向 stackView 追加列
    [self.contentView appendColumnWithDirection:direction];
    
    // 这一步，处理追加事件，为 verseVCs 数组的内容进行追加。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
    [self handleAppendEventWithVerseRef:verseRef direction:direction];
    
    CGFloat removedWidth = 0;
    BOOL fallthrough = NO;
    
    NSInteger columnsNumShouldRemove = (direction == VBViewAppendDirectionLeft) ? [self shouldRemoveLastVCsWithBrowserWidth:width] : [self shouldRemoveFirstVCsWithBrowserWidth:width];
    
    switch (direction) {
            
        case VBViewAppendDirectionRight:
            
            for (NSInteger i = 0; i < columnsNumShouldRemove; i++) {
                removedWidth += self.verseVCs.firstObject.contentSize.width;
                [self.verseVCs removeObjectAtIndex: 0];
                [self.contentView removeFirstColumn];
            }
            if (!columnsNumShouldRemove) {
                
                [self.contentView reloadLastColumn];
                [self updateLastVCWidth];
                [self updateMaxHeightByDeterHeight:self.verseVCs.lastObject.contentSize.height];
                break;
            }
            fallthrough = YES;
            
        case VBViewAppendDirectionLeft:
            
            if (!fallthrough)
                for (NSInteger i = 0; i < columnsNumShouldRemove; i++) {
                    removedWidth += self.verseVCs.lastObject.contentSize.width;
                    [self.verseVCs removeLastObject];
                    [self.contentView removeLastColumn];
                }
            
            
            [self.contentView reloadDisplay];
            [self updateAllVCsWidths];
            [self updateMaxHeight];
            break;
            
        default: break;
    }
    
    
    
    return removedWidth;
}

- (void)checkLayoutWithBrowserWindowWidth:(CGFloat)width {
//    NSInteger lastVCsShouldRemoveNum = [self shouldRemoveLastVCsWithBrowserWidth:width] - 1;
//
//    for (NSInteger i = 0; i < lastVCsShouldRemoveNum; i++) {
//        [self.verseVCs removeLastObject];
//        [self.contentView removeLastColumn];
//    }
    
//    [self.view layoutSubtreeIfNeeded];
}

- (VBTableView *)contentView {
    return ((VBTableView *)self.view);
}

- (VBVerseReference *)leftestVerseRef {
    if (self.verseVCs.count <= 0) return NULL;
    return self.verseVCs.firstObject.verseReference;
}

- (VBVerseReference *)rightestVerseRef {
    if (self.verseVCs.count <= 0) return NULL;
    return self.verseVCs.lastObject.verseReference;
}

- (CGFloat)firstVerseViewWidth {
    return (self.verseVCs.count >= 1) ? self.verseVCs[0].contentSize.width : 0;
}

- (CGFloat)secondVerseViewWidth {
    return (self.verseVCs.count >= 2) ? self.verseVCs[1].contentSize.width : 0;
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
            [self.contentView changeWidthOfColumnWithIndex:index width:size.width];
        }
        
        [self updateMaxHeightByDeterHeight:size.height];
        
    }
    
    verseVC.contentSize = size;
}

- (void)updateAllVCsWidths {
    NSInteger i = 0;
    for (VBVerseViewController * curVC in self.verseVCs) {
        [self.contentView changeWidthOfColumnWithIndex:i width:curVC.contentSize.width];
        i += 1;
    }
}


- (NSInteger)shouldRemoveFirstVCsWithBrowserWidth:(CGFloat)w {
    
    if (self.verseVCs.count <= 0) return 0;
    
    CGFloat curWidth = 0;
    
    NSInteger i = self.verseVCs.count - 1;
    for (; i >= 0; i--) {
        VBVerseViewController * curVC = self.verseVCs[i];
        curWidth += curVC.contentSize.width;
        if (curWidth >= w) break;
    }
    
    NSInteger remainingItems = i;
    
    if (remainingItems < (self.remainingItemCount)) return 0;
    
    return remainingItems - self.remainingItemCount;
}

- (NSInteger)shouldRemoveLastVCsWithBrowserWidth:(CGFloat)w {
    
    if (self.verseVCs.count <= 0) return 0;
    
    CGFloat curWidth = 0;
    
    NSInteger i = 0;
    for (; i < self.verseVCs.count; i++) {
        VBVerseViewController * curVC = self.verseVCs[i];
        curWidth += curVC.contentSize.width;
        if (curWidth >= w) break;
    }
    
    NSInteger remainingItems = self.verseVCs.count - i - 1;
    
    if (remainingItems < (self.remainingItemCount)) return 0;
    
    return remainingItems - self.remainingItemCount;
}


- (void)updateLastVCWidth {
    [self.contentView changeWidthOfColumnWithIndex:self.verseVCs.count - 1 width:self.verseVCs.lastObject.contentSize.width];
}

- (void)updateMaxHeight {
    CGFloat curMaxHeight = [self checkMaxHeight];
    self.maxHeight = curMaxHeight;
    [self.contentView changeMaxHeight:self.maxHeight];
}

- (void)updateMaxHeightByDeterHeight:(CGFloat)height {
    if (self.maxHeight < height) {
        self.maxHeight = height;
        [self.contentView changeMaxHeight:self.maxHeight];
    }
}

- (CGFloat)checkMaxHeight {
    CGFloat maxHeight = 0;
    
    for (VBVerseViewController * curVC in self.verseVCs) {
        
        CGFloat curHeight = curVC.contentSize.height;
        if (curHeight > maxHeight) {
            maxHeight = curHeight;
        }
    }
    
    return maxHeight;
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

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing {
    if (self.verseVCs.count <= 0) return VBViewAppendDirectionRight;
    
    NSLog(@"leading: %f, trailing: %f", leading, trailing);
    
    VBVerseViewController * leftestVC = self.verseVCs.firstObject;
    VBVerseViewController * rightestVC = self.verseVCs.lastObject;
    
//    if (leftestVC.contentSize.width > leading && rightestVC.contentSize.width > trailing) return VBViewAppendDirectionNone;
    
    if (leftestVC.contentSize.width > leading) {
        return VBViewAppendDirectionLeft;
    } else if (rightestVC.contentSize.width > trailing) {
        return VBViewAppendDirectionRight;
    }
    
    return VBViewAppendDirectionNone;
}

- (VBViewAppendDirection)isAtEdgeWithLeadingSpace:(CGFloat)leading windowWidth:(CGFloat)windowWidth {
    
    if (leading <= 0) return VBViewAppendDirectionLeft;
    
//    if (leading <= (self.firstVerseViewWidth + self.secondVerseViewWidth)) return VBViewAppendDirectionLeft;
    
    CGFloat totalWidth = 0;
    
    for (NSInteger i = 0; i < self.verseVCs.count; i++) {
        VBVerseViewController * curVC = self.verseVCs[i];
        totalWidth += curVC.contentSize.width;
    }
    
    NSLog(@"%f, %f", (windowWidth + leading  - (7 * 2)), totalWidth);
    
    if ((windowWidth + leading - 7 * 2) >= (totalWidth)) return VBViewAppendDirectionRight;
    
    return VBViewAppendDirectionNone;
    
}

@end
