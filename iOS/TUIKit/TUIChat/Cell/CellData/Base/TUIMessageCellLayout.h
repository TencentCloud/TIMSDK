
#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIMessageCellLayout
 * 【功能说明】消息单元布局
 *  - 用于实现各类消息单元（文本、语音、视频、图像、表情等）的 UI 布局。
 *  - 当您想对 TUIKit 中的界面布局作出调整时，您可以对此布局中的对应属性进行修改。
 *
 *【Module Name】TUIMessageCellLayout
 *【Function description】The layout of message unit
 * - UI layouts for implementing various message units (text, voice, video, images, emoticons, etc.).
 * - When you want to adjust the interface layout in TUIKit, you can modify the corresponding properties in this layout.
 */
@interface TUIMessageCellLayout : NSObject

/**
 * The insets of message
 */
@property UIEdgeInsets messageInsets;

/**
 * The insets of bubble content.
 */
@property UIEdgeInsets bubbleInsets;

/**
 * The insets of avatar
 */
@property UIEdgeInsets avatarInsets;

/**
 * The size of avatar
 */
@property CGSize avatarSize;


/////////////////////////////////////////////////////////////////////////////////
//                      Text Message Layout
/////////////////////////////////////////////////////////////////////////////////

/**
 *  获取文本消息（接收）布局
 *
 *  Getting text message (receive) layout
 */
+ (TUIMessageCellLayout *)incommingTextMessageLayout;

/**
 *  获取文本消息（发送）布局
 *
 *  Getting text message (send) layout
 */
+ (TUIMessageCellLayout *)outgoingTextMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      Voice Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取语音消息（接收）布局
 *
 *  Getting voice message (receive) layout
 */
+ (TUIMessageCellLayout *)incommingVoiceMessageLayout;

/**
 *  获取语音消息（发送）布局
 *
 *  Getting voice message (send) layout
 */
+ (TUIMessageCellLayout *)outgoingVoiceMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      System Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取系统消息布局
 *
 *  Getting system message layout
 */
+ (TUIMessageCellLayout *)systemMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                     Other Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取接收消息布局
 *
 *  Getting receive message layout
 */
+ (TUIMessageCellLayout *)incommingMessageLayout;

/**
 *  获取发送消息布局
 *
 *  Getting send message layout
 */
+ (TUIMessageCellLayout *)outgoingMessageLayout;

@end

NS_ASSUME_NONNULL_END
