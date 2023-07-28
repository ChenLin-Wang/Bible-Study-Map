//
//  VBVerseStackViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBVerseStackViewController.h"
#import "VBVerseStackView.h"
#import "VBVerseStackViewController-Categories.m"
#import "VBVerseViewController.h"
#import "VBVerseViewController+addtions.h"
#import "VBFreezingBar.h"

#define VERSE_VIEW_DEFAULT_HEIGHT 200
#define VERSE_VIEW_DEFAULT_WIDTH 100
#define REMAINING_ITEM_COUNT 3
#define ROW_NUMBER 1

@interface VBVerseStackViewController () <VBFreezingBarDelegate>

@property (readonly) VBVerseStackView * contentView;
@property NSMutableArray<VBVerseViewController *> * verseVCs;
@property CGFloat maxHeight;
@property (weak) id verseDataProvider;

@property NSMutableOrderedSet<VBVerseViewController *> * backupedVerseVCs;
@property (class, readonly) NSInteger maximumBackupNum;

@end

@implementation VBVerseStackViewController
@synthesize freezingBar = freezingBar;

+ (instancetype)makeNew {
    return [NSStoryboard storyboardWithName:NSStringFromClass(VBVerseStackViewController.class) bundle:NSBundle.mainBundle].instantiateInitialController;
}

//- (void)prepareWithVerseDataProvider:(id)verseDataProvider layoutHandler:(id<VBVerseStackViewLayoutHandler>)layoutHandler {
- (void)prepareWithVerseDataProvider:(id)verseDataProvider {
    self->freezingBar = [VBFreezingBar newFreezingBar];
    self.freezingBar.delegate = self;
    self.verseVCs = [NSMutableArray new];
    [self prepareForBackupMethod];
    self.verseDataProvider = verseDataProvider;
//    self.layoutHandler = layoutHandler;
}

- (CGFloat)updateWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs browserWindowWidth:(CGFloat)width {
    
    [self removeAllBackup];
    
    self.maxHeight = 0;
    
    // 更新 stackView 的列数
    [self.contentView updateColumnNums:verseRefs.count];
    
    // 通过 verseRefs 确定 verseVCs 数组中的 VBVerseViewController s。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
    [self verifyVerseVCsWithVerseRefs:verseRefs];
    
    NSInteger lastColumnsNumShouldRemove = [self shouldRemoveLastVCsWithBrowserWidth:width] - 1;
    
    CGFloat removedWidth = 0;
    
    for (NSInteger i = 0; i < lastColumnsNumShouldRemove; i++) {
        removedWidth += self.verseVCs.lastObject.contentSize.width;
        [self.verseVCs removeLastObject];
        [self.freezingBar removeLastCell];
        [self.contentView removeLastColumn];
    }
    
    // 刷新所有数据并更新所有列的宽度
    [self.contentView reloadDisplay];
    [self updateAllVCsWidths];
    [self updateMaxHeight];
    
//    NSLog(@"%ld", lastColumnsNumShouldRemove);
//    NSLog(@"vcc: %ld, tbcc: %ld", self.verseVCs.count, ((NSTableView *)self.contentView.subviews.firstObject).tableColumns.count);
    
    return removedWidth;
}

- (CGFloat)appendVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction browserWindowWidth:(CGFloat)width {
    
    // 向 stackView 追加列
    [self.contentView appendColumnWithDirection:direction];
    
    NSInteger columnsNumShouldRemove = (direction == VBViewAppendDirectionLeft) ? [self shouldRemoveLastVCsWithBrowserWidth:width] : [self shouldRemoveFirstVCsWithBrowserWidth:width];
    
    // 这一步，处理追加事件，为 verseVCs 数组的内容进行追加。通过这一步，使得 verseRefs 与 verseVCs 的内容一一匹配
    [self handleAppendEventWithVerseRef:verseRef direction:direction];
    
    CGFloat removedWidth = 0;
    BOOL fallthrough = NO;
    
    switch (direction) {
            
        case VBViewAppendDirectionRight:
            
            for (NSInteger i = 0; i < columnsNumShouldRemove; i++) {
                removedWidth += self.verseVCs.firstObject.contentSize.width;
                [self addNewBackup:self.verseVCs.firstObject];
                [self.verseVCs removeObjectAtIndex: 0];
                [self.freezingBar removeFirstCell];
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
                    [self addNewBackup:self.verseVCs.lastObject];
                    [self.verseVCs removeLastObject];
                    [self.freezingBar removeLastCell];
                    [self.contentView removeLastColumn];
                }
            
            [self.contentView reloadDisplay];
            [self updateAllVCsWidths];
            [self updateMaxHeight];
            break;
            
        default: break;
    }
    
//    NSLog(@"vcc: %ld, tcc: %ld", self.verseVCs.count, ((NSTableView *)self.contentView.subviews.firstObject).tableColumns.count);
    
    return removedWidth;
}

- (void)checkLayoutWithBrowserWindowWidth:(CGFloat)width {
    NSInteger lastVCsShouldRemoveNum = [self shouldRemoveLastVCsWithBrowserWidth:width] - 1;

    for (NSInteger i = 0; i < lastVCsShouldRemoveNum; i++) {
        [self addNewBackup:self.verseVCs.lastObject];
        [self.verseVCs removeLastObject];
        [self.contentView removeLastColumn];
    }
    
//    [self.view layoutSubtreeIfNeeded];
}

- (VBVerseStackView *)contentView {
    return ((VBVerseStackView *)self.view);
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
    return self.verseVCs.firstObject.contentSize.width;
}

- (CGFloat)secondVerseViewWidth {
    return self.verseVCs[1].contentSize.width;
}

+ (NSInteger)maximumBackupNum { return 30; }

- (void)translationDidChangeWithVersion:(NSString *)version newContent:(NSString *)newContent verseRef:(VBVerseReference *)verseRef {
    [self.freezingBarDelegate translationDidChangeWithVersion:version newContent:newContent verseRef:verseRef];
}

- (void)translationVersionDidChangeAtVerseRef:(VBVerseReference *)verseRef newVersion:(NSString *)newVersion {
    [self.freezingBarDelegate translationVersionDidChangeAtVerseRef:verseRef newVersion:newVersion];
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
    [self.freezingBar removeAll];
    
    NSInteger i = 0;
    for (VBVerseReference * curVerseRef in verseRefs) {
        VBVerseViewController * resultVC = NULL;
        NSInteger curVerseVCIndex = 0;
        for (VBVerseViewController * curVerseVC in self.verseVCs) {
            if ([curVerseVC.verseReference isEqualToVerseRef:curVerseRef]) {
                resultVC = curVerseVC;
                break;
            }
            curVerseVCIndex ++;
        }
        if (resultVC) {
            // 从原数组中移除 curVerseVC，防止在 newVerseVCs 中存入重复项
            [self.verseVCs removeObject:resultVC];
        } else {
            // 未在旧数组中找到，新增 VerseVC
            resultVC = [self makeNewVerseVCWithVerseRef:curVerseRef];
        }
        
        [self.freezingBar addCellWithConf:VBMakeFreezingCellConf(curVerseRef, resultVC.view.frame.size.width)];
        [newVerseVCs addObject:resultVC];
        i += 1;
    }
    
    // 使用 newVerseVCs 替换掉旧的 verseVCs，但保险起见，还是不要直接修改指针，而是软替换
    [self.verseVCs removeAllObjects];
    [self.verseVCs addObjectsFromArray:newVerseVCs];
}

- (void)handleAppendEventWithVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction {
    
    VBVerseViewController * newVerseVC = [self makeNewVerseVCWithVerseRef:verseRef];
    VBFreezingCellConf conf = VBMakeFreezingCellConf(verseRef, newVerseVC.view.frame.size.width);
    
    switch (direction) {
        case VBViewAppendDirectionLeft: [self.verseVCs insertObject:newVerseVC atIndex:0]; [self.freezingBar insertCellWithIndex:0 conf:conf]; break;
        case VBViewAppendDirectionRight: [self.verseVCs addObject:newVerseVC]; [self.freezingBar addCellWithConf:conf]; break;
        default: break;
    }
    
}

- (VBVerseViewController *)makeNewVerseVCWithVerseRef:(VBVerseReference *)verseRef {
    VBVerseViewController * newVC;
    
    // 先检查是否有备份
    newVC = [self getVerseVCFromBackupIfExists:verseRef];
    
    if (newVC) {
        // 有备份
        newVC.isNewVC = YES;
        [newVC viewShouldPrepare];
        newVC.isNewVC = NO;
    } else {
        // 无备份，需要新建一个
        newVC = [VBVerseViewController newVerseViewControllerWithDataProvider:self.verseDataProvider layoutDelegate:self];
        newVC.verseReference = verseRef;
        [self configTheNewVerseVC:newVC];
    }
    
    return newVC;
}

- (void)configTheNewVerseVC:(VBVerseViewController *)verseVC {
    verseVC.contentSize = NSMakeSize(VERSE_VIEW_DEFAULT_WIDTH, VERSE_VIEW_DEFAULT_HEIGHT);
    verseVC.isInitialized = false;
    verseVC.isNewVC = YES;
    [verseVC viewShouldPrepare];
    verseVC.isNewVC = NO;
}

@end


@implementation VBVerseStackViewController(layout)

- (void)reLayoutWithContentSize:(NSSize)size verseVC:(VBVerseViewController *)verseVC {
    if (!verseVC.isNewVC) {
        if (![self.verseVCs containsObject:verseVC]) return;
        NSInteger index = [self.verseVCs indexOfObject:verseVC];
        if (index < 0) return;
        if (verseVC.contentSize.width != size.width) {
            [self.contentView changeWidthOfColumnWithIndex:index width:size.width];
        }
        [self updateMaxHeightByDeterHeight:size.height];
        [self.freezingBar updateCellWithIndex:index conf:VBMakeFreezingCellConf(verseVC.verseReference, size.width)];
    }
    verseVC.contentSize = size;
//    [self.layoutHandler verseStackVCShouldCheckLayout:self];
}

- (void)updateAllVCsWidths {
    NSInteger i = 0;
    for (VBVerseViewController * curVC in self.verseVCs) {
        [self.contentView changeWidthOfColumnWithIndex:i width:curVC.contentSize.width];
        [self.freezingBar updateCellWithIndex:i conf:VBMakeFreezingCellConf(curVC.verseReference, curVC.contentSize.width)];
        i += 1;
    }
}


- (NSInteger)shouldRemoveFirstVCsWithBrowserWidth:(CGFloat)w {
    CGFloat curWidth = 0;
    NSInteger i = self.verseVCs.count - 1;
    for (; i >= 0; i--) {
        VBVerseViewController * curVC = self.verseVCs[i];
        curWidth += curVC.contentSize.width;
        if (curWidth >= w) break;
    }
    NSInteger remainingItems = i;
    if (remainingItems < (REMAINING_ITEM_COUNT + 1)) return 0;
    return remainingItems - REMAINING_ITEM_COUNT;
}

- (NSInteger)shouldRemoveLastVCsWithBrowserWidth:(CGFloat)w {
    CGFloat curWidth = 0;
    NSInteger i = 0;
    for (; i < self.verseVCs.count; i++) {
        VBVerseViewController * curVC = self.verseVCs[i];
        curWidth += curVC.contentSize.width;
        if (curWidth >= w) break;
    }
    
    NSInteger remainingItems = self.verseVCs.count - i - 1;
    if (remainingItems < (REMAINING_ITEM_COUNT + 1)) return 0;
    return remainingItems - REMAINING_ITEM_COUNT;
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
    if (!curVC.isInitialized) {
        [curVC viewWillAttachToStackView];
        curVC.isInitialized = true;
    }
    return curVC.view;
}

@end


@implementation VBVerseStackViewController(viewAppendable)

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing {
    if (self.verseVCs.count <= 0) return VBViewAppendDirectionLeft;
    
//    NSLog(@"leading: %f, trailing: %f", leading, trailing);
    
    VBVerseViewController * leftestVC = self.verseVCs.firstObject;
    VBVerseViewController * rightestVC = self.verseVCs.lastObject;
    
    if (leftestVC.contentSize.width > leading && rightestVC.contentSize.width > trailing) return 3;
    
    if (leftestVC.contentSize.width > leading) {
        return VBViewAppendDirectionLeft;
    } else if (rightestVC.contentSize.width > trailing) {
        return VBViewAppendDirectionRight;
    }
    
    return VBViewAppendDirectionNone;
}

@end





@implementation VBVerseStackViewController(VerseVCBackup)

- (void)prepareForBackupMethod { self.backupedVerseVCs = [NSMutableOrderedSet new]; }
- (void)removeAllBackup { [self.backupedVerseVCs removeAllObjects]; }
- (void)addNewBackup:(VBVerseViewController *)verseVC {
//    [self.backupedVerseVCs addObject:verseVC];
////    NSLog(@"%@ -- backup count: %li", verseVC.verseReference, self.backupedVerseVCs.count);
//    if (self.backupedVerseVCs.count > VBVerseStackViewController.maximumBackupNum) {
//        [self.backupedVerseVCs removeObjectAtIndex:0];
//    }
}
- (VBVerseViewController * __nullable)getVerseVCFromBackupIfExists:(VBVerseReference *)verseRef {
//    NSLog(@"Find: %@", verseRef);
//    for (VBVerseViewController * curVerseVC in self.backupedVerseVCs.reversedOrderedSet) {
//        if ([curVerseVC.verseReference isEqualToVerseRef:verseRef]) {
////            NSLog(@"YES! We have backup!");
//            return curVerseVC;
//        }
//    }
    return nil;
}

@end
