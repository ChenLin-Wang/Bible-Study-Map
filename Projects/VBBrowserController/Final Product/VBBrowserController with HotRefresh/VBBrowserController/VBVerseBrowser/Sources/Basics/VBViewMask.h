//
//  VBViewMask.h
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import <Cocoa/Cocoa.h>
#import "VBMaskedViewFirstResponderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBViewMask : NSView <VBMaskedViewFirstResponderDelegate>

@property (readonly, weak, nullable) NSView<VBMaskedView> * focusedView;
@property NSArray<NSView<VBMaskedView> *> * maskedViews;
@property (weak) __kindof NSView * containerView;

@end

NS_ASSUME_NONNULL_END
