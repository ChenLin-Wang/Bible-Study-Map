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

/** 经文具体数据提供者的指针，由 VBBrowserController 模块提供，用于取得具体的经文内容 */
@property(readonly) id dataProvider;
/**
 * 排版代理的指针，当自己的内容发生变化时，通知此代理以请求更新自己的大小。
 * @discussion 因为 VerseView 的大小牵扯到上一层 TableView 的大小控制，
 * 所以此 View 的大小控制所有权在上层 TableView 手中，所以必须通过代理的方式通知其以更新大小。
 */
@property(readonly) id<VBVerseViewLayoutDelegate> layoutDelegate;

/** 新建一个 VBVerseViewController，并为其提供 DataProvider 和 LayoutDelegate */
+ (VBVerseViewController *)newVerseViewControllerWithDataProvider:(id)dataProvider layoutDelegate:(id<VBVerseViewLayoutDelegate>)layoutDelegate;
/** 提供 verseReference 以更新显示内容 */
- (void)updateVerseData:(VBVerseReference *)verseReference;

@end

/**
 * @protocol VBVerseViewLayoutDelegate
 * @brief 此协议仅仅用于配合 VBVerseStackView 来实现大小动态改变的效果，并不牵扯到任何经文数据的动作
 */
@protocol VBVerseViewLayoutDelegate <NSObject>

/**
 * 向 LayoutDelegate 发送通知，表示 verseView 的大小应当更新
 * @param size 提供 VerseView 的内容大小，LayoutDelegate 将根据此 Size，使得 VerseView 的大小适配此 Size
 * @param verseVC 通知发送者
 */
- (void)reLayoutWithContentSize:(NSSize)size verseVC:(VBVerseViewController *)verseVC;

@end

#endif /* VBVerseView_h */
