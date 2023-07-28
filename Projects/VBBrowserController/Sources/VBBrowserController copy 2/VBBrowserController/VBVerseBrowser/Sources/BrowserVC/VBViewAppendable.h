//
//  VBViewAppendable.h
//  VBBrowserController
//
//  Created by CL Wang on 3/14/23.
//

#import <Foundation/Foundation.h>

#ifndef VBViewAppendable_h
#define VBViewAppendable_h

typedef enum {
    VBViewAppendDirectionNone           = 0,
    VBViewAppendDirectionLeft           = 1,
    VBViewAppendDirectionRight          = 2,
} VBViewAppendDirection;

@protocol VBViewAppendable <NSObject>

- (VBViewAppendDirection)checkAppendDirectionWithLeadingSpace:(CGFloat)leading trailingSpace:(CGFloat)trailing;
- (VBViewAppendDirection)isAtEdgeWithLeadingSpace:(CGFloat)leading windowWidth:(CGFloat)windowWidth;

@end

#endif /* VBViewAppendable_h */
