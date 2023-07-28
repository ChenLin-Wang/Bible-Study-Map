//
//  VBScrollView.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBScrollView.h"
#import "VBScrollView-Categories.m"
#import "VBViewAppendable.h"

@interface VBScrollView()

@property (weak) id<VBBrowserVCDelegate> delegate;
@property (readonly) NSView<VBViewAppendable> * sourceView;

@end

@interface FlippedClipView : NSClipView
@end
@implementation FlippedClipView
- (BOOL)isFlipped { return YES; }
@end

@implementation VBScrollView

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView delegate:(id<VBBrowserVCDelegate>)delegate {
    self.delegate = delegate;
    [self deploySettings];
    [self loadDocumentWithView: sourceView];
}

- (void)_initScrollPointWithWidth:(CGFloat)width {

    [self scrollClipView:self.contentView toPoint:NSMakePoint(width, 0)];
}

- (void)checkLayout {
        NSLog(@"%@, %@", NSStringFromSize(self.bounds.size), NSStringFromSize(self.documentView.bounds.size));

        if (self.bounds.size.width >= self.documentView.bounds.size.width) return;

        CGFloat leadingWidth = self.curScrollingX;
        CGFloat trailingWidth = (self.documentView.bounds.size.width - self.contentView.bounds.size.width) - leadingWidth;

        VBViewAppendDirection appendDirection = [self.sourceView checkAppendDirectionWithLeadingSpace:leadingWidth trailingSpace:trailingWidth];
    
        if (appendDirection != VBViewAppendDirectionNone && appendDirection != 3) {
            [self.delegate verseViewShouldAppend:self requestType:(appendDirection == VBViewAppendDirectionLeft) ? VBVerseRequestTypePrevious : VBVerseRequestTypeNext completed:^(CGFloat appendWidth, CGFloat deletedWidth) {}];
        } else if (appendDirection == 3) {
            NSLog(@"YES");
            [self.delegate verseViewShouldAppend:self requestType:VBVerseRequestTypeNext completed:^(CGFloat appendWidth, CGFloat deletedWidth) {}];
        }
}

- (NSView<VBViewAppendable> *)sourceView {
    return self.documentView;
}

@end

@implementation VBScrollView(settings)

- (void)loadDocumentWithView:(__kindof NSView *)documentView {
    self.documentView = documentView;
    
    self.documentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * heightConstraint = [self.documentView.heightAnchor constraintEqualToAnchor:self.heightAnchor];
    heightConstraint.priority = 200;
    heightConstraint.active = YES;
    
    NSLayoutConstraint * widthConstraint = [self.documentView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
    widthConstraint.priority = 200;
    widthConstraint.active = YES;
    
}

- (void)deploySettings {
    
    self.allowedTouchTypes = NSTouchTypeDirect | NSTouchTypeIndirect;
    
    FlippedClipView * clipView = [[FlippedClipView alloc] initWithFrame:self.bounds];
    self.contentView = clipView;
    
    self.hasHorizontalScroller = YES;
    self.hasVerticalScroller = YES;
    
    self.horizontalScrollElasticity = NSScrollElasticityNone;
    self.verticalScrollElasticity = NSScrollElasticityNone;
    
}

@end

@implementation VBScrollView(appendEventMonitor)


- (void)scrollClipView:(NSClipView *)clipView toPoint:(NSPoint)point {
    
    [super scrollClipView:clipView toPoint:point];
    
    if (self.bounds.size.width >= self.documentView.bounds.size.width) return;
    
    if (self.curScrollingX != point.x) {
        [self checkVerseAppendEvent:point.x];
    }
}

//- (void)reflectScrolledClipView:(NSClipView *)cView {
//    [super reflectScrolledClipView:cView];
//
//    if (self.bounds.size.width >= self.documentView.bounds.size.width) return;
//
//    [self checkVerseAppendEvent:self.curScrollingX];
//}

- (void)checkVerseAppendEvent:(CGFloat)leadingWidth {
    
    CGFloat trailingWidth = (self.documentView.bounds.size.width - self.contentView.bounds.size.width) - leadingWidth;
    
    
    VBViewAppendDirection appendDirection = [self.sourceView checkAppendDirectionWithLeadingSpace:leadingWidth trailingSpace:trailingWidth];
    
//    NSLog(@"trail: %f, lead: %f, direction: %ld", trailingWidth, leadingWidth, appendDirection);
    if (appendDirection != VBViewAppendDirectionNone && appendDirection != 3) {

        NSPoint oldPoint = self.curScrollingPoint;

        [self.delegate verseViewShouldAppend:self requestType:(appendDirection == VBViewAppendDirectionLeft) ? VBVerseRequestTypePrevious : VBVerseRequestTypeNext completed:^(CGFloat appendWidth, CGFloat deletedWidth) {
            if (appendDirection == VBViewAppendDirectionLeft) {
                [self scrollClipView:self.contentView toPoint:NSMakePoint(oldPoint.x + appendWidth, oldPoint.y)];
            } else {
                [self scrollClipView:self.contentView toPoint:NSMakePoint(oldPoint.x - deletedWidth, oldPoint.y)];
            }
        }];
    }
    
}

@end


@implementation VBScrollView(layout)

- (NSPoint)curScrollingPoint {
    return NSMakePoint(self.curScrollingX, self.curScrollingY);
}

- (CGFloat)curScrollingX {
    return (self.documentView.bounds.size.width - self.contentView.bounds.size.width) * self.horizontalScroller.floatValue;
}

- (CGFloat)curScrollingY {
    return (self.documentView.bounds.size.height - self.contentView.bounds.size.height) * self.verticalScroller.floatValue;
}

@end
