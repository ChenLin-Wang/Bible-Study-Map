//
//  VBTextView.m
//  VerseView
//
//  Created by CL Wang on 4/12/23.
//

#import "VBTextView.h"

@implementation VBTextView

- (BOOL)resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    if (result) [self.firstResponderDelegate textViewResignFirstResponder:self];
    return result;
}

- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if (result) [self.firstResponderDelegate textViewBecomeFirstResponder:self];
    return result;
}

- (BOOL)acceptsFirstResponder { return true; }

- (void)mouseEntered:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseEntered:event]; }
- (void)mouseMoved:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseMoved:event]; }
- (void)mouseExited:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseExited:event]; }

@end
