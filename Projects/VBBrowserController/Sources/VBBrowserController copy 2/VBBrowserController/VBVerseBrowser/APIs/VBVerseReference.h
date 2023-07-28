//
//  VBVerseData.h
//  VBVerseReference 头文件定义
//
//  Created by CL Wang on 3/3/23.
//

#ifndef VBVerseData_h
#define VBVerseData_h

#import <Foundation/Foundation.h>

/**
 * @enum VBVerseRefCompareResult
 *
 * @brief 用于描述 VBVerseReference 类的 -isContinuouslyCompareWith: 比较方法的结果
 */
typedef enum: NSUInteger {
    VBVerseRefCompareResultNotContinuously          = 0,    // 不连续
    VBVerseRefCompareResultDescending               = 1,    // 降序，即被比较的经文是参照经文的上文
    VBVerseRefCompareResultAscending                = 2     // 升序，即被比较的经文是参照经文的下文
    
} VBVerseRefCompareResult;


// 1 2 3 4 5 6 5


/**
 * @class VBVerseReference
 *
 * @brief 用来标志一节经文的索引以及此经文的版本号
 *
 * @discussion 这个数据包只包括了经文的索引，并不包括具体的经文内容
 * 具体的内容均交由 VBVerseViewController 与数据源交互，
 * VBBrowserController 模块不与经文的内容交互
 */
@interface VBVerseReference : NSObject

/** @brief 圣经版本号，可能有多个版本 */
@property(readonly) NSArray<NSString *> * versionMarks;

/** @brief 经文的索引 */
@property(readonly) NSNumber * verseIndex;

- (VBVerseReference *)initWithVersionMarks:(NSArray<NSString *> *)versionMarks verseIndex:(NSNumber *)verseIndex;

/**
 * @brief 用于比较两个 VerseReference，不通过对比指针的方式进行比较，
 * 而是对比其中的值(即 versionMarks 和 verseIndex)，
 * 并且是深比较，这意味着也不比较 versionMarks 这个数组的指针，而是比较两个数组中的值是否一致。
 * 另外由于 versionMarks 数组中存的是 NSString，不用考虑指针不同，而其中的值相同的问题，
 * 所以这个方法确保了真正意义上的值相等，而不是指针相等
 */
- (BOOL)isEqualToVerseRef:(VBVerseReference *)verseRef;

@end

#endif /* VBVerseData_h */
