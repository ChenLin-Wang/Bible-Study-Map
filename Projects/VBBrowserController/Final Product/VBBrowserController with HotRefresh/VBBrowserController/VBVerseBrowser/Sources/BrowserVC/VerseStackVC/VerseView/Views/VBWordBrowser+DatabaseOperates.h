//
//  VBWordBrowser+DatabaseOperates.h
//  VerseView
//
//  Created by CL Wang on 4/19/23.
//

#import "VBWordBrowser.h"
#import "VBWord.h"
#import "VBComment.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    VBCardDataChangeTypeMove                = 0,
    VBCardDataChangeTypeResize              = 1,
    VBCardDataChangeTypeCommentChange       = 2,
} VBCardDataChangeType;

@interface VBWordBrowser(DatabaseOperates)
- (void)prepareDatabase;

- (void)wordsFromDatabaseWithCompleteBlock:(void (^)(NSArray<VBWord *> * words))completeBlock;
- (void)commentsFromDatabaseWithCompleteBlock:(void (^)(NSArray<VBComment *> * comments))completeBlock;

- (VBComment *)createANewCommentWithLinerPoint:(NSPoint)point size:(NSSize)size;
- (void)addCommentToDatabase:(VBComment *)comment;
- (void)deleteCommentsFromDatabase:(NSArray<VBComment *> *)comments;

- (void)updateCommentAtDatabase:(VBComment *)comment type:(VBCardDataChangeType)type undoAtomic:(CDDatabaseUndoAtomic *)undoAtomic;
- (void)updateWordAtDatabase:(VBWord *)word type:(VBCardDataChangeType)type undoAtomic:(CDDatabaseUndoAtomic *)undoAtomic;

- (void)addDoItToUndoManagerWithUndoAtomic:(CDDatabaseUndoAtomic *)undoAtomic;

@end

NS_ASSUME_NONNULL_END
