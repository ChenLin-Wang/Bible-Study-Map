//
//  VBMultiSelectionBox.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class VBMultiSelectionBox;

typedef struct {
    
    NSSize originOffset;
    NSSize sizeOffset;
    NSSize totalOriginOffset;
    NSSize totalSizeOffset;
    
} VBSelectionBoxResizeParams;

@protocol VBSelectionBoxMouseEventHandler <NSObject>

- (void)selectionBox:(VBMultiSelectionBox *)selectionBox mouseDown:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox mouseUp:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox mouseDragged:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox rightMouseDown:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox rightMouseUp:(NSEvent *)event;
- (BOOL)selectionBox:(VBMultiSelectionBox *)selectionBox allowResize:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizeWillStart:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizeDidFinish:(NSEvent *)event;
- (void)selectionBox:(VBMultiSelectionBox *)selectionBox resizing:(NSEvent *)event resizeParams:(VBSelectionBoxResizeParams)resizeParams;

@end

@interface FlippedView: NSView @end

@interface VBMultiSelectionBox : FlippedView

@property (readonly) NSRect selectionRect;
@property (readonly) NSRect realSelectionRect;
@property (readonly) NSRect preparationSelectionRect;
@property (readonly, weak) id<VBSelectionBoxMouseEventHandler> mouseEventHandler;

+ (NSRect)wrappedRect:(NSRect)rect;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(NSRect)frameRect NS_UNAVAILABLE;
- (instancetype)initWithMouseEventHandler:(id<VBSelectionBoxMouseEventHandler>)mouseEventHandler;

- (void)showSelectBoxAtRect:(NSRect)rect;
- (void)showPreparationRingAtRect:(NSRect)rect;
- (void)clearSelectBox;
- (void)clearPreparationRing;

@end

NS_ASSUME_NONNULL_END
