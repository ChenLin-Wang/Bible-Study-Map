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
@property NSPoint lastScrollPoint;
@property BOOL isInitializing;
@property NSSize lastSize;
@property BOOL islayouting;
@property BOOL isScrolling;

@end


@implementation VBScrollView

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView delegate:(id<VBBrowserVCDelegate>)delegate {
    self.delegate = delegate;
    [self deploySettings];
}

- (void)_initScrollPointWithWidth:(CGFloat)width {
    self.lastScrollPoint = NSMakePoint(-1000, -1000);
    self.isInitializing = YES;
    [self scrollClipView:self.contentView toPoint:NSMakePoint(width, 0)];
    self.isInitializing = NO;
}

- (void)checkLayout {
//    NSLog(@"%@, %@", StringFromSize(self.bounds.size), NSStringFromSize(self.documentView.bounds.size));

    
//    if (self.isInitializing) return;
//
//    if (self.bounds.size.width >= self.documentView.bounds.size.width) return;
//    if (self.isScrolling) return;
//
//    self.islayouting = YES;
//
//    NSLog(@"Layouting");
//
//    CGFloat leadingWidth = self.curScrollingX;
//    CGFloat trailingWidth = (self.documentView.bounds.size.width - self.contentView.bounds.size.width) - leadingWidth;
//
//    VBViewAppendDirection appendDirection = [self.sourceView checkAppendDirectionWithLeadingSpace:leadingWidth trailingSpace:trailingWidth];
//
//    if (appendDirection == VBViewAppendDirectionRight) {
//        [self.delegate verseViewShouldAppend:self requestType:VBVerseRequestTypeNext completed:^(BOOL canAppend, CGFloat appendWidth, CGFloat deletedWidth) {}];
//    }
//
//    self.islayouting = NO;
}

- (NSView<VBViewAppendable> *)sourceView {
    return self.documentView;
}

@end

@implementation VBScrollView(appendEventMonitor)


- (void)scrollClipView:(NSClipView *)clipView toPoint:(NSPoint)point {
    
//    self.isScrolling = YES;
//
    while(YES) {
        NSPoint newPoint = point;
//
        if (point.x <= 0) {
            newPoint = NSMakePoint(0, point.y);
        } else {
            CGFloat remainingWidth = self.documentView.bounds.size.width - self.contentView.bounds.size.width;

            if (remainingWidth - point.x < 0) {
                newPoint = NSMakePoint(remainingWidth, point.y);
            }
        }

        if (!self.isInitializing && newPoint.x == self.lastScrollPoint.x) break;

        self.lastScrollPoint = newPoint;
//
        [super scrollClipView:clipView toPoint:newPoint];
//
//        if (self.islayouting || self.contentView.bounds.size.width > self.documentView.bounds.size.width) break;
//
//        if (self.isInitializing || self.curScrollingX != newPoint.x) {
//            NSLog(@"Scrolling");
//            [self checkVerseAppendEvent:newPoint.x];
//        }
//
        break;
    }
    
    self.isScrolling = NO;
}

- (void)checkVerseAppendEvent:(CGFloat)leadingWidth {
    
    CGFloat trailingWidth = (self.documentView.bounds.size.width - self.contentView.bounds.size.width) - leadingWidth;
    
    VBViewAppendDirection appendDirection = [self.sourceView checkAppendDirectionWithLeadingSpace:leadingWidth trailingSpace:trailingWidth];
    
    if (appendDirection != VBViewAppendDirectionNone) {
        NSPoint oldPoint = self.curScrollingPoint;
        [self.delegate verseViewShouldAppend:self requestType:(appendDirection == VBViewAppendDirectionLeft) ? VBVerseRequestTypePrevious : VBVerseRequestTypeNext completed:^(BOOL canAppend, CGFloat appendWidth, CGFloat deletedWidth) {
            if (!canAppend) return;
            if (appendDirection == VBViewAppendDirectionLeft) {
                [self scrollClipView:self.contentView toPoint:NSMakePoint(leadingWidth + appendWidth, oldPoint.y)];
            } else {
                [self scrollClipView:self.contentView toPoint:NSMakePoint(leadingWidth - deletedWidth, oldPoint.y)];
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

@implementation VBScrollView(settings)

- (void)deploySettings {
    
    self.isScrolling = NO;
    self.islayouting = NO;
    self.lastScrollPoint = NSZeroPoint;
    self.isInitializing = YES;
    self.lastSize = self.contentView.bounds.size;
    
    self.hasHorizontalScroller = YES;
    self.hasVerticalScroller = YES;
    
    self.horizontalScrollElasticity = NSScrollElasticityNone;
    self.verticalScrollElasticity = NSScrollElasticityNone;
    
    self.horizontalScroller.continuous = NO;
    
}

@end
