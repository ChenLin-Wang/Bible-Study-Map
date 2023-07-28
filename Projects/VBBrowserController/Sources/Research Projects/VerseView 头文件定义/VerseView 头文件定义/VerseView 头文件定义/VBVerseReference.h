//
//  VBVerseData.h
//  VBVerseReference 头文件定义
//
//  Created by CL Wang on 3/3/23.
//

#ifndef VBVerseData_h
#define VBVerseData_h

/**
 * @class VBVerseReference
 * @brief 用来标志一节经文的索引以及此经文的版本号
 * @discussion 这个数据包只包括了经文的索引，并不包括具体的经文内容
 * 具体的内容均交由 VBVerseViewController 与数据源交互，
 * VBBrowserController 模块不与经文的内容交互
 */
@interface VBVerseReference : NSObject

/** 圣经版本号，可能有多个版本 */
@property(readonly) NSArray<NSString *> * versionMarks;

/** 经文的索引 */
@property(readonly) NSNumber * verseIndex;

- (VBVerseReference *)initWithVersionMarks:(NSArray<NSString *> *)versionMarks verseIndex:(NSNumber *)verseIndex;

@end

#endif /* VBVerseData_h */
