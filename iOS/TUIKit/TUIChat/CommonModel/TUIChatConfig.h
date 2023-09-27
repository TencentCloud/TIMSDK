//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatConfig : NSObject

+ (TUIChatConfig *)defaultConfig;
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatContextEmojiDetailGroups;

/**
 *  发送消息是否需要已读回执，默认 NO
 *  A read receipt is required to send a message, the default is NO
 */

@property(nonatomic, assign) BOOL msgNeedReadReceipt;

/**
 *  是否展示视频通话按钮，如果集成了 TUICalling 组件，默认 YES
 *  Display the video call button, if the TUICalling component is integrated, the default is YES
 */

@property(nonatomic, assign) BOOL enableVideoCall;

/**
 *  是否展示音频通话按钮，如果集成了 TUICalling 组件，默认 YES
 *  Whether to display the audio call button, if the TUICalling component is integrated, the default is YES
 */
@property(nonatomic, assign) BOOL enableAudioCall;

/**
 *  是否展示自定义的欢迎消息按钮，默认 YES
 *  Display custom welcome message button, default YES
 */

@property(nonatomic, assign) BOOL enableWelcomeCustomMessage;

/**
 *  聊天长按弹框是否展示emoji互动消息功能，默认 YES
 *  In the chat interface, long press the pop-up box to display the emoji interactive message function, the default is YES
 */

@property(nonatomic, assign) BOOL enablePopMenuEmojiReactAction;

/**
 *  聊天长按弹框是否展示 消息回复功能入口，默认 YES
 *  Chat long press the pop-up box to display the message reply function entry, the default is YES
 */

@property(nonatomic, assign) BOOL enablePopMenuReplyAction;

/**
 *  聊天长按弹框是否展示 消息引用功能入口，默认 YES
 *  Chat long press the pop-up box to display the entry of the message reference function, the default is YES
 */

@property(nonatomic, assign) BOOL enablePopMenuReferenceAction;

/**
 *  C2C聊天对话框是否展示 "对方正在输入中..."，默认 YES
 *  Whether the C2C chat dialog box displays "The other party is typing...", the default is YES
 */
@property(nonatomic, assign) BOOL enableTypingStatus;

/**
 *  聊天对话框是否展示 输入框 默认 YES
 *  Whether the  chat dialog box displays "InputBar", the default is YES
 */
@property(nonatomic, assign) BOOL enableMainPageInputBar;

/**
 * 设置聊天界面背景颜色
 * Setup the backgroud color of chat page
 */
@property(nonatomic, strong) UIColor *backgroudColor;

/**
 * 设置聊天界面背景图片
 * Setup the backgroud image of chat page
 */
@property(nonatomic, strong) UIImage *backgroudImage;

/**
 * 是否开启音视频通话悬浮窗，默认开启
 * Whether to turn on audio and video call suspension windows, default is YES
 */
@property(nonatomic, assign) BOOL enableFloatWindowForCall;

/**
 * 设置音视频通话开启多端登录功能，默认关闭
 * Whether to enable multi-terminal login function for audio and video calls, default is NO
 */
@property(nonatomic, assign) BOOL enableMultiDeviceForCall;

/**
 * 消息可撤回时间，单位秒，默认 120 秒。如果想调整该配置，请同步修改 IM 控制台设置。
 * The time interval for message recall, in seconds, default is 120 seconds. If you want to adjust this configuration, please modify the IM console settings
 * synchronously.
 *
 * https://cloud.tencent.com/document/product/269/38656#.E6.B6.88.E6.81.AF.E6.92.A4.E5.9B.9E.E8.AE.BE.E7.BD.AE
 */
@property(nonatomic, assign) NSUInteger timeIntervalForMessageRecall;

@end

NS_ASSUME_NONNULL_END
