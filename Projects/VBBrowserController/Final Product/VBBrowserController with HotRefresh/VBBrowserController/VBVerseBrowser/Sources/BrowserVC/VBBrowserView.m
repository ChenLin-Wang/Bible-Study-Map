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

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView headerView:(__kindof NSView *)headerView delegate:(id<VBBrowserVCDelegate>)delegate {
    [self.contentView prepareWithSourceView:sourceView headerView:headerView delegate:delegate];
}

- (void)_initScrollPointWithWidth:(CGFloat)width {
    [self.contentView _initScrollPointWithWidth:width];
}

- (void)checkLayout {
    [self.contentView checkLayout];
}

- (void)checkLayoutUsingWidth:(CGFloat)width {
    [self.contentView checkLayoutUsingWidth:width];
}

- (VBScrollView *)contentView {
    return self.subviews.firstObject;
}

@end
