//
//  VBCommentCard.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Cocoa/Cocoa.h>
#import "VBSelectableCard.h"
#import "VBComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBCommentCard : VBSelectableCard

@property (readonly) VBComment * comment;
@property (class, readonly) NSSize defaultSize;
@property (class, readonly) NSSize minSize;

- (instancetype)initWithComment:(VBComment *)comment layoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate;
- (void)changeSize:(NSSize)size;

- (instancetype)initWithLayoutDelegate:(id<VBGraphicPositionDelegate>)layoutDelegate    NS_UNAVAILABLE;
- (void)linkXib                                                                         NS_UNAVAILABLE;
- (void)changeStateColor:(BOOL)isPrimary                                                NS_UNAVAILABLE;
- (void)changeLayoutFrame:(NSRect)newFrame                                              NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
