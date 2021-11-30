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
#import "CallingLocalized.h"
#import "TRTCSignalFactory.h"

@implementation TRTCCalling (Signal)

- (void)addSignalListener {
    [[V2TIMManager sharedInstance] addSignalingListener:self];
}

- (void)removeSignalListener {
    [[V2TIMManager sharedInstance] removeSignalingListener:self];
}

- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model cmdInfo:(NSString *)cmdInfo {
    return [self invite:receiver action:action model:model cmdInfo:cmdInfo userIds:nil];
}

- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model cmdInfo:(NSString *)cmdInfo userIds:(NSArray<NSString *> *)userIds {
    NSString *callID = @"";
    
    
    if (receiver.length <= 0) {
        return callID;
    }
    CallModel *realModel = [self generateModel:action];
    BOOL isGroup = [self.curGroupID isEqualToString:receiver];
    if (model) {
        realModel = [model copy];
        realModel.action = action;
        if (model.groupid.length > 0) {
            isGroup = YES;
        }
    }
    switch (realModel.action) {
        case CallAction_Call:
        {
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
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:cmd cmdInfo:@"" userIds:userIds ?: @[] message:@"" callType:realModel.calltype];
            [dataDic setValue:@(realModel.roomid) forKey:SIGNALING_EXTRA_KEY_ROOM_ID];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            
            if (isGroup) {
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid inviteeList:realModel.invitedList data:data onlineUserOnly:self.onlineUserOnly timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:^{
                    @strongify(self)
                    // 发起 Apns 推送,群组的邀请，需要单独对每个被邀请人发起推送
                    for (NSString *invitee in realModel.invitedList) {
                        [self sendAPNsForCall:invitee inviteeList:realModel.invitedList callID:self.callID  groupid:realModel.groupid roomid:realModel.roomid];
                    }
                } fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            } else {
                @weakify(self)
                V2TIMOfflinePushInfo *info = [self getOfflinePushInfoWithInviteeList:realModel.invitedList callID:nil groupid:nil roomid:realModel.roomid];
                callID = [[V2TIMManager sharedInstance] invite:receiver data:data onlineUserOnly:self.onlineUserOnly offlinePushInfo:info timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:^{
                } fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            }
        }
            break;
            
        case CallAction_Accept:
        {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:@"" cmdInfo:@"" message:@"" callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] accept:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
            
        case CallAction_Reject:
        {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:@"" cmdInfo:@"" message:@"" callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] reject:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
            
        case CallAction_Linebusy:
        {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:@"" cmdInfo:@"" message:SIGNALING_MESSAGE_LINEBUSY callType:realModel.calltype];
            [dataDic setValue:SIGNALING_EXTRA_KEY_LINE_BUSY forKey:SIGNALING_EXTRA_KEY_LINE_BUSY];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] reject:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
            
        case CallAction_Cancel:
        {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:@"" cmdInfo:@"" message:@"" callType:realModel.calltype];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] cancel:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                @strongify(self)
                if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
            
        case CallAction_End:
        {
            if (isGroup) {
                // 群通话不需要计算通话时长
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:SIGNALING_CMD_HANGUP cmdInfo:@"0" message:@"" callType:realModel.calltype];
                [dataDic setValue:@(0) forKey:SIGNALING_EXTRA_KEY_CALL_END];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                // 这里发结束事件的时候，inviteeList 已经为 nil 了，可以伪造一个被邀请用户，把结束的信令发到群里展示。
                // timeout 这里传 0，结束的事件不需要做超时检测
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid inviteeList:@[@"inviteeList"] data:data onlineUserOnly:self.onlineUserOnly timeout:0 succ:nil fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
            } else {
                NSDate *now = [NSDate date];
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:SIGNALING_CMD_HANGUP cmdInfo:[NSString stringWithFormat:@"%llu",(UInt64)[now timeIntervalSince1970] - self.startCallTS] message:@"" callType:realModel.calltype];
                [dataDic setValue:@((UInt64)[now timeIntervalSince1970] - self.startCallTS) forKey:SIGNALING_EXTRA_KEY_CALL_END];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] invite:receiver data:data onlineUserOnly:self.onlineUserOnly offlinePushInfo:nil timeout:0 succ:nil fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onError:msg:)]) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.startCallTS = 0;
            }
        }
            break;
        case CallAction_SwitchToAudio: {
            NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:realModel.roomid cmd:SIGNALING_CMD_SWITCHTOVOICECALL cmdInfo:@"" message:@"" callType:realModel.calltype];
            [dataDic setValue:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
            NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
            @weakify(self)
            [[V2TIMManager sharedInstance] invite:receiver data:data onlineUserOnly:self.onlineUserOnly offlinePushInfo:nil timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:^{
                
            } fail:^(int code, NSString *desc) {
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

- (void)sendAPNsForCall:(NSString *)receiver inviteeList:(NSArray *)inviteeList callID:(NSString *)callID groupid:(NSString *)groupid roomid:(UInt32)roomid {
    if (callID.length == 0 || inviteeList.count == 0 || roomid == 0) {
        NSLog(@"sendAPNsForCall failed");
        return;
    }
    V2TIMOfflinePushInfo *info = [self getOfflinePushInfoWithInviteeList:inviteeList callID:callID groupid:groupid roomid:roomid];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"version" : @(Version) , @"businessID" : SIGNALING_BUSINESSID}]];
    // 针对每个被邀请成员单独邀请
    [[V2TIMManager sharedInstance] sendMessage:msg receiver:receiver groupID:nil priority:V2TIM_PRIORITY_HIGH onlineUserOnly:YES offlinePushInfo:info progress:nil succ:nil fail:nil];
}


- (V2TIMOfflinePushInfo *)getOfflinePushInfoWithInviteeList:(NSArray *)inviteeList callID:(NSString *)callID groupid:(NSString *)groupid roomid:(UInt32)roomid{
    int chatType; //单聊：1 群聊：2
    if (groupid.length > 0) {
        chatType = 2;
    } else {
        chatType = 1;
        groupid = @"";
    }
    //{"entity":{"version":1,"content":"{\"action\":1,\"call_type\":2,\"room_id\":804544637,\"call_id\":\"144115224095613335-1595234230-3304653590\",\"timeout\":30,\"version\":4,\"invited_list\":[\"2019\"],\"group_id\":\"@TGS#1PWYXLTGA\"}","sendTime":1595234231,"sender":"10457","chatType":2,"action":2}}
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
                                  @"sender" : [TRTCCallingUtils loginUser],
                                  @"version" : @(APNs_Version)};       // 推送版本
    NSDictionary *extParam = @{@"entity" : entityParam};
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    info.desc = CallingLocalize(@"Demo.TRTC.calling.callingrequest");
    info.ext = [TRTCCallingUtils dictionary2JsonStr:extParam];
    return info;
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    if (signalingInfo.inviteID.length > 0 && signalingInfo.inviter.length > 0 && signalingInfo.inviteeList.count > 0 && signalingInfo.groupID.length > 0) {
        [[V2TIMManager sharedInstance] addInvitedSignaling:signalingInfo succ:^{
            [self onReceiveNewInvitation:signalingInfo.inviteID inviter:signalingInfo.inviter groupID:signalingInfo.groupID inviteeList:signalingInfo.inviteeList data:signalingInfo.data];
        } fail:^(int code, NSString *desc) {
            NSLog(@"onReceiveAPNsForGroupCall failed,code:%d desc:%@",code,desc);
        }];
    }
}

#pragma mark - V2TIMSignalingListener

-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
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
            model.action = CallAction_SwitchToAudio;
            self.switchToAudioCallID = inviteID;
        }
        else {
            self.currentCallingUserID = inviter;
            model.action = CallAction_Call;
        }
        [self handleCallModel:inviter model:model message:cmdInfoStr userIds:userIds];
    }
}

-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Cancel;
        [self handleCallModel:inviter model:model message:@""];
    }
}

-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        [TRTCCloud sharedInstance].delegate = self;
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        NSDictionary *data = [TRTCSignalFactory getDataDictionary:param];
        if ([data[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL]) {
            model.action = CallAction_AcceptSwitchToAudio;
        }
        else {
            model.action = CallAction_Accept;
        }
        [self handleCallModel:invitee model:model message:@""];
    }
}

-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        NSDictionary *data = [TRTCSignalFactory getDataDictionary:param];
        if ([data[SIGNALING_EXTRA_KEY_MESSAGE] isEqualToString:SIGNALING_MESSAGE_LINEBUSY]) {
            model.action = CallAction_Linebusy;
        }
        else if ([data[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_SWITCHTOVOICECALL]) {
            model.action = CallAction_AcceptSwitchToAudio;
        }
        else {
            model.action = CallAction_Reject;
        }
        [self handleCallModel:invitee model:model message:@"Other status error"];
    }
}

-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)invitedList {
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    model.invitedList = [NSMutableArray arrayWithArray:invitedList];
    model.action = CallAction_Timeout;
    [self handleCallModel:@"" model:model message:@"Timeout"];
}

- (NSDictionary *)check:(NSString *)data {
    NSDictionary *signalingDictionary = [TRTCCallingUtils jsonSring2Dictionary:data];
    
    if(!signalingDictionary[SIGNALING_EXTRA_KEY_PLATFORM] || !signalingDictionary[SIGNALING_EXTRA_KEY_DATA]) {
        signalingDictionary = [TRTCSignalFactory convertOldSignalingToNewSignaling:signalingDictionary];
    }
    
    if (![signalingDictionary[SIGNALING_EXTRA_KEY_BUSINESSID] isEqualToString:SIGNALING_BUSINESSID]) {
        return nil;
    }
    NSInteger version = [signalingDictionary[SIGNALING_EXTRA_KEY_VERSION] integerValue];
    if (version > Version) {
        return nil;
    }
    NSDictionary *dataDictionary = [TRTCSignalFactory getDataDictionary:signalingDictionary];
    if ([dataDictionary[SIGNALING_EXTRA_KEY_CMD] isEqualToString:SIGNALING_CMD_HANGUP]) {
        //结束的事件只用于 UI 展示通话时长，不参与业务逻辑的处理
        return nil;
    }
    return signalingDictionary;
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model message:(NSString *)message {
    [self handleCallModel:user model:model message:message userIds:nil];
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model message:(NSString *)message userIds:(NSArray *)userIds {
    switch (model.action) {
        case CallAction_Call:
        {
            void(^syncInvitingList)(void) = ^(){
                if (self.curGroupID.length > 0) {
                    for (NSString *invitee in model.invitedList) {
                        if (![self.curInvitingList containsObject:invitee]) {
                            [self.curInvitingList addObject:invitee];
                        }
                    }
                }
            };
            if (model.groupid != nil && ![model.invitedList containsObject:[TRTCCallingUtils loginUser]]
                ) { //群聊但是邀请不包含自己不处理
                if (self.curCallID == model.callid) { //在房间中更新列表
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
                if (![model.callid isEqualToString:self.curCallID]) {
                    [self invite:model.groupid.length > 0 ? model.groupid : user action:CallAction_Linebusy model:model cmdInfo:nil];
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
            
        }
            break;
            
        case CallAction_Cancel:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                [self checkAutoHangUp];
                self.isOnCalling = NO;
                [self.delegate onCallingCancel:user];
            }
        }
            break;
            
        case CallAction_Reject:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                if ([self canDelegateRespondMethod:@selector(onReject:)]) {
                    [self.delegate onReject:user];
                }
                [self checkAutoHangUp];
            }
        }
            break;
            
        case CallAction_Timeout:
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                // 这里需要判断下是否是自己超时了，自己超时，直接退出界面
                if ([model.invitedList containsObject:[TRTCCallingUtils loginUser]] && self.delegate) {
                    self.isOnCalling = false;
                    if ([self canDelegateRespondMethod:@selector(onCallingTimeOut)]) {
                        [self.delegate onCallingTimeOut];
                    }
                } else {
                    for (NSString *userID in model.invitedList) {
                        if ([self.curInvitingList containsObject:userID] && ![self.curRespList containsObject:userID]) {
                            if ([self canDelegateRespondMethod:@selector(onNoResp:)]) {
                                [self.delegate onNoResp:userID];
                            }
                            if ([self.curInvitingList containsObject:userID]) {
                                [self.curInvitingList removeObject:userID];
                            }
                        }
                    }
                }
                [self checkAutoHangUp];
            }
            break;
            
        case CallAction_End:
            // 不需处理
            break;
            
        case CallAction_Linebusy:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                [self.delegate onLineBusy:user];
                [self checkAutoHangUp];
            }
        }
            break;
            
        case CallAction_Error:
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
                if ([self.curInvitingList containsObject:user]) {
                    [self.curInvitingList removeObject:user];
                }
                [self.delegate onError:-1 msg:CallingLocalize(@"Demo.TRTC.calling.syserror")];
                [self checkAutoHangUp];
            }
            break;
        case CallAction_SwitchToAudio: {
            if (!self.switchToAudioCallID) {
                break;
            }
            int res = [self checkAudioStatus];
            if (res == 0) {
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:0 cmd:SIGNALING_CMD_SWITCHTOVOICECALL cmdInfo:@"" message:@"" callType:CallType_Video];
                [dataDic setValue:@(1) forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                @weakify(self)
                [[V2TIMManager sharedInstance] accept:self.switchToAudioCallID data:data succ:^{
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                        [self.delegate onSwitchToAudio:YES message:@""];
                    }
                } fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                        [self.delegate onSwitchToAudio:NO message:desc];
                    }
                }];
            }
            else {
                NSMutableDictionary *dataDic = [TRTCSignalFactory packagingSignalingWithExtInfo:@"" roomID:0 cmd:@"" cmdInfo:@"" message:@"" callType:CallType_Video];
                [dataDic setValue:@(0) forKey:SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL];
                NSString *data = [TRTCCallingUtils dictionary2JsonStr:dataDic];
                [[V2TIMManager sharedInstance] reject:self.switchToAudioCallID data:data succ:^{
                    
                } fail:^(int code, NSString *desc) {
                    
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
        default:
        {
            NSLog(@"📳 👻 WTF ????");
        }
            break;
    }
}

#pragma mark - utils

- (CallModel *)generateModel:(CallAction)action {
    CallModel *model = [self.curLastModel copy];
    model.action = action;
    return model;
}

// 检查是否能自动挂断
- (void)checkAutoHangUp {
    if (self.isInRoom && self.curRoomList.count == 0) {
        if (self.curGroupID.length > 0) {
            if (self.curInvitingList.count == 0) {
                [self invite:self.curGroupID action:CallAction_End model:nil cmdInfo:nil];
                [self autoHangUp];
            }
        } else {
            NSString *user = @"";
            if (self.curSponsorForMe.length > 0) {
                user = self.curSponsorForMe;
            } else {
                user = self.curLastModel.invitedList.firstObject;
            }
            [self invite:user action:CallAction_End model:nil cmdInfo:nil];
            [self autoHangUp];
        }
    }
}

// 自动挂断
- (void)autoHangUp {
    [self quitRoom];
    self.isOnCalling = NO;
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
}

#pragma mark - private method
- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

@end
