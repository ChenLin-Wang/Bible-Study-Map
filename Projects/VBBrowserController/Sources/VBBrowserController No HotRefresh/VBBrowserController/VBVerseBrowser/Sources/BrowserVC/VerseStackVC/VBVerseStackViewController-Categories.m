//
//  VBVerseStackViewController-Categories.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Foundation/Foundation.h>
#import "VBVerseStackViewController.h"
#import "VBVerseViewProvider.h"
#import "VBVerseViewController.h"

@interface VBVerseStackViewController(additions)

@end

@interface VBVerseStackViewController(verseViewProvider) <VBVerseViewProvider>

@end

@interface VBVerseStackViewController(dataHandler)

- (void)verifyVerseVCsWithVerseRefs:(NSArray<VBVerseReference *> * __nonnull)verseRefs;
- (void)handleAppendEventWithVerseRef:(VBVerseReference * __nonnull)verseRef direction:(VBViewAppendDirection)direction;

@end

@interface VBVerseStackViewController(layout) <VBVerseViewLayoutDelegate>

- (NSInteger)calculateItemCountsShouldRemoveWithBrowserWidth:(CGFloat)w
                                           shouldRemoveWidth:(CGFloat * __nullable)widthShouldRemove
                                                 removeFirst:(BOOL)removeFirst;
- (void)updateAllVCsWidths;
- (void)updateLastVCWidth;
- (void)updateMaxHeight;
- (void)updateMaxHeightByDeterHeight:(CGFloat)height oldHeight:(CGFloat)oldHeight;
- (CGFloat)recalculateMaxHeight;
- (void)calculateTotalWidthAndMonitorSpaces;

@end
