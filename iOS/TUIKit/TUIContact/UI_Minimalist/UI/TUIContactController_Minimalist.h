
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUIContactViewDataProvider_Minimalist.h"
#import "TUIFindContactCellModel_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIContactControllerListener_Minimalist <NSObject>
@optional
- (void)onSelectFriend:(TUICommonContactCell_Minimalist *)cell;
- (void)onAddNewFriend:(TUICommonTableViewCell *)cell;
- (void)onGroupConversation:(TUICommonTableViewCell *)cell;
@end

@interface TUIContactController_Minimalist : UIViewController

@property(nonatomic, strong) TUIContactViewDataProvider_Minimalist *viewModel;
@property(nonatomic, weak) id<TUIContactControllerListener_Minimalist> delegate;
@property UITableView *tableView;

- (void)addToContacts;
- (void)addGroups;
@end

NS_ASSUME_NONNULL_END
