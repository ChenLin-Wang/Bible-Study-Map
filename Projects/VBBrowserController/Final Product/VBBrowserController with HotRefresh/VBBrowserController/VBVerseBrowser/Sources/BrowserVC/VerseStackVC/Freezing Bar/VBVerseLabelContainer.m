//
//  VBVerseLabel.m
//  VBBrowserController
//
//  Created by CL Wang on 5/4/23.
//

#import "VBVerseLabelContainer.h"
#import "NSObject+LayoutConstraints.h"

@interface VBVerseLabelContainer()
@property (readonly) NSTextField * verseLabel;
@end

@implementation VBVerseLabelContainer
@synthesize curIndex = curIndex;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self prepare];
    return self;
}

- (void)prepare {
    self.verseLabel.selectable = true;
}

- (NSTextField *)verseLabel { return self.subviews[1]; }

- (void)refreshVersionWithIndex:(NSInteger)index {
    if (index >= self.bibleVersions.count || index < 0) { NSBeep(); return; }
    self->curIndex = index;
    self.verseLabel.stringValue = self.bibleVersions[index];
}

- (BOOL)canGoNext { return self.curIndex < (self.bibleVersions.count - 1); }
- (BOOL)canGoPrevious { return self.curIndex > 0; }

- (void)goNext {
    [self refreshVersionWithIndex:self.curIndex + 1];
}

- (void)goPrevious {
    [self refreshVersionWithIndex:self.curIndex - 1];
}

- (NSString *)curVersion { return self.bibleVersions[self.curIndex]; }

@end
