//
//  VBVerseStackView.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBVerseViewProvider.h"
#import "VBViewAppendable.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBVerseStackView : NSView <VBViewAppendable>

@property (weak) id<VBViewAppendable> superAppendable;

- (void)prepareWithVerseViewProvider:(id<VBVerseViewProvider>)verseViewProvider;

- (void)updateColumnNums:(NSInteger)columnCount;
- (void)appendColumnWithDirection:(VBViewAppendDirection)direction;

- (void)removeFirstColumn;
- (void)removeLastColumn;

- (void)changeWidthOfColumnWithIndex:(NSInteger)index width:(CGFloat)width;
- (void)changeMaxHeight:(CGFloat)maxHeight;

- (void)reloadDisplay;
- (void)reloadLastColumn;

@end

NS_ASSUME_NONNULL_END
