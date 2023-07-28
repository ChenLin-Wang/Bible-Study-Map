//
//  VBVerseStackViewController.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBViewAppendable.h"
#import "VBVerseReference.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBVerseStackViewController : NSViewController

@property (readonly, nullable) VBVerseReference * leftestVerseRef;
@property (readonly, nullable) VBVerseReference * rightestVerseRef;
@property (readonly) CGFloat firstVerseViewWidth;
@property (readonly) CGFloat totalWidth;
@property (readonly) CGFloat leading;
@property (readonly) CGFloat trailing;

@property (readonly) BOOL isBusy;

- (void)prepareWithVerseDataProvider:(id)verseDataProvider;
- (CGFloat)updateWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs browserWindowWidth:(CGFloat)width;
- (CGFloat)appendVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction browserWindowWidth:(CGFloat)width;
- (void)checkLayoutWithBrowserWindowWidth:(CGFloat)width;

@end

@interface VBVerseStackViewController(viewAppendable) <VBViewAppendable>

@end

NS_ASSUME_NONNULL_END
