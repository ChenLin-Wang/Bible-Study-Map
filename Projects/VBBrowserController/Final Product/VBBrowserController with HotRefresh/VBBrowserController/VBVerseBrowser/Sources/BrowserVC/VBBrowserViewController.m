//
//  VBBrowserViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import "VBBrowserViewController.h"
#import "VBVerseStackViewController.h"
#import "NSObject+LayoutConstraints.h"
#import "VBBrowserViewController-Categories.m"
#import "VBBrowserView.h"
#import "VBVerseViewController.h"

@interface VBBrowserViewController () <VBFreezingBarDelegate> {
    __weak id<VBBrowserDataSource> delegate;
}

@property VBVerseStackViewController * verseStackVC;
@property (readonly) VBBrowserView * contentView;

@end

@implementation VBBrowserViewController(additions)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentView prepareWithSourceView:((__kindof NSView<VBViewAppendable> *)self.verseStackVC.view) headerView:((__kindof NSView *)self.verseStackVC.freezingBar) delegate:self];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self.contentView checkLayout];
    [self.verseStackVC checkLayoutWithBrowserWindowWidth:self.view.bounds.size.width];
}

@end

@implementation VBBrowserViewController

+ (instancetype)makeNew {
    VBBrowserViewController * newVC = [NSStoryboard storyboardWithName:NSStringFromClass(VBBrowserViewController.class) bundle:NSBundle.mainBundle].instantiateInitialController;
    newVC.verseStackVC = [VBVerseStackViewController makeNew];
    newVC.verseStackVC.freezingBarDelegate = newVC;
    return newVC;
}

- (void)prepareWithDelegate:(id<VBBrowserDataSource>)delegate {
    self->delegate = delegate;
    [self.verseStackVC prepareWithVerseDataProvider:[self.delegate verseDataProviderWithBrowser:(VBBrowserController *)self]];
}

- (void)replaceVerseDatas:(NSArray<VBVerseReference *> *)verseReferences {
    [self.view layoutSubtreeIfNeeded];
    [self.verseStackVC updateWithVerseRefs:verseReferences browserWindowWidth:self.contentView.bounds.size.width];
    if (self.verseStackVC.firstVerseViewWidth > 0) {
        [self.contentView _initScrollPointWithWidth:self.verseStackVC.firstVerseViewWidth + self.verseStackVC.secondVerseViewWidth];
    }
    [self.contentView checkLayoutUsingWidth:verseReferences.count * VBVerseViewController.minimumWidth];
}

//- (void)verseStackVCShouldCheckLayout:(VBVerseStackViewController *)verseStackVC {
//    [self.contentView checkLayout];
//}

- (__kindof NSView *)contentView { return self.view; }
- (id<VBBrowserDataSource>)delegate { return self->delegate; }

@class VBBrowserController;
- (void)translationDidChangeWithVersion:(NSString *)version newContent:(NSString *)newContent verseRef:(VBVerseReference *)verseRef {
    [self.delegate translationShouldChange:(VBBrowserController *)self verseReference:verseRef bibleVersion:version newTranslationContent:newContent];
}

- (void)translationVersionDidChangeAtVerseRef:(VBVerseReference *)verseRef newVersion:(NSString *)newVersion {
    [self.delegate bibleVersionDidChange:(VBBrowserController *)self verseReference:verseRef newBibleVersion:newVersion];
}

@end

@implementation VBBrowserViewController(browserViewControllerDelegate)

- (void)verseViewShouldAppend:(__kindof NSView *)sender requestType:(VBVerseRequestType)requestType completed:(void(^)(CGFloat appendedWidth, CGFloat deletedWidth))completed {
    if (requestType != VBVerseRequestTypePrevious && requestType != VBVerseRequestTypeNext) return;
    VBVerseReference * curRef = (requestType == VBVerseRequestTypePrevious) ? self.verseStackVC.leftestVerseRef : self.verseStackVC.rightestVerseRef;
    VBVerseReference * __nullable newRef = [self.delegate verseWillAppend:(VBBrowserController *)self currentVerseReference:curRef requestType:requestType];
    if (!newRef) return;
    CGFloat deletedWidth = [self.verseStackVC appendVerseRef:newRef direction:(VBViewAppendDirection)requestType browserWindowWidth:self.contentView.bounds.size.width];
    completed(self.verseStackVC.firstVerseViewWidth, deletedWidth);
}

@end
