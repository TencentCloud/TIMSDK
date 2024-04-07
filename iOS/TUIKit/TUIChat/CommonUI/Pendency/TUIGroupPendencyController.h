
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This document declares the relevant modules for group request management.
 *  You can manage users' group join requests through the TUIGroupPendencyController in this file.
 *  Including browsing applicant information, processing applicant requests and other related operations.
 */

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIGroupPendencyDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 【Module name】 TUIGroupPendencyController
 * 【Function description】Group request controller.
 *  This view is responsible for providing the group administrator with a controller for processing group addition applications when the group is set to
 * "Require Admin Approval" This control is implemented by UITableView by default, and the application for group membership is displayed through tableView. The
 * information for joining a group application includes: user avatar, user nickname, application introduction, and agree button. After clicking a specific
 * tableCell, you can enter the detailed interface corresponding to the application (the detailed page includes a reject button).
 */
@interface TUIGroupPendencyController : UITableViewController

@property TUIGroupPendencyDataProvider *viewModel;

@property(nonatomic, copy) void (^cellClickBlock)(TUIGroupPendencyCell *cell);

@end

NS_ASSUME_NONNULL_END
