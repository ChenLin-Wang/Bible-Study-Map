//
//  VBVerseLabelContainer.h
//  VBBrowserController
//
//  Created by CL Wang on 5/4/23.
//

//#import "VBMaskedTextView.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

//@class VBVerseLabel;

@interface VBVerseLabelContainer : NSView

@property NSArray<NSString *> * bibleVersions;
@property (readonly) NSInteger curIndex;
@property (readonly) NSString * curVersion;

- (void)refreshVersionWithIndex:(NSInteger)index;
- (BOOL)canGoNext;
- (BOOL)canGoPrevious;
- (void)goNext;
- (void)goPrevious;

@end

NS_ASSUME_NONNULL_END
