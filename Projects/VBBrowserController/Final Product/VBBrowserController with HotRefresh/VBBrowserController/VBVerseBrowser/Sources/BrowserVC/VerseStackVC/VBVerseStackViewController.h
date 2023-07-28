//
//  VBVerseStackViewController.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBViewAppendable.h"
#import "VBVerseReference.h"
#import "VBFreezingBarDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VBFreezingBar;
@class VBVerseStackViewController;

//@protocol VBVerseStackViewLayoutHandler <NSObject>
//- (void)verseStackVCShouldCheckLayout:(VBVerseStackViewController *)verseStackVC;
//@end

@interface VBVerseStackViewController : NSViewController

@property (readonly, nullable) VBVerseReference * leftestVerseRef;
@property (readonly, nullable) VBVerseReference * rightestVerseRef;
@property (readonly) CGFloat firstVerseViewWidth;
@property (readonly) CGFloat secondVerseViewWidth;
@property (readonly) VBFreezingBar * freezingBar;
@property (weak) id<VBFreezingBarDelegate> freezingBarDelegate;
//@property (weak) id<VBVerseStackViewLayoutHandler> layoutHandler;

+ (instancetype)makeNew;

//- (void)prepareWithVerseDataProvider:(id)verseDataProvider layoutHandler:(id<VBVerseStackViewLayoutHandler>)layoutHandler;
- (void)prepareWithVerseDataProvider:(id)verseDataProvider;
- (CGFloat)updateWithVerseRefs:(NSArray<VBVerseReference *> *)verseRefs browserWindowWidth:(CGFloat)width;
- (CGFloat)appendVerseRef:(VBVerseReference *)verseRef direction:(VBViewAppendDirection)direction browserWindowWidth:(CGFloat)width;
- (void)checkLayoutWithBrowserWindowWidth:(CGFloat)width;

@end

@interface VBVerseStackViewController(viewAppendable) <VBViewAppendable>

@end

NS_ASSUME_NONNULL_END
