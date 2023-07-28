//
//  VBVerseViewController.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBVerseViewController.h"
#import "VBWordBrowser.h"
#import "NSObject+LayoutConstraints.h"

@class CDSQLite3OperaterDelegate;

@interface VBVerseViewController () {
    id<VBVerseViewLayoutDelegate> __weak layoutDelegate;
    id __weak dataProvider;
}

@property (readonly) NSString * versionsString;
@property (readonly) NSString * verseNum;
@property (weak) IBOutlet NSLayoutConstraint * heightSpaceConstraint;

@property VBWordBrowser * wordBrowser;
@property (readonly) CDSQLite3OperaterDelegate * dataOperator;
@property (weak) IBOutlet NSView * contentView;
@property (strong) IBOutlet NSMenu * rightClickMenu;

@end








@interface VBVerseViewController() <VBVerseViewLayoutDelegate>

@end

@implementation VBVerseViewController

+ (VBVerseViewController *)newVerseViewControllerWithDataProvider:(id)dataProvider layoutDelegate:(id<VBVerseViewLayoutDelegate>)layoutDelegate {
    VBVerseViewController * newVC = [NSStoryboard storyboardWithName:@"VBVerseViewController" bundle:NSBundle.mainBundle].instantiateInitialController;
    newVC->dataProvider = dataProvider;
    newVC->layoutDelegate = layoutDelegate;
    return newVC;
}

- (void)viewDidLoad {
    [self embedWordBrowser];
}

- (void)viewShouldPrepare {
    self.wordBrowser = [VBWordBrowser newBrowserWithDBOperator:self.dataOperator layoutDelegate:self];
    [self.layoutDelegate reLayoutWithContentSize:VBWordBrowser.minimumSize verseVC:self];
}

- (void)viewWillAttachToStackView {
    if (![self.verseReference isEqualToVerseRef:self.wordBrowser.verseRef]) [self.wordBrowser refreshWithVerseRef:self.verseReference];
}

- (NSString *)versionsString { return [self.verseReference.versionMarks componentsJoinedByString:@", "]; }
- (NSString *)verseNum { return self.verseReference.verseIndex.stringValue; }
- (id)dataProvider { return self->dataProvider; }
- (CDSQLite3OperaterDelegate *)dataOperator { return self->dataProvider; }
- (id<VBVerseViewLayoutDelegate>)layoutDelegate { return self->layoutDelegate; }

- (void)reLayoutWithContentSize:(NSSize)size verseVC:(id)verseVC {
    [self.layoutDelegate reLayoutWithContentSize:NSMakeSize(size.width, size.height + self.heightSpaceConstraint.constant) verseVC:self];
}

- (void)embedWordBrowser {
    [self.contentView addSubview: self.wordBrowser];
    [self makeEdgeLayoutConstraintsForView:self.contentView usingView:self.wordBrowser];
    self.wordBrowser.rightMenu = self.rightClickMenu;
}

+ (CGFloat)minimumWidth { return VBWordBrowser.minimumSize.width; }

@end
