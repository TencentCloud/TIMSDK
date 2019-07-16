/******************************************************************************
 *
 *  本文件声明了群组请求管理的相关模块。
 *  您可以通过本文件中的 TUIGroupPendencyController 对用户的加群请求进行管理。
 *  包括浏览申请者信息，处理申请者请求等相关操作。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TUIGroupPendencyViewModel.h"
NS_ASSUME_NONNULL_BEGIN

/** 腾讯云 TUIKit
 * 【模块名称】TUIGroupPendencyController
 * 【功能说明】TUI 群组请求控制器。
 *  本视图负责在群组设置为“需要管理员审批“时，为管理员提供申请的审批视图控制器。
 *  本控制默认用 UITableView 实现，通过 tableView 展示所的入群申请。
 *  申请的信息包括：用户头像、用户昵称、申请简介、同意按钮。点击某一具体 tableCell 后，可以进入申请对应的详细界面（在详细页面中包含拒绝按钮）。
 */
@interface TUIGroupPendencyController : UITableViewController
/**
 *  请求视图的视图模型。
 *  负责视图的具体实现。包含信息加载、未读计数、以及通过 IM SDK 同意/拒绝申请等业务逻辑
 *  详细信息请参考 Section\Chat\Pendency\ViewModel\TUIGroupPendencyViewModel.h
 */
@property TUIGroupPendencyViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
