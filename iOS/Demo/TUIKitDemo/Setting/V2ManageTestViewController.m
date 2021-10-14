//
//  V2ManageTestViewController.m
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "V2ManageTestViewController.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"
#import "TUIKit.h"
#import <AVFoundation/AVFoundation.h>

@interface V2ManageTestViewController () <V2TIMSDKListener,V2TIMSimpleMsgListener,V2TIMAdvancedMsgListener,V2TIMAPNSListener,V2TIMGroupListener,V2TIMConversationListener,V2TIMSignalingListener>
@property(nonatomic,strong) NSString *tologinUser;
@property(nonatomic,strong) NSString *conversationID;
@property(nonatomic,strong) NSArray<V2TIMConversation *> *list;
@property(nonatomic,assign) uint64_t lastTs;
@end

@implementation V2ManageTestViewController
{
    V2TIMMessage *_lastMsg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[V2TIMManager sharedInstance] unInitSDK];
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    config.logLevel = V2TIM_LOG_INFO;
    [[V2TIMManager sharedInstance] initSDK:SDKAPPID config:config listener:self];
    [[V2TIMManager sharedInstance] setGroupListener:self];
    [[V2TIMManager sharedInstance] addSimpleMsgListener:self];
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    [[V2TIMManager sharedInstance] setAPNSListener:self];
    [[V2TIMManager sharedInstance] addSignalingListener:self];
    [self.eventInfo setEditable:NO];
    self.tologinUser = self.loginUser.placeholder;
    self.conversationID = @"xixi";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tap];
}

- (void)onTap
{
    [self.loginUser resignFirstResponder];
    [self.groupName resignFirstResponder];
    [self.groupType resignFirstResponder];
    [self.joinGroupID resignFirstResponder];
    [self.quitGroupID resignFirstResponder];
    [self.dismissGroupID resignFirstResponder];
    [self.nickName resignFirstResponder];
    [self.faceUrl resignFirstResponder];
    [self.selfSignature resignFirstResponder];
    [self.gender resignFirstResponder];
    [self.allowType resignFirstResponder];
    [self.customKey resignFirstResponder];
    [self.customValue resignFirstResponder];
    [self.eventInfo resignFirstResponder];
    [self.attributeValue resignFirstResponder];
    [self.attributeKey resignFirstResponder];
}

- (IBAction)closeVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clear:(id)sender {
    self.eventInfo.text = @"";
}

- (IBAction)login:(id)sender {
    if (self.loginUser.text.length > 0) {
        self.tologinUser = self.loginUser.text;
    }
    [[V2TIMManager sharedInstance] login:self.tologinUser userSig:[GenerateTestUserSig genTestUserSig:self.tologinUser] succ:^{
        [self appendString:[NSString stringWithFormat:@"登录成功，useID：%@",self.tologinUser]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"登录失败，useID：%@ code：%d msg：%@",self.tologinUser,code,msg]];
    }];
}

- (IBAction)logout:(id)sender {
    [[V2TIMManager sharedInstance] logout:^{
        [self appendString:[NSString stringWithFormat:@"登出成功，useID：%@",self.tologinUser]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"登出失败，useID：%@ code：%d msg：%@",self.tologinUser,code,msg]];
    }];
}

- (IBAction)switchID:(id)sender {
    if ([self.convSwitch isOn]) {
        self.conversationID = @"xixi";
    } else {
        self.conversationID = @"@TGS#a2DTPHQGK";
        [[V2TIMManager sharedInstance] joinGroup:self.conversationID msg:nil succ:nil fail:nil];
    }
}

- (IBAction)sendSimpleTextMsg:(id)sender {
    NSString *msgID = @"";
    if ([self.conversationID containsString:@"@TGS"]) {
        msgID = [[V2TIMManager sharedInstance] sendGroupTextMessage:@"发送普通文本消息" to:self.conversationID priority:V2TIM_PRIORITY_HIGH succ:^{
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通文本消息成功",self.conversationID]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通文本消息失败,code：%d msg：%@",self.conversationID,code,msg]];
        }];
    } else {
        msgID = [[V2TIMManager sharedInstance] sendC2CTextMessage:@"发送普通文本消息" to:self.conversationID succ:^{
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通文本消息成功",self.conversationID]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通文本消息失败,code：%d msg：%@",self.conversationID,code,msg]];
        }];
    }
    [self appendString:[NSString stringWithFormat:@"发送普通文本消息返回 msgID 成功：%@",msgID]];
}

- (IBAction)sendSimpleCustomMsg:(id)sender {
    NSString *msgID = @"";
    if ([self.conversationID containsString:@"@TGS"]) {
        msgID = [[V2TIMManager sharedInstance] sendGroupCustomMessage:[@"发送普通自定义消息" dataUsingEncoding:NSUTF8StringEncoding] to:self.conversationID priority:V2TIM_PRIORITY_HIGH succ:^{
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通自定义消息成功",self.conversationID]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通自定义消息失败,code：%d msg：%@",self.conversationID,code,msg]];
        }];
    } else {
        msgID = [[V2TIMManager sharedInstance] sendC2CCustomMessage:[@"发送普通自定义消息" dataUsingEncoding:NSUTF8StringEncoding] to:self.conversationID succ:^{
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通自定义消息成功",self.conversationID]];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"给 %@ 发送普通自定义消息失败,code：%d msg：%@",self.conversationID,code,msg]];
        }];
    }
    [self appendString:[NSString stringWithFormat:@"发送普通自定义消息返回 msgID 成功：%@",msgID]];
}

- (IBAction)sendTextMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createTextMessage:@"发送文本消息"];
    [self sendMsg:msg type:@"文本"];
}

- (IBAction)sendCustomMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:[@"发送自定义消息" dataUsingEncoding:NSUTF8StringEncoding]];
    [self sendMsg:msg type:@"自定义"];
}

- (IBAction)sendImageMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createImageMessage:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"]];
    [self sendMsg:msg type:@"图片"];
}

- (IBAction)sendSoundMsg:(id)sender {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"m4a"];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createSoundMessage:soundPath duration:[self getDuration:soundPath]];
    [self sendMsg:msg type:@"语音"];
}

- (IBAction)sendVideoMsg:(id)sender {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSString *snapShotPath = [[NSBundle mainBundle] pathForResource:@"testpng" ofType:@""];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createVideoMessage:videoPath type:@"mp4" duration:[self getDuration:videoPath] snapshotPath:snapShotPath];
    [self sendMsg:msg type:@"视频"];
}

- (IBAction)sendFileMsg:(id)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createFileMessage:filePath fileName:@"发送文件消息"];
    [self sendMsg:msg type:@"文件"];
}

- (IBAction)sendLocationMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createLocationMessage:@"发送地理位置消息" longitude:0.5 latitude:0.5];
    [self sendMsg:msg type:@"地理位置"];
}

- (IBAction)sendFaceMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createFaceMessage:1 data:[@"tt00" dataUsingEncoding:NSUTF8StringEncoding]];
    [self sendMsg:msg type:@"头像"];
}

- (IBAction)sendOnlineMsg:(id)sender {
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createTextMessage:@"发送在线文本消息"];
    NSString *receiver = nil;
    NSString *groupID = nil;
    if ([self.conversationID containsString:@"@TGS"]) {
        groupID = self.conversationID;
    } else {
        receiver = self.conversationID;
    }
    [[V2TIMManager sharedInstance] sendMessage:msg receiver:receiver groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:YES offlinePushInfo:nil progress:^(uint32_t progress) {
        [self appendString:[NSString stringWithFormat:@"消息发送进度：progress:%u",progress]];
    } succ:^{
        [self appendString:[NSString stringWithFormat:@"给 %@ 发送在线文本消息成功",self.conversationID]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"给 %@ 发送在线文本消息失败,code：%d msg：%@",self.conversationID,code,msg]];
    }];
}

- (IBAction)getMessages:(id)sender {
    if ([self.conversationID containsString:@"@TGS"]) {
        [[V2TIMManager sharedInstance] getGroupHistoryMessageList:self.conversationID count:20 lastMsg:nil succ:^(NSArray<V2TIMMessage *> *msgs) {
            int index = 1;
            for (V2TIMMessage *msg in msgs) {
                [self appendString:[NSString stringWithFormat:@"拉取到第%d条漫游消息：%@",index,msg]];
                index++;
            }
        } fail:^(int code, NSString *msg) {
            [self appendString:@"拉取漫游消息失败"];
        }];
    } else {
        [[V2TIMManager sharedInstance] getC2CHistoryMessageList:self.conversationID count:20 lastMsg:nil succ:^(NSArray<V2TIMMessage *> *msgs) {
            int index = 1;
            for (V2TIMMessage *msg in msgs) {
                [self appendString:[NSString stringWithFormat:@"拉取到第%d条漫游消息：%@",index,msg]];
                index++;
            }
        } fail:^(int code, NSString *msg) {
            [self appendString:@"拉取漫游消息失败"];
        }];
    }
}

- (IBAction)revokeMsg:(id)sender {
    [[V2TIMManager sharedInstance] revokeMessage:_lastMsg succ:^{
        [self appendString:@"撤回消息成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:@"撤回消息失败"];
    }];
}

- (IBAction)deleteMsg:(id)sender {
    [[V2TIMManager sharedInstance] deleteMessageFromLocalStorage:_lastMsg succ:^{
        [self appendString:@"删除消息成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:@"删除消息失败"];
    }];
}

- (IBAction)setRead:(id)sender {
    if ([self.conversationID containsString:@"@TGS"]) {
        [[V2TIMManager sharedInstance] markGroupMessageAsRead:self.conversationID succ:^{
            [self appendString:@"设置已读成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"设置已读失败,code：%d msg：%@",code,msg]];
        }];
    } else {
        [[V2TIMManager sharedInstance] markC2CMessageAsRead:self.conversationID succ:^{
            [self appendString:@"设置已读成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"设置已读失败,code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)insertMsg:(id)sender {
    if ([self.conversationID containsString:@"@TGS"]) {
        V2TIMMessage *msg = [[V2TIMManager sharedInstance] createTextMessage:@"本地插入一条群消息"];
        [[V2TIMManager sharedInstance] insertGroupMessageToLocalStorage:msg to:self.conversationID sender:self.tologinUser succ:^{
            [self appendString:@"插入群消息成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"插入群消息失败,code：%d msg：%@",code,msg]];
        }];
    } else {
        V2TIMMessage *msg = [[V2TIMManager sharedInstance] createTextMessage:@"本地插入一条 C2C 消息"];
        [[V2TIMManager sharedInstance] insertC2CMessageToLocalStorage:msg to:self.conversationID sender:self.tologinUser succ:^{
            [self appendString:@"插入 C2C 消息成功"];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"插入 C2C 消息失败,code：%d msg：%@",code,msg]];
        }];
    }
}

- (IBAction)setApns:(id)sender {
    V2TIMAPNSConfig *config = [[V2TIMAPNSConfig alloc] init];
    config.businessID = sdkBusiId;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    config.token = delegate.deviceToken;
    [[V2TIMManager sharedInstance] setAPNS:config succ:^{
        [self appendString:@"设置推送成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置推送失败,code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getConversationList:(id)sender {
    [[V2TIMManager sharedInstance] getConversationList:0 count:20 succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        self.list = list;
        [self appendString:[NSString stringWithFormat:@"获取会话列表成功：lastTs:%llu,isFinished:%d,list:%@",lastTS,isFinished,list]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取会话列表失败,code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)getConversationByTs:(id)sender {
    [[V2TIMManager sharedInstance] getConversationList:self.lastTs count:1 succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        self.lastTs = lastTS;
        [self appendString:[NSString stringWithFormat:@"获取会话列表成功：lastTs:%llu,isFinished:%d,list:%@",lastTS,isFinished,list]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取会话列表失败,code：%d msg：%@",code,msg]];
    }];
}

- (IBAction)deleteConversation:(id)sender {
    [[V2TIMManager sharedInstance] deleteConversation:self.list[0].conversationID succ:^{
        [self appendString:@"删除会话成功"];
    } fail:^(int code, NSString *msg) {
        [self appendString:@"删除会话成功"];
    }];
}

- (IBAction)createGroup:(id)sender {
    NSString *groupName = self.groupName.placeholder;
    if (self.groupName.text.length > 0) {
        groupName = self.groupName.text;
    }
    NSString *groupType = self.groupType.placeholder;
    if (self.groupType.text.length > 0) {
        groupType = self.groupType.text;
    }
    [[V2TIMManager sharedInstance] createGroup:groupType groupID:nil groupName:groupName succ:^(NSString *groupID) {
        self.dismissGroupID.placeholder = groupID;
        [self appendString:[NSString stringWithFormat:@"创建群组成功，groupID:%@",groupID]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"创建群组失败，code：%d msg:%@",code,msg]];
    }];
}

- (IBAction)joinGroup:(id)sender {
    NSString *groupID = @"";
    if (self.joinGroupID.placeholder.length > 0) {
        groupID = self.joinGroupID.placeholder;
    }
    if (self.joinGroupID.text.length > 0) {
        groupID = self.joinGroupID.text;
    }
    [[V2TIMManager sharedInstance] joinGroup:groupID msg:@"请求加入群组" succ:^{
        self.quitGroupID.placeholder = groupID;
        [self appendString:[NSString stringWithFormat:@"加入群组成功，groupID:%@",groupID]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"加入群组失败，code：%d msg:%@",code,msg]];
    }];
}

- (IBAction)quitGroup:(id)sender {
    NSString *groupID = @"";
    if (self.quitGroupID.placeholder.length > 0) {
        groupID = self.quitGroupID.placeholder;
    }
    if (self.quitGroupID.text.length > 0) {
        groupID = self.quitGroupID.text;
    }
    [[V2TIMManager sharedInstance] quitGroup:groupID succ:^{
        [self appendString:[NSString stringWithFormat:@"退出群组成功，groupID:%@",groupID]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"退出群组失败，code：%d msg:%@",code,msg]];
    }];
}

- (IBAction)dismissGroup:(id)sender {
    [[V2TIMManager sharedInstance] dismissGroup:self.dismissGroupID.placeholder succ:^{
        [self appendString:[NSString stringWithFormat:@"解散群组成功，groupID:%@",self.dismissGroupID.text]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"解散群组失败，code：%d msg:%@",code,msg]];
    }];
}

- (IBAction)getUserProfile:(id)sender {
    [[V2TIMManager sharedInstance] getUsersInfo:@[self.tologinUser] succ:^(NSArray<V2TIMUserInfo *> *infoList) {
        [self appendString:[NSString stringWithFormat:@"获取用户资料成功，资料详情：%@",infoList[0]]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"获取用户信息失败，code：%d msg:%@",code,msg]];
    }];
}

- (IBAction)setSelfProfille:(id)sender {
    [[V2TIMManager sharedInstance] getUsersInfo:@[self.tologinUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *fullInfo = infoList[0];
        if (self.nickName.text.length > 0) {
            fullInfo.nickName = self.nickName.text;
        }
        if (self.faceUrl.text.length > 0) {
            fullInfo.faceURL = self.faceUrl.text;
        }
        if (self.selfSignature.text.length > 0) {
            fullInfo.selfSignature = self.selfSignature.text;
        }
        if (self.gender.text.length > 0) {
            fullInfo.gender = [self.gender.text intValue];
        }
        if (self.allowType.text.length > 0) {
            fullInfo.allowType = [self.allowType.text intValue];
        }
        if (self.customKey.text.length > 0 && self.customValue.text.length > 0) {
            fullInfo.customInfo = @{self.customKey.text : [self.customValue.text dataUsingEncoding:NSUTF8StringEncoding]};
        }
        [[V2TIMManager sharedInstance] setSelfInfo:fullInfo succ:^{
            [[V2TIMManager sharedInstance] getUsersInfo:@[self.tologinUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                [self appendString:[NSString stringWithFormat:@"设置个人资料成功，资料详情：%@",infoList[0]]];
            } fail:^(int code, NSString *msg) {
                [self appendString:[NSString stringWithFormat:@"设置个人资料失败，code：%d msg:%@",code,msg]];
            }];
        } fail:^(int code, NSString *msg) {
            [self appendString:[NSString stringWithFormat:@"设置个人资料失败，code：%d msg:%@",code,msg]];
        }];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"设置个人资料失败，code：%d msg:%@",code,msg]];
    }];
}

- (void)sendMsg:(V2TIMMessage *)msg type:(NSString *)type
{
    _lastMsg = msg;
    NSString *receiver = nil;
    NSString *groupID = nil;
    if ([self.conversationID containsString:@"@TGS"]) {
        groupID = self.conversationID;
    } else {
        receiver = self.conversationID;
    }
    V2TIMOfflinePushInfo *pushInfo = [[V2TIMOfflinePushInfo alloc] init];
    pushInfo.title = @"自定义推送 Title 展示";
    pushInfo.iOSSound = @"01.caf";
    NSString *msgID = [[V2TIMManager sharedInstance] sendMessage:msg receiver:receiver groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:pushInfo progress:^(uint32_t progress) {
        [self appendString:[NSString stringWithFormat:@"消息发送进度：progress:%u",progress]];
    } succ:^{
        [self appendString:[NSString stringWithFormat:@"给 %@ 发送消息成功",self.conversationID]];
    } fail:^(int code, NSString *msg) {
        [self appendString:[NSString stringWithFormat:@"给 %@ 发送消息失败,code：%d msg：%@",self.conversationID,code,msg]];
    }];
    [self appendString:[NSString stringWithFormat:@"发送消息返回 msgID 成功：%@",msgID]];
}

- (void)appendString:(NSString *)str
{
    self.eventInfo.text = [NSString stringWithFormat:@"%@\n%@",self.eventInfo.text,str];
    [self.eventInfo scrollRangeToVisible:NSMakeRange(self.eventInfo.text.length, 1)];
}

- (int)getDuration:(NSString *)path
{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    return seconds;
    return 0;
}

- (IBAction)invite:(id)sender {
    NSString *receiver = nil;
    NSString *groupID = nil;
    if ([self.conversationID containsString:@"@TGS"]) {
        groupID = self.conversationID;
    } else {
        receiver = self.conversationID;
    }
    NSString *inviteID = nil;
    if (groupID.length > 0) {
        inviteID = [[V2TIMManager sharedInstance] inviteInGroup:groupID inviteeList:@[@"vinson1",@"teacher2"] data:@"发起邀请" onlineUserOnly:NO timeout:30 succ:^{
            [self appendString:@"邀请成功"];
        } fail:^(int code, NSString *desc) {
            [self appendString:[NSString stringWithFormat:@"邀请失败,code：%d msg：%@",code,desc]];
        }];
    } else {
        inviteID = [[V2TIMManager sharedInstance] invite:receiver data:@"发起邀请" onlineUserOnly:NO offlinePushInfo:nil timeout:30 succ:^{
            [self appendString:@"邀请成功"];
        } fail:^(int code, NSString *desc) {
            [self appendString:[NSString stringWithFormat:@"邀请失败,code：%d msg：%@",code,desc]];
        }];
    }
    [self appendString:[NSString stringWithFormat:@"发起邀请，inviteID:%@",inviteID]];
    self.inviteID.text = inviteID;
}

- (IBAction)cancelInvite:(id)sender {
    [[V2TIMManager sharedInstance] cancel:self.inviteID.text data:@"取消邀请" succ:^{
        [self appendString:[NSString stringWithFormat:@"取消邀请，inviteID:%@",self.inviteID.text]];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"取消邀请失败,code：%d msg：%@",code,desc]];
    }];
    [self appendString:[NSString stringWithFormat:@"取消邀请，inviteID:%@",self.inviteID.text]];
}

- (IBAction)accept:(id)sender {
    [[V2TIMManager sharedInstance] accept:self.inviteID.text data:@"接受邀请" succ:^{
        [self appendString:@"接受邀请成功"];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"接受邀请失败,code：%d msg：%@",code,desc]];
    }];
    [self appendString:[NSString stringWithFormat:@"接受邀请，inviteID:%@",self.inviteID.text]];
}

- (IBAction)reject:(id)sender {
    [[V2TIMManager sharedInstance] reject:self.inviteID.text data:@"拒绝邀请" succ:^{
        [self appendString:@"拒绝邀请成功"];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"拒绝邀请失败,code：%d msg：%@",code,desc]];
    }];
    [self appendString:[NSString stringWithFormat:@"拒绝邀请，inviteID:%@",self.inviteID.text]];
}

- (IBAction)initAttribute:(id)sender {
    [[V2TIMManager sharedInstance] initGroupAttributes:self.conversationID attributes:@{self.attributeKey.text:self.attributeValue.text} succ:^{
        [self appendString:@"群属性初始化成功"];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"群属性初始化失败,code：%d msg：%@",code,desc]];
    }];
}

- (IBAction)setAttribute:(id)sender {
    [[V2TIMManager sharedInstance] setGroupAttributes:self.conversationID attributes:@{self.attributeKey.text:self.attributeValue.text} succ:^{
        [self appendString:@"群属性设置成功"];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"群属性设置失败,code：%d msg：%@",code,desc]];
    }];
}

- (IBAction)deleteAttribute:(id)sender {
    [[V2TIMManager sharedInstance] deleteGroupAttributes:self.conversationID keys:@[self.attributeKey.text] succ:^{
        [self appendString:@"群属性删除成功"];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"群属性删除失败,code：%d msg：%@",code,desc]];
    }];
}

- (IBAction)getAttribute:(id)sender {
    [[V2TIMManager sharedInstance] getGroupAttributes:self.conversationID keys:@[self.attributeKey.text] succ:^(NSMutableDictionary<NSString *,NSString *> *groupAttributeList) {
        [self appendString:[NSString stringWithFormat:@"群属性获取成功,groupAttributeList：%@",groupAttributeList]];
    } fail:^(int code, NSString *desc) {
        [self appendString:[NSString stringWithFormat:@"群属性获取失败,code：%d msg：%@",code,desc]];
    }];
}

#pragma mark V2TIMSDKListener

- (void)onConnecting
{
    [self appendString:@"网络连接中"];
}

- (void)onConnectSuccess
{
    [self appendString:@"网络连接成功"];
}

- (void)onConnectFailed:(int)code err:(NSString*)err
{
    [self appendString:[NSString stringWithFormat:@"网络连接失败，code：%d msg:%@",code,err]];
}

- (void)onKickedOffline
{
    [self appendString:@"被踢下线"];
}

- (void)onUserSigExpired
{
    [self appendString:@"票据过期"];
}

- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info
{
    [self appendString:[NSString stringWithFormat:@"个人资料更新: %@",Info]];
}

#pragma mark V2TIMSimpleMsgListener
- (void)onRecvC2CTextMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info text:(NSString *)text {
    [self appendString:[NSString stringWithFormat:@"收到一条文本消息 msgID：%@ sender：%@ text：%@ ",msgID,info,text]];
}

- (void)onRecvC2CCustomMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info customData:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"收到一条文本消息 msgID：%@ sender：%@ data：%@ ",msgID,info,data]];
}

- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text {
    [self appendString:[NSString stringWithFormat:@"收到一条文本消息 msgID:%@ groupID：%@ sender：%@ text：%@ ",msgID,groupID,info,text]];
}

- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"收到一条文本消息 msgID:%@ groupID：%@ sender：%@ data：%@ ",msgID,groupID,info,data]];
}

#pragma mark V2TIMGroupListener

// 有用户加入群（全员能够收到）
- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self appendString:[NSString stringWithFormat:@"有人加入群，groupID:%@ member:%@",groupID,memberList]];
}

// 有用户离开群（全员能够收到）已验证
- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    [self appendString:[NSString stringWithFormat:@"有人离开群，groupID:%@ member:%@",groupID,member]];
}

// 某些人被拉入某群（全员能够收到）已验证
- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self appendString:[NSString stringWithFormat:@"有人被拉入群，groupID:%@ opUser：%@ memberList:%@",groupID,opUser,memberList]];
}

// 某些人被踢出某群（全员能够收到）已验证
- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList {
    [self appendString:[NSString stringWithFormat:@"有人被踢出群，groupID:%@ opUser：%@ memberList:%@",groupID,opUser,memberList]];
}

// 创建群（主要用于多端同步）已验证
- (void)onNewGroupCreated:(NSString *)groupID {
    [self appendString:[NSString stringWithFormat:@"主动创建群组，groupID:%@",groupID]];
}

// 群被解散了（全员能收到）已验证
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self appendString:[NSString stringWithFormat:@"有群被解散，groupID:%@ opUser：%@",groupID,opUser]];
}

// 群被回收（全员能收到）
- (void)onGroupRecycled:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self appendString:[NSString stringWithFormat:@"有群被回收，groupID:%@ opUser：%@",groupID,opUser]];
}

// 有新的加群请求（只有群主和管理员会收到）已验证
- (void)onReceiveJoinApplication:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member opReason:(NSString *)opReason {
    [self appendString:[NSString stringWithFormat:@"有新的加群请求，groupID:%@ member：%@ opReason：%@",groupID,member,opReason]];
}

// 加群请求已经被群主或管理员处理了（只有申请人能够收到）已验证
- (void)onApplicationProcessed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser opResult:(BOOL)isAgreeJoin opReason:(NSString *)opReason {
    [self appendString:[NSString stringWithFormat:@"加群请求被处理，groupID:%@ opUser：%@ isAgreeJoin：%d opReason:%@",groupID,opUser,isAgreeJoin,opReason]];
}

// 群信息被修改（全员能收到）已验证
- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList {
    [self appendString:[NSString stringWithFormat:@"群信息被修改:%@:%@",groupID,changeInfoList]];
}

// 群属性被修改（全员能收到）
- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes {
    [self appendString:[NSString stringWithFormat:@"群属性变更：groupID:%@ attributes：%@",groupID,attributes]];
}

// 群成员信息被修改（全员能收到）已验证
- (void)onMemberInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupMemberChangeInfo *> *)changeInfoList {
    [self appendString:[NSString stringWithFormat:@"群成员信息被修改:%@:%@",groupID,changeInfoList]];
}

// 指定管理员身份
- (void)onGrantAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    [self appendString:[NSString stringWithFormat:@"有人被指定为管理员:%@ opUser：%@ memberList：%@",groupID,opUser,memberList]];
}

// 取消管理员身份
- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    [self appendString:[NSString stringWithFormat:@"有人被取消管理员:%@ opUser：%@ memberList：%@",groupID,opUser,memberList]];
}

// 主动退出群组（主要用于多端同步，直播群（AVChatRoom）不支持）已验证
- (void)onQuitFromGroup:(NSString *)groupID {
    [self appendString:[NSString stringWithFormat:@"主动退出群组，groupID:%@",groupID]];
}

//  收到 RESTAPI 下发的自定义系统消息
- (void)onReceiveRESTCustomData:(NSString *)groupID data:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"REST 下发自定义数据，groupID:%@ data:%@",groupID,data]];
}

#pragma mark V2TIMAPNSListener
- (uint32_t)onSetAPPUnreadCount
{
    [self appendString:@"收到自定义 APP 未读数通知"];
    return 100; // test
}

#pragma mark V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    [self appendString:[NSString stringWithFormat:@"收到一条消息：%@",msg]];
}

- (void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList {
    [self appendString:[NSString stringWithFormat:@"收到 C2C 已读回执：%@",receiptList]];
}

- (void)onRecvMessageRevoked:(NSString *)msgID
{
    [self appendString:[NSString stringWithFormat:@"收到消息撤回通知：%@",msgID]];
}

#pragma mark V2TIMConversationListener

- (void)onSyncServerStart
{
    [self appendString:@"同步服务器会话开始"];
}

- (void)onSyncServerFinish
{
    [self appendString:@"同步服务器会话结束"];
}

- (void)onSyncServerFailed
{
    [self appendString:@"同步服务器会话失败"];
}

- (void)onNewConversation:(NSArray<V2TIMConversation*> *) conversationList
{
    [self appendString:[NSString stringWithFormat:@"收到会话新增通知：%@",conversationList]];
}

- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList
{
    [self appendString:[NSString stringWithFormat:@"收到会话变更通知：%@",conversationList]];
}

- (void)onConversationDeleted:(NSArray<V2TIMConversation*> *)conversationList
{
    [self appendString:[NSString stringWithFormat:@"收到会话删除通知：%@",conversationList]];
}
#pragma V2TIMInviteListener
/// 收到邀请的回调
-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"收到邀请，inviteID：%@ inviter：%@ groupID：%@ inviteeList：%@ data:%@",inviteID,inviter,groupID,inviteeList,data]];
    self.inviteID.text = inviteID;
}

/// 被邀请者接受邀请
-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"有邀请被接受，inviteID：%@ invitee：%@ data:%@",inviteID,invitee,data]];
}

/// 被邀请者拒绝邀请
-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"有邀请被拒绝，inviteID：%@ invitee：%@ data:%@",inviteID,invitee,data]];
}

/// 邀请被取消
-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSData *)data {
    [self appendString:[NSString stringWithFormat:@"有邀请被取消，inviteID：%@ inviter：%@ data:%@",inviteID,inviter,data]];
}

/// 邀请超时
-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList {
    [self appendString:[NSString stringWithFormat:@"有邀请超时，inviteID：%@ inviteeList：%@",inviteID,inviteeList]];
}
@end
