/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+APNS
//
//  消息推送接口，里面包含了消息的推送的开启逻辑
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"
@class V2TIMAPNSConfig;
V2TIM_EXPORT @protocol V2TIMAPNSListener;

V2TIM_EXPORT @interface V2TIMManager (APNS)

/////////////////////////////////////////////////////////////////////////////////
//
//                         设置 APNS 推送
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  1.1 设置 APNS 监听
 */
- (void)setAPNSListener:(_Nullable id<V2TIMAPNSListener>)apnsListener NS_SWIFT_NAME(setAPNSListener(apnsListener:));

/**
 *  1.2 设置 APNS 推送
 *
 *  config -> token：苹果后台对客户端的唯一标识，需要主动调用系统 API 获取,获取方法如下:
 *
 *  <pre>
 *  //获取 token 代码示例
 *  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
 *    [[UIApplication sharedApplication] registerUserNotificationSettings:
 *        [UIUserNotificationSettings settingsForTypes:
 *            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
 *    [[UIApplication sharedApplication] registerForRemoteNotifications];
 *  }
 *  else{
 *    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
 *        (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
 *  }
 *
 *  //收到 token 代码示例
 *  -(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 *    //回调的 deviceToken 就是需要的 token 信息
 *  }
 *  </pre>
 *
 *  config -> busiId：推送证书 ID，上传推送证书（p.12）到 IM 控制台后生成。
 *  具体步骤请参考 [离线推送](https://cloud.tencent.com/document/product/269/9154)。
 *
 *  @note
 *  - 接口成功设置后会开启离线推送功能，如果您需要自定义推送的格式信息，请参考 V2TIMManager+Message.h 里面的 sendMessage 接口。
 *  - 如果成功开启了离线推送，APP 进后台后，如果收到消息，会弹系统推送通知，APP 进前台后，如果收到消息，则不会弹系统推送通知。
 *  - APP 进后台后 SDK 会默认设置应用角标为所有会话未读数之和,如果您需要自定义 APP 的未读数，请监听 V2TIMAPNSListener 回调设置。
 *  - APP 在未初始化或未登录成功状态下 SDK 不会设置应用角标，这种情况下如需设置应用角标，请自行调用系统函数设置。
 *  - 如果您想关闭离线推送，请把 config 设置为 nil。
 */
- (void)setAPNS:(V2TIMAPNSConfig* _Nullable)config succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setAPNS(config:succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         APNS 监听器
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @protocol V2TIMAPNSListener <NSObject>
@optional
/** 程序进后台后，自定义 APP 的未读数，如果不处理，APP 未读数默认为所有会话未读数之和
 *  <pre>
 *
 *   - (uint32_t)onSetAPPUnreadCount {
 *       return 100;  // 自定义未读数
 *   }
 *
 *  </pre>
 */
- (uint32_t)onSetAPPUnreadCount;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         APNS 配置
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMAPNSConfig : NSObject

/**
 * APNS token
 */
@property(nonatomic,strong) NSData *token;

/**
 * IM 控制台证书 ID，接入 TPNS 时不需要填写
 */
@property(nonatomic,assign) int businessID;

/**
 * 是否接入配置 TPNS, token 是否是从 TPNS 获取
 * @note 该字段已废弃
 * - 如果您之前通过 TPNS 接入离线推送，并且在 TPNS 控制台配置推送信息，可以继续按照该方式接入推送功能；
 * - 如果您从未接入 TPNS，从未在 TPNS 控制台配置推送信息，IM 将不在支持 TPNS 方式接入离线推送功能, 推荐参照如下方式接入：
 *  https://cloud.tencent.com/document/product/269/74284
 */
@property(nonatomic,assign) BOOL isTPNSToken __attribute__((deprecated("not supported anymore, please use APNs")));

@end
