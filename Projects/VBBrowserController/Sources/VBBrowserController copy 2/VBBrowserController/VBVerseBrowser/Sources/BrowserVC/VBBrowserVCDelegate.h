//
//  VBBrowserVCDelegate.h
//  VBBrowserController
//
//  Created by CL Wang on 3/14/23.
//

#import "VBBrowserController.h"

#ifndef VBBrowserVCDelegate_h
#define VBBrowserVCDelegate_h

@protocol VBBrowserVCDelegate <NSObject>

- (void)verseViewShouldAppend:(__kindof NSView *)sender requestType:(VBVerseRequestType)requestType completed:(void(^)(BOOL canAppend, CGFloat appendedWidth, CGFloat deletedWidth))completed;

@end

#endif /* VBBrowserVCDelegate_h */
