/******************************************************************************
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 群组列表界面
 *
 *  本文件声明了群列表界面的相关组件。
 *  群列表界面类似于好友列表，可以将用户所在的群组按照首字母顺序展示出来。
 *  用户可以点击相应的群组进入群组详细界面进行进一步操作。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TUIGroupConversationListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】群组列表界面（TUIGroupConversationListController）
 * 【功能说明】负责拉取用户的所在的群组信息，并在界面中显示。
 *  用户可以通过群列表界面查看自己所在的所有群，群组展示顺序按首字母开头从 A 到 Z 展示，特殊符号的群名在最后显示。
 */
@interface TUIGroupConversationListController : UIViewController

/**
 *  群列表的 TableView
 *  本界面通过 tableView 展示用户所在的所有群组。同时 tableView 能够实现对用户交互操作的响应。
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  群列表界面的视图模型。
 *  视图模型负责通过 IM SDK 提供的接口拉取群列表数据并进行加载，方便页面对群列表进行展示。
 */
@property (nonatomic, strong) TUIGroupConversationListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
