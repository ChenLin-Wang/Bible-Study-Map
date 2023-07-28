//
//  VBTableView.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBVerseViewProvider.h"
#import "VBViewAppendable.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBTableView : NSTableView

- (void)prepareForSuperView:(__kindof NSView *)superView verseViewProvider:(id<VBVerseViewProvider>)verseViewProvider;

- (void)updateColumnNums:(NSInteger)columnCount;
- (void)appendColumnWithDirection:(VBViewAppendDirection)direction;

- (void)removeFirstColumn;
- (void)removeLastColumn;

- (void)changeWidthOfColumnWithIndex:(NSInteger)index width:(CGFloat)width;
- (void)changeMaxHeight:(CGFloat)maxHeight;

@end


NS_ASSUME_NONNULL_END
