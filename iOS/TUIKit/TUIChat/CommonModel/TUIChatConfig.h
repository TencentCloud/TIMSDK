//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TUIMessageCellData.h>
@class TUIChatEventConfig;

typedef NS_ENUM(NSUInteger, TUIChatRegisterCustomMessageStyleType) {
    TUIChatRegisterCustomMessageStyleTypeClassic = 0,
    TUIChatRegisterCustomMessageStyleTypeMinimalist = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatConfig : NSObject

+ (TUIChatConfig *)defaultConfig;
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatContextEmojiDetailGroups;

/**
 *  发送消息是否需要已读回执，默认 NO
 *  A read receipt is required to send a message
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

/**
 * 本类用来从外部向 Chat 注册事件监听器，用来监听 Chat 的各个事件并作出相应的处理，比如监听点击头像事件，长按消息事件等
 * 需要设置一个实现方法的被委托方 TUIChatConfig.defaultConfig.eventConfig.chatEventListener = "YourDelegateViewController"
 * 在您的YourDelegateViewController需要遵循 <TUIChatEventListener>协议，并实现协议方法。
 * 以- (BOOL)onUserIconClicked:messageCellData:为例 ， 返回为NO时为插入行为， 此事件不被拦截，Chat 内部会继续处理。
 * 以- (BOOL)onUserIconClicked:messageCellData:为例 ， 返回为YES时为重写行为，此事件会被拦截，只会执行重写的方法，Chat内部不会继续处理。
 *
 * This class is used to register event listeners for Chat from external sources, to listen for various events in Chat and respond accordingly,
 * such as listening for avatar click events, long-press message events, etc.
 * You need to set a delegate for the implementation method: TUIChatConfig.defaultConfig.eventConfig.chatEventListener = "YourDelegateViewController".
 * YourDelegateViewController needs to conform to the <TUIChatEventListener> protocol and implement the protocol method.
 * Taking - (BOOL)onUserIconClicked:messageCellData: as an example, returning NO indicates an insertion behavior, 
 * which is not intercepted and will be further processed by the Chat module.
 * Taking - (BOOL)onUserIconClicked:messageCellData: as an example, returning YES indicates an override behavior, 
 * which will be intercepted and only the overridden method will be executed. The Chat module will not continue to process it.
 */
@property(nonatomic, strong) TUIChatEventConfig * eventConfig;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatEventListener <NSObject>

/**
 * 聊天列表界面用户头像被点击时触发此回调，返回 YES 表示此事件已经被拦截，Chat 内部后续不再处理， 
 * 返回 NO 表示此事件不被拦截， Chat 内部会继续处理
 * This callback is triggered when a user avatar in the chat list interface is clicked. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserIconClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
/**
 * 聊天列表界面用户头像被长按时触发此回调，返回 YES 表示此事件已经被拦截，Chat 内部后续不再处理， 
 * 返回 NO 表示此事件不被拦截， Chat 内部会继续处理
 * This callback is triggered when a user avatar in the chat list interface is long-pressed. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserIconLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;

/**
 * 聊天列表界面消息被点击时触发此回调，返回 YES 表示此事件已经被拦截，Chat 内部后续不再处理， 
 * 返回 NO 表示此事件不被拦截， Chat 内部会继续处理
 * This callback is triggered when a message in the chat list interface is clicked. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;

/**
 * 聊天列表界面消息被长按时触发此回调，返回 YES 表示此事件已经被拦截，Chat 内部后续不再处理，
 * 返回 NO 表示此事件不被拦截， Chat 内部会继续处理
 * This callback is triggered when a message in the chat list interface is long-pressed. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
@end

@interface TUIChatEventConfig : NSObject
@property (nonatomic,weak)id <TUIChatEventListener>chatEventListener;
@end

// Regiser custom message category
// You can call this method like :
//
// [TUIChatConfig.defaultConfig registerCustomMessage:@"YourBusinessID"
//                               messageCellClassName:@"YourCustomCellNameString"
//                           messageCellDataClassName:@"YourCustomCellDataNameString"];
@interface TUIChatConfig (CustomMessageRegiser)

/**
 * 注册自定义消息  ，默认向经典版 UI 注册
 * @param businessID 自定义消息 businessID（注意不能重复）
 * @param cellName 自定义消息 messageCell 类名
 * @param cellDataName 自定义消息 messageCellData  类名
 *
 * Register custom message ,  by default, register to the classic UI.
 * param businessID Custom message businessID (note that it must be unique)
 * param cellName Custom message messagCell  type
 * param cellDataName Custom message  MessagCellData type
 */
- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName;

/**
 * 注册自定义消息
 * @param businessID 自定义消息 businessID（注意不能重复）
 * @param cellName 自定义消息 messageCellClass 类名
 * @param cellDataName 自定义消息 messageCellDataClass的 类名
 * @param styleType 此自定义消息对应的 UI 风格，例如 TUIChatRegisterCustomMessageStyleTypeClassic
 *
 * Register custom message
 * param businessID Custom message businessID (note that it must be unique)
 * param cellName Custom message messagCell  type
 * param cellDataName Custom message  MessagCellData type
 * param styleType UI style corresponding to this custom message, for example TUIChatRegisterCustomMessageStyleTypeClassic
 */
- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName
                    styleType:(TUIChatRegisterCustomMessageStyleType)styleType;
@end

NS_ASSUME_NONNULL_END

