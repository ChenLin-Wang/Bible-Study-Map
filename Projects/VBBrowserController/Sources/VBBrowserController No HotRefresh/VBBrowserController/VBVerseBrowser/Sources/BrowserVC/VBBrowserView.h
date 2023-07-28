//
//  VBBrowserView.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBBrowserVCDelegate.h"
#import "VBViewAppendable.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBBrowserView : NSView

- (void)prepareWithSourceView:(__kindof NSView<VBViewAppendable> *)sourceView delegate:(id<VBBrowserVCDelegate>)delegate;
- (void)_initScrollPointWithWidth:(CGFloat)width;
- (void)checkLayout;

@end

NS_ASSUME_NONNULL_END
