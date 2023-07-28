//
//  VBSelectedCard.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Cocoa/Cocoa.h>

#define VB_CARD_SPACING 8
#define CARD_CONTENT_BORDER_WIDTH 4.0

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    
    BOOL    canDrag;
    BOOL    isDragged;
    BOOL    isFirstDrag;
    NSSize  dragStepOffset;
    NSSize  dragTotalOffset;
    
    NSPoint lastDragPoint;
    NSPoint dragStartPoint;
    
} VBSelectableCardPositionParams;

@class VBSelectableCard;

@protocol VBGraphicPositionDelegate <NSObject>

- (void)selectableCard:(__kindof VBSelectableCard *)card mouseDown:(NSEvent *)event;
- (void)selectableCard:(__kindof VBSelectableCard *)card rightMouseUp:(NSEvent *)event;
- (void)selectableCard:(__kindof VBSelectableCard *)card didSelect:(NSEvent *)event;
- (void)selectableCard:(__kindof VBSelectableCard *)card positionDragging:(NSEvent *)event;
- (void)selectableCard:(__kindof VBSelectableCard *)card dragFinished:(NSEvent *)event;

@end

@interface VBXIBView : NSView
@property (strong) IBOutlet NSView * contentView;
- (void)linkXib;
@end

@class VBWordBrowser;

@interface VBSelectableCard : VBXIBView

@property (readonly) BOOL isOneStateCard;
@property (readonly) BOOL selectState;
@property (readonly, weak) id<VBGraphicPositionDelegate> layoutDelegate;
@property (readonly) VBSelectableCardPositionParams positionParams;
@property (readonly) NSRect layoutFrame;

- (instancetype)initWithLayoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate;

- (void)changeLayoutFrame:(NSRect)newFrame;
- (void)changeFrame:(NSRect)newFrame;
- (void)changeOrigin:(NSPoint)newOrigin;

- (void)changeStateColor:(BOOL)isPrimary;
- (void)changeSelectState:(BOOL)isSelected;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(NSRect)frameRect NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
