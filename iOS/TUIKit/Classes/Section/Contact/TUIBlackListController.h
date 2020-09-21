/******************************************************************************
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 黑名单界面组件
 *  本文件声明用于实现黑名单页面的组件。
 *  黑名单页面用于统一显示用户黑名单中的组件。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIBlackListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】黑名单界面（TUIBlackListController）
 * 【功能说明】负责拉取用户的黑名单信息，并在页面中显示。
 *  界面（Controller）提供了黑名单的展示功能，同时也实现了对用户交互动作的响应。
 *  用户也可点击黑名单中的某位用户，将其移出黑名单或对其发送消息。
 */
@interface TUIBlackListController : UITableViewController

/**
 *  黑名单界面的视图模型。
 *  负责黑名单数据的拉取、加载等操作。
 */
@property TUIBlackListViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
