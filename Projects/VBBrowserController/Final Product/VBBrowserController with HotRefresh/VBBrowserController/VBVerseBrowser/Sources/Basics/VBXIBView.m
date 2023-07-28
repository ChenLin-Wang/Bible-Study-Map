//
//  VBXIBView.m
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import "VBXIBView.h"
#import "NSObject+LayoutConstraints.h"

@implementation VBXIBView

- (void)linkXib {
    [NSBundle.mainBundle loadNibNamed:self.className owner:self topLevelObjects: nil];
    [self addSubview:self.contentView];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self makeEdgeLayoutConstraintsForView:self usingView:self.contentView];
}

@end
