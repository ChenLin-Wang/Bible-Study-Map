//
//  VBBrowserController.h
//  VerseView 头文件定义
//
//  Created by CL Wang on 3/3/23.
//

#ifndef VBBrowserController_h
#define VBBrowserController_h

#import <Cocoa/Cocoa.h>
#import "VBVerseReference.h"

NS_ASSUME_NONNULL_BEGIN

@class VBBrowserController;

/**
 * @enum VBVerseRequestType
 * @brief 描述了请求经文类型
 *
 * @discussion 当请求类型为 VBVerseRequestTypeNext 时，表示数据提供者应当提供下一节经文的索引
 * 当请求类型为 VBVerseRequestTypePrevious 时，表示数据提供者应当提供上一节经文的索引
 * 这个 enum 只会在 - (VBVerseReference *)verseWillAppend: currentVerseReference: requestType: 方法中使用，用于标识经文请求的行为
 */
typedef enum : NSUInteger {
    
    /** 表示数据提供者应当提供上一节经文的索引 */
    VBVerseRequestTypePrevious                  = 1,
    /** 表示数据提供者应当提供下一节经文的索引 */
    VBVerseRequestTypeNext                      = 2
    
} VBVerseRequestType;


/**
 * @protocol VBBrowserDataSource
 * @brief 一个数据源协议，实现此协议的应当为 VBBrowserController 提供经文索引以供其显示和排列内容
 */
@protocol VBBrowserDataSource <NSObject>

/**
 * @brief browser 向 dataSource 请求一个 VerseDataProvider，这个 VerseDataProvider 用于提供具体的经文内容
 * 但在 Browser Controller 模块中并不会被使用，而是只负责将此指针传递到最底层的 VBVerseView。
 */
// 请求一个数据库指针，用于传递给底层 VerseView
- (id)verseDataProviderWithBrowser:(VBBrowserController *)browser;

/**
 * @brief browser 向 dataSource 请求新经文索引，一般在当浏览视图撞击到边缘时的追加动作时发生。
 *
 * @param browser 表示请求者
 *
 * @param curVerseReference 表示用于参照的经文索引，
 * 根据 requestType 决定 browser 请求的是前一节经文还是后一节
 * 若此参数为 NULL，表示此模块中没有任何 VerseReference，需要新增一条
 *
 * @param requestType 表示请求类型，请求前一节经文还是后一节经文
 *
 * @result 返回与请求相符的经文索引，若返回值与 curVerseReference 的顺序不符合 requestType，程序将抛出异常，导致崩溃
 * 若返回值为 NULL，表示没有新的经文可以追加了
 */
- (VBVerseReference * __nullable)verseWillAppend:(VBBrowserController *)browser
                           currentVerseReference:(VBVerseReference * __nullable)curVerseReference
                                     requestType:(VBVerseRequestType)requestType;

@end

/**
 * @class VBBrowserController
 * @brief Browser 模块主控制器，负责与外部数据源交互
 */
@interface VBBrowserController: NSObject

/** @brief 数据源的指针，一次设定将永远无法改变，并且只有在此类初始化时才可被设置，见 + (VBBrowserController *)newBrowserWithDataSource: 方法 */
@property(readonly) id<VBBrowserDataSource> dataSource;

/** @brief 新建一个 VBBrowserController 对象，并为其提供数据源的指针 */
+ (VBBrowserController *)newBrowserWithDataSource:(id<VBBrowserDataSource>)dataSource;

/**
 * @brief 将一个 view 作为参数传入到此方法，以将 BrowserView 嵌在其中
 */
- (void)showBrowserInView:(__kindof NSView *)view;

/**
 * @brief 更换当前显示的经文数据，当数据源主动要求更改显示内容时调用
 *
 * @param verseReferences 要显示的经文索引，如果传 nil，表示不提供任何索引。那么此模块将通过代理获取经文索引
 */
- (void)replaceVerseDatas:(NSArray<VBVerseReference *> * __nullable)verseReferences;

@end


#endif /* VBBrowserController_h */

NS_ASSUME_NONNULL_END
