//
//  VBFreezingBar.m
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import "VBFreezingBar.h"
#import "VBFreezingCell.h"
#import "NSObject+LayoutConstraints.h"

@interface VBFreezingBar()
@property NSStackView * contentStackView;
@property NSBox * backgroundBox;
@end

@implementation VBFreezingBar

+ (VBFreezingBar *)newFreezingBar {
    VBFreezingBar * newFreezingBar = [VBFreezingBar new];
    [newFreezingBar makeBackground];
    [newFreezingBar configeStackView];
    return newFreezingBar;
}

- (void)makeBackground {
    self.backgroundBox = [NSBox new];
    self.backgroundBox.boxType = NSBoxCustom;
    self.backgroundBox.fillColor = NSColor.textBackgroundColor;
    self.backgroundBox.borderWidth = 0;
    
    self.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.backgroundBox];
    [self makeEdgeLayoutConstraintsForView:self usingView:self.backgroundBox];
}

- (void)configeStackView {
    self.contentStackView = [NSStackView new];
    self.contentStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.contentStackView.spacing = 0;
    
    self.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.contentStackView];
    [self makeEdgeLayoutConstraintsForView:self usingView:self.contentStackView];
}






- (void)addCellWithConf:(VBFreezingCellConf)conf {
    VBFreezingCell * newCell = [self newFreezingCellWithConf:conf];
    [self.contentStackView addView:newCell inGravity:NSStackViewGravityLeading];
}

- (void)insertCellWithIndex:(NSInteger)index conf:(VBFreezingCellConf)conf {
    VBFreezingCell * newCell = [self newFreezingCellWithConf:conf];
    [self.contentStackView insertView:newCell atIndex:index inGravity:NSStackViewGravityLeading];
}

- (void)updateCellWithIndex:(NSInteger)index conf:(VBFreezingCellConf)conf {
    [self updateCell:self.contentStackView.arrangedSubviews[index] usingConf:conf];
}

- (void)removeFirstCell {
    [self.contentStackView removeView:self.contentStackView.arrangedSubviews.firstObject];
}

- (void)removeLastCell {
    [self.contentStackView removeView:self.contentStackView.arrangedSubviews.lastObject];
}

- (void)removeWithIndex:(NSInteger)index {
    [self.contentStackView removeView:self.contentStackView.arrangedSubviews[index]];
}

- (void)removeAll {
    for (NSInteger i = self.contentStackView.arrangedSubviews.count - 1; i >= 0; i--) {
        [self removeFirstCell];
    }
}




- (VBFreezingCell *)newFreezingCellWithConf:(VBFreezingCellConf)conf {
    VBFreezingCell * newCell = [VBFreezingCell newFreezingCellWithVerseRef:conf.verseRef];
    newCell.target = self;
    newCell.translationChangeAction = @selector(translationDidChange:);
    newCell.translationVersionChangeAction = @selector(translationVersionDidChange:);
    [newCell changeWidth:conf.width];
    return newCell;
}

- (void)updateCell:(VBFreezingCell *)cell usingConf:(VBFreezingCellConf)conf {
    cell.verseRef = conf.verseRef;
    [cell changeWidth:conf.width];
}

- (void)translationDidChange:(NSDictionary *)data {
    [self.delegate translationDidChangeWithVersion:data[BibleVersionKey] newContent:data[TranslationContentKey] verseRef:data[VerseReferenceKey]];
}

- (void)translationVersionDidChange:(NSDictionary *)data {
    [self.delegate translationVersionDidChangeAtVerseRef:data[VerseReferenceKey] newVersion:data[BibleVersionKey]];
}

@end

VBFreezingCellConf VBMakeFreezingCellConf(VBVerseReference * verseRef, CGFloat width) {
    VBFreezingCellConf conf;
    conf.verseRef = verseRef;
    conf.width = width;
    return conf;
}
