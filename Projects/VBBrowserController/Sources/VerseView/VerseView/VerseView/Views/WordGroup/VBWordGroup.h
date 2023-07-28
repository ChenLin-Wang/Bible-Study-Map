//
//  VBWordGroup.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Foundation/Foundation.h>
#import "VBWordCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBWordGroup : NSObject

@property (readonly) NSArray<VBWordCard *> * wordCards;
@property (readonly) NSRect contentRect;
@property (readonly) BOOL isEmpty;

- (instancetype)initRefGroupWithWordCard:(VBWordCard *)wordCard initPoint:(NSPoint)point;
- (void)appendWordCard:(VBWordCard *)wordCard;
- (void)removeWordCardWithMode:(BOOL)isRemoveHead;
- (void)removeAll;
- (void)changeOrigin:(NSPoint)origin;

@end


@interface VBWordCard(GroupExtension)

@property (weak, nullable) VBWordGroup * belongedGroup;

@end


NS_ASSUME_NONNULL_END
