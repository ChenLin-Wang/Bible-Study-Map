//
//  NSObject+LayoutConstraints.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject(LayoutConstraints)

- (void)makeEdgeLayoutConstraintsForView:(__kindof NSView *)view usingView:(__kindof NSView *)sourceView;

@end

NS_ASSUME_NONNULL_END
