//
//  VBVerseViewLayoutDelegate.h
//  VBBrowserController
//
//  Created by CL Wang on 5/2/23.
//

#ifndef VBVerseViewLayoutDelegate_h
#define VBVerseViewLayoutDelegate_h

@class VBVerseViewController;

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

#endif /* VBVerseViewLayoutDelegate_h */
