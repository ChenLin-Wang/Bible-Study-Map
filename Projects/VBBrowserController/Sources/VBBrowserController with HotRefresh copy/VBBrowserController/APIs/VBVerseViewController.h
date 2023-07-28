//
//  VBVerseViewController.h
//
//
//  Created by CL Wang on 3/3/23.
//

#ifndef VBVerseView_h
#define VBVerseView_h

#import<Cocoa/Cocoa.h>
#import "VBVerseReference.h"

@protocol VBVerseViewLayoutDelegate;

/**
 * @class VBVerseViewController
 * @brief VerseView 的 ViewController
 * @discussion 由于 VBVerseView 只是一个 NSView，不应当用于处理数据，所以新建一个 ViewController 来进行这些动作。
 * VBBrowserController 模块将只对此 ViewController 进行动作。
 */
@interface VBVerseViewController: NSViewController

/** @brief 经文具体数据提供者的指针，由 VBBrowserController 模块提供，用于取得具体的经文内容 */
@property (readonly) id dataProvider;
/**
 * @brief 排版代理的指针，当自己的内容发生变化时，通知此代理以请求更新自己的大小。
 *
 * @discussion 因为 VerseView 的大小牵扯到上一层 TableView 的大小控制，
 * 所以此 View 的大小控制所有权在上层 TableView 手中，所以必须通过代理的方式通知其以更新大小。
 */
@property (readonly) id<VBVerseViewLayoutDelegate> layoutDelegate;
/**
 * @brief 此 VerseViewController 的经文引用，这个参数开放给外部修改，但修改后不应当进行任何视图更新动作，
 * 任何视图更新都不应当在此参数被更改是进行
 * 不要在此参数修改后立即通过 layoutDelegate 呼叫上级重新进行排版，这会导致程序崩溃
 */
@property VBVerseReference * verseReference;

/**
 * @brief 实现此方法，当此方法被调用时，进行一些初始化
 * 你应当在此方法中通过 VBVerseViewLayoutDelegate 的 -reLayoutWithContentSize:verseVC: 方法为自己设置初始宽度和高度，
 * 若不设置，则 view 的高度和宽度都为默认值
 */
- (void)viewShouldPrepare;

/** @brief 新建一个 VBVerseViewController，并为其提供 DataProvider 和 LayoutDelegate */
+ (VBVerseViewController *)newVerseViewControllerWithDataProvider:(id)dataProvider layoutDelegate:(id<VBVerseViewLayoutDelegate>)layoutDelegate;
/**
 * @brief 这个方法表示此 view 即将被放入到上级 StackView 中，即此 View 即将显示
 * 实现这个方法以进行一些视图更新或其他动作
 */
- (void)viewWillAttachToStackView;

@end

/**
 * @protocol VBVerseViewLayoutDelegate
 * @brief 此协议仅仅用于配合 VBVerseStackView 来实现大小动态改变的效果，并不牵扯到任何经文数据的动作
 */
@protocol VBVerseViewLayoutDelegate <NSObject>

/**
 * @brief 向 LayoutDelegate 发送通知，表示 verseView 的大小应当更新
 * @param size 提供 VerseView 的内容大小，LayoutDelegate 将根据此 Size，使得 VerseView 的大小适配此 Size
 * @param verseVC 通知发送者
 */
- (void)reLayoutWithContentSize:(NSSize)size verseVC:(VBVerseViewController *)verseVC;

@end

#endif /* VBVerseView_h */
