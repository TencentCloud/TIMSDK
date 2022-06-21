//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface TUIChatConfig : NSObject

+ (TUIChatConfig *)defaultConfig;

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
 */

@property(nonatomic, assign) BOOL enableAudioCall;

/**
 *  是否展示自定义消息按钮，默认 YES
 *  Display custom message button, default YES
 */

@property(nonatomic, assign) BOOL enableLink;

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

@end

NS_ASSUME_NONNULL_END
