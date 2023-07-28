//
//  VBTextViewMask.h
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import <Cocoa/Cocoa.h>
#import "VBTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBTextViewMask : NSView <VBTextViewFirstResponderDelegate>

@property (readonly) BOOL isFocused;
@property (weak) VBTextView * contentTextView;
@property (weak) __kindof NSView * containerView;

@end

NS_ASSUME_NONNULL_END
