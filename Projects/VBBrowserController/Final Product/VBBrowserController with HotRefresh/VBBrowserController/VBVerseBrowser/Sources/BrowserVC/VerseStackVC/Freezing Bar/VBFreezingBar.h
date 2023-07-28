//
//  VBFreezingBar.h
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#import <Cocoa/Cocoa.h>
#import "VBVerseReference.h"
#import "VBFreezingBarDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    VBVerseReference * verseRef;
    CGFloat width;
} VBFreezingCellConf;

VBFreezingCellConf VBMakeFreezingCellConf(VBVerseReference * __nullable verseRef, CGFloat width);

@interface VBFreezingBar: NSView

@property (weak) id<VBFreezingBarDelegate> delegate;

+ (VBFreezingBar *)newFreezingBar;

- (void)addCellWithConf:(VBFreezingCellConf)conf;
- (void)insertCellWithIndex:(NSInteger)index conf:(VBFreezingCellConf)conf;
- (void)updateCellWithIndex:(NSInteger)index conf:(VBFreezingCellConf)conf;
- (void)removeFirstCell;
- (void)removeLastCell;
- (void)removeWithIndex:(NSInteger)index;
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
