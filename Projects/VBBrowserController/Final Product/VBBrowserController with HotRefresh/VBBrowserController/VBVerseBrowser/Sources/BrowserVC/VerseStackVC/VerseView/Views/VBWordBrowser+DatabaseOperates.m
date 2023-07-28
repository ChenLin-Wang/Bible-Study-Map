//
//  VBWordBrowser+DatabaseOperates.m
//  VerseView
//
//  Created by CL Wang on 4/19/23.
//

#import "VBWordBrowser+DatabaseOperates.h"

NSOperationQueue * DatabaseQueryQueue;

const NSArray<NSString *> * VBCardDataChangeTypeSummaries = @[
    @"Moved",
    @"Resized",
    @"CommentChanged"
];

@interface VBWordBrowser()
@property CDUndoManger * dataUndomanager;
@end

@interface VBWordBrowser(DatabaseAdditions)
- (NSString *)getLocalVersionWithStrongNumber:(NSNumber *)strongNumber;
- (NSArray *)getFieldsFromTable:(NSString *)TableName withFieldsName:(NSArray<NSString*>*)FieldsName;
@end

// 这个分类用于处理数据库操作，本 VerseView 的所有数据都是从这里来的，修改也通过此处
@implementation VBWordBrowser(DatabaseOperates)

- (void)prepareDatabase {
    // 在这里对数据库进行一些参数设置的操作，需要注意的是，此时数据库已经完成了初始化。
    // self.DBOperator 即为数据库指针
//    NSLog(@"Prepare Database: %@", self.DBOperator);
    self.dataUndomanager = [[CDUndoManger alloc] initWithSteps:50];
    if (!DatabaseQueryQueue) DatabaseQueryQueue = [NSOperationQueue new];
}

// 此方法应当从数据库中读取所有的单词，详见 VBWord
- (void)wordsFromDatabaseWithCompleteBlock:(void (^)(NSArray<VBWord *> * words))completeBlock {
    
    [DatabaseQueryQueue addBarrierBlock:^{
        NSArray<CDField *> * fields = [self.DBOperator listFiledsByTableName:@"NetBible_WordsOfVerses"];
        NSString * whereas = [NSString stringWithFormat:@"BPVWNum LIKE \"%li___\"", self.verseRef.verseIndex.integerValue];
        CDSelectRecords * records = [self.DBOperator selectRecordswithFileds:fields fromTable:@"NetBible_WordsOfVerses" whereas:whereas];

        NSMutableArray<VBWord *> * words = [NSMutableArray arrayWithCapacity:records.Records.count];

        for (NSArray * curRecord in records.Records) {
            NSString * curLocalVersion = [self getLocalVersionWithStrongNumber:curRecord[2]];
            VBWord * newWord = [VBWord newWordWithBPVWNumber:curRecord[0] POS:curRecord[3] HebrewWord:curRecord[1] StrongNumber:curRecord[2] KJVUsages:curRecord[5] LocalVersion:curLocalVersion linerPoint:NSMakePoint(((NSNumber *)curRecord[6]).doubleValue, ((NSNumber *)curRecord[7]).doubleValue)];
            [words addObject:newWord];
        }

        completeBlock(words);
        
        // for test
//        completeBlock(@[
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 1) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 2) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 3) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 4) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 5) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 6) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 7) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 8) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 9) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 10) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//          [VBWord newWordWithBPVWNumber:@(self.verseRef.verseIndex.integerValue * 1000 + 11) POS:@"POS" HebrewWord:@"HebrewWord" StrongNumber:@(1235) KJVUsages:@"KJVUsages" LocalVersion:@"LocalVersion" linerPoint:NSMakePoint(0, 0)],
//        ]);
    }];

}

// 此方法应当从数据库中读取所有的注释，详见 VBComment
- (void)commentsFromDatabaseWithCompleteBlock:(void (^)(NSArray<VBComment *> * comments))completeBlock {
    
    [DatabaseQueryQueue addBarrierBlock:^{
        NSArray<CDField *> * fields = [self.DBOperator listFiledsByTableName:@"Bible_Comments"];
        NSString * whereas = [NSString stringWithFormat:@"CommentId LIKE \"%li___%%\"", self.verseRef.verseIndex.integerValue];
        CDSelectRecords * records = [self.DBOperator selectRecordswithFileds:fields fromTable:@"Bible_Comments" whereas:whereas];

        NSMutableArray<VBComment *> * comments = [NSMutableArray arrayWithCapacity:records.Records.count];

        for (NSArray * curRecord in records.Records) {
            NSArray<NSString *> * partsOfCommentId = [curRecord[0] componentsSeparatedByString:@"_"];
            VBComment * newComment = [VBComment newCommentWithBPVNumber:@(partsOfCommentId[0].integerValue) commentId:@(partsOfCommentId[1].integerValue) rtfdString:curRecord[1] size:NSMakeSize(((NSNumber *)curRecord[2]).doubleValue, ((NSNumber *)curRecord[3]).doubleValue) linerPoint:NSMakePoint(((NSNumber *)curRecord[4]).doubleValue, ((NSNumber *)curRecord[5]).doubleValue)];
            [comments addObject:newComment];
        }

        completeBlock(comments);
        
        // for test
//        completeBlock( @[
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//            [VBComment newCommentWithBPVNumber:@(1001001) commentId:@(1235) rtfdString:[NSAttributedString new] size:NSMakeSize(100, 100) linerPoint:NSMakePoint(100, 100)],
//        ]);
    }];
    
}

- (VBComment *)createANewCommentWithLinerPoint:(NSPoint)point size:(NSSize)size {
    NSInteger curTimeStamp = ((NSInteger)(NSDate.now.timeIntervalSince1970 * 1000.0));
    VBComment * newComment = [VBComment newCommentWithBPVNumber:self.verseRef.verseIndex commentId:@(curTimeStamp) rtfdString:[[NSAttributedString alloc] initWithString:@"Comment"] size:size linerPoint:point];
    return newComment;
}

- (void)addCommentToDatabase:(VBComment *)comment {
//    NSLog(@"add comment: %@", comment);
    
    CDRecord * record = [[CDRecord alloc] init];
    
    record.doAction = CDIDU_doInsert;
    record.TableName = @"Bible_Comments";
    record.TableStructure = [self.DBOperator listFiledsByTableName:@"Bible_Comments"];
    record.Values = @[[NSString stringWithFormat:@"%li_%li", comment.BPVNumber.integerValue, comment.commentId.integerValue], comment.rtfdString, @(comment.size.width), @(comment.size.height), @(comment.linerPoint.x), @(comment.linerPoint.y), @(0), @(0)];
    record.DatabaseOperater = self.DBOperator;
    
    CDDatabaseUndoAtomic * undoAtomic = [[CDDatabaseUndoAtomic alloc] initWithUndomanger:self.dataUndomanager];
    [undoAtomic.Records addObject:record];
    
    [self addDoItToUndoManagerWithUndoAtomic:undoAtomic];
}

- (void)deleteCommentsFromDatabase:(NSArray<VBComment *> *)comments {
//    NSLog(@"delete comments: %@", comments);
    
    CDDatabaseUndoAtomic * undoAtomic = [[CDDatabaseUndoAtomic alloc] initWithUndomanger:self.dataUndomanager];
    
    for (VBComment * curComment in comments) {
        CDRecord * record = [[CDRecord alloc] init];
        
        record.doAction = CDIDU_doDelete;
        record.TableName = @"Bible_Comments";
        record.TableStructure = [self getFieldsFromTable:@"Bible_Comments" withFieldsName:@[@"CommentId"]];
        record.Values = @[[NSString stringWithFormat:@"%li_%li", curComment.BPVNumber.integerValue, curComment.commentId.integerValue]];
        
        record.DatabaseOperater = self.DBOperator;
        
        [undoAtomic.Records addObject:record];
    }
    
    [self addDoItToUndoManagerWithUndoAtomic:undoAtomic];
}

- (void)updateCommentAtDatabase:(VBComment *)comment type:(VBCardDataChangeType)type undoAtomic:(CDDatabaseUndoAtomic *)undoAtomic {
//    NSLog(@"comment--%@: %@", VBCardDataChangeTypeSummaries[type], comment);    // <- 请暂时保留此 NSLog，若要禁用，请注释，不要删除
    
    CDRecord * record = [[CDRecord alloc] init];
    
    record.doAction = CDIDU_doUpdate;
    record.TableName = @"Bible_Comments";
    
    switch (type) {
        case VBCardDataChangeTypeMove:
            record.TableStructure = [self getFieldsFromTable:@"Bible_Comments" withFieldsName:@[@"CommentId", @"liner_x", @"liner_y"]];
            record.Values = @[[NSString stringWithFormat:@"%li_%li", comment.BPVNumber.integerValue, comment.commentId.integerValue], @(comment.linerPoint.x), @(comment.linerPoint.y)];
            break;
        case VBCardDataChangeTypeResize:
            record.TableStructure = [self getFieldsFromTable:@"Bible_Comments" withFieldsName:@[@"CommentId", @"width", @"height"]];
            record.Values = @[[NSString stringWithFormat:@"%li_%li", comment.BPVNumber.integerValue, comment.commentId.integerValue], @(comment.size.width), @(comment.size.height)];
            break;
        case VBCardDataChangeTypeCommentChange:
            record.TableStructure = [self getFieldsFromTable:@"Bible_Comments" withFieldsName:@[@"CommentId", @"RTFD_ATS"]];
            record.Values = @[[NSString stringWithFormat:@"%li_%li", comment.BPVNumber.integerValue, comment.commentId.integerValue], comment.rtfdString];
            break;
    }
    
    record.DatabaseOperater = self.DBOperator;
    
    [undoAtomic.Records addObject:record];
    
    [comment modifySaved]; // <- 每次将数据库数据更新完时，请调用此方法
}

- (void)updateWordAtDatabase:(VBWord *)word type:(VBCardDataChangeType)type undoAtomic:(CDDatabaseUndoAtomic *)undoAtomic {
//    NSLog(@"word--%@: %@", VBCardDataChangeTypeSummaries[type], word);          // <- 请暂时保留此 NSLog，若要禁用，请注释，不要删除
    
    CDRecord * record = [[CDRecord alloc] init];
    
    record.doAction = CDIDU_doUpdate;
    record.TableName = @"NetBible_WordsOfVerses";
    record.TableStructure = [self getFieldsFromTable:@"NetBible_WordsOfVerses" withFieldsName:@[@"BPVWNum", @"liner_X", @"liner_Y"]];
    record.Values = @[word.BPVWNumber, @(word.linerPoint.x), @(word.linerPoint.y)];
    record.DatabaseOperater = self.DBOperator;
    
    [undoAtomic.Records addObject:record];
    
    [word modifySaved]; // <- 每次将数据库数据更新完时，请调用此方法
}

- (void)addDoItToUndoManagerWithUndoAtomic:(CDDatabaseUndoAtomic *)undoAtomic {
    [self.dataUndomanager addDoItWithUndo:undoAtomic];
}

@end


// -----------------------------------------------------------------------------------------------------


@implementation VBWordBrowser(DatabaseAdditions)

- (NSString *)getLocalVersionWithStrongNumber:(NSNumber *)strongNumber {
    NSArray *fields = [self getFieldsFromTable:@"StrongNumberWordsTranslate_DY" withFieldsName:@[@"StrongNumber", @"LocalVersion"]];
    NSString *whereas = [NSString stringWithFormat:@"StrongNumber IS \"%@\"", strongNumber];
    CDRecord * record = [self.DBOperator findaRecordwithFileds:fields
                                                           fromTable:@"StrongNumberWordsTranslate_DY"
                                                             whereas:whereas];
    return [record.Values[1] isEqualToString:@"InCDYV:"] ? @"" : record.Values[1];
}

- (NSArray<CDField *> *)getFieldsFromTable:(NSString *)TableName withFieldsName:(NSArray<NSString*>*)FieldsName {
    if (self.DBOperator == nil) return nil;
    NSArray * Fields = [self.DBOperator listFiledsByTableName:TableName];
    NSMutableArray<CDField *> * FieldsWant = [NSMutableArray new];
    
    for (NSString * FieldName in FieldsName)
        for (CDField * F in Fields) {
            if([F.FieldName isEqualTo:FieldName]) {
                F.TableName = TableName;
                [FieldsWant addObject:F];
                break;
            }
        }
    return FieldsWant;
};

@end
