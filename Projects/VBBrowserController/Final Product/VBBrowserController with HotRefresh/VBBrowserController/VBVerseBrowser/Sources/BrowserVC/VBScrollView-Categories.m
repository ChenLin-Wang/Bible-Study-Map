//
//  VBScrollView-Categories.m
//  VBBrowserController
//
//  Created by CL Wang on 3/14/23.
//

#import <Foundation/Foundation.h>
#import "VBScrollView.h"

@interface VBScrollView(settings)

- (void)loadDocumentWithView:(__kindof NSView *)documentView headerView:(NSTableHeaderView *)headerView;
- (void)deploySettings;

@end

@interface VBScrollView(appendEventMonitor)

- (void)checkVerseAppendEvent:(CGFloat)leadingWidth;

@end

@interface VBScrollView(layout)

- (NSPoint)curScrollingPoint;
- (CGFloat)curScrollingX;
- (CGFloat)curScrollingY;

@end
