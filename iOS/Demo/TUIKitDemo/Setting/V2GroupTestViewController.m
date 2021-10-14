//
//  V2GroupTestViewController.m
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "V2GroupTestViewController.h"
#import "TUIKit.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"

@interface V2GroupTestViewController ()<V2TIMSDKListener>
@property(nonatomic,strong) NSString *groupID;
@property(nonatomic,strong) NSString *defaultMemberID;
@property(nonatomic,strong) NSString *toMemberID;
@property(nonatomic,strong) NSString *toAddMemberID;
@property(nonatomic,strong) V2TIMGroupApplicationResult *response;
@end

@implementation V2GroupTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[V2TIMManager sharedInstance] unInitSDK];
    [[V2TIMManager sharedInstance] initSDK:SDKAPPID config:nil listener:self];
    [[V2TIMManager sharedInstance] setGroupListener:self];
    [self.eventInfo setEditable:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tap];
}

- (void)onTap
{
    [self.createGroupName resignFirstResponder];
    [self.createGroupType resignFirstResponder];
    [self.defaultMembers resignFirstResponder];
    [self.groupName resignFirstResponder];
    [self.notification resignFirstResponder];
    [self.introduction resignFirstResponder];
    [self.customKey resignFirstResponder];
    [self.customValue resignFirstResponder];
    [self.isAllMuted resignFirstResponder];
    [self.groupAddOpt resignFirstResponder];
    [self.faceURL resignFirstResponder];
    [self.receiveOpt resignFirstResponder];
    [self.memberID resignFirstResponder];
    [self.nameCard resignFirstResponder];
    [self.addMemberID resignFirstResponder];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clear:(id)sender {
    self.eventInfo.text = @"";
}

- (IBAction)createGroup:(id)sender {
    NSString *groupName = self.createGroupName.placeholder;
    if (self.createGroupName.text.length > 0) {
        groupName = self.createGroupName.text;
    }
    NSString *groupType = self.createGroupType.placeholder;
    if (self.createGroupType.text.length > 0) {
        groupType = self.createGroupType.text;
    }
    self.defaultMemberID = self.defaultMembers.placeholder;
    if (self.defaultMembers.text.length > 0) {
        self.defaultMemberID = self.defaultMembers.text;
    }
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupName = groupName;
    info.groupType = groupType;
    if ([groupType isEqualToString:@"AVChatRoom"] || [groupType isEqualToString:@"ChatRoom"] || [groupType isEqualToString:@"BChatRoom"]) {
        [[V2TIMManager sharedInstance] createGroup:groupType groupID:nil groupName:groupType succ:^(NSString *groupID) {
            self.groupID = groupID;
            [self appendString:[NSString stringWithFormat:@"创建群组成功:%@",self.groupID]];
            [[V2TIMManager sharedInstance] sendGroupTextMessage:@"创建群组" to:groupID priority:V2TIM_PRIORITY_DEFAULT succ:^{
                ;
            } fail:^(int code, NSString *msg) {
                
            }];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"创建群组失败，code：%d msg：%@",code,msg]];
        }];
    } else {
        V2TIMCreateGroupMemberInfo *memberInfo = [[V2TIMCreateGroupMemberInfo alloc] init];
        memberInfo.userID = self.defaultMemberID;
        [[V2TIMManager sharedInstance] createGroup:info memberList:@[memberInfo] succ:^(NSString *groupID) {
            self.groupID = groupID;
            [self appendString:[NSString stringWithFormat:@"创建群组成功:%@",self.groupID]];
            [[V2TIMManager sharedInstance] sendGroupTextMessage:@"创建群组" to:groupID priority:V2TIM_PRIORITY_DEFAULT succ:^{
                ;
            } fail:^(int code, NSString *msg) {
                
            }];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"创建群组失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)dismissGroup:(id)sender {
    [[V2TIMManager sharedInstance] dismissGroup:self.groupID succ:^{
        [self appendString:[NSString stringWithFormat:@"解散群组成功:%@",self.groupID]];;
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"解散群组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getJoinGroups:(id)sender {
    [[V2TIMManager sharedInstance] getJoinedGroupList:^(NSArray<V2TIMGroupInfo *> *groupList) {
        [self appendString:[NSString stringWithFormat:@"获取群列表成功：%@",groupList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取群列表失败，code：%d msg：%@",code,msg]];
    }];
}


- (IBAction)getGroupInfos:(id)sender {
    [[V2TIMManager sharedInstance] getGroupsInfo:@[self.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        [self appendString:[NSString stringWithFormat:@"获取群资料成功：%@",groupResultList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取群资料失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)setGroupInfo:(id)sender {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    if (self.groupName.text.length > 0) {
        info.groupName = self.groupName.text;
    }
    if (self.notification.text.length > 0) {
        info.notification = self.notification.text;
    }
    if (self.introduction.text.length > 0) {
        info.introduction = self.introduction.text;
    }
//    if (self.customKey.text.length > 0 && self.customValue.text.length > 0) {
//        info.customInfo = @{self.customKey.text:[self.customValue.text dataUsingEncoding:NSUTF8StringEncoding]};
//    }
    if (self.isAllMuted.text.length > 0) {
        info.allMuted = [self.isAllMuted.text intValue];
    }
    if (self.groupAddOpt.text.length > 0) {
        info.groupAddOpt = [self.groupAddOpt.text intValue];
    }
    if (self.faceURL.text.length > 0) {
        info.faceURL = self.faceURL.text;
    }
    if (self.receiveOpt.text.length > 0) {
        [[V2TIMManager sharedInstance] setGroupReceiveMessageOpt:self.groupID opt:[self.receiveOpt.text intValue] succ:^{
            [self appendString:@"设置消息接收选项成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"设置消息接收选项失败，code：%d msg：%@",code,msg]];
        }];
    }
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        [self appendString:@"设置群组信息成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置群组信息失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getGroupMembers:(id)sender {
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberInfo *> *memberList) {
        [self appendString:[NSString stringWithFormat:@"获取群成员列表成功，nextSeq：%llu memberList：%@",nextSeq,memberList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置群组信息失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getGroupMemberInfo:(id)sender {
    self.toMemberID = self.memberID.placeholder;
    if (self.memberID.text.length > 0) {
        self.toMemberID = self.memberID.text;
    }
    [[V2TIMManager sharedInstance] getGroupMembersInfo:self.groupID  memberList:@[self.toMemberID] succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        [self appendString:[NSString stringWithFormat:@"拉取到群成员资料：%@",memberList]];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"拉取群成员资料失败，code：%d msg：%@",code,desc]];
    }];
}

- (IBAction)setGroupMemberNameCard:(id)sender {
    NSString *nameCard = self.nameCard.placeholder;
    if (self.nameCard.text.length > 0) {
        nameCard = self.nameCard.text;
    }
    V2TIMGroupMemberFullInfo *memberInfo = [[V2TIMGroupMemberFullInfo alloc] init];
    memberInfo.userID = self.toMemberID;
    memberInfo.nameCard = nameCard;
    [[V2TIMManager sharedInstance] setGroupMemberInfo:self.groupID info:memberInfo succ:^{
        [self appendString:@"设置群名片成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置群名片失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)mute:(id)sender {
    [[V2TIMManager sharedInstance] muteGroupMember:self.groupID member:self.toMemberID muteTime:100 succ:^{
        [self appendString:@"禁言群成员成功"];;
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"禁言群成员失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)inviteMember:(id)sender {
    self.toAddMemberID = self.addMemberID.placeholder;
    if (self.addMemberID.text.length > 0) {
        self.toAddMemberID = self.addMemberID.text;
    }
    [[V2TIMManager sharedInstance] inviteUserToGroup:self.groupID userList:@[self.toAddMemberID] succ:^(NSArray<V2TIMGroupMemberOperationResult *> *results) {
        for (V2TIMGroupMemberOperationResult *result in results) {
            [self appendString:[NSString stringWithFormat:@"邀请入群成功：%@",result]];
        }
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"邀请入群失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)kickMember:(id)sender {
    [[V2TIMManager sharedInstance] kickGroupMember:self.groupID memberList:@[self.toAddMemberID] reason:@"踢人原因" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [self appendString:[NSString stringWithFormat:@"踢人成功：%@",resultList]];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"踢人失败，code：%d msg：%@",code,desc]];
    }];
}

- (IBAction)setRole:(id)sender {
    [[V2TIMManager sharedInstance] setGroupMemberRole:self.groupID member:self.defaultMemberID newRole:V2TIM_GROUP_MEMBER_ROLE_ADMIN succ:^{
        [self appendString:@"切换角色成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"切换角色失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)transformGroup:(id)sender {
    [[V2TIMManager sharedInstance] transferGroupOwner:self.groupID member:self.defaultMemberID succ:^{
        [self appendString:@"转让群组成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"转让群组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getApplicationList:(id)sender {
    [[V2TIMManager sharedInstance] getGroupApplicationList:^(V2TIMGroupApplicationResult *response) {
        self.response = response;
        [self appendString:[NSString stringWithFormat:@"获取加群申请成功：%@",response]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取加群申请失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)accept:(id)sender {
    for (V2TIMGroupApplication *application in self.response.applicationList) {
        [[V2TIMManager sharedInstance] acceptGroupApplication:application reason:@"接受入群申请" succ:^{
            [self appendString:[NSString stringWithFormat:@"接受入群申请成功：%@",application]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"获取入群申请失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)refuse:(id)sender {
    for (V2TIMGroupApplication *application in self.response.applicationList) {
        [[V2TIMManager sharedInstance] refuseGroupApplication:application reason:@"拒绝入群申请" succ:^{
            [self appendString:[NSString stringWithFormat:@"拒绝入群申请成功：%@",application]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"拒绝入群申请失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)setRead:(id)sender {
    [[V2TIMManager sharedInstance] setGroupApplicationRead:^{
        [self appendString:@"设置群未决已读成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"拒绝入群申请失败，code：%d msg：%@",code,msg]];
    }];
}

- (void)appendString:(NSString *)str
{
    self.eventInfo.text = [NSString stringWithFormat:@"%@\n%@",self.eventInfo.text,str];
    [self.eventInfo scrollRangeToVisible:NSMakeRange(self.eventInfo.text.length, 1)];
}

@end
