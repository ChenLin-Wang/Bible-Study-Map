//
//  VBWordCard.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Cocoa/Cocoa.h>
#import "VBSelectableCard.h"
#import "VBWord.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBWordCard: VBSelectableCard

@property (readonly, class) NSSize fixedSize;
@property (readonly) VBWord * word;

- (instancetype)initWithWord:(VBWord *)word layoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate;

- (instancetype)initWithLayoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate    NS_UNAVAILABLE;
- (void)linkXib                                                                         NS_UNAVAILABLE;
- (void)changeStateColor:(BOOL)isPrimary                                                NS_UNAVAILABLE;
- (void)changeLayoutFrame:(NSRect)newFrame                                              NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
