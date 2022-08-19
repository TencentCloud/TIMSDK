#import <UIKit/UIKit.h>
#import "TUIBlackListViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】黑名单界面（TUIBlackListController）
 * 【功能说明】负责拉取用户的黑名单信息，并在页面中显示。
 *  界面（Controller）提供了黑名单的展示功能，同时也实现了对用户交互动作的响应。
 *  用户也可点击黑名单中的某位用户，将其移出黑名单或对其发送消息。
 *
 * 【Module name】Block list interferface (TUIBlackListController)
 * 【Function description】It is responsible for pulling the user's blocklist information and displaying it on the page.
 *  - ViewController provides the display function of the blocklist, and also realizes the response to user interaction.
 *  - Users can also click on a user in the blocklist to remove them from the blocklist or send them a message.
 */
@interface TUIBlackListController : UITableViewController

@property TUIBlackListViewDataProvider *viewModel;

@property (nonatomic, copy) void (^didSelectCellBlock)(TUICommonContactCell *cell);
@end

NS_ASSUME_NONNULL_END
