//
//  VBFreezingCell.m
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import "VBFreezingCell.h"
#import "VBVerseLabelContainer.h"

NSString * const BibleVersionKey = @"BibleVersionKey";
NSString * const TranslationContentKey = @"TranslationContentKey";
NSString * const VerseReferenceKey = @"VerseReferenceKey";

@interface VBFreezingCell()
@property (weak) IBOutlet NSTextField * label;
@property (weak) IBOutlet VBVerseLabelContainer * verseLabelContainer;
@end

@implementation VBFreezingCell

+ (VBFreezingCell *)newFreezingCellWithVerseRef:(VBVerseReference *)verseRef {
    VBFreezingCell * newCell = [VBFreezingCell new];
    newCell.verseRef = verseRef;
    [newCell linkXib];
    return newCell;
}

- (void)awakeFromNib {
    self.label.stringValue = [NSString stringWithFormat:@"%@", self.verseRef.verseIndex];
    self.verseLabelContainer.bibleVersions = self.verseRef.versionMarks;
    [self.verseLabelContainer refreshVersionWithIndex:0];
}

- (void)changeWidth:(CGFloat)width {
    self.widthConstraint.constant = width;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0;
        [self layoutSubtreeIfNeeded];
    }];
}

- (IBAction)translationDidChange:(NSTextField *)sender {
    [NSApp sendAction:self.translationChangeAction to:self.target from:@{
        BibleVersionKey: self.verseLabelContainer.curVersion,
        TranslationContentKey: sender.stringValue,
        VerseReferenceKey: self.verseRef
    }];
}

- (IBAction)goPreviousButtonDidClick:(NSButton *)sender {
    if (![self.verseLabelContainer canGoPrevious]) { NSBeep(); return; }
    [self.verseLabelContainer goPrevious];
    [NSApp sendAction:self.translationVersionChangeAction to:self.target from:@{
        VerseReferenceKey: self.verseRef,
        BibleVersionKey: self.verseLabelContainer.curVersion
    }];
}

- (IBAction)goNextButtonDidClick:(NSButton *)sender {
    if (![self.verseLabelContainer canGoNext]) { NSBeep(); return; }
    [self.verseLabelContainer goNext];
    [NSApp sendAction:self.translationVersionChangeAction to:self.target from:@{
        VerseReferenceKey: self.verseRef,
        BibleVersionKey: self.verseLabelContainer.curVersion
    }];
}

@end
