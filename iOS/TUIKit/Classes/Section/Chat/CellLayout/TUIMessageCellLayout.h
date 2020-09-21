
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIMessageCellLayout
 * 【功能说明】消息单元布局
 *  用于实现个类消息单元（文本、语音、视频、图像、表情等）的 UI 布局。
 *  布局可以使得 UI 风格统一，且易于管理与修改。
 *  当您想对 TUIKit 中的界面布局作出调整时，您可以对此布局中的对应属性进行修改。
 */
@interface TUIMessageCellLayout : NSObject
/**
 * 消息边距
 */
@property UIEdgeInsets messageInsets;
/**
 * 气泡内部内容边距
 */
@property UIEdgeInsets bubbleInsets;
/**
 * 头像边距
 */
@property UIEdgeInsets avatarInsets;
/**
 * 头像大小
 */
@property CGSize avatarSize;


/////////////////////////////////////////////////////////////////////////////////
//                      文本消息布局
/////////////////////////////////////////////////////////////////////////////////

/**
 *  获取文本消息（接收）布局
 */
+ (TUIMessageCellLayout *)incommingTextMessageLayout;

/**
 *  获取文本消息（发送）布局
 */
+ (TUIMessageCellLayout *)outgoingTextMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      语音消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取语音消息（接收）布局
 */
+ (TUIMessageCellLayout *)incommingVoiceMessageLayout;

/**
 *  获取语音消息（发送）布局
 */
+ (TUIMessageCellLayout *)outgoingVoiceMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      系统消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取系统消息布局
 */
+ (TUIMessageCellLayout *)systemMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      其他消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取接收消息布局
 */
+ (TUIMessageCellLayout *)incommingMessageLayout;

/**
 *  获取发送消息布局
 */
+ (TUIMessageCellLayout *)outgoingMessageLayout;

@end

NS_ASSUME_NONNULL_END
