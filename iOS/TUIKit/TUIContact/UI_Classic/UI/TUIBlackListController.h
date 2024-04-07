
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIBlackListViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】Block list interferface (TUIBlackListController)
 * 【Function description】It is responsible for pulling the user's blocklist information and displaying it on the page.
 *  - ViewController provides the display function of the blocklist, and also realizes the response to user interaction.
 *  - Users can also click on a user in the blocklist to remove them from the blocklist or send them a message.
 */
@interface TUIBlackListController : UITableViewController

@property TUIBlackListViewDataProvider *viewModel;

@property(nonatomic, copy) void (^didSelectCellBlock)(TUICommonContactCell *cell);
@end

NS_ASSUME_NONNULL_END
