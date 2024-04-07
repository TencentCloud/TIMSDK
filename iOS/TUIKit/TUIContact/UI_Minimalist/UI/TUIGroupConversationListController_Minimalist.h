
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIGroupConversationListViewDataProvider_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIGroupConversationListSelectCallback_Minimalist)(TUICommonContactCellData_Minimalist *cellData);

/**
 * 【Module name】Group list interface (TUIGroupConversationListController)
 * 【Function description】Responsible for pulling the group information of the user and displaying it in the interface.
 *  Users can view all the groups they hava joined through the group list interface. The groups are displayed in the order of the first latter of the group
 * names, and the group names with special symbols are displayed at the end.
 */
@interface TUIGroupConversationListController_Minimalist : UIViewController

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) TUIGroupConversationListViewDataProvider_Minimalist *viewModel;

/**
 * The selected callback, if it is empty, TUIKit will jump by itself
 */
@property(nonatomic, copy) TUIGroupConversationListSelectCallback_Minimalist __nullable onSelect;

@end

NS_ASSUME_NONNULL_END
