//
//  VBFreezingCell.h
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import <Cocoa/Cocoa.h>
#import "VBXIBView.h"
#import "VBVerseReference.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BibleVersionKey;
extern NSString * const TranslationContentKey;
extern NSString * const VerseReferenceKey;

@interface VBFreezingCell : VBXIBView

@property (weak) VBVerseReference * verseRef;
@property (weak) IBOutlet NSLayoutConstraint * widthConstraint;

@property (weak) id target;
@property SEL translationChangeAction;
@property SEL translationVersionChangeAction;

+ (VBFreezingCell *)newFreezingCellWithVerseRef:(VBVerseReference *)verseRef;

- (void)changeWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
