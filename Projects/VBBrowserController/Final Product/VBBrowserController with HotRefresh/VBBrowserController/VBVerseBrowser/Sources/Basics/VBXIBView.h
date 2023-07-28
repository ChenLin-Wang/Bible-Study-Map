//
//  VBXIBView.h
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VBXIBView : NSView
@property (strong) IBOutlet NSView * contentView;
- (void)linkXib;
@end

NS_ASSUME_NONNULL_END
