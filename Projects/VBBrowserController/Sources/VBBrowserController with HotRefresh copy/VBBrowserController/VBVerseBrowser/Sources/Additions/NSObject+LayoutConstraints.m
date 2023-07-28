//
//  NSObject+LayoutConstraints.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "NSObject+LayoutConstraints.h"

@implementation NSObject(LayoutConstraints)

- (void)makeEdgeLayoutConstraintsForView:(__kindof NSView *)view usingView:(__kindof NSView *)sourceView {
    
    sourceView.translatesAutoresizingMaskIntoConstraints = false;
    [sourceView.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [sourceView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    [sourceView.rightAnchor constraintEqualToAnchor:view.rightAnchor].active = YES;
    [sourceView.leftAnchor constraintEqualToAnchor:view.leftAnchor].active = YES;
    
}

@end
