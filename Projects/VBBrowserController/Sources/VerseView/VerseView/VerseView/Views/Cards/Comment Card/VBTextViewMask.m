//
//  VBTextViewMask.m
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import "VBTextViewMask.h"

@interface VBTextViewMask()

@end

@implementation VBTextViewMask
@synthesize isFocused = isFocused;
@synthesize contentTextView = contentTextView;

- (VBTextView *)contentTextView {
    return self->contentTextView;
}

- (void)setContentTextView:(VBTextView *)contentTextView {
    self->contentTextView = contentTextView;
    self->contentTextView.firstResponderDelegate = self;
}

- (void)mouseDown:(NSEvent *)event {
    if (self.isFocused) [self.contentTextView mouseDown:event];
    else [self.containerView mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {

    if (self.isFocused) [self.contentTextView mouseUp:event];
    else [self.containerView mouseUp:event];

    if (event.clickCount >= 2) {
        self.contentTextView.shouldMonitorMouse = true;
        [self.contentTextView setEditable:true];
        [self.window makeFirstResponder:self.contentTextView];
        [self.contentTextView mouseMoved:event];
        self->isFocused = true;
    }

}

- (void)rightMouseDown:(NSEvent *)event {
    if (self.isFocused) [self.contentTextView rightMouseDown:event];
    else [self.containerView rightMouseDown:event];
}

- (void)rightMouseUp:(NSEvent *)event {
    if (self.isFocused) [self.contentTextView rightMouseUp:event];
    else [self.containerView rightMouseUp:event];
}

- (void)mouseDragged:(NSEvent *)event {
    if (self.isFocused) [self.contentTextView mouseDragged:event];
    else [self.containerView mouseDragged:event];
}

- (void)textViewBecomeFirstResponder:(nonnull VBTextView *)textView {}

- (void)textViewResignFirstResponder:(nonnull VBTextView *)textView {
    [textView setEditable:false];
    [self.contentTextView setSelectedRange:NSMakeRange(0, 0)];
    self.contentTextView.shouldMonitorMouse = false;
    self->isFocused = false;
}

@end
