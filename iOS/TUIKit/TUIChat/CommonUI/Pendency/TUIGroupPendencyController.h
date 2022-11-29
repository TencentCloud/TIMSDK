/**
 *
 *  本文件声明了群组请求管理的相关模块。
 *  您可以通过本文件中的 TUIGroupPendencyController 对用户的加群请求进行管理。
 *  包括浏览申请者信息，处理申请者请求等相关操作。
 *
 *  This document declares the relevant modules for group request management.
 *  You can manage users' group join requests through the TUIGroupPendencyController in this file.
 *  Including browsing applicant information, processing applicant requests and other related operations.
 */

#import <UIKit/UIKit.h>
#import "TUIGroupPendencyDataProvider.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIGroupPendencyController
 * 【功能说明】群组请求控制器。
 *  本视图负责在群组设置为“需要管理员审批“时，为管理员提供申请的审批视图控制器。
 *  本控制默认用 UITableView 实现，通过 tableView 展示所的入群申请。
 *  申请的信息包括：用户头像、用户昵称、申请简介、同意按钮。点击某一具体 tableCell 后，可以进入申请对应的详细界面（在详细页面中包含拒绝按钮）。
 *
 * 【Module name】 TUIGroupPendencyController
 * 【Function description】Group request controller.
 *  This view is responsible for providing the group administrator with a controller for processing group addition applications when the group is set to "Require Admin Approval"
 *  This control is implemented by UITableView by default, and the application for group membership is displayed through tableView.
 *  The information for joining a group application includes: user avatar, user nickname, application introduction, and agree button.
 *  After clicking a specific tableCell, you can enter the detailed interface corresponding to the application (the detailed page includes a reject button).
 */
@interface TUIGroupPendencyController : UITableViewController

@property TUIGroupPendencyDataProvider *viewModel;

@property (nonatomic, copy) void (^cellClickBlock)(TUIGroupPendencyCell *cell);


@end

NS_ASSUME_NONNULL_END
