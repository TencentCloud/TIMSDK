#import <UIKit/UIKit.h>
#import "TUIGroupConversationListViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIGroupConversationListSelectCallback)(TUICommonContactCellData *cellData);

/**
 * 【模块名称】群组列表界面（TUIGroupConversationListController）
 * 【功能说明】负责拉取用户的所在的群组信息，并在界面中显示。
 *  用户可以通过群列表界面查看自己所在的所有群，群组展示顺序按首字母开头从 A 到 Z 展示，特殊符号的群名在最后显示。
 *
 * 【Module name】Group list interface (TUIGroupConversationListController)
 * 【Function description】Responsible for pulling the group information of the user and displaying it in the interface.
 *  Users can view all the groups they hava joined through the group list interface. The groups are displayed in the order of the first latter of the group names, and the group names with special symbols are displayed at the end.
 */
@interface TUIGroupConversationListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) TUIGroupConversationListViewDataProvider *viewModel;

/**
 * 选中后的回调，如果为空，TUIKit 内部会自己跳转
 * The selected callback, if it is empty, TUIKit will jump by itself
 */
@property (nonatomic, copy) TUIGroupConversationListSelectCallback __nullable onSelect;

@end

NS_ASSUME_NONNULL_END
