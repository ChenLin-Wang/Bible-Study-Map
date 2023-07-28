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

- (BOOL)verseCanBeAppendInDirection:(VBVerseRequestType)direction sender:(__kindof NSView *)sender;

- (void)verseViewShouldAppend:(__kindof NSView *)sender requestType:(VBVerseRequestType)requestType completed:(void(^)(CGFloat appendedWidth, CGFloat deletedWidth))completed;

@end

#endif /* VBBrowserVCDelegate_h */
