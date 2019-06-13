//
//  GroupMemberController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIGroupMembersView.h"

@class TUIGroupMemberController;
@protocol TGroupMemberControllerDelegagte <NSObject>
- (void)groupMemberController:(TUIGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;
- (void)groupMemberController:(TUIGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;
- (void)didCancelInGroupMemberController:(TUIGroupMemberController *)controller;
@end

@interface TUIGroupMemberController : UIViewController
@property (nonatomic, strong) TUIGroupMembersView *groupMembersView;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak) id<TGroupMemberControllerDelegagte> delegate;
- (void)updateData;
@end
