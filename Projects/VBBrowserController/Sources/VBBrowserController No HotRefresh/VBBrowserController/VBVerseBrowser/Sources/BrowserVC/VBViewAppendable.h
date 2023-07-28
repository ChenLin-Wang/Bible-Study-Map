//
//  VBViewAppendable.h
//  VBBrowserController
//
//  Created by CL Wang on 3/14/23.
//

#import <Foundation/Foundation.h>

#ifndef VBViewAppendable_h
#define VBViewAppendable_h

typedef enum: NSInteger {
    VBViewAppendDirectionError          = -1,
    VBViewAppendDirectionNone           = 0,
    VBViewAppendDirectionLeft           = 1,
    VBViewAppendDirectionRight          = 2,
} VBViewAppendDirection;

@protocol VBViewAppendable <NSObject>

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading
                                                trailingSpace:(CGFloat)trailing
                                                  leftLimited:(BOOL)leftLimited
                                                 rightLimited:(BOOL)rightLimited;
- (VBViewAppendDirection)isAtEdgeWithLeadingSpace:(CGFloat)leading windowWidth:(CGFloat)windowWidth;

@end

#endif /* VBViewAppendable_h */
