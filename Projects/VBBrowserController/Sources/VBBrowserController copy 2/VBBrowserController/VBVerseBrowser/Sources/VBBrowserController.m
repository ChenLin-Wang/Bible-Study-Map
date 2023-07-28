//
//  VBBrowserController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Foundation/Foundation.h>
#import "VBBrowserController.h"
#import "VBBrowserViewController.h"
#import "VBBrowserController-Categories.m"

@interface VBBrowserController() <VBBrowserDataSource> {
    id<VBBrowserDataSource> __weak dataSource;
}

@property VBBrowserViewController * contentVC;
@property (readonly) __kindof NSView * contentView;

@end

@implementation VBBrowserController

+ (VBBrowserController *)newBrowserWithDataSource:(id<VBBrowserDataSource>)dataSource {
    VBBrowserController * vc = [VBBrowserController new];
    vc->dataSource = dataSource;
    [vc loadGUIs];
    return vc;
}

- (void)showBrowserInView:(__kindof NSView *)view {
    [self loadGUIs];
    self.contentVC.view.frame = view.bounds;
    self.contentVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [view addSubview:self.contentVC.view];
}

- (void)replaceVerseDatas:(NSArray<VBVerseReference *> *)verseReferences {
    
    NSArray * verses = verseReferences;
    
    if (!verseReferences) verses = @[];
    
    // verseReferences 是连续的，进行显示
    [self.contentVC replaceVerseDatas:verses];
}

- (id<VBBrowserDataSource>)dataSource {
    return self->dataSource;
}

- (__kindof NSView *)contentView {
    return self.contentVC.view;
}

- (VBVerseReference *)verseWillAppend:(VBBrowserController *)browser currentVerseReference:(VBVerseReference *)curVerseReference requestType:(VBVerseRequestType)requestType {
    VBVerseReference * __nullable newVerseReference = [self.dataSource verseWillAppend:self currentVerseReference:curVerseReference requestType:requestType];
    
    if (!newVerseReference) return NULL;
  
    return newVerseReference;
}

- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser {
    return [self.dataSource verseDataProviderWithBrowser:self];
}


@end

@implementation VBBrowserController(addition)

// 在这个方法中创建各种 View 和 VC
- (void)loadGUIs {
    self.contentVC = [VBBrowserViewController makeNew];
    [self.contentVC prepareWithDelegate:self];
}

@end
