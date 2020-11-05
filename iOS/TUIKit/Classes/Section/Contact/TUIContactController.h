/******************************************************************************
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 通讯录界面组件
 *  本文件声明用于实现通讯录界面的模块。
 *  通讯录界面包含好友请求管理、群聊菜单、黑名单管理以及好友列表管理等功能。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】消息列表界面（TUIContactController）
 * 【功能说明】显示消息列表总界面，为用户提供消息管理的操作入口。
 *  消息列表包含了：
 *  1、好友请求管理（TUINewFriendViewController）
 *  2、群聊菜单（TUIGroupConversationListController）
 *  3、黑名单（TUIBlackListController）
 *  4、好友列表
 */
@interface TUIContactController : UIViewController

/**
 *  消息列表界面的视图模型
 *  视图模型负责通过 IM SDK 的接口，拉取好友列表、好友请求等信息并将其加载，以便客户端的进一步处理。
 *  详细信息请参考 Section\Contact\ViewModel\TContactViewModel.h
 */
@property (nonatomic) TContactViewModel *viewModel;
@property UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
