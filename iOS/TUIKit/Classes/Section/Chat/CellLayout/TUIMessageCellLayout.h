/**
 *  本文件声明了5个类，分别为
 *  1、TUIMessageCellLayout
 *  2、TIncomingCellLayout
 *  3、TOutgoingCellLayout
 *  4、TIncomingVoiceCellLayout
 *  5、TOutgoingVoiceCellLayout
 *  其中，类2、3继承自类1。类4继承自类2。类5继承自类3。
 *  本文件通过此种继承关系，达到分层细化消息单元布局的效果。
 *  您可以通过本布局，修改全体消息的头像大小与位置，调整消息/昵称的字体和颜色以及气泡内边距等布局特征。
 *  您可以通过修改本类的子类，达到修改某一特定消息布局的效果。
 *  当您想对自定义消息添加布局时，也可声明一个继承自本布局的子类，并对子类进行修改，以针对自定义消息进行特殊 UI 布局。
 */
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

/**
 *  获取接收消息布局
 */
+ (TUIMessageCellLayout *)incommingMessageLayout;

/**
 *  设置接收消息布局
 */
+ (void)setIncommingMessageLayout:(TUIMessageCellLayout *)incommingMessageLayout;

/**
 *  获取发送消息布局
 */
+ (TUIMessageCellLayout *)outgoingMessageLayout;

/**
 *  设置发送消息布局
 */
+ (void)setOutgoingMessageLayout:(TUIMessageCellLayout *)outgoingMessageLayout;

/**
 *  获取系统消息布局
 */
+ (TUIMessageCellLayout *)systemMessageLayout;

/**
 *  设置系统消息布局
 */
+ (void)setSystemMessageLayout:(TUIMessageCellLayout *)systemMessageLayout;

/**
 *  获取文本消息（接收）布局
 */
+ (TUIMessageCellLayout *)incommingTextMessageLayout;

/**
 *  设置文本消息（接收）布局
 */
+ (void)setIncommingTextMessageLayout:(TUIMessageCellLayout *)incommingTextMessageLayout;

/**
 *  获取文本消息（发送）布局
 */
+ (TUIMessageCellLayout *)outgoingTextMessageLayout;

/**
 *  设置文本消息（发送）布局
 */
+ (void)setOutgoingTextMessageLayout:(TUIMessageCellLayout *)outgoingTextMessageLayout;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIMessageCell 的细化布局
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 【模块名称】TIncomingCellLayout
 * 【功能说明】接收单元布局
 *  用于接收消息时，消息单元的默认布局。
 */
@interface TIncommingCellLayout : TUIMessageCellLayout

@end

/**
 * 【模块名称】TOutgoingCellLayout
 * 【功能说明】发送单元布局
 *  用于发送消息时，消息单元的默认布局。
 */
@interface TOutgoingCellLayout : TUIMessageCellLayout

@end


/**
 * 【模块名称】TIncomingVoiceCellLayout
 * 【功能说明】语音接收单元布局
 *  用于接收语音消息时，消息单元的默认布局。
 */
@interface TIncommingVoiceCellLayout : TIncommingCellLayout

@end

/**
 * 【模块名称】TOutgoingVoiceCellLayout
 * 【功能说明】语音发送单元布局
 *  用于发送语音消息时，消息单元的默认布局。
 */
@interface TOutgoingVoiceCellLayout : TOutgoingCellLayout

@end

NS_ASSUME_NONNULL_END
