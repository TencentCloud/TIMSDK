
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUIGroupMembersView.h"

@class TUIGroupMemberController_Minimalist;
@class V2TIMGroupInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMemberController_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGroupMemberController_Minimalist : UIViewController

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSString *groupId;

@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;

- (void)refreshData;

@end
