//
//  VBVerseStackView.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBVerseStackView.h"
#import "VBTableView.h"

@interface VBVerseStackView() {
    VBTableView * contentView;
}

@property (readonly) VBTableView * contentView;

@end

@implementation VBVerseStackView

- (void)prepareWithVerseViewProvider:(id<VBVerseViewProvider>)verseViewProvider {
    [self buildContentTableView];
    [self.contentView prepareForSuperView:self verseViewProvider:verseViewProvider];
}

- (void)updateColumnNums:(NSInteger)columnCount {
    [self.contentView updateColumnNums:columnCount];
}

- (void)appendColumnWithDirection:(VBViewAppendDirection)direction {
    [self.contentView appendColumnWithDirection:direction];
}

- (void)buildContentTableView {
    self->contentView = [VBTableView new];
}

- (void)removeFirstColumn {
    [self.contentView removeFirstColumn];
}

- (void)removeLastColumn {
    [self.contentView removeLastColumn];
}

- (void)changeWidthOfColumnWithIndex:(NSInteger)index width:(CGFloat)width {
    [self.contentView changeWidthOfColumnWithIndex:index width:width];
}

- (void)changeMaxHeight:(CGFloat)maxHeight {
    [self.contentView changeMaxHeight:maxHeight];
}

- (void)reloadDisplay {
    [self.contentView reloadData];
}

- (void)reloadLastColumn {
    [self.contentView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndex:self.contentView.tableColumns.count - 1]];
}

- (VBTableView *)contentView {
    return self->contentView;
}

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing {
    return [self.superAppendable checkAppendDirectionWithLeadingSpace:leading trailingSpace:trailing];
}

@end
