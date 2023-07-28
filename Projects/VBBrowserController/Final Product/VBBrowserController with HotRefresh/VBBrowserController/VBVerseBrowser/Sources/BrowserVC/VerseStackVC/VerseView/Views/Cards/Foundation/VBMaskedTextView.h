//
//  VBMaskedTextView.h
//  VerseView
//
//  Created by CL Wang on 4/12/23.
//

#import <Cocoa/Cocoa.h>
#import "VBMaskedViewFirstResponderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBMaskedTextView : NSTextView <VBMaskedView>

@property BOOL canBeEdit;
@property BOOL shouldMonitorMouse;
@property (weak) id<VBMaskedViewFirstResponderDelegate> firstResponderDelegate;

@end

NS_ASSUME_NONNULL_END
