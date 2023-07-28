//
//  VBWord.h
//  VerseView
//
//  Created by CL Wang on 4/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VBWord : NSObject

@property (readonly) NSNumber * BPVWNumber;
@property (readonly) NSString * POS;
@property (readonly) NSString * HebrewWord;
@property (readonly) NSNumber * StrongNumber;
@property (readonly) NSString * KJVUsages;
@property (readonly) NSString * LocalVersion;
@property NSPoint linerPoint;                       // <- 该程序只可修改 linerPoint，其他字段不可修改

@property (readonly) BOOL isModified;               // <- 此 word 距离上次保存后是否被修改过
@property (readonly) BOOL isLinerPointModified;     // <- 记录 linerPoint 距离上次保存数据后是否被修改过

- (void)modifySaved;                                // <- 调用此方法，表示修改已经被保存了

- (BOOL)isNextWord:(VBWord *)word;                  // <- 检查所传入的 word 是否为此 word 的下一个单词
+ (instancetype)newWordWithBPVWNumber:(NSNumber *)BPVWNumber
                                  POS:(NSString *)POS
                           HebrewWord:(NSString *)HebrewWord
                         StrongNumber:(NSNumber *)StrongNumber
                            KJVUsages:(NSString *)KJVUsages
                         LocalVersion:(NSString *)LocalVersion
                           linerPoint:(NSPoint)linerPoint;

@end

NS_ASSUME_NONNULL_END
