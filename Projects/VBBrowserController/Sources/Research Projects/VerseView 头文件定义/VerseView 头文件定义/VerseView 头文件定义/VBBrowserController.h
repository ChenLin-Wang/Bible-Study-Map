//
//  VBBrowserController.h
//  VerseView 头文件定义
//
//  Created by CL Wang on 3/3/23.
//

#ifndef VBBrowserController_h
#define VBBrowserController_h

#import <Cocoa/Cocoa.h>
#import "VBVerseData.h"

/**
 * @enum VBVerseRequestType
 * @brief 描述了请求经文类型
 * @discussion 当请求类型为 VBVerseRequestTypeNext 时，表示数据提供者应当提供下一节经文的索引
 * 当请求类型为 VBVerseRequestTypePrevious 时，表示数据提供者应当提供上一节经文的索引
 * 这个 enum 只会在 - (VBVerseReference *)verseWillAppend: currentVerseReference: requestType: 方法中使用，用于标识经文请求的行为
 */
typedef enum : NSUInteger {
    
    /** 表示数据提供者应当提供下一节经文的索引 */
    VBVerseRequestTypeNext                      = 0,
    /** 表示数据提供者应当提供上一节经文的索引 */
    VBVerseRequestTypePrevious                  = 1
    
} VBVerseRequestType;


/**
 * @protocol VBBrowserDataSource
 * @brief 一个数据源协议，实现此协议的应当为 VBBrowserController 提供经文索引以供其显示和排列内容
 */
@protocol VBBrowserDataSource <NSObject>

/**
 * browser 向 dataSource 请求一个 VerseDataProvider，这个 VerseDataProvider 用于提供具体的经文内容
 * 但在 Browser Controller 模块中并不会被使用，而是只负责将此指针传递到最底层的 VBVerseView。
 */
// 请求一个数据库指针，用于传递给底层 VerseView
- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser;

/**
 * browser 向 dataSource 请求新经文索引，一般在当浏览视图撞击到边缘时的追加动作时发生。
 * @param browser 表示请求者
 * @param curVerseReference 表示用于参照的经文索引，根据 requestType 决定 browser 请求的是前一节经文还是后一节
 * @param requestType 表示请求类型，请求前一节经文还是后一节经文
 */
- (VBVerseReference *)verseWillAppend:(VBBrowserController *)browser
                currentVerseReference:(VBVerseReference *)curVerseReference
                          requestType:(VBVerseRequestType)requestType;

@end

/**
 * @class VBBrowserController
 * @brief Browser 模块主控制器，负责与外部数据源交互
 */
@interface VBBrowserController: NSObject

/** 数据源的指针，一次设定将永远无法改变，并且只有在此类初始化时才可被设置，见 + (VBBrowserController *)newBrowserWithDataSource: 方法 */
@property(readonly) id<VBBrowserDataSource> dataSource;

/** 新建一个 VBBrowserController 对象，并为其提供数据源的指针 */
+ (VBBrowserController *)newBrowserWithDataSource(id<VBBrowserDataSource>)dataSource;

/**
 * 更换当前显示的经文数据，当数据源主动要求更改显示内容时调用
 * 注：verseReferences 必须传入连续经文，否则程序会抛出异常
 */
- (void)replaceVerseDatas:(NSArray<VBVerseReference *> *)verseReferences;

@end


#endif /* VBBrowserController_h */
