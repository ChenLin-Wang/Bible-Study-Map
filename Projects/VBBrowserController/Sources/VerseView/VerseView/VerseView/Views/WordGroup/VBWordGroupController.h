//
//  VBWordGroupController.h
//  VerseView
//
//  Created by CL Wang on 4/6/23.
//

#import <Foundation/Foundation.h>
#import "VBWordGroup.h"

#define VB_SPACING_OVERAGE 10

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    BOOL isCombined;
    NSArray<__kindof VBSelectableCard *> * effectedCards;
} VBCardsMoveResult;

@interface VBWordGroupController : NSObject

@property (readonly) NSArray<VBWordGroup *> * groups;
@property (readonly) NSArray<VBWordCard *> * allcards;

- (void)remakeWithWords:(NSArray<VBWord *> *)words cardDelegate:(id<VBGraphicPositionDelegate>)cardDelegate;
- (VBCardsMoveResult)wordCardsDidMove:(NSArray<VBWordCard *> *)cards offset:(NSSize)offset;
- (NSArray<VBWordCard *> *)selectedCardsAtMultiSelectionRect:(NSRect)rect;
- (void)clearAllGroups;
- (BOOL)recorrectFrames; // <- 检查是否有负坐标，并纠正

@end

NS_ASSUME_NONNULL_END
