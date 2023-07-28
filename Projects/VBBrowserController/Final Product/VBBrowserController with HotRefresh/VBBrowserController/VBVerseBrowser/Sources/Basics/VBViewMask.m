//
//  VBViewMask.m
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import "VBViewMask.h"

@interface VBViewMask()

@end

@implementation VBViewMask
@synthesize focusedView = focusedView;
@synthesize maskedViews = maskedViews;

- (NSArray<NSView<VBMaskedView> *> *)maskedViews { return self->maskedViews; }

- (void)setMaskedViews:(NSArray<NSView<VBMaskedView> *> *)maskedViews {
    self->maskedViews = maskedViews;
    for (NSView<VBMaskedView> * curView in maskedViews) {
        curView.firstResponderDelegate = self;
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (self.focusedView) [self.focusedView mouseDown:event];
    else [self.containerView mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {
    if (self.focusedView) [self.focusedView mouseUp:event];
    else [self.containerView mouseUp:event];
    
    if (event.clickCount >= 2) {
        NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
        
        for (NSView<VBMaskedView> * curMaskedView in self.maskedViews.reverseObjectEnumerator) {
            NSRect curMaskedViewFrame = [curMaskedView.superview convertRect:curMaskedView.frame toView:self];
            
            if (NSPointInRect(point, curMaskedViewFrame)) {
                self->focusedView = curMaskedView;
                self.focusedView.shouldMonitorMouse = true;
                [self.window makeFirstResponder:self.focusedView];
                [self.focusedView mouseMoved:event];                // <- 这句代码没有写错，是为了保证鼠标双击之后样式正确
                break;
            }
        }
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    if (self.focusedView) [self.focusedView rightMouseDown:event];
    else [self.containerView rightMouseDown:event];
}

- (void)rightMouseUp:(NSEvent *)event {
    if (self.focusedView) [self.focusedView rightMouseUp:event];
    else [self.containerView rightMouseUp:event];
}

- (void)mouseDragged:(NSEvent *)event {
    if (self.focusedView) [self.focusedView mouseDragged:event];
    else [self.containerView mouseDragged:event];
}

- (void)maskedViewBecomeFirstResponder:(__kindof NSView *)maskedView {}

- (void)maskedViewResignFirstResponder:(__kindof NSView *)maskedView {
    self.focusedView.shouldMonitorMouse = false;
    self->focusedView = nil;
}

@end
