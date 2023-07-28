//
//  VBWordCard.m
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import "VBWordCard.h"

@interface VBWordCard()
@property (weak) IBOutlet NSLayoutConstraint * widthConstraint;
@property (weak) IBOutlet NSLayoutConstraint * heightConstraint;
@end

@implementation VBWordCard
@synthesize word = word;

- (BOOL)isOneStateCard { return false; }

- (instancetype)initWithWord:(VBWord *)word layoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate {
    self = [super initWithLayoutDelegate:layoutDelegate];
    self->word = word;
    [self linkXib];
    [self changeStateColor:(word.LocalVersion != nil && ![word.LocalVersion isEqualToString:@""])];
    return self;
}

+ (NSSize)fixedSize { return NSMakeSize(180, 74); }

- (NSRect)layoutFrame {
    NSRect frame = [super layoutFrame];
    return NSMakeRect(frame.origin.x, frame.origin.y, VBWordCard.fixedSize.width, VBWordCard.fixedSize.height);
}

- (void)awakeFromNib {
    self.widthConstraint.constant = VBWordCard.fixedSize.width;
    self.heightConstraint.constant = VBWordCard.fixedSize.height;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<VBWordCard with %@>", self.word.description];
}

@end
