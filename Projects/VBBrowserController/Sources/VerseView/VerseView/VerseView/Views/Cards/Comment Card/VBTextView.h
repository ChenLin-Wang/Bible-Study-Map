//
//  VBTextView.h
//  VerseView
//
//  Created by CL Wang on 4/12/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class VBTextView;

@protocol VBTextViewFirstResponderDelegate <NSObject>

- (void)textViewBecomeFirstResponder:(VBTextView *)textView;
- (void)textViewResignFirstResponder:(VBTextView *)textView;

@end

@interface VBTextView : NSTextView

@property BOOL shouldMonitorMouse;
@property (weak) id<VBTextViewFirstResponderDelegate> firstResponderDelegate;

@end

NS_ASSUME_NONNULL_END
