//
//  VBTableView.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBTableView.h"
#import "VBTableView-Categories.m"
#import "NSObject+LayoutConstraints.h"

#define COLUMN_MIN_WIDTH 50
#define DEFAULT_MAX_HEIGHT 50
#define TABLE_ID_HEADER @"VBVerseBrowser.VBBrowserVC.VBVerseStackView.VBTableView.Column.Id"


@interface VBTableView()

@property CGFloat maxHeight;
@property (weak) id<VBVerseViewProvider> verseViewProvider;
@property BOOL shouldShowDisplayNow;

@end

@implementation VBTableView

- (void)prepareWithVerseViewProvider:(id<VBVerseViewProvider>)verseViewProvider {
    self.verseViewProvider = verseViewProvider;
    [self configDefaultValues];
    [self deploySettings];
}

- (void)updateColumnNums:(NSInteger)columnCount {
    self.shouldShowDisplayNow = NO;
    // 更新表列的数量
    [self updateColumnsWithCount: columnCount];
}

- (void)appendColumnWithDirection:(VBViewAppendDirection)direction {
    self.shouldShowDisplayNow = NO;
    // 更新表列的数量，使其 + 1
    [self updateColumnsWithCount: self.tableColumns.count + 1];
}

- (void)removeFirstColumn {
    self.shouldShowDisplayNow = NO;
    [self removeTableColumn:self.tableColumns.firstObject];
}

- (void)removeLastColumn {
    self.shouldShowDisplayNow = NO;
    [self removeTableColumn:self.tableColumns.lastObject];
}

- (void)changeWidthOfColumnWithIndex:(NSInteger)index width:(CGFloat)width {
    self.tableColumns[index].width = width;
}

- (void)changeMaxHeight:(CGFloat)maxHeight {
    CGFloat newHeight = maxHeight;
    if (maxHeight <= 0) newHeight = 1;
    self.maxHeight = newHeight;
    self.rowHeight = newHeight;
}

- (void)reloadDisplay {
    [self reloadData];
}

- (void)reloadLastColumn {
    [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndex:self.tableColumns.count - 1]];
}

- (void)reloadData {
    self.shouldShowDisplayNow = YES;
    [super reloadData];
}

- (void)reloadDataForRowIndexes:(NSIndexSet *)rowIndexes columnIndexes:(NSIndexSet *)columnIndexes {
    self.shouldShowDisplayNow = YES;
    [super reloadDataForRowIndexes:rowIndexes columnIndexes:columnIndexes];
    [self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
}

@end

@implementation VBTableView(viewFunctions)

- (void)updateColumnsWithCount:(NSInteger)count {
    
    NSInteger neededColumns = count - self.tableColumns.count;
    if (neededColumns == 0) return;
    
    if (neededColumns > 0) {
        // 需要更多的列
        for (NSInteger i = 0; i < neededColumns; i++) {
            NSTableColumn * newColumn = [self makeNewColumnWithId:[self makeColumnIdWithIndex:i]];
            [self addTableColumn: newColumn];
        }
    } else {
        // 列太多了，需要删除一些
        for (NSInteger i = 0; i < -neededColumns; i++) {
            [self removeTableColumn:self.tableColumns.lastObject];
        }
    }
    
}

- (NSString *)makeColumnIdWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@-%ld", TABLE_ID_HEADER, index];
}

- (NSTableColumn *)makeNewColumnWithId:(NSString *)identifier {
    NSTableColumn * newColumn = [[NSTableColumn alloc] initWithIdentifier:identifier];
    newColumn.minWidth = COLUMN_MIN_WIDTH;
    return newColumn;
}

@end

@implementation VBTableView(tableViewProtocols)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.shouldShowDisplayNow ? [self.verseViewProvider numberOfRowsInTableView:tableView] : 0 ;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return self.shouldShowDisplayNow ? [self.verseViewProvider tableView:tableView viewForTableColumn:tableColumn row:row] : NULL;
}

@end

@implementation VBTableView(layout)

- (NSSize)intrinsicContentSize {
    CGFloat totalWidth = 0;
    for (NSTableColumn * curCol in self.tableColumns) {
        totalWidth += curCol.width;
    }
//    NSLog(@"size: %@", NSStringFromSize( NSMakeSize(totalWidth, self.maxHeight)));
    return NSMakeSize(totalWidth, self.maxHeight);
}

@end


@implementation VBTableView(settings)

- (void)configDefaultValues {
    self.shouldShowDisplayNow = NO;
    self.maxHeight = DEFAULT_MAX_HEIGHT;
    
    [self removeTableColumn:self.tableColumns.firstObject];
    
}

- (void)deploySettings {
    self.delegate = self;
    self.dataSource = self;
    self.style = NSTableViewStyleFullWidth;
    self.intercellSpacing = NSZeroSize;
    self.usesAutomaticRowHeights = NO;
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.focusRingType = NSFocusRingTypeNone;
    self.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
    self.gridStyleMask = NSTableViewSolidVerticalGridLineMask;
}

@end


@implementation VBTableView(appendable)

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing {
    return [self.superAppendable checkAppendDirectionWithLeadingSpace:leading trailingSpace:trailing];
}

- (VBViewAppendDirection)isAtEdgeWithLeadingSpace:(CGFloat)leading windowWidth:(CGFloat)windowWidth {
    return [self.superAppendable isAtEdgeWithLeadingSpace:leading windowWidth:windowWidth];
}

@end
