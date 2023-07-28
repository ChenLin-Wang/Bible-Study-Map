//
//  VBMultiSelectionBox.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBMultiSelectionBox.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Quartz/Quartz.h>
#import "VBSelectableCard.h"

#define SELECT_HANDLE_RECT_WIDTH 7.5
#define SELECT_HANDLE_STROKE_WIDTH 1.0
#define SELECT_RING_STROKE_WIDTH 1.5
#define SELECT_PREPERATION_HANDLE_STROKE_WIDTH 1.0

@interface NSCursor()

@property (class, readonly, strong) NSCursor * _windowResizeEastCursor;
@property (class, readonly, strong) NSCursor * _windowResizeWestCursor;
@property (class, readonly, strong) NSCursor * _windowResizeEastWestCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthCursor;
@property (class, readonly, strong) NSCursor * _windowResizeSouthCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthSouthCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthEastCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthWestCursor;
@property (class, readonly, strong) NSCursor * _windowResizeSouthEastCursor;
@property (class, readonly, strong) NSCursor * _windowResizeSouthWestCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthEastSouthWestCursor;
@property (class, readonly, strong) NSCursor * _windowResizeNorthWestSouthEastCursor;
@property (class, readonly, strong) NSCursor * _zoomInCursor;
@property (class, readonly, strong) NSCursor * _zoomOutCursor;
@property (class, readonly, strong) NSCursor * _helpCursor;
@property (class, readonly, strong) NSCursor * _copyDragCursor;
@property (class, readonly, strong) NSCursor * _genericDragCursor;
@property (class, readonly, strong) NSCursor * _handCursor;
@property (class, readonly, strong) NSCursor * _closedHandCursor;
@property (class, readonly, strong) NSCursor * _moveCursor;
@property (class, readonly, strong) NSCursor * _waitCursor;
@property (class, readonly, strong) NSCursor * _crosshairCursor;
@property (class, readonly, strong) NSCursor * _horizontalResizeCursor;
@property (class, readonly, strong) NSCursor * _verticalResizeCursor;
@property (class, readonly, strong) NSCursor * _bottomLeftResizeCursor;
@property (class, readonly, strong) NSCursor * _topLeftResizeCursor;
@property (class, readonly, strong) NSCursor * _bottomRightResizeCursor;
@property (class, readonly, strong) NSCursor * _topRightResizeCursor;
@property (class, readonly, strong) NSCursor * _resizeLeftCursor;
@property (class, readonly, strong) NSCursor * _resizeRightCursor;
@property (class, readonly, strong) NSCursor * _resizeLeftRightCursor;

@end

typedef enum : NSUInteger {
    VBDragHandleDirectionLeftTop                = 0,
    VBDragHandleDirectionMidTop                 = 1,
    VBDragHandleDirectionRightTop               = 2,
    VBDragHandleDirectionMidRight               = 3,
    VBDragHandleDirectionRightBottom            = 4,
    VBDragHandleDirectionMidBottom              = 5,
    VBDragHandleDirectionLeftBottom             = 6,
    VBDragHandleDirectionMidLeft                = 7
} VBDragHandleDirection;

VBSelectionBoxResizeParams makeTempResizeParams(CGFloat deltaX, CGFloat deltaY, CGFloat widthOffset, CGFloat heightOffset) {
    VBSelectionBoxResizeParams newParams;
    newParams.originOffset = NSMakeSize(deltaX, deltaY);
    newParams.sizeOffset = NSMakeSize(widthOffset, heightOffset);
    return newParams;
}

VBSelectionBoxResizeParams makeResizeParams(VBSelectionBoxResizeParams tempParams, NSSize totalDelta, NSSize totalSizeOffset) {
    VBSelectionBoxResizeParams newParams;
    newParams.originOffset = tempParams.originOffset;
    newParams.sizeOffset = tempParams.sizeOffset;
    newParams.totalOriginOffset = totalDelta;
    newParams.totalSizeOffset = totalSizeOffset;
    return newParams;
}

@implementation FlippedView - (BOOL)isFlipped { return true; } @end

@interface VBMultiSelectionBox()
@property CAShapeLayer * selectionHandlesLayer;
@property CAShapeLayer * selectionRingLayer;
@property CAShapeLayer * preparationRingLayer;
@property NSArray<NSValue *> * dragHandles;
@property VBDragHandleDirection resizingDirection;
@property BOOL isResizing;
@property BOOL isDragging;
@property BOOL isMouseDisabled;
@property BOOL isResizingStarted;
@property NSSize totalResizeOriginOffset;
@property NSSize totalResizeSizeOffset;
@end

@implementation VBMultiSelectionBox
@synthesize selectionRect = selectionRect;
@synthesize preparationSelectionRect = preparationSelectionRect;
@synthesize mouseEventHandler = mouseEventHandler;

+ (NSRect)wrappedRect:(NSRect)rect {
    return NSMakeRect(rect.origin.x - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH - SELECT_HANDLE_STROKE_WIDTH) / 2, rect.origin.y - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH - SELECT_HANDLE_STROKE_WIDTH) / 2, rect.size.width + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH - SELECT_HANDLE_STROKE_WIDTH), rect.size.height + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH - SELECT_HANDLE_STROKE_WIDTH));
}

- (instancetype)initWithMouseEventHandler:(id<VBSelectionBoxMouseEventHandler>)mouseEventHandler {
    self = [super init];
    self->mouseEventHandler = mouseEventHandler;
    [self prepare];
    return self;
}

- (void)showSelectBoxAtRect:(NSRect)rect {
    self->selectionRect = rect;
    
    NSRect boundsFrame = NSMakeRect(rect.origin.x - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH) / 2, rect.origin.y - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH) / 2, rect.size.width + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH), rect.size.height + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH));
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.selectionHandlesLayer.frame = NSMakeRect(boundsFrame.origin.x + SELECT_HANDLE_STROKE_WIDTH / 2, boundsFrame.origin.y + SELECT_HANDLE_STROKE_WIDTH / 2, boundsFrame.size.width - SELECT_HANDLE_STROKE_WIDTH, boundsFrame.size.height - SELECT_HANDLE_STROKE_WIDTH);
    self.selectionRingLayer.frame = NSMakeRect(boundsFrame.origin.x + (SELECT_HANDLE_STROKE_WIDTH + SELECT_HANDLE_RECT_WIDTH) / 2, boundsFrame.origin.y + (SELECT_HANDLE_STROKE_WIDTH + SELECT_HANDLE_RECT_WIDTH) / 2, boundsFrame.size.width - SELECT_HANDLE_STROKE_WIDTH - SELECT_HANDLE_RECT_WIDTH, boundsFrame.size.height - SELECT_HANDLE_STROKE_WIDTH - SELECT_HANDLE_RECT_WIDTH);
    
    [CATransaction commit];
    
    [self redrawSelectionBox];
}

- (void)showPreparationRingAtRect:(NSRect)rect {
    self->preparationSelectionRect = rect;
    
    NSRect boundsFrame = NSMakeRect(rect.origin.x - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH) / 2, rect.origin.y - (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH) / 2, rect.size.width + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH), rect.size.height + (SELECT_HANDLE_RECT_WIDTH + CARD_CONTENT_BORDER_WIDTH));
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.preparationRingLayer.frame = NSMakeRect(boundsFrame.origin.x + SELECT_HANDLE_STROKE_WIDTH / 2, boundsFrame.origin.y + SELECT_HANDLE_STROKE_WIDTH / 2, boundsFrame.size.width - SELECT_HANDLE_STROKE_WIDTH, boundsFrame.size.height - SELECT_HANDLE_STROKE_WIDTH);
    
    [CATransaction commit];
    
    [self redrawPreparationRing];
}

- (void)clearSelectBox {
    for (NSTrackingArea * curTrackingArea in self.trackingAreas) if (((NSNumber *)curTrackingArea.userInfo[@"index"]).integerValue > -1) [self removeTrackingArea:curTrackingArea];
    self.selectionRingLayer.path = nil;
    self.selectionHandlesLayer.path = nil;
}

- (void)clearPreparationRing {
    self.preparationRingLayer.path = nil;
}

- (NSRect)realSelectionRect {
    return self.selectionHandlesLayer.frame;
}

- (void)prepare {
    self.isResizing = false;
    self.isDragging = false;
    self.totalResizeSizeOffset = NSZeroSize;
    self.totalResizeOriginOffset = NSZeroSize;
    
    self.wantsLayer = YES;
    
    self.selectionHandlesLayer = [CAShapeLayer layer];
    self.selectionHandlesLayer.strokeColor = NSColor.blackColor.CGColor;
    self.selectionHandlesLayer.fillColor = NSColor.whiteColor.CGColor;
    self.selectionHandlesLayer.lineWidth = SELECT_HANDLE_STROKE_WIDTH;
    
    self.selectionRingLayer = [CAShapeLayer layer];
    self.selectionRingLayer.strokeColor = NSColor.controlAccentColor.CGColor;
    self.selectionRingLayer.fillColor = nil;
    self.selectionRingLayer.lineWidth = SELECT_RING_STROKE_WIDTH;
    
    self.preparationRingLayer = [CAShapeLayer layer];
    self.preparationRingLayer.fillColor = nil;
    self.preparationRingLayer.strokeColor = NSColor.textColor.CGColor;
    self.preparationRingLayer.lineWidth = SELECT_PREPERATION_HANDLE_STROKE_WIDTH;
    
    [self.layer addSublayer:self.selectionRingLayer];
    [self.layer addSublayer:self.selectionHandlesLayer];
    [self.layer addSublayer:self.preparationRingLayer];
    
    self.shadow = [NSShadow new];
    
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingInVisibleRect owner:self userInfo:@{@"index": @(-1)}]];
}

- (void)redrawPreparationRing {
    CGMutablePathRef path = CGPathCreateMutable();
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CGPathAddRect(path, nil, self.preparationRingLayer.bounds);
    
    self.preparationRingLayer.path = path;
    
    [CATransaction commit];
}

- (void)redrawSelectionBox {
    
    BOOL isAllowResize = [self.mouseEventHandler selectionBox:self allowResize:[NSEvent new]];
    
    // 拖拽柄在数组中的位置
    //  0    1    2
    //  7         3
    //  6    5    4
    self.dragHandles = @[
        [NSValue valueWithRect:CGRectMake(0, self.selectionHandlesLayer.bounds.size.height - SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake((self.selectionHandlesLayer.bounds.size.width - SELECT_HANDLE_RECT_WIDTH) / 2, self.selectionHandlesLayer.bounds.size.height - SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake(self.selectionHandlesLayer.bounds.size.width - SELECT_HANDLE_RECT_WIDTH, self.selectionHandlesLayer.bounds.size.height - SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake(self.selectionHandlesLayer.bounds.size.width - SELECT_HANDLE_RECT_WIDTH, (self.selectionHandlesLayer.bounds.size.height - SELECT_HANDLE_RECT_WIDTH) / 2, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake(self.selectionHandlesLayer.bounds.size.width - SELECT_HANDLE_RECT_WIDTH, 0, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake((self.selectionHandlesLayer.bounds.size.width - SELECT_HANDLE_RECT_WIDTH) / 2, 0, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake(0, 0, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
        [NSValue valueWithRect:CGRectMake(0, (self.selectionHandlesLayer.bounds.size.height - SELECT_HANDLE_RECT_WIDTH) / 2, SELECT_HANDLE_RECT_WIDTH, SELECT_HANDLE_RECT_WIDTH)],
    ];
    
    for (NSTrackingArea * curTrackingArea in self.trackingAreas) if (((NSNumber *)curTrackingArea.userInfo[@"index"]).integerValue > -1) [self removeTrackingArea:curTrackingArea];
    for (NSInteger i = 0; i < self.dragHandles.count; i ++) {
        NSRect curHandleRect = self.dragHandles[i].rectValue;
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:CGRectOffset(curHandleRect, self.selectionHandlesLayer.frame.origin.x, self.selectionHandlesLayer.frame.origin.y) options:NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited owner:self userInfo:@{@"index": @(i)}]];
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef ringPath = nil;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    for (NSValue * curValue in self.dragHandles) {
        NSRect curHandleRect = curValue.rectValue;
        CGPathAddRect(path, nil, curHandleRect);
        
        if (!isAllowResize) {
            CGPathMoveToPoint(path, nil, curHandleRect.origin.x, curHandleRect.origin.y);
            CGPathAddLineToPoint(path, nil, curHandleRect.origin.x + curHandleRect.size.width, curHandleRect.origin.y + curHandleRect.size.height);
            
            CGPathMoveToPoint(path, nil, curHandleRect.origin.x + curHandleRect.size.width, curHandleRect.origin.y);
            CGPathAddLineToPoint(path, nil, curHandleRect.origin.x, curHandleRect.origin.y + curHandleRect.size.height);
        }
    }
    
    ringPath = CGPathCreateMutable();
    CGPathAddRect(ringPath, nil, self.selectionRingLayer.bounds);
    
    self.selectionHandlesLayer.path = path;
    self.selectionRingLayer.path = ringPath;
    
    [CATransaction commit];
}

- (void)mouseDown:(NSEvent *)event {
    if (self.isResizing) {
        [self.mouseEventHandler selectionBox:self resizeWillStart:event];
        self.isResizingStarted = true;
    } else {
        [self.mouseEventHandler selectionBox:self mouseDown:event];
        self.isDragging = false;
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (self.isResizing) {
        if (self.isResizingStarted) [self.mouseEventHandler selectionBox:self resizeDidFinish:event];
        [NSCursor.arrowCursor set];
        self.isResizing = false;
        self.isResizingStarted = false;
        self.totalResizeSizeOffset = NSZeroSize;
        self.totalResizeOriginOffset = NSZeroSize;
    } else {
        [self.mouseEventHandler selectionBox:self mouseUp:event];
        self.isDragging = false;
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    [self.mouseEventHandler selectionBox:self rightMouseDown:event];
}

- (void)rightMouseUp:(NSEvent *)event {
    [self.mouseEventHandler selectionBox:self rightMouseUp:event];
}

- (void)mouseDragged:(NSEvent *)event {
    self.isDragging = true;
    if (self.isResizing) {
        
        if (!self.isResizingStarted) return;
        VBSelectionBoxResizeParams resizeParams;
        
        switch (self.resizingDirection) {
            case VBDragHandleDirectionLeftTop: resizeParams = makeTempResizeParams(event.deltaX, 0, -event.deltaX, event.deltaY); break;
            case VBDragHandleDirectionMidTop: resizeParams = makeTempResizeParams(0, 0, 0, event.deltaY); break;
            case VBDragHandleDirectionRightTop: resizeParams = makeTempResizeParams(0, 0, event.deltaX, event.deltaY); break;
            case VBDragHandleDirectionMidRight: resizeParams = makeTempResizeParams(0, 0, event.deltaX, 0); break;
            case VBDragHandleDirectionRightBottom: resizeParams = makeTempResizeParams(0, event.deltaY, event.deltaX, -event.deltaY); break;
            case VBDragHandleDirectionMidBottom: resizeParams = makeTempResizeParams(0, event.deltaY, 0, -event.deltaY); break;
            case VBDragHandleDirectionLeftBottom: resizeParams = makeTempResizeParams(event.deltaX, event.deltaY, -event.deltaX, -event.deltaY); break;
            case VBDragHandleDirectionMidLeft: resizeParams = makeTempResizeParams(event.deltaX, 0, -event.deltaX, 0); break;
        }
        
        self.totalResizeOriginOffset = NSMakeSize(self.totalResizeOriginOffset.width + resizeParams.originOffset.width, self.totalResizeOriginOffset.height + resizeParams.originOffset.height);
        self.totalResizeSizeOffset = NSMakeSize(self.totalResizeSizeOffset.width + resizeParams.sizeOffset.width, self.totalResizeSizeOffset.height + resizeParams.sizeOffset.height);
        
        [self.mouseEventHandler selectionBox:self resizing:event resizeParams:makeResizeParams(resizeParams, self.totalResizeOriginOffset, self.totalResizeSizeOffset)];
        
    } else [self.mouseEventHandler selectionBox:self mouseDragged:event];
}

- (void)mouseEntered:(NSEvent *)event {
    
    if (self.isResizing) return;
    self.isResizing = [self.mouseEventHandler selectionBox:self allowResize:event];
     
    if (!self.isResizing) { self.isMouseDisabled = true; [NSCursor.operationNotAllowedCursor set]; return; }
    self.resizingDirection = ((NSNumber *)event.trackingArea.userInfo[@"index"]).integerValue;
    
    switch (self.resizingDirection) {
        case VBDragHandleDirectionLeftTop:
        case VBDragHandleDirectionRightBottom: [NSCursor._windowResizeNorthEastSouthWestCursor set]; break;
        case VBDragHandleDirectionRightTop:
        case VBDragHandleDirectionLeftBottom: [NSCursor._windowResizeNorthWestSouthEastCursor set]; break;
        case VBDragHandleDirectionMidTop:
        case VBDragHandleDirectionMidBottom: [NSCursor._windowResizeNorthSouthCursor set]; break;
        case VBDragHandleDirectionMidRight:
        case VBDragHandleDirectionMidLeft: [NSCursor._windowResizeEastWestCursor set]; break;
    }
    
}

- (void)mouseExited:(NSEvent *)event {
    
    if (self.isMouseDisabled) [NSCursor.arrowCursor set];
//    if (!self.isResizing) return;
//    self.isResizing = false;
//    [NSCursor.arrowCursor set];
//    self.totalResizeSizeOffset = NSZeroSize;
//    self.totalResizeOriginOffset = NSZeroSize;
}

- (void)mouseMoved:(NSEvent *)event {
//    NSLog(@"mouseMoved");
    if (!self.isResizing) return;
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
    BOOL isFounded = false;
    for (NSTrackingArea * curArea in self.trackingAreas) {
        if (NSPointInRect(point, curArea.rect)) {
            isFounded = true;
        }
    }
    if (!isFounded) {
        self.isResizing = false;
        [NSCursor.arrowCursor set];
        self.totalResizeSizeOffset = NSZeroSize;
        self.totalResizeOriginOffset = NSZeroSize;
    }
}

@end
