//
//  TRTCCall+Signal.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TUICall+Signal.h"
#import "TUICall+TRTC.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "NSBundle+TUIKIT.h"

@implementation TUICall (Signal)

- (void)addSignalListener {
    [[V2TIMManager sharedInstance] addSignalingListener:self];
}

- (void)removeSignalListener {
    [[V2TIMManager sharedInstance] removeSignalingListener:self];
}

- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model {
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
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:Signal_Business_Call,Signal_Business_ID,@( AVCall_Version),SIGNALING_EXTRA_KEY_VERSION,@(realModel.calltype), SIGNALING_EXTRA_KEY_CALL_TYPE,nil];
    switch (realModel.action) {
    case CallAction_Call:
        {
            param[SIGNALING_EXTRA_KEY_ROOM_ID] = @(realModel.roomid);
            NSString *data = [TUICallUtils dictionary2JsonStr:param];
            if (isGroup) {
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid inviteeList:realModel.invitedList data:data onlineUserOnly:NO timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:^{
                    @strongify(self)
                    // 发起 Apns 推送,群组的邀请，需要单独对每个被邀请人发起推送
                    for (NSString *invitee in realModel.invitedList) {
                        [self sendAPNsForGroupCall:invitee inviteeList:realModel.invitedList callID:self.callID  groupid:realModel.groupid roomid:realModel.roomid];
                    }
                } fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if (self.delegate) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            } else {
                V2TIMOfflinePushInfo *info = [self getOfflinePushInfo:realModel.invitedList.firstObject inviteeList:realModel.invitedList callID:self.callID groupid:realModel.groupid roomid:realModel.roomid];
                @weakify(self)
                callID = [[V2TIMManager sharedInstance] invite:realModel.invitedList.firstObject data:data onlineUserOnly:NO offlinePushInfo:info timeout:SIGNALING_EXTRA_KEY_TIME_OUT succ:nil fail:^(int code, NSString *desc) {
                    @strongify(self)
                    if (self.delegate) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
                self.callID = callID;
            }
        }
            break;
        
    case CallAction_Accept:
        {
            NSString *data = [TUICallUtils dictionary2JsonStr:param];
            [[V2TIMManager sharedInstance] accept:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                if (self.delegate) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
        
    case CallAction_Reject:
        {
            NSString *data = [TUICallUtils dictionary2JsonStr:param];
            [[V2TIMManager sharedInstance] reject:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                if (self.delegate) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
        
    case CallAction_Linebusy:
        {
            param[SIGNALING_EXTRA_KEY_LINE_BUSY] = SIGNALING_EXTRA_KEY_LINE_BUSY;
            NSString *data = [TUICallUtils dictionary2JsonStr:param];
            [[V2TIMManager sharedInstance] reject:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                if (self.delegate) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
        
    case CallAction_Cancel:
        {
            NSString *data = [TUICallUtils dictionary2JsonStr:param];
            [[V2TIMManager sharedInstance] cancel:realModel.callid data:data succ:nil fail:^(int code, NSString *desc) {
                if (self.delegate) {
                    [self.delegate onError:code msg:desc];
                };
            }];
        }
            break;
        
    case CallAction_End:
        {
            if (isGroup) {
                param[SIGNALING_EXTRA_KEY_CALL_END] = @(0);  // 群通话不需要计算通话时长
                NSString *data = [TUICallUtils dictionary2JsonStr:param];
                // 这里发结束事件的时候，inviteeList 已经为 nil 了，可以伪造一个被邀请用户，把结束的信令发到群里展示。
                // timeout 这里传 0，结束的事件不需要做超时检测
                callID = [[V2TIMManager sharedInstance] inviteInGroup:realModel.groupid inviteeList:@[@"inviteeList"] data:data onlineUserOnly:NO timeout:0 succ:nil fail:^(int code, NSString *desc) {
                    if (self.delegate) {
                        [self.delegate onError:code msg:desc];
                    };
                }];
            } else {
                if (self.startCallTS > 0) {
                    NSDate *now = [NSDate date];
                    param[SIGNALING_EXTRA_KEY_CALL_END] = @((UInt64)[now timeIntervalSince1970] - self.startCallTS);
                    NSString *data = [TUICallUtils dictionary2JsonStr:param];
                    callID = [[V2TIMManager sharedInstance] invite:receiver data:data onlineUserOnly:NO offlinePushInfo:nil timeout:0 succ:nil fail:^(int code, NSString *desc) {
                        if (self.delegate) {
                            [self.delegate onError:code msg:desc];
                        };
                    }];
                }
                self.startCallTS = 0;
            }
        }
            break;
    
    default:
            break;
    }
    if (realModel.action != CallAction_Reject &&
        realModel.action != CallAction_Accept &&
        realModel.action != CallAction_End &&
        realModel.action != CallAction_Cancel &&
        model == nil) {
        self.curLastModel = [realModel copy];
    }
    return callID;
}

- (void)sendAPNsForGroupCall:(NSString *)receiver inviteeList:(NSArray *)inviteeList callID:(NSString *)callID groupid:(NSString *)groupid roomid:(UInt32)roomid{
    V2TIMOfflinePushInfo *info = [self getOfflinePushInfo:receiver inviteeList:inviteeList callID:callID groupid:groupid roomid:roomid];
    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:[TUICallUtils dictionary2JsonData:@{@"version" : @(AVCall_Version) , @"businessID" : AVCall}]];
    [[V2TIMManager sharedInstance] sendMessage:msg receiver:receiver groupID:nil priority:V2TIM_PRIORITY_HIGH onlineUserOnly:YES offlinePushInfo:info progress:nil succ:nil fail:nil];
}

- (V2TIMOfflinePushInfo *)getOfflinePushInfo:(NSString *)receiver inviteeList:(NSArray *)inviteeList callID:(NSString *)callID groupid:(NSString *)groupid roomid:(UInt32)roomid {
    if (callID.length == 0 || inviteeList.count == 0 || roomid == 0) {
        NSLog(@"sendAPNsForCall failed");
        return nil;
    }
    int chatType; //单聊：1 群聊：2
    if (groupid.length > 0) {
        chatType = 2;
    } else {
        chatType = 1;
        groupid = @"";
    }
    //{"entity":{"version":1,"content":"{\"action\":1,\"call_type\":2,\"room_id\":804544637,\"call_id\":\"144115224095613335-1595234230-3304653590\",\"timeout\":30,\"version\":4,\"invited_list\":[\"2019\"],\"group_id\":\"@TGS#1PWYXLTGA\"}","sendTime":1595234231,"sender":"10457","chatType":2,"action":2}}
    NSDictionary *contentParam = @{@"action":@(SignalingActionType_Invite),
                                   @"call_id":callID,
                                   @"call_type":@(self.curType),
                                   @"invited_list":inviteeList,
                                   @"room_id":@(roomid),
                                   @"group_id":groupid,
                                   @"timeout":@(SIGNALING_EXTRA_KEY_TIME_OUT),
                                   @"version":@(AVCall_Version)};      // 音视频呼叫版本
    NSDictionary *entityParam = @{@"action" : @(APNs_Business_Call),   // 音视频业务逻辑推送
                                  @"chatType" : @(chatType),
                                  @"content" : [TUICallUtils dictionary2JsonStr:contentParam],
                                  @"sendTime" : @([[V2TIMManager sharedInstance] getServerTime]),
                                  @"sender" : [TUICallUtils loginUser],
                                  @"version" : @(APNs_Version)};       // 推送版本
    NSDictionary *extParam = @{@"entity" : entityParam};
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    info.desc = TUILocalizableString(TUIKitOfflinePushCallTips); // @"您有一个通话请求";
    info.ext = [TUICallUtils dictionary2JsonStr:extParam];
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

#pragma mark V2TIMSignalingListener

-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.groupid = groupID;
        model.inviter = inviter;
        model.invitedList = [NSMutableArray arrayWithArray:inviteeList];
        model.calltype = (CallType)[param[SIGNALING_EXTRA_KEY_CALL_TYPE] intValue];
        model.roomid = [param[SIGNALING_EXTRA_KEY_ROOM_ID] intValue];
        model.action = CallAction_Call;
        [self handleCallModel:inviter model:model];
    }
}

-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Cancel;
        [self handleCallModel:inviter model:model];
    }
}

-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        [TRTCCloud sharedInstance].delegate = self;
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Accept;
        [self handleCallModel:invitee model:model];
    }
}

-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    NSDictionary *param = [self check:data];
    if (param) {
        CallModel *model = [[CallModel alloc] init];
        model.callid = inviteID;
        model.action = CallAction_Reject;
        if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
            model.action = CallAction_Linebusy;
        }
        [self handleCallModel:invitee model:model];
    }
}

-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)invitedList {
    CallModel *model = [[CallModel alloc] init];
    model.callid = inviteID;
    model.invitedList = [NSMutableArray arrayWithArray:invitedList];
    model.action = CallAction_Timeout;
    [self handleCallModel:@"" model:model];
}

- (NSDictionary *)check:(NSString *)data {
    NSDictionary *param = [TUICallUtils jsonSring2Dictionary:data];
    // 判断是不是音视频通话信令（这里不要用 Signal_Business_ID 判断，老版本没有传这个字段，会有兼容性问题）
    if (![param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_TYPE]) {
        return nil;
    }
    //结束的事件只用于 UI 展示通话时长，不参与业务逻辑的处理
    if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
        return nil;
    }
    if (![param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_TYPE]) {
        // 说明是直播过来的信息，不予响应
        return nil; 
    }
    NSInteger version = [param[SIGNALING_EXTRA_KEY_VERSION] integerValue];
    if (version > AVCall_Version) {
        return nil;
    }
    return param;
}

- (void)handleCallModel:(NSString *)user model:(CallModel *)model {
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
            if (model.groupid != nil && ![model.invitedList containsObject:[TUICallUtils loginUser]]
                ) { //群聊但是邀请不包含自己不处理
                if (self.curCallID == model.callid) { //在房间中更新列表
                    syncInvitingList();
                    if (self.curInvitingList.count > 0) {
                        if (self.delegate) {
                            [self.delegate onGroupCallInviteeListUpdate:self.curInvitingList];
                        }
                    }
                }
                return;
            }
            if (self.isOnCalling) { // tell busy
                if (![model.callid isEqualToString:self.curCallID]) {
                    [self invite:model.groupid.length > 0 ? model.groupid : user action:CallAction_Linebusy model:model];
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
                if (self.delegate) {
                    [self.delegate onInvited:user userIds:model.invitedList isFromGroup:self.curGroupID.length > 0 ? YES : NO callType:model.calltype];
                }
            }
            
        }
            break;
        
    case CallAction_Cancel:
        {
            if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
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
                [self.delegate onReject:user];
                [self checkAutoHangUp];
            }
        }
            break;
        
    case CallAction_Timeout:
        if ([self.curCallID isEqualToString:model.callid] && self.delegate) {
            // 这里需要判断下是否是自己超时了，自己超时，直接退出界面
            if ([model.invitedList containsObject:[TUICallUtils loginUser]] && self.delegate) {
                self.isOnCalling = false;
                [self.delegate onCallingTimeOut];
            } else {
                for (NSString *userID in model.invitedList) {
                    if ([self.curInvitingList containsObject:userID] && ![self.curRespList containsObject:userID]) {
                        if (self.delegate) {
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
            [self.delegate onError:-1 msg:TUILocalizableString(TUIKitTipsSystemError)];
            [self checkAutoHangUp];
        }
            break;

    default:
        {
             NSLog(@"📳 👻 unknown error");
        }
            break;
    }
}

#pragma mark utils
- (CallModel *)generateModel:(CallAction)action {
    CallModel *model = [self.curLastModel copy];
    model.action = action;
    return model;
}

//检查是否能自动挂断
- (void)checkAutoHangUp {
    if (self.isInRoom && self.curRoomList.count == 0) {
        if (self.curGroupID.length > 0) {
            if (self.curInvitingList.count == 0) {
                [self invite:self.curGroupID action:CallAction_End model:nil];
                [self autoHangUp];
            }
        } else {
            NSString *user = @"";
            if (self.curSponsorForMe.length > 0) {
                user = self.curSponsorForMe;
            } else {
                user = self.curLastModel.invitedList.firstObject;
            }
            [self invite:user action:CallAction_End model:nil];
            [self autoHangUp];
        }
    }
}

//自动挂断
- (void)autoHangUp {
    [self quitRoom];
    self.isOnCalling = NO;
    if (self.delegate) {
        [self.delegate onCallEnd];
    }
}

@end
