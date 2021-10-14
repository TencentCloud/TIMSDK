//
//  TUIChatManager.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//

#import <Foundation/Foundation.h>
#import "TUIC2CChatViewController.h"
#import "TUIGroupChatViewController.h"
#import "TUICore.h"
#import "TUIDefine.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

// TUIChatService 目前提供两个服务：
// 1、创建聊天类
// 2、通过 V2TIMMessage 对象获取展示文本信息
//
// TUIChatService 服务唤起有两种方式：
// 1、强依赖唤起：
// 如果您强依赖 TUIChat 组件，可以直接通过 [[TUIChatService shareInstance] createChatViewController:..] 方法唤起服务。
//
// 2、弱依赖唤起：
// 如果您弱依赖 TUIChat 组件，可以通过 [TUICore callService:..] 方法唤起服务，不同的服务传参如下：
// > 创建聊天类：
// serviceName: TUICore_TUIChatService
// method: TUICore_TUIChatService_GetChatViewControllerMethod
// param: @{
//         TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey : @"title",
//         TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey : @"userID",
//         TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey : @"groupID",
//         TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey : @"conversationID",
//         TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey : @"highlightKeyword",
//         TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey : V2TIMMessage,
//         };
//
// > 通过 V2TIMMessage 对象获取展示文本信息：
// serviceName: TUICore_TUIChatService
// method ：TUICore_TUIChatService_GetDisplayStringMethod
// param: @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey:V2TIMMessage};

@interface TUIChatService : NSObject <TUIServiceProtocol>
/**
 *  获取 TUIChatService 管理实例
 */
+ (TUIChatService *)shareInstance;

/**
 *  获取聊天界面
 *
 *  @param title 聊天界面展示 title
 *  @param userID 会话 userID
 *  @param groupID 会话 groupID
 *  @param conversationID 会话 ID
 *  @param highlightKeyword 需要高亮展示的文本
 *  @param locateMessage 需要定位的消息
 *  @return 聊天界面对象，如果是 C2C 聊天，返回 "TUIC2CChatViewController" 对象, 如果是群聊，返回 "TUIGroupChatViewController" 对象
 */
- (TUIBaseChatViewController *)createChatViewController:(NSString *)title
                                                 userID:(NSString *)userID
                                                groupID:(NSString *)groupID
                                         conversationID:(NSString *)conversationID
                                       highlightKeyword:(NSString *)highlightKeyword
                                          locateMessage:(V2TIMMessage *)locateMessage;

/**
 *  通过消息获取展示文本
 *
 *  @param message 消息对象
 *  @return 展示文本
 */
- (NSString *)getDisplayString:(V2TIMMessage *)message;
@end
NS_ASSUME_NONNULL_END
