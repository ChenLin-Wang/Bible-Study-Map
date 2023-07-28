//
//  VBSelectedCard.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBSelectableCard.h"
#import <Quartz/Quartz.h>

#define CONTENT_VIEW_EDGE 0
#define SHADOW_RADIUS 3.0

@interface VBSelectableCard()
@property CALayer * styleLayer;
@end

@interface VBSelectableCard(MouseEventMonitor)
- (void)preparePositionParams;
@end

@implementation VBSelectableCard
@synthesize selectState = selectState;
@synthesize layoutDelegate = layoutDelegate;
@synthesize positionParams = positionParams;
@synthesize layoutFrame = layoutFrame;

- (BOOL)isFlipped { return true; }

- (BOOL)isOneStateCard { return false; }

- (instancetype)initWithLayoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate {
    self = [super init];
    self->layoutDelegate = layoutDelegate;
    [self preparePositionParams];
    [self prepare];
    return self;
}

- (void)prepare {
    self.wantsLayer = YES;
    
    self.styleLayer = [CALayer layer];
    self.styleLayer.cornerRadius = self.isOneStateCard ? 7 : 10;
    self.styleLayer.borderWidth = CARD_CONTENT_BORDER_WIDTH;
    
    [self.layer addSublayer:self.styleLayer];
    
    self.shadow = [NSShadow new];
    self.styleLayer.shadowColor = [NSColor colorNamed:@"SelectRingColor"].CGColor;
    self.styleLayer.shadowOpacity = 0;
    self.styleLayer.shadowOffset = NSMakeSize(0, 0);
    self.styleLayer.shadowRadius = SHADOW_RADIUS;
    
    if (self.isOneStateCard) {
        self.styleLayer.backgroundColor = [NSColor colorNamed:@"CommentCardColor"].CGColor;
        self.styleLayer.borderColor = [NSColor colorNamed:@"CommentCardBorderColor"].CGColor;
    }
}

- (void)layout {
    [super layout];
    self.styleLayer.frame = NSMakeRect(CONTENT_VIEW_EDGE, CONTENT_VIEW_EDGE, self.layer.bounds.size.width - 2 * CONTENT_VIEW_EDGE, self.layer.bounds.size.height - 2 * CONTENT_VIEW_EDGE);
    [self changeSelectState:self.selectState];
}

- (NSRect)layoutFrame {
    if (NSEqualRects(self->layoutFrame, NSZeroRect)) {
        return self.frame;
    } else {
        return self->layoutFrame;
    }
}

- (void)changeLayoutFrame:(NSRect)newFrame {
    self->layoutFrame = newFrame;
}

- (void)changeFrame:(NSRect)newFrame {
    self->layoutFrame = newFrame;
    self.frame = newFrame;
}

- (void)changeOrigin:(NSPoint)newOrigin {
    self->layoutFrame = NSMakeRect(newOrigin.x, newOrigin.y, self->layoutFrame.size.width, self->layoutFrame.size.height);
    [self setFrameOrigin:newOrigin];
}

- (void)changeStateColor:(BOOL)isPrimary {
    if (self.isOneStateCard) return;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.styleLayer.backgroundColor = isPrimary ? [NSColor colorNamed:@"PrimaryCardColor"].CGColor : [NSColor colorNamed:@"SecondaryCardColor"].CGColor;
    self.styleLayer.borderColor = isPrimary ? [NSColor colorNamed:@"PrimaryCardBorderColor"].CGColor : [NSColor colorNamed:@"SecondaryCardBorderColor"].CGColor;
    [CATransaction commit];
}

- (void)changeSelectState:(BOOL)isSelected {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self->selectState = isSelected;
    if (isSelected) self.styleLayer.shadowOpacity = 1.0;
    else self.styleLayer.shadowOpacity = 0;
    [CATransaction commit];
}

@end


@implementation VBSelectableCard(MouseEventMonitor)

- (void)preparePositionParams {
    self->positionParams.canDrag = false;
    self->positionParams.isDragged = false;
    self->positionParams.dragStartPoint = NSZeroPoint;
    self->positionParams.dragTotalOffset = NSZeroSize;
    self->positionParams.isFirstDrag = false;
}

- (void)mouseDown:(NSEvent *)event {
//    NSLog(@"mouse down-----------");
    self->positionParams.canDrag = true;
    self->positionParams.lastDragPoint = event.locationInWindow;
    self->positionParams.dragStartPoint = event.locationInWindow;
    self->positionParams.isFirstDrag = true;
    [self.layoutDelegate selectableCard:self mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {
//    NSLog(@"mouse up----------");
    if (self.positionParams.isDragged) {
        [self.layoutDelegate selectableCard:self dragFinished:event];
    } else {
        [self.layoutDelegate selectableCard:self didSelect:event];
    }
    
    self->positionParams.canDrag = false;
    self->positionParams.isDragged = false;
    self->positionParams.dragStepOffset = NSZeroSize;
    self->positionParams.dragTotalOffset = NSZeroSize;
}

- (void)mouseDragged:(NSEvent *)event {
//    NSLog(@"mouse dragged*************");
    if (self.positionParams.canDrag) {
        self->positionParams.isDragged = true;
        self->positionParams.dragStepOffset = NSMakeSize(event.locationInWindow.x - self.positionParams.lastDragPoint.x, event.locationInWindow.y - self.positionParams.lastDragPoint.y);
        self->positionParams.lastDragPoint = event.locationInWindow;
        self->positionParams.dragTotalOffset = NSMakeSize(event.locationInWindow.x - self.positionParams.dragStartPoint.x, event.locationInWindow.y - self.positionParams.dragStartPoint.y);
        
        [self.layoutDelegate selectableCard:self positionDragging:event];
        
        if (self.positionParams.isFirstDrag) self->positionParams.isFirstDrag = false;
    }
}

@end
