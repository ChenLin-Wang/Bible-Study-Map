//
//  VBScrollView.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBBrowserVCDelegate.h"
#import "VBViewAppendable.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBScrollView : NSScrollView

- (void)prepareWithSourceView:(__kindof NSView *)sourceView headerView:(__kindof NSView *)headerView delegate:(id<VBBrowserVCDelegate>)delegate;
- (void)_initScrollPointWithWidth:(CGFloat)width;
- (void)checkLayout;
- (void)checkLayoutUsingWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
