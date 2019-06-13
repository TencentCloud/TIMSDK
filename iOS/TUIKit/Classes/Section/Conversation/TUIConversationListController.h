//
//  TUIConversationListController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TConversationListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIConversationListController;
@protocol TUIConversationListControllerDelegagte <NSObject>
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation;
@end

@interface TUIConversationListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<TUIConversationListControllerDelegagte> delegate;
@property (nonatomic, strong) TConversationListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
