//
//  VBMaskedViewFirstResponderDelegate.h
//  VBBrowserController
//
//  Created by CL Wang on 5/3/23.
//

#ifndef VBMaskedViewFirstResponderDelegate_h
#define VBMaskedViewFirstResponderDelegate_h

@protocol VBMaskedViewFirstResponderDelegate;

@protocol VBMaskedView <NSObject>

- (id<VBMaskedViewFirstResponderDelegate>)firstResponderDelegate;
- (void)setFirstResponderDelegate:(id<VBMaskedViewFirstResponderDelegate>)responderDelegate;

- (BOOL)shouldMonitorMouse;
- (void)setShouldMonitorMouse:(BOOL)shouldMonitorMouse;

@end

@protocol VBMaskedViewFirstResponderDelegate <NSObject>

- (void)maskedViewBecomeFirstResponder:(NSView<VBMaskedView> *)maskedView;
- (void)maskedViewResignFirstResponder:(NSView<VBMaskedView> *)maskedView;

@end

#endif /* VBMaskedViewFirstResponderDelegate_h */
