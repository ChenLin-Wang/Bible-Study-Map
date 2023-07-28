//
//  VBWordLabelView.h
//  VBBrowserController
//
//  Created by CL Wang on 5/4/23.
//

#import "VBMaskedTextView.h"
#import "VBWord.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBWordLabelView : NSView

@property (readonly, weak) VBWord * word;
@property (readonly, weak) VBMaskedTextView * contentTextView;

- (void)refreshWithWord:(VBWord *)word;

@end

NS_ASSUME_NONNULL_END
