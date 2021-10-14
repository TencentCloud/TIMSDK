//
//  V2FriendTestViewController.m
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "V2FriendTestViewController.h"
#import "TUIKit.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"

@interface V2FriendTestViewController ()<V2TIMSDKListener,V2TIMFriendshipListener>
@property(nonatomic,strong) V2TIMFriendApplicationResult *response;
@property(nonatomic,strong) NSString *toUserID;
@property(nonatomic,strong) NSString *toAddGroupUserID;
@property(nonatomic,strong) NSString *groupName;
@end

@implementation V2FriendTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[V2TIMManager sharedInstance] unInitSDK];
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:SDKAPPID config:config listener:self];
    [[V2TIMManager sharedInstance] setFriendListener:self];
    
    self.toUserID = self.userID.placeholder;
    self.toAddGroupUserID = self.addGroupUserID.placeholder;
    self.groupName = @"我的好友";
    [self.eventInfo setEditable:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tap];
}

- (void)onTap
{
    [self.userID resignFirstResponder];
    [self.remark resignFirstResponder];
    [self.customKey resignFirstResponder];
    [self.customValue resignFirstResponder];
    [self.addGroupUserID resignFirstResponder];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clear:(id)sender {
    self.eventInfo.text = @"";
}

- (IBAction)getFriendList:(id)sender {
    [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        [self appendString:[NSString stringWithFormat:@"拉取到好友：%@\n",infoList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"拉取好友资料失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getFriend:(id)sender {
    if (self.userID.text.length > 0) {
        self.toUserID = self.userID.text;
    }
    [[V2TIMManager sharedInstance] getFriendsInfo:@[self.toUserID] succ:^(NSArray<V2TIMFriendInfoResult *> *infoResultList) {
        for (V2TIMFriendInfoResult *result in infoResultList) {
            [self appendString:[NSString stringWithFormat:@"拉取到好友：%@\n",result]];
        }
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"拉取好友资料失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)setFriend:(id)sender {
    if (self.userID.text.length > 0) {
        self.toUserID = self.userID.text;
    }
    NSString *remark = self.remark.placeholder;
    if (self.remark.text.length > 0) {
        remark = self.remark.text;
    }
    V2TIMFriendInfo *info = [[V2TIMFriendInfo alloc] init];
    info.userID = self.toUserID;
    info.friendRemark = remark;
    if (self.customKey.text.length > 0 && self.customValue.text.length > 0) {
        info.friendCustomInfo = @{self.customKey.text:[self.customValue.text dataUsingEncoding:NSUTF8StringEncoding]};
    }
    [[V2TIMManager sharedInstance] setFriendInfo:info succ:^{
        [self appendString:@"设置好友资料成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置好友资料失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)addFriend:(id)sender {
    V2TIMFriendAddApplication *application = [[V2TIMFriendAddApplication alloc] init];
    application.userID = self.toUserID;
    application.addType = V2TIM_FRIEND_TYPE_BOTH;
    application.addSource = @"ios";
    application.addWording = @"加个好友吧";
    [[V2TIMManager sharedInstance] addFriend:application succ:^(V2TIMFriendOperationResult *result) {
        [self appendString:[NSString stringWithFormat:@"添加好友成功：%@",result]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"添加好友失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteFriend:(id)sender {
    [[V2TIMManager sharedInstance] deleteFromFriendList:@[self.toUserID] deleteType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        [self appendString:[NSString stringWithFormat:@"删除好友成功：%@",resultList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"删除好友失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)checkFriend:(id)sender {
    [[V2TIMManager sharedInstance] checkFriend:@[self.toUserID] checkType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendCheckResult *> *resultList) {
        [self appendString:[NSString stringWithFormat:@"检查好友关系成功：%@", resultList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"检查好友关系失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getApplications:(id)sender {
    [[V2TIMManager sharedInstance] getFriendApplicationList:^(V2TIMFriendApplicationResult *response) {
        self.response = response;
        [self appendString:[NSString stringWithFormat:@"获取好友申请列表成功：%@",response]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取好友申请列表失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)acceptFriend:(id)sender {
    if (self.response.applicationList.count > 0) {
        [[V2TIMManager sharedInstance] acceptFriendApplication:self.response.applicationList[0] type:V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD succ:^(V2TIMFriendOperationResult *result) {
            [self appendString:[NSString stringWithFormat:@"接受好友申请成功：%@",result]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"接受好友申请失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)refuseFriend:(id)sender {
    if (self.response.applicationList.count > 0) {
        [[V2TIMManager sharedInstance] refuseFriendApplication:self.response.applicationList[0] succ:^(V2TIMFriendOperationResult *result) {
            [self appendString:[NSString stringWithFormat:@"拒绝好友申请成功：%@",result]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"拒绝好友申请失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)setRead:(id)sender {
    [[V2TIMManager sharedInstance] setFriendApplicationRead:^{
        [self appendString:@"设置好友申请已读成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置好友申请已读失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteFriendAdd:(id)sender {
    if (self.response.applicationList.count > 0) {
        [[V2TIMManager sharedInstance] deleteFriendApplication:self.response.applicationList[0] succ:^{
            [self appendString:@"删除好友申请成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"删除好友申请失败，code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)addBlacklist:(id)sender {
    [[V2TIMManager sharedInstance] addToBlackList:@[self.toUserID] succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        for (V2TIMFriendOperationResult *result in resultList) {
            [self appendString:[NSString stringWithFormat:@"加入黑名单成功：%@",result]];
        }
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"加入黑名单失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteBlacklist:(id)sender {
    [[V2TIMManager sharedInstance] deleteFromBlackList:@[self.toUserID] succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        for (V2TIMFriendOperationResult *result in resultList) {
            [self appendString:[NSString stringWithFormat:@"删除黑名单成功：%@",result]];
        }
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"删除黑名单失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getBlacklist:(id)sender {
    [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        [self appendString:[NSString stringWithFormat:@"获取黑名单成功：%@",infoList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取黑名单失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)createGroup:(id)sender {
    [[V2TIMManager sharedInstance] createFriendGroup:self.groupName userIDList:@[self.toUserID] succ:^(NSArray<V2TIMFriendOperationResult *> *result) {
        [self appendString:[NSString stringWithFormat:@"创建好友分组成功：%@",result]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"创建好友分组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getGroup:(id)sender {
    [[V2TIMManager sharedInstance] getFriendGroupList:@[self.groupName] succ:^(NSArray<V2TIMFriendGroup *> *groups) {
        for (V2TIMFriendGroup *group in groups) {
            [self appendString:[NSString stringWithFormat:@"获取好友分组成功：%@",group]];
        }
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取好友分组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteGroup:(id)sender {
    [[V2TIMManager sharedInstance] deleteFriendGroup:@[self.groupName] succ:^{
        [self appendString:@"删除好友分组成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"删除好友分组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)renameGroup:(id)sender {
    static int x = 0;
    NSString *newName = [NSString stringWithFormat:@"%@%d",self.groupName,x++];
    [[V2TIMManager sharedInstance] renameFriendGroup:self.groupName newName:newName succ:^{
        self.groupName = newName;
        [self appendString:@"重命名好友分组成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"重命名好友分组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)addToGroup:(id)sender {
    if (self.addGroupUserID.text.length > 0) {
        self.toAddGroupUserID = self.addGroupUserID.text;
    }
    [[V2TIMManager sharedInstance] addFriendsToFriendGroup:self.groupName userIDList:@[self.toAddGroupUserID] succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        [self appendString:[NSString stringWithFormat:@"添加到好友分组成功：%@",resultList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"添加到好友分组失败，code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteFromGroup:(id)sender {
    [[V2TIMManager sharedInstance] deleteFriendsFromFriendGroup:self.groupName userIDList:@[self.addGroupUserID.text] succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
        [self appendString:[NSString stringWithFormat:@"从好友分组删除成功：%@",resultList]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"从好友分组删除失败，code：%d msg：%@",code,msg]];
    }];
}

- (void)appendString:(NSString *)str
{
    self.eventInfo.text = [NSString stringWithFormat:@"%@\n%@",self.eventInfo.text,str];
    [self.eventInfo scrollRangeToVisible:NSMakeRange(self.eventInfo.text.length, 1)];
}

#pragma mark V2TIMFriendshipListener

- (void)onFriendApplicationListAdded:(NSArray<V2TIMFriendApplication *> *)applicationList
{
    [self appendString:[NSString stringWithFormat:@"好友申请新增：%@",applicationList]];
}

- (void)onFriendApplicationListDeleted:(NSArray *)userIDList
{
    [self appendString:[NSString stringWithFormat:@"好友申请删除：%@",userIDList]];
}

- (void)onFriendApplicationListRead
{
    [self appendString:@"好友申请已读"];
}

- (void)onFriendListAdded:(NSArray<V2TIMFriendInfo *>*)infoList
{
    [self appendString:[NSString stringWithFormat:@"好友新增：%@",infoList]];
}

- (void)onFriendListDeleted:(NSArray*)userIDList
{
    [self appendString:[NSString stringWithFormat:@"好友删除：%@",userIDList]];
}

- (void)onBlackListAdded:(NSArray<V2TIMFriendInfo *>*)infoList
{
    [self appendString:[NSString stringWithFormat:@"黑名单新增：%@",infoList]];
}

- (void)onBlackListDeleted:(NSArray*)userIDList
{
    [self appendString:[NSString stringWithFormat:@"黑名单删除：%@",userIDList]];
}

- (void)onFriendProfileChanged:(NSArray<V2TIMFriendInfo *> *)infoList
{
    [self appendString:[NSString stringWithFormat:@"好友资料变更：%@",infoList]];
}
@end
