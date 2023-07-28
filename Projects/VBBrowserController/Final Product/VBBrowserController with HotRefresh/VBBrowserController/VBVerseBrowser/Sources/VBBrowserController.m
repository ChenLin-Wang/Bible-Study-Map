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
    // 首先判断 verseReferences 的连续性
    VBVerseRefCompareResult result = -1;
    BOOL throwException = NO;
    
    for(NSInteger i = 0; i < (verseReferences.count - 1); i++) {
        
        VBVerseReference * curVerseRef = verseReferences[i];
        VBVerseReference * nextVerseRef = verseReferences[i + 1];
        
        VBVerseRefCompareResult curCompareResult = [curVerseRef isContinuouslyCompareWith:nextVerseRef];
        
        if (curCompareResult == VBVerseRefCompareResultNotContinuously) { throwException = YES; break; }
        
        if (result == -1) result = curCompareResult;
        else { if (curCompareResult != result) { throwException = YES; break; } }
    }
    
    if (throwException) @throw [[NSException alloc] initWithName:@"VerseReferences 不连续!" reason:@"传入的 verseReferences 数组中的 verses 不连续!" userInfo:NULL];
    
    // verseReferences 是连续的，进行显示
    [self.contentVC replaceVerseDatas:verseReferences];
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
    
    // 判断连续性
    if ([curVerseReference isContinuouslyCompareWith:newVerseReference] != ((requestType == VBVerseRequestTypePrevious) ? VBVerseRefCompareResultDescending : VBVerseRefCompareResultAscending))
        @throw [[NSException alloc] initWithName:@"VerseReference 不连续!" reason:@"从 -verseWillAppend:currentVerseReference:requestType: 协议方法取得的 verseRef 不连续!" userInfo:NULL];
    
    return newVerseReference;
}

- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser {
    return [self.dataSource verseDataProviderWithBrowser:self];
}

- (void)translationShouldChange:(nonnull VBBrowserController *)browser verseReference:(nonnull VBVerseReference *)verseReference bibleVersion:(nonnull NSString *)bibleVersion newTranslationContent:(nonnull NSString *)newTranslationContent {
    [self.dataSource translationShouldChange:self verseReference:verseReference bibleVersion:bibleVersion newTranslationContent:newTranslationContent];
}

- (void)bibleVersionDidChange:(VBBrowserController *)browser verseReference:(VBVerseReference *)verseReference newBibleVersion:(NSString *)newBibleVersion {
    [self.dataSource bibleVersionDidChange:self verseReference:verseReference newBibleVersion:newBibleVersion];
}


@end

@implementation VBBrowserController(addition)

// 在这个方法中创建各种 View 和 VC
- (void)loadGUIs {
    self.contentVC = [VBBrowserViewController makeNew];
    [self.contentVC prepareWithDelegate:self];
}

@end
