//
//  VBBrowserView.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBBrowserView.h"
#import "VBScrollView.h"

@interface VBBrowserView()

@property (readonly) VBScrollView * contentView;

@end

@implementation VBBrowserView

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView delegate:(id<VBBrowserVCDelegate>)delegate {
    [self.contentView prepareWithSourceView:sourceView delegate:delegate];
}

- (void)_initScrollPointWithWidth:(CGFloat)width {
    [self.contentView _initScrollPointWithWidth:width];
}

- (void)checkLayout {
    [self.contentView checkLayout];
}

- (VBScrollView *)contentView {
    return self.subviews.firstObject;
}

@end
