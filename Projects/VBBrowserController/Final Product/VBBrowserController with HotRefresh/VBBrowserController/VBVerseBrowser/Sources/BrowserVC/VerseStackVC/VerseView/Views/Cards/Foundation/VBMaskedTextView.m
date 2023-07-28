//
//  VBMaskedTextView.m
//  VerseView
//
//  Created by CL Wang on 4/12/23.
//

#import "VBMaskedTextView.h"

@implementation VBMaskedTextView
@synthesize shouldMonitorMouse = shouldMonitorMouse;

- (BOOL)resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    if (result) [self.firstResponderDelegate maskedViewResignFirstResponder:self];
    return result;
}

- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if (result) [self.firstResponderDelegate maskedViewBecomeFirstResponder:self];
    return result;
}

- (BOOL)acceptsFirstResponder { return true; }

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self.superview];
    if (!NSPointInRect(point, self.frame)) {
        [self.window makeFirstResponder:self.superview];
    }
}

- (void)mouseEntered:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseEntered:event]; }
- (void)mouseMoved:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseMoved:event]; }
- (void)mouseExited:(NSEvent *)event { if (self.shouldMonitorMouse) [super mouseExited:event]; }
- (void)cursorUpdate:(NSEvent *)event { if (self.shouldMonitorMouse) [super cursorUpdate:event]; else [[NSCursor arrowCursor] set]; }

- (BOOL)shouldMonitorMouse { return self->shouldMonitorMouse; }
- (void)setShouldMonitorMouse:(BOOL)shouldMonitorMouse {
    self->shouldMonitorMouse = shouldMonitorMouse;
    if (self.canBeEdit) self.editable = shouldMonitorMouse;
    if (!shouldMonitorMouse) self.selectedRange = NSMakeRange(0, 0);
}

@end
