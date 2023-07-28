//
//  VBCommentCard.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBCommentCard.h"
#import "VBViewMask.h"
#import "VBMaskedTextView.h"

@interface VBCommentCard() <NSTextViewDelegate>

@property (weak) IBOutlet NSLayoutConstraint * widthConstraint;
@property (weak) IBOutlet NSLayoutConstraint * heightConstraint;

@property (weak) IBOutlet NSScrollView * contentScrollView;
@property (weak) IBOutlet VBMaskedTextView * contentTextView;

@property (weak) IBOutlet VBViewMask * viewMask;

@end

@implementation VBCommentCard
@synthesize comment = comment;

- (BOOL)isOneStateCard { return true; }
+ (NSSize)defaultSize { return  NSMakeSize(300, 120); }
+ (NSSize)minSize { return NSMakeSize(100, 40); }

- (instancetype)initWithComment:(VBComment *)comment layoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate {
    self = [super initWithLayoutDelegate:layoutDelegate];
    self->comment = comment;
    [self linkXib];
    self.viewMask.containerView = self;
    self.viewMask.maskedViews = @[self.contentScrollView.documentView];
    self.contentTextView.canBeEdit = true;
    return self;
}

- (void)changeOrigin:(NSPoint)newOrigin {
    [super changeOrigin:newOrigin];
    self.comment.linerPoint = newOrigin;
}

- (void)changeFrame:(NSRect)newFrame {
    [self changeOrigin:newFrame.origin];
    [self changeSize:newFrame.size];
}

- (void)changeSize:(NSSize)size {
    
    CGFloat width = (size.width > VBCommentCard.minSize.width) ? size.width : VBCommentCard.minSize.width;
    CGFloat height = (size.height > VBCommentCard.minSize.height) ? size.height : VBCommentCard.minSize.height;
    
    self.comment.size = NSMakeSize(width, height);
    
    self.widthConstraint.constant = width;
    self.heightConstraint.constant = height;
    
    [self changeLayoutFrame:NSMakeRect(self.layoutFrame.origin.x, self.layoutFrame.origin.y, width, height)];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0;
        [self layoutSubtreeIfNeeded];
    }];

}

- (void)awakeFromNib {
    if (self.comment.size.height == 0 || self.comment.size.width == 0) [self changeSize:VBCommentCard.defaultSize];
    [self.contentTextView.textStorage setAttributedString:self.comment.rtfdString];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<VBCommentCard with %@>", self.comment.description];
}

- (void)textViewDidChangeTypingAttributes:(NSNotification *)notification {
    self.comment.rtfdString = self.contentTextView.attributedString;
}

@end
