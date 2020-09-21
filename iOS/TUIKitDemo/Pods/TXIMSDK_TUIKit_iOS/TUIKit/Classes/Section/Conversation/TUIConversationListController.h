/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 消息列表组件。
 *
 * 本文件声明了消息列表的视图组件。
 * 消息列表组件能够按照新消息发来时间顺序（越新的消息排序越靠前），展示各个会话的简要信息。
 * 消息列表所展示的会话信息包括：
 * 1、头像信息（用户头像/群头像）
 * 2、会话标题（用户昵称/群名称）
 * 3、会话消息概览（展示最新的一条的消息内容）
 * 4、未读消息数（若有未读消息的话）
 * 5、会话时间（最新消息的收到/发出时间）
 * 消息列表中展示的会话信息，由 TUIConversationCell 具体实现。详细信息请参考 Section\Conversation\Cell\TUIConversationCell.h
 *
 ******************************************************************************/


#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TConversationListViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@class TUIConversationListController;

/////////////////////////////////////////////////////////////////////////////////
//
//                  TUIConversationListControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIConversationListControllerDelegate <NSObject>

/**
 *  在消息列表中，点击了具体某一会话后的回调。
 *  您可以通过该回调响应用户的点击操作，跳转到该会话对应的聊天界面。
 *
 *  @param conversationController 委托者，当前所在的消息列表。
 *  @param conversation 被选中的会话单元
 */
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation;
@end

/**
 * 【模块名称】消息列表界面组件（TUIConversationListController）
 *
 * 【功能说明】负责按消息的接收顺序展示各个会话，同时响应用户的操作，为用户提供多会话的管理功能。
 *  消息列表所展示的会话信息包括：
 *  1、头像信息（用户头像/群头像）
 *  2、会话标题（用户昵称/群名称）
 *  3、会话消息概览（展示最新的一条的消息内容）
 *  4、未读消息数（若有未读消息的话）
 *  5、会话时间（最新消息的收到/发出时间）
 */
@interface TUIConversationListController : UIViewController

/**
 *  消息列表。
 *  消息列表控制器通过 UITableView 的形式实现会话的统一展示。
 *  UITableView 同时能够提供各个单元的删除、点击响应等管理操作。
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  委托类，负责实现 TUIConversationListControllerDelegate 的委托函数。
 */
@property (nonatomic, weak) id<TUIConversationListControllerDelegate> delegate;

/**
 *  消息列表的视图模型
 *  视图模型能够协助消息列表界面实现数据的加载、移除、过滤等多种功能。替界面分摊部分的业务逻辑运算。
 */
@property (nonatomic, strong) TConversationListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
