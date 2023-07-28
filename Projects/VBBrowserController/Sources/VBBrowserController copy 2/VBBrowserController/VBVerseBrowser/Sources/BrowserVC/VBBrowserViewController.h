//
//  VBBrowserViewController.h
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Cocoa/Cocoa.h>
#import "VBBrowserController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBBrowserViewController : NSViewController

@property (readonly) id<VBBrowserDataSource> delegate;

+ (instancetype)makeNew;
- (void)prepareWithDelegate:(id<VBBrowserDataSource>)delegate;
- (void)replaceVerseDatas:(NSArray<VBVerseReference *> *)verseReferences;

@end

NS_ASSUME_NONNULL_END
