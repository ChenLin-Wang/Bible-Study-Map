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

@end


@implementation VBScrollView

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView delegate:(id<VBBrowserVCDelegate>)delegate {
    self.delegate = delegate;
    [self deploySettings];
}

- (void)_initScrollPointWithWidth:(CGFloat)width {
    [self scrollClipView:self.contentView toPoint:NSMakePoint(width, 0)];
}

- (void)checkLayout {}

- (NSView<VBViewAppendable> *)sourceView {
    return self.documentView;
}

@end

@implementation VBScrollView(appendEventMonitor)

//- (void)scrollClipView:(NSClipView *)clipView toPoint:(NSPoint)point {
//
//    if (self.needsLayout) return;
//
//    while(YES) {
//        NSPoint newPoint = point;
//        [super scrollClipView:clipView toPoint:newPoint];
////        if (shouldCheck) {
//            [self checkVerseAppendEvent:self.curScrollingX];
////        }
//
//        break;
//    }
//}

- (void)checkVerseAppendEvent:(CGFloat)leadingWidth {
    
    CGFloat trailingWidth = (self.documentView.bounds.size.width - self.contentView.bounds.size.width) - leadingWidth;
    
    BOOL canBeAppendInRight = [self.delegate verseCanBeAppendInDirection:VBVerseRequestTypeNext sender:self];
    BOOL canBeAppendInLeft = [self.delegate verseCanBeAppendInDirection:VBVerseRequestTypePrevious sender:self];
    
    VBViewAppendDirection appendDirection = [self.sourceView checkAppendDirectionWithLeadingSpace:leadingWidth
                                                                                    trailingSpace:trailingWidth
                                                                                      leftLimited:!canBeAppendInLeft
                                                                                     rightLimited:!canBeAppendInRight];

    if (appendDirection == VBViewAppendDirectionError) return;
    
//    NSLog(@"Leading: %f, Trailing: %f, %ld", leadingWidth, trailingWidth, appendDirection);
    
    if (appendDirection == VBViewAppendDirectionNone) return;
    
    NSPoint oldPoint = self.curScrollingPoint;
    [self.delegate verseViewShouldAppend:self requestType:(appendDirection == VBViewAppendDirectionLeft) ? VBVerseRequestTypePrevious : VBVerseRequestTypeNext completed:^(CGFloat appendWidth, CGFloat deletedWidth) {
        if (appendDirection == VBViewAppendDirectionLeft) {
//                NSLog(@"LeadingWidth: %f, NewPoint X: %f, AppendWidth: %f, %ld", leadingWidth, leadingWidth + appendWidth, appendWidth, appendDirection);
            [super scrollClipView:self.contentView toPoint:NSMakePoint(leadingWidth + appendWidth, oldPoint.y)];
        } else {
//                NSLog(@"LeadingWidth: %f, NewPoint X: %f, DeletedWidth: %f, %ld", leadingWidth, leadingWidth - deletedWidth, deletedWidth, appendDirection);
            [super scrollClipView:self.contentView toPoint:NSMakePoint(leadingWidth - deletedWidth, oldPoint.y)];
        }
    }];
    
}

@end


@implementation VBScrollView(layout)

- (NSPoint)curScrollingPoint {
    return NSMakePoint(self.curScrollingX, self.curScrollingY);
}

- (CGFloat)curScrollingX {
    return self.contentView.bounds.origin.x;
}

- (CGFloat)curScrollingY {
    return self.contentView.bounds.origin.y;
}

@end

@implementation VBScrollView(settings)

- (void)deploySettings {
    
    self.lastScrollPoint = NSZeroPoint;
    self.isInitializing = YES;
    self.lastSize = self.contentView.bounds.size;
    
    self.hasHorizontalScroller = YES;
    self.hasVerticalScroller = YES;
    
    self.horizontalScrollElasticity = NSScrollElasticityNone;
    self.verticalScrollElasticity = NSScrollElasticityNone;
    
    self.scrollerInsets = NSEdgeInsetsMake(0, 0, 0, 0);
    
}

@end
