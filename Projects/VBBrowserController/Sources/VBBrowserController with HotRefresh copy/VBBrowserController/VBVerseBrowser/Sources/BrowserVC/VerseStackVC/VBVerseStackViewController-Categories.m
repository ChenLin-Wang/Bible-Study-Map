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

- (void)verifyVerseVCsWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs;
- (void)handleAppendEventWithVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction;

@end

@interface VBVerseStackViewController(layout) <VBVerseViewLayoutDelegate>

- (NSInteger)shouldRemoveFirstVCsWithBrowserWidth:(CGFloat)w;
- (NSInteger)shouldRemoveLastVCsWithBrowserWidth:(CGFloat)w;
- (void)updateAllVCsWidths;
- (void)updateLastVCWidth;
- (void)updateMaxHeight;
- (void)updateMaxHeightByDeterHeight:(CGFloat)height;
- (CGFloat)checkMaxHeight;

@end
