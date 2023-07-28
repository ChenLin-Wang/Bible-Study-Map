//
//  VBWordLabelView.m
//  VBBrowserController
//
//  Created by CL Wang on 5/4/23.
//

#import "VBWordLabelView.h"
#import "NSObject+LayoutConstraints.h"

@interface VBWordLabelView()

@property (class, readonly) CGFloat fontSize;

@end

@implementation VBWordLabelView
@synthesize word = word;
@synthesize contentTextView = contentTextView;

+ (CGFloat)fontSize { return 10; }

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self prepare];
    return self;
}

- (void)prepare {
    VBMaskedTextView * textView = [[VBMaskedTextView alloc] initWithFrame:self.bounds];
    textView.backgroundColor = NSColor.clearColor;
    textView.textContainer.lineFragmentPadding = 0;
    textView.editable = false;
    textView.selectable = true;
    textView.richText = true;
    textView.canBeEdit = false;
    
    self->contentTextView = textView;
    
    [self addSubview:textView];
    [self makeEdgeLayoutConstraintsForView:self usingView:textView];
    [textView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = true;
    [textView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = true;
}

- (void)refreshWithWord:(VBWord *)word {
    self->word = word;
    
    NSMutableAttributedString * attributedStr = [NSMutableAttributedString new];
    
    NSMutableParagraphStyle * pStyle = [NSMutableParagraphStyle new];
    pStyle.tabStops = @[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight location:self.contentTextView.textContainer.size.width options:@{}]];
    pStyle.lineSpacing = 3.5;
    
    NSAttributedString * firstLineStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t%@\n", word.BPVWNumber, word.POS] attributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:VBWordLabelView.fontSize],
        NSForegroundColorAttributeName: NSColor.textColor,
        NSParagraphStyleAttributeName: pStyle
    }];
    
    NSAttributedString * secondLineStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t%@\n", word.HebrewWord, word.StrongNumber] attributes:@{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:VBWordLabelView.fontSize],
        NSForegroundColorAttributeName: NSColor.textColor,
        NSParagraphStyleAttributeName: pStyle
    }];
    
    NSAttributedString * thirdLineStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", word.KJVUsages] attributes:@{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:VBWordLabelView.fontSize],
        NSForegroundColorAttributeName: NSColor.secondaryLabelColor,
        NSParagraphStyleAttributeName: pStyle
    }];
    
    NSAttributedString * forthLineStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", word.LocalVersion] attributes:@{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:VBWordLabelView.fontSize],
        NSForegroundColorAttributeName: NSColor.controlAccentColor,
        NSParagraphStyleAttributeName: pStyle
    }];
    
    [attributedStr appendAttributedString:firstLineStr];
    [attributedStr appendAttributedString:secondLineStr];
    [attributedStr appendAttributedString:thirdLineStr];
    [attributedStr appendAttributedString:forthLineStr];
    
    [self.contentTextView.textStorage setAttributedString:attributedStr];
}

@end
