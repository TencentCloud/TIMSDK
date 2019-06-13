//
//  TUIGroupConversationListController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/10.
//

#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TUIGroupConversationListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupConversationListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUIGroupConversationListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
