//
//  GroupInfoController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIGroupInfoController;
@protocol TGroupInfoControllerDelegate <NSObject>
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId;
- (void)groupInfoController:(TUIGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId members:(NSArray *)members;
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId members:(NSArray *)members;
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteGroup:(NSString *)groupId;
- (void)groupInfoController:(TUIGroupInfoController *)controller didQuitGroup:(NSString *)groupId;
@end

@interface TUIGroupInfoController : UITableViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak) id<TGroupInfoControllerDelegate> delegate;
- (void)updateData;
@end
