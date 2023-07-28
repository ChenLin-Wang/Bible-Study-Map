//
//  VBComment.h
//  VerseView
//
//  Created by CL Wang on 4/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VBComment : NSObject

@property (readonly) NSNumber * BPVNumber;
@property (readonly) NSNumber * commentId;
@property NSAttributedString * rtfdString;      /* |\                                                           */
@property NSSize size;                          /* |- 该程序只可修改 rtfdString, size, linerPoint，其他字段不可修改     */
@property NSPoint linerPoint;                   /* |/                                                           */

@property (readonly) BOOL isModified;           // <- 此 comment 距离上次保存后是否被修改过
@property (readonly) BOOL isSizeModified;       // <- 记录 size 距离上次保存数据后是否被修改过
@property (readonly) BOOL isLinerPointModified; // <- 记录 linerPoint 距离上次保存数据后是否被修改过

- (void)modifySaved;                            // <- 调用此方法，表示修改已经被保存了

+ (instancetype)newCommentWithBPVNumber:(NSNumber *) BPVNumber
                              commentId:(NSNumber *) commentId
                             rtfdString:(NSAttributedString *) rtfdString
                                   size:(NSSize) size
                             linerPoint:(NSPoint) linerPoint;

@end

NS_ASSUME_NONNULL_END
