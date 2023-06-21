
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUIContactViewDataProvider.h"
#import "TUIFindContactCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIContactControllerListener <NSObject>
@optional
- (void)onSelectFriend:(TUICommonContactCell *)cell;
- (void)onAddNewFriend:(TUICommonTableViewCell *)cell;
- (void)onGroupConversation:(TUICommonTableViewCell *)cell;
@end

@interface TUIContactController : UIViewController

@property(nonatomic, strong) TUIContactViewDataProvider *viewModel;
@property(nonatomic, weak) id<TUIContactControllerListener> delegate;
@property UITableView *tableView;

- (void)addToContactsOrGroups:(TUIFindContactType)type;
@end

NS_ASSUME_NONNULL_END
