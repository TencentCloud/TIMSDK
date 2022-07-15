//
//  TRTCCall+Signal.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TRTCCalling+Signal.h"
#import "TRTCCallingUtils.h"
#import "TRTCCallingHeader.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUILogin.h"
#import "CallingLocalized.h"
#import "TRTCSignalFactory.h"
#import "TUICallingConstants.h"

@implementation TRTCCalling (Signal)

- (void)addSignalListener {
    [[V2TIMManager sharedInstance] addSignalingListener:self];
    [[V2TIMManager sharedInstance] addSimpleMsgListener:self];
}

- (void)removeSignalListener {
    [[V2TIMManager sharedInstance] removeSignalingListener:self];
}

- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model cmdInfo:(NSString *)cmdInfo {
    return [self invite:receiver action:action model:model cmdInfo:cmdInfo userIds:nil];
}

- (NSString *)invite:(NSString *)receiver
              action:(CallAction)action
               model:(CallModel *)model
             cmdInfo:(NSString *)cmdInfo
             userIds:(NSArray<NSString *> *)userIds {
    TRTCLog(@"Calling - invite receiver:%@ action:%ld cmdInfo:%@", receiver, action, cmdInfo);
    NSString *callID = @"";
    CallModel *realModel = [self generateModel:action];
    BOOL isGroup = [self.curGroupID isEqualToString:receiver];
    
    if (model) {
        realModel = [model copy];
        realModel.action = action;
        if (model.groupid.length > 0) {
            isGroup = YES;
        }
    }
    
    /// 邀请 ID, 说明：不存在GroupID 组通话，分成多个C to C, 在Map中存储userID 和inviteID 关系。 GroupID组 和 单个 C to C 通话，inviteID 从Model中取。
    NSString *inviteID = [self getCallIDWithUserID:receiver] ?: realModel.callid;
    
    switch (realModel.action) {
        case CallAction_Call: {
            NSString *cmd = @"";
            switch (realModel.calltype) {
                case CallType_Video:
                    cmd = SIGNALING_CMD_VIDEOCALL;
                    break;
                case CallType_Audio:
                    cmd = SIGNALING_CMD_AUDIOCALL;
                    break;
                default:
                    break;
            }
            
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:cmd
                                                                                    cmdInfo:@""
                                                                                    userIds:userIds ?: @[]
                                                                                    message:@""
                                                                                   callType:realModel.calltype];
            [dataDic setValue:@(realModel.roomid) forKey:SIGNALING_EXTRA_KEY_ROOM_ID];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            
            if (isGroup) {
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid
                                                          inviteeList:realModel.invitedList
                                                                 data:data
                                                       onlineUserOnly:self.onlineUserOnly
                                                              timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:^{
                    TRTCLog(@"Calling - CallAction_Call inviteInGroup success");
                    @strongify(self)
                    // 发起 Apns 推送,群组的邀请，需要单独对每个被邀请人发起推送
                    for (NSString *invitee in realModel.invitedList) {
                        [self sendAPNsForCall:invitee
                                  inviteeList:realModel.invitedList
                                       callID:self.callID
                                      groupid:realModel.groupid
                                       roomid:realModel.roomid];
                    }
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"Calling - CallAction_Call inviteInGroup failed, code: %d desc: %@", code, desc);
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            } else {
                @weakify(self)
                V2TIMOfflinePushInfo *info = [self getOfflinePushInfoWithInviteeList:realModel.invitedList
                                                                              callID:nil groupid:nil
                                                                              roomid:realModel.roomid];
                callID = [[V2TIMManager sharedInstance] invite:receiver data:data
                                                onlineUserOnly:self.onlineUserOnly
                                               offlinePushInfo:info
                                                       timeout:SIGNALING_EXTRA_KEY_TIME_OUT
                                                          succ:^{
                    TRTCLog(@"Calling - CallAction_Call invite success");
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"Calling - CallAction_Call invite failed, code: %d desc: %@", code, desc);
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            }
        } break;
            
        case CallAction_Accept: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:@""
                                                                                    cmdInfo:@""
                                                                                    message:@""
                                                                                   callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            
            @weakify(self)
            [[V2TIMManager sharedInstance] accept:inviteID data:data succ:^{
                TRTCLog(@"Calling - CallAction_Accept accept success");
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"Calling - CallAction_Accept accept failed, code: %d desc: %@", code, desc);
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        } break;
            
        case CallAction_Reject: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:@""
                                                                                    cmdInfo:@""
                                                                                    message:@""
                                                                                   callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] reject:inviteID data:data succ:^{
                TRTCLog(@"Calling - CallAction_Reject reject success");
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"Calling - CallAction_Reject reject failed, code: %d desc: %@", code, desc);
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        } break;
            
        case CallAction_Linebusy: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:@""
                                                                                    cmdInfo:@""
                                                                                    message:SIGNALING_MESSAGE_LINEBUSY
                                                                                   callType:realModel.calltype];
            [dataDic setValue:SIGNALING_EXTRA_KEY_LINE_BUSY forKey:SIGNALING_EXTRA_KEY_LINE_BUSY];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            
            @weakify(self)
            [[V2TIMManager sharedInstance] reject:inviteID data:data succ:^{
                TRTCLog(@"Calling - CallAction_Linebusy reject success");
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"Calling - CallAction_Linebusy reject failed, code: %d desc: %@", code, desc);
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        } break;
            
        case CallAction_Cancel: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:@""
                                                                                    cmdInfo:@""
                                                                                    message:@""
                                                                                   callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            
            @weakify(self)
            [[V2TIMManager sharedInstance] cancel:inviteID data:data succ:^{
                TRTCLog(@"Calling - CallAction_Cancel cancel success");
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"Calling - CallAction_Cancel cancel failed, code: %d desc: %@", code, desc);
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        } break;
            
        case CallAction_End: {
            if (isGroup) {
                // 群通话不需要计算通话时长
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                         roomID:realModel.roomid
                                                                                            cmd:SIGNALING_CMD_HANGUP
                                                                                        cmdInfo:@"0"
                                                                                        message:@""
                                                                                       callType:realModel.calltype];
                [dataDic setValue:@(0) forKey:SIGNALING_EXTRA_KEY_CALL_END];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                // 这里发结束事件的时候，inviteeList 已经为 nil 了，可以伪造一个被邀请用户，把结束的信令发到群里展示。
                // timeout 这里传 0，结束的事件不需要做超时检测
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid
                                                          inviteeList:@[@"inviteeList"]
                                                                 data:data
                                                       onlineUserOnly:self.onlineUserOnly
                                                              timeout:0
                                                                 succ:^{
                    TRTCLog(@"Calling - CallAction_End inviteInGroup success");
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"Calling - CallAction_End inviteInGroup failed, code: %d desc: %@", code, desc);
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
            } else {
                NSDate *now = [NSDate date];
                NSString *cmdInfo = [NSString stringWithFormat:@"%llu", (UInt64)[now timeIntervalSince1970] - self.startCallTS];
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                         roomID:realModel.roomid
                                                                                            cmd:SIGNALING_CMD_HANGUP
                                                                                        cmdInfo:cmdInfo
                                                                                        message:@""
                                                                                       callType:realModel.calltype];
                [dataDic setValue:@((UInt64)[now timeIntervalSince1970] - self.startCallTS) forKey:SIGNALING_EXTRA_KEY_CALL_END];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] invite:receiver
                                                          data:data
                                                onlineUserOnly:self.onlineUserOnly
                                               offlinePushInfo:nil
                                                       timeout:0
                                                          succ:^{
                    TRTCLog(@"Calling - CallAction_End invite success");
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"Calling - CallAction_End invite failed, code: %d desc: %@", code, desc);
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.startCallTS = 0;
            }
        } break;
            
        case CallAction_SwitchToAudio: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                     roomID:realModel.roomid
                                                                                        cmd:SIGNALING_CMD_SWITCHTOVOICECALL
                                                                                    cmdInfo:@""
                                                                                    message:@""
                                                                                   callType:realModel.calltype];
            [dataDic setValue:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] invite:receiver
                                             data:data
                                   onlineUserOnly:self.onlineUserOnly
                                  offlinePushInfo:nil
                                          timeout:SIGNALING_EXTRA_KEY_TIME_OUT
                                             succ:^{
                TRTCLog(@"Calling - CallAction_SwitchToAudio invite success");
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"Calling - CallAction_SwitchToAudio invite failed, code: %d desc: %@", code, desc);
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        } break;
            
        default:
            break;
    }
    
    if (realModel.action != CallAction_Reject &&
        realModel.action != CallAction_Accept &&
        realModel.action != CallAction_End &&
        realModel.action != CallAction_Cancel &&
        realModel.action != CallAction_SwitchToAudio &&
        realModel.action != CallAction_AcceptSwitchToAudio &&
        realModel.action != CallAction_RejectSwitchToAudio &&
        model == nil) {
        self.curLastModel = [realModel copy];
    }
    return callID;
}

- (void)sendAPNsForCall:(NSString *)receiver
            inviteeList:(NSArray *)inviteeList
                 callID:(NSString *)callID
                groupid:(NSString *)groupid
                 roomid:(UInt32)roomid {
    TRTCLog(@"Calling - sendAPNsForCall receiver:%@ inviteeList:%@ groupid:%@ roomid:%d", receiver, inviteeList, groupid, roomid);
    if (callID.length == 0 || inviteeList.count == 0 || roomid == 0) {
        TRTCLog(@"sendAPNsForCall failed");
        return;
    }
    V2TIMOfflinePushInfo *info = [self getOfflinePushInfoWithInviteeList:inviteeList
                                                                  callID:callID
                                                                 groupid:groupid
                                                                  roomid:roomid];
    NSData *customMessage = [TRTCCallingUtils dictionary2JsonData:@{@"version" : @(Version) , @"businessID" : SIGNALING_BUSINESSID}];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:customMessage];
    // 针对每个被邀请成员单独邀请
    [[V2TIMManager sharedInstance] sendMessage:msg
                                      receiver:receiver
                                       groupID:nil
                                      priority:V2TIM_PRIORITY_HIGH
                                onlineUserOnly:YES
                               offlinePushInfo:info
                                      progress:nil
                                          succ:nil
                                          fail:nil];
}

- (V2TIMOfflinePushInfo *)getOfflinePushInfoWithInviteeList:(NSArray *)inviteeList
                                                     callID:(NSString *)callID
                                                    groupid:(NSString *)groupid
                                                     roomid:(UInt32)roomid{
    int chatType; //单聊：1 群聊：2
    
    if (groupid.length > 0) {
        chatType = 2;
    } else {
        chatType = 1;
        groupid = @"";
    }
    /**
     {"entity":{"version":1,"content":"{\"action\":1,\"call_type\":2,\"room_id\":804544637,\"call_id\":\"144115224095613335-1595234230-3304653590\",\"timeout\":30,\"version\":4,\"invited_list\":[\"2019\"],\"group_id\":\"@TGS#1PWYXLTGA\"}","sendTime":1595234231,"sender":"10457","chatType":2,"action":2}}
     */
    NSDictionary *contentParam = @{@"action":@(SignalingActionType_Invite),
                                   @"call_id":callID ?: @"",
                                   @"call_type":@(self.curType),
                                   @"invited_list":inviteeList.count > 0 ? inviteeList : @[],
                                   @"room_id":@(roomid),
                                   @"group_id":groupid,
                                   @"timeout":@(SIGNALING_EXTRA_KEY_TIME_OUT),
                                   @"version":@(Version)};             // TUIkit 业务版本
    NSDictionary *entityParam = @{@"action" : @(APNs_Business_Call),   // 音视频业务逻辑推送
                                  @"chatType" : @(chatType),
                                  @"content" : [TRTCCallingUtils dictionary2JsonStr:contentParam],
                                  @"sendTime" : @((UInt32)[[V2TIMManager sharedInstance] getServerTime]),
                                  @"sender" : TUILogin.getUserID ?: @"",
                                  @"version" : @(APNs_Version)};       // 推送版本
    NSDictionary *extParam = @{@"entity" : entityParam};
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    info.desc = TUICallingLocalize(@"Demo.TRTC.calling.callingrequest");
    info.ext = [TRTCCallingUtils dictionary2JsonStr:extParam];
    info.iOSSound = @"phone_ringing.mp3";
    return info;
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    if (signalingInfo.inviteID.length > 0 &&
        signalingInfo.inviter.length > 0 &&
        signalingInfo.inviteeList.count > 0 &&
        signalingInfo.groupID.length > 0) {
        [[V2TIMManager sharedInstance] addInvitedSignaling:signalingInfo succ:^{
            [self onReceiveNewInvitation:signalingInfo.inviteID
                                 inviter:signalingInfo.inviter
                                 groupID:signalingInfo.groupID
                             inviteeList:signalingInfo.inviteeList
                                    data:signalingInfo.data];
        } fail:^(int code, NSString *desc) {
            TRTCLog(@"Calling - onReceiveAPNsForGroupCall failed,code:%d desc:%@",code,desc);
        }];
    }
}

#pragma mark - V2TIMSignalingListener

/// 收到邀请 - 回调
- (void)onReceiveNewInvitation:(NSString *)inviteID
                       inviter:(NSString *)inviter
                       groupID:(NSString *)groupID
                   inviteeList:(NSArray<NSString *> *)inviteeList
                          data:(NSString *)data {
    TRTCLog(@"Calling - onReceiveNewInvitation inviteID:%@ inviter:%@ inviteeList:%@ data:%@", inviteID, inviter, inviteeList, data);
    NSDictionary *param = [self check:data];
    
    if (param) {
        self.isBeingCalled = YES;
        NSString *cmdInfoStr = @"";
        NSArray *userIds = nil;
        
        if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_DATA]) {
            NSDictionary *data = param[SIGNALING_EXTRA_KEY_DATA];
            if ([data.allKeys containsObject:SIGNALING_EXTRA_KEY_CMDINFO]) {
                cmdInfoStr = data[SIGNALING_EXTRA_KEY_CMDINFO];
            }
            if ([data.allKeys containsObject:SIGNALING_EXTRA_KEY_USERIDS]) {
                userIds = data[SIGNALING_EXTRA_KEY_USERIDS];
            }
        }
        
        NSDictionary *data = [TRTCSignalFactory getDataDictionary:param];
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.groupid = groupID;
        model.inviter = inviter;
        model.invitedList = [NSMutableArray arrayWithArray:inviteeList];
        model.calltype = [TRTCSignalFactory convertCmdToCallType:data[SIGNALING_EXTRA_KEY_CMD]];
        model.roomid = [data[SIGNALING_EXTRA_KEY_ROOMID] intValue];
        
        if ([data[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL]) {
            /// 多端登录，A1和A2同时登录账号A，A1呼叫B，B接听，B点击切换语音按钮，A2需要过滤掉A1的「邀请信令」
            /// 过滤条件：当前不在通话流程中， 收到被邀请者的点击切换按钮的「邀请信令」，不做处理。
            if (!self.isOnCalling) {
                return;
            }
            
            model.action = CallAction_SwitchToAudio;
            self.switchToAudioCallID = inviteID;
        } else {
            /// 多端登录，A1和A2同时登录账号A，账号A1呼叫账号B 或者 A1点击切换语音，过滤掉A2收到的自己的邀请信令
            if ([self checkLoginUserIsEqualTo:inviter]) {
                return;
            }
            
            self.currentCallingUserID = inviter;
            model.action = CallAction_Call;
        }
        
        [self handleCallModel:inviter model:model message:cmdInfoStr userIds:userIds];
    }
}

/// 邀请被取消 -  回调
- (void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    TRTCLog(@"Calling - onInvitationCancelled inviteID:%@ inviter:%@ data:%@", inviteID, inviter, data);
    /// 多端登录，A1和A2同时登录账号A，账号A呼叫账号B ，账号A取消通话，过滤掉A1和A2自己收到的此信令
    if ([self checkLoginUserIsEqualTo:inviter]) {
        return;
    }
    
    NSDictionary *param = [self check:data];
    if (!(param && [param isKindOfClass:[NSDictionary class]])) {
        return;
    }
    
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    model.action = CallAction_Cancel;
    [self handleCallModel:inviter model:model message:@""];
}

/// 邀请者接受邀请 -  回调
- (void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    TRTCLog(@"Calling - onInviteeAccepted inviteID:%@ invitee:%@ data:%@", inviteID, invitee, data);
    /// 多端登录，A1和A2同时登录账号A，A1呼叫B，B接听，A2 需要过滤掉B「接受邀请信令」
    /// 过滤条件：当前不在通话流程中， 收到邀请者接受邀请，不做处理。
    if (!self.isOnCalling) {
        return;
    }
    
    NSDictionary *param = [self check:data];
    if (!(param && [param isKindOfClass:[NSDictionary class]])) {
        return;
    }
    
    [TRTCCloud sharedInstance].delegate = self;
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    NSDictionary *paramData = [TRTCSignalFactory getDataDictionary:param];
    
    if ([paramData[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL]) {
        model.action = CallAction_AcceptSwitchToAudio;
    } else {
        /// 多端登录，A1和A2同时登录账号A，账号B呼叫账号A ，A1接听正常处理，A2需要退出界面
        if (!self.isProcessedBySelf && [self checkLoginUserIsEqualTo:invitee]) {
            [self exitRoom];
            return;
        }
        model.action = CallAction_Accept;
    }
    
    [self handleCallModel:invitee model:model message:@""];
}

/// 被邀请者拒绝邀请  -  回调
- (void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    TRTCLog(@"Calling - onInviteeRejected inviteID:%@ invitee:%@ data:%@", inviteID, invitee, data);
    /// 多端登录，A1和A2同时登录账号A，A1呼叫B，B拒绝接听，A2 需要过滤掉B「拒绝邀请信令」
    /// 过滤条件：当前不在通话流程中， 收到被邀请者拒绝邀请信令，不做处理。
    if (!self.isOnCalling) {
        return;
    }
    
    NSDictionary *param = [self check:data];
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    NSDictionary *dataDic = [TRTCSignalFactory getDataDictionary:param];
    
    if ([dataDic[SIGNALING_EXTRA_KEY_MESSAGE] isEqualToString:SIGNALING_MESSAGE_LINEBUSY]) {
        model.action = CallAction_Linebusy;
    } else if ([dataDic[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL]) {
        model.action = CallAction_AcceptSwitchToAudio;
    } else {
        /// 多端登录，A1和A2同时登录账号A，账号B呼叫账号A ，A1拒接通话，A2退出界面
        if (!self.isProcessedBySelf && [self checkLoginUserIsEqualTo:invitee]) {
            [self exitRoom];
            return;
        }
        model.action = CallAction_Reject;
    }
    [self handleCallModel:invitee model:model message:@"Other status error"];
}

/// 邀请超时 -  回调
- (void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)invitedList {
    TRTCLog(@"Calling - onInvitationTimeout inviteID:%@ invitedList:%@", inviteID, invitedList);
    /// 多端登录，A1和A2同时登录账号A，A1呼叫B，B未接听，A2 需要过滤掉B「超时信令」
    /// 过滤条件：当前不在通话流程中， 收到被邀请者拒绝邀请信令，不做处理。
    if (!self.isOnCalling) {
        return;
    }
    
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    model.invitedList = [NSMutableArray arrayWithArray:invitedList];
    model.action = CallAction_Timeout;
    [self handleCallModel:[invitedList firstObject] model:model message:@"Timeout"];
}

- (NSDictionary *)check:(NSString *)data {
    NSDictionary *signalingDictionary = [TRTCCallingUtils jsonSring2Dictionary:data];
    
    if(!signalingDictionary[SIGNALING_EXTRA_KEY_PLATFORM] || !signalingDictionary[SIGNALING_EXTRA_KEY_DATA]) {
        signalingDictionary = [TRTCSignalFactory convertOldSignalingToNewSignaling:signalingDictionary];
    }
    
    if (!signalingDictionary[SIGNALING_EXTRA_KEY_BUSINESSID] ||
        ![signalingDictionary[SIGNALING_EXTRA_KEY_BUSINESSID] isKindOfClass:[NSString class]] ||
        ![signalingDictionary[SIGNALING_EXTRA_KEY_BUSINESSID] isEqualToString:SIGNALING_BUSINESSID]) {
        return nil;
    }
    
    NSInteger version = [signalingDictionary[SIGNALING_EXTRA_KEY_VERSION] integerValue];
    if (version > Version) {
        return nil;
    }
    
    NSDictionary *dataDictionary = [TRTCSignalFactory getDataDictionary:signalingDictionary];
    if (dataDictionary[SIGNALING_EXTRA_KEY_CMD] &&
        [dataDictionary[SIGNALING_EXTRA_KEY_CMD] isKindOfClass:[NSString class]] &&
        [dataDictionary[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_HANGUP]) {
        // 结束的事件只用于 UI 展示通话时长，不参与业务逻辑的处理
        return nil;
    }
    return signalingDictionary;
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model message:(NSString *)message {
    [self handleCallModel:user model:model message:message userIds:nil];
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model message:(NSString *)message userIds:(NSArray *)userIds {
    TRTCLog(@"Calling - handleCallModel user:%@ model:%@ message:%@ userIds:%@", user, model, message, userIds);
    BOOL checkCallID = [self.curCallID isEqualToString:model.callid] || [[self getCallIDWithUserID:user] isEqualToString:model.callid];
    
    switch (model.action) {
        case CallAction_Call: {
            [self sendInviteAction:CallAction_Call user:user model:model];
            
            void(^syncInvitingList)(void) = ^(){
                for (NSString *invitee in model.invitedList) {
                    if (![self.curInvitingList containsObject:invitee]) {
                        [self.curInvitingList addObject:invitee];
                    }
                }
            };
            
            if (model.groupid != nil && ![model.invitedList containsObject:TUILogin.getUserID]
                ) { // 群聊但是邀请不包含自己不处理
                if ([self.curCallID isEqualToString:model.callid]) { // 在房间中更新列表
                    syncInvitingList();
                    if (self.curInvitingList.count > 0) {
                        if ([self canDelegateRespondMethod:@selector(onGroupCallInviteeListUpdate:)]) {
                            [self.delegate onGroupCallInviteeListUpdate:self.curInvitingList];
                        }
                    }
                }
                return;
            }
            
            if (self.isOnCalling) { // tell busy
                if (!checkCallID) {
                    BOOL isGroup = (model.groupid && model.groupid > 0);
                    [self invite:isGroup ? model.groupid : user action:CallAction_Linebusy model:model cmdInfo:nil];
                }
            } else {
                self.isOnCalling = true;
                self.curCallID = model.callid;
                self.curRoomID = model.roomid;
                if (model.groupid.length > 0) {
                    self.curGroupID = model.groupid;
                }
                self.curType = model.calltype;
                self.curSponsorForMe = user;
                syncInvitingList();
                
                if ([self canDelegateRespondMethod:@selector(onInvited:userIds:isFromGroup:callType:)]) {
                    NSMutableArray *userIdAry = model.invitedList;
                    [userIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![userIdAry containsObject:obj]) {
                            [userIdAry addObject:obj];
                        }
                    }];
                    
                    [self.delegate onInvited:user userIds:userIdAry isFromGroup:self.curGroupID.length > 0 ? YES : NO callType:model.calltype];
                }
            }
        } break;
            
        case CallAction_Cancel: {
            [self sendInviteAction:CallAction_Cancel user:user model:model];
            
            if (checkCallID && self.delegate) {
                [self preExitRoom];
                self.isOnCalling = NO;
                [self.delegate onCallingCancel:user];
            }
        } break;
            
        case CallAction_Reject: {
            [self sendInviteAction:CallAction_Reject user:user model:model];
            
            if (checkCallID && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                if ([self canDelegateRespondMethod:@selector(onReject:)]) {
                    [self.delegate onReject:user];
                }
                [self preExitRoom];
            }
        } break;
            
        case CallAction_Timeout: {
            [self sendInviteAction:CallAction_Timeout user:user model:model];
            
            if (checkCallID && self.delegate) {
                // 这里需要判断下是否是自己超时了，自己超时，直接退出界面
                if ([model.invitedList containsObject:TUILogin.getUserID] && self.delegate) {
                    self.isOnCalling = false;
                    if ([self canDelegateRespondMethod:@selector(onCallingTimeOut)]) {
                        [self.delegate onCallingTimeOut];
                    }
                } else {
                    for (NSString *userID in model.invitedList) {
                        if ([self canDelegateRespondMethod:@selector(onNoResp:)]) {
                            [self.delegate onNoResp:userID];
                        }
                        if ([self.curInvitingList containsObject:userID]) {
                            [self.curInvitingList removeObject:userID];
                        }
                    }
                }
                // 每次超时都需要判断当前是否需要结束通话
                [self preExitRoom];
            }
        } break;
            
        case CallAction_Linebusy: {
            TRTCLog(@"Calling - CallAction_Linebusy_out user:%@ userIds:%@ curCallID:%@ model: %@", user, userIds, self.curCallID, model);
            [self sendInviteAction:CallAction_Linebusy user:user model:model];
            
            if (checkCallID && self.delegate) {
                TRTCLog(@"Calling - CallAction_Linebusy_in user:%@ userIds:%@", user, userIds);
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                [self.delegate onLineBusy:user];
                [self preExitRoom];
            }
        } break;
            
        case CallAction_Error: {
            [self sendInviteAction:CallAction_Error user:user model:model];
            
            if (checkCallID && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                [self.delegate onError:-1 msg:TUICallingLocalize(@"Demo.TRTC.calling.syserror")];
                [self preExitRoom];
            }
        } break;
            
        case CallAction_SwitchToAudio: {
            if (!self.switchToAudioCallID) {
                break;
            }
            int res = [self checkAudioStatus];
            if (res == 0) {
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                         roomID:0
                                                                                            cmd:SIGNALING_CMD_SWITCHTOVOICECALL
                                                                                        cmdInfo:@""
                                                                                        message:@""
                                                                                       callType:CallType_Video];
                [dataDic setValue:@(1) forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                @weakify(self)
                [[V2TIMManager sharedInstance] accept:self.switchToAudioCallID data:data succ:^{
                    TRTCLog(@"res==0 - accept success");
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                        [self.delegate onSwitchToAudio:YES message:@""];
                    }
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"res==0 - accept failed, code: %d desc: %@",code,desc);
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                        [self.delegate onSwitchToAudio:NO message:desc];
                    }
                }];
            } else {
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                         roomID:0
                                                                                            cmd:@""
                                                                                        cmdInfo:@""
                                                                                        message:@""
                                                                                       callType:CallType_Video];
                [dataDic setValue:@(0) forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                [[V2TIMManager sharedInstance] reject:self.switchToAudioCallID data:data succ:^{
                    TRTCLog(@"res!=0 - reject success");
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"res!=0 - reject failed, code: %d desc: %@",code,desc);
                }];
                if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                    [self.delegate onSwitchToAudio:NO message:@"Local status error"];
                }
            }
        } break;
            
        case CallAction_AcceptSwitchToAudio: {
            if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                [self.delegate onSwitchToAudio:YES message:@""];
            }
        } break;
            
        case CallAction_RejectSwitchToAudio: {
            if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                [self.delegate onSwitchToAudio:NO message:message];
            }
        } break;
            
        default: {
            TRTCLog(@"Default CallAction");
        } break;
    }
}

#pragma mark - V2TIMSimpleMsgListener

/// 收到 C2C 自定义（信令）消息
- (void)onRecvC2CCustomMessage:(NSString *)msgID  sender:(V2TIMUserInfo *)info customData:(NSData *)data {
    TRTCLog(@"Calling - onRecvC2CCustomMessage inviteID:%@ inviter:%@", msgID, data);
    if (!self.isBeingCalled) return;
    
    NSDictionary *param = [self check:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *dataDic;
    NSString *cmdStr;
    
    if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_DATA] ) {
        dataDic = param[SIGNALING_EXTRA_KEY_DATA];
        
        if ([dataDic.allKeys containsObject:SIGNALING_EXTRA_KEY_CMD]) {
            cmdStr = dataDic[SIGNALING_EXTRA_KEY_CMD];
        }
    }
    
    if (![cmdStr isEqualToString:@"sync_info"]) return;
    
    CallModel *model = [[CallModel alloc] init];
    model.callid = param[SIGNALING_CUSTOM_CALLID];
    model.inviter = param[SIGNALING_CUSTOM_USER];
    model.action =  [param[SIGNALING_CUSTOM_CALL_ACTION] integerValue];
    model.roomid = [dataDic[SIGNALING_EXTRA_KEY_ROOMID] intValue];
    
    if (model.inviter && model.action == CallAction_Timeout) {
        model.invitedList = [@[model.inviter] mutableCopy];
    }
    
    [self handleCallModel:model.inviter model:model message:@"" userIds:nil];
}

#pragma mark - Utils

- (CallModel *)generateModel:(CallAction)action {
    CallModel *model = [self.curLastModel copy];
    model.action = action;
    return model;
}

- (void)preExitRoom {
    [self preExitRoom:nil];
}

- (void)preExitRoom:(NSString *)leaveUser {
    if (!self.isInRoom && self.curInvitingList.count == 0) {
        [self exitRoom];
        return;
    }
    
    // 当前房间中存在成员，不能自动退房
    if (self.curRoomList.count > 0) return;
    
    if (self.curGroupID.length > 0) {
        // IM 多人通话逻辑
        if (self.curInvitingList.count == 0) {
            if (leaveUser) {
                [self invite:@"" action:CallAction_End model:nil cmdInfo:nil];
            }
            [self exitRoom];
        }
        return;
    }
    
    // C2C多人通话 和 单人通话 逻辑
    if (self.curInvitingList.count >= 1) {
        return;
    }
    if (leaveUser) {
        [self invite:leaveUser action:CallAction_End model:nil cmdInfo:nil];
    }
    [self exitRoom];
}

- (void)exitRoom {
    TRTCLog(@"Calling - autoHangUp");
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
    [self quitRoom];
    self.isOnCalling = NO;
}

#pragma mark - private method
/// 检查当前登录用户是否是邀请者/被邀请者
- (BOOL)checkLoginUserIsEqualTo:(NSString *)inviteUser {
    if (inviteUser && [inviteUser isKindOfClass:NSString.class] && inviteUser.length > 0 && [inviteUser isEqualToString:TUILogin.getUserID]) {
        return YES;
    }
    return NO;
}

- (void)sendInviteAction:(CallAction)action user:(NSString *)user model:(CallModel *)model {
    BOOL isGroupidCall = (model.groupid && model.groupid > 0);
    
    if (self.isBeingCalled || isGroupidCall || [user isEqualToString:TUILogin.getUserID]) {
        return;
    }
    
    @weakify(self)
    [self.calleeUserIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull calleeUserID, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![calleeUserID isEqualToString:user]) {
            @strongify(self)
            
            NSString *callid = [self getCallIDWithUserID:calleeUserID];
            
            if (callid && callid.length  > 0) {
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@""
                                                                                         roomID:model.roomid
                                                                                            cmd:@"sync_info"
                                                                                        cmdInfo:@""
                                                                                        message:@""
                                                                                       callType:model.calltype];
                [dataDic setValue:@(action) forKey:SIGNALING_CUSTOM_CALL_ACTION];
                [dataDic setValue:callid forKey:SIGNALING_CUSTOM_CALLID];
                [dataDic setValue:user ?: @"" forKey:SIGNALING_CUSTOM_USER];
                [[V2TIMManager sharedInstance] sendC2CCustomMessage:[TRTCCallingUtils dictionary2JsonData:dataDic] to:calleeUserID succ:^{
                    TRTCLog(@"Calling - sendC2CCustomMessage success %@ %@", dataDic, calleeUserID);
                } fail:^(int code, NSString *desc) {
                    TRTCLog(@"Calling - sendC2CCustomMessage failed, code: %d desc: %@", code, desc);
                }];
            } else {
                TRTCLog(@"Calling - sendInviteAction callid error");
            }
        }
    }];
}

- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

- (NSString * _Nullable)getCallIDWithUserID:(NSString *)userID {
    NSString *callID;
    
    if (userID && [userID isKindOfClass:NSString.class] && userID.length > 0) {
        callID = self.curCallIdDic[userID];
    }
    
    if ([callID isKindOfClass:NSString.class]) {
        return callID;
    }
    
    return nil;
}

@end
