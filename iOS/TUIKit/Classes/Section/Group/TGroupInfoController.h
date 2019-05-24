//
//  GroupInfoController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TGroupInfoController;
@protocol TGroupInfoControllerDelegate <NSObject>
- (void)groupInfoController:(TGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId;
- (void)groupInfoController:(TGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId;
- (void)groupInfoController:(TGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId;
- (void)groupInfoController:(TGroupInfoController *)controller didDeleteGroup:(NSString *)groupId;
- (void)groupInfoController:(TGroupInfoController *)controller didQuitGroup:(NSString *)groupId;
@end

@interface TGroupInfoController : UITableViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak) id<TGroupInfoControllerDelegate> delegate;
- (void)updateData;
@end
