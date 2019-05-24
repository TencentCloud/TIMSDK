//
//  GroupMemberController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGroupMembersView.h"

@class TGroupMemberController;
@protocol TGroupMemberControllerDelegagte <NSObject>
- (void)groupMemberController:(TGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;
- (void)groupMemberController:(TGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;
- (void)didCancelInGroupMemberController:(TGroupMemberController *)controller;
@end

@interface TGroupMemberController : UIViewController
@property (nonatomic, strong) TGroupMembersView *groupMembersView;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak) id<TGroupMemberControllerDelegagte> delegate;
- (void)updateData;
@end
