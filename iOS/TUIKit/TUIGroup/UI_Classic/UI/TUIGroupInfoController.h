
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

@class TUIGroupInfoController;
@class TUIGroupMemberCellData;
@class V2TIMGroupInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupInfoController
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGroupInfoController : UITableViewController

@property(nonatomic, strong) NSString *groupId;

- (void)updateData;
- (void)updateGroupInfo;
@end
