//
//  VBVerseViewController.m
//  VBBrowserController
//
//  Created by CL Wang on 3/13/23.
//

#import <Foundation/Foundation.h>
#import "VBVerseViewController.h"

@interface VBVerseViewController() {
    id<VBVerseViewLayoutDelegate> __weak layoutDelegate;
    id __weak dataProvider;
}

@property (readonly) NSString * versionsString;
@property (readonly) NSString * verseNum;
@property NSString * width;
@property NSString * height;

@end

@implementation VBVerseViewController

+ (VBVerseViewController *)newVerseViewControllerWithDataProvider:(id)dataProvider layoutDelegate:(id<VBVerseViewLayoutDelegate>)layoutDelegate {
    VBVerseViewController * newVC = [NSStoryboard storyboardWithName:@"VBTestVerseViewController" bundle:NSBundle.mainBundle].instantiateInitialController;
    newVC->dataProvider = dataProvider;
    newVC->layoutDelegate = layoutDelegate;
    return newVC;
}

- (void)viewShouldPrepare {
    [self changeSize:nil];
//    [self.layoutDelegate reLayoutWithContentSize:NSMakeSize(560, 500) verseVC:self];
    
}

- (void)viewWillAttachToStackView {}

- (NSString *)versionsString {
    return [self.verseReference.versionMarks componentsJoinedByString:@", "];
}

- (NSString *)verseNum {
    return self.verseReference.verseIndex.stringValue;
}

- (id)dataProvider {
    return self->dataProvider;
}

- (id<VBVerseViewLayoutDelegate>)layoutDelegate {
    return self->layoutDelegate;
}

- (IBAction)changeSize:(NSButton *)sender {
    NSSize randomSize = NSMakeSize(random() % 700, random() % 700);
    [self.layoutDelegate reLayoutWithContentSize:randomSize verseVC:self];
    
    self.width = [NSString stringWithFormat:@"%0.f", randomSize.width];
    self.height = [NSString stringWithFormat:@"%0.f", randomSize.height];
}


@end
