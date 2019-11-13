//
//  VideoCallManager.m
//  TUIKitDemo
//
//  Created by xcoderliu on 9/30/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "VideoCallManager.h"
#import "TCUtil.h"
#import "VideoCallCellData.h"
#import "THelper.h"
#import "VideoCallManager+videoMeeting.h"
#import "ChatViewController.h"
#import <MBProgressHUD.h>
#import <ReactiveObjC.h>

@interface VideoCallManager ()
@property (nonatomic, strong, nullable) UIAlertController *requestAlert;
@property (nonatomic, strong, nullable) UIAlertController *actionAlert;
/// 正在视频通过的过程中
@property (nonatomic,assign) BOOL isOnCalling;
/// 主动发起视频请求roomID
@property (nonatomic,assign) UInt32 lastRequestRoomID;
/// 当前roomID 请求者
@property (nonatomic,assign) NSString* currentRoomRequestUser;
/// 视频请求是否返回结果
@property (nonatomic, strong) NSMutableArray* getResultRoomIDs;
/// 进入会议室时间
@property (nonatomic, strong, nullable) NSDate *enterRoomDate;
@end

@implementation VideoCallManager
static VideoCallManager* _instance = nil;
 
+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        [_instance setIsOnCalling:NO];
        [_instance setLastRequestRoomID:0];
        [_instance setCurrentRoomID:0];
        [_instance setGetResultRoomIDs:[NSMutableArray arrayWithCapacity:1]];
        [_instance setConversationData:[[TUIConversationCellData alloc] init]];
    }) ;
    
    return _instance ;
}

- (void)onNewVideoCallMessage:(TIMMessage *)msg {
    TIMElem *elem = [msg getElem:0];
    if([elem isKindOfClass:[TIMCustomElem class]]) {
        
        NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
        UInt32 state = [param[@"videoState"] unsignedIntValue];
        
        if ( state == VIDEOCALL_REQUESTING || state == VIDEOCALL_USER_CONNECTTING ) { //请求或开始连接
            [self handActionMessage:msg videoState:state];
        } else {
            [self handResultMessage:msg videoState:state];
        }
    }
}

- (BOOL)videoCallTimeOut: (TIMMessage*)message {
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:message.timestamp];
    if ( time >= VIDEOCALL_TIMEOUT) {
        return YES;
    }
    return NO;
}

- (void)handActionMessage:(TIMMessage *)msg videoState:(videoCallState)state {
    @weakify(self);
    TIMElem *elem = [msg getElem:0];
    NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
    UInt32 roomID = [param[@"roomID"] unsignedIntValue];
    NSString* user = param[@"requestUser"];
    
    if(state == VIDEOCALL_REQUESTING) {
        if (_isOnCalling || [self videoCallTimeOut:msg]) { //正在通话过程中 //或者超时了
            // FIXME: should send msg that is on calling , which user's ui should show other is on calling
            return;
        }
        //test code
        [msg getSenderProfile:^(TIMUserProfile *profile) { //处理申请消息 A -> B B处理 是否接收视频
            @strongify(self);
            
            self.conversationData.convType = TIM_C2C;
            self.conversationData.convId = profile.identifier;
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@来电",user] preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"接听" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self acceptVideoCall:roomID requestUser:user Accept:YES];
            }];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                 [self acceptVideoCall:roomID requestUser:user Accept:NO];
            }];

            [alertController addAction:cancelAction];
            [alertController addAction:okAction];

            UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
            [window.rootViewController presentViewController:alertController animated:YES completion:nil];
            NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:msg.timestamp];
            time = MIN(VIDEOCALL_TIMEOUT, time);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((VIDEOCALL_TIMEOUT - time) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertController dismissViewControllerAnimated:YES completion:nil];
            });
            self.actionAlert = alertController;
        }];
        
    } else if (state == VIDEOCALL_USER_CONNECTTING) {
        [self.getResultRoomIDs addObject:@(roomID)];
        if (_lastRequestRoomID == roomID) {
            [self dismissRequestAlert];
            [self enterVideoRoom:roomID requestUser:user];
        }
    }
    
}

- (void)acceptVideoCall:(UInt32)roomID requestUser:(NSString*)user Accept:(BOOL)accept {
    if (!accept) {
        [self sendVideoCallResult:roomID requestUser:user state:VIDEOCALL_USER_REJECT];
        self.isOnCalling = NO;
    } else {
        [self sendVideoCallAction:roomID requestUser:user state:VIDEOCALL_USER_CONNECTTING];
        [self enterVideoRoom:roomID requestUser:user];
        self.isOnCalling = YES;
    }
}

- (void)handResultMessage:(TIMMessage *)msg videoState:(videoCallState)state {
    TIMElem *elem = [msg getElem:0];
    NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
    UInt32 roomID = [param[@"roomID"] unsignedIntValue];
     [self.getResultRoomIDs addObject:@(roomID)];
    if(!msg.isSelf) { //对方回应
        if (state == VIDEOCALL_USER_REJECT) { //对方拒绝
            [self dismissRequestAlert];
            _lastRequestRoomID = 0;
            _isOnCalling = NO;
            _currentRoomID = 0;
        }
        else if (state == VIDEOCALL_USER_CANCEL) { //对方取消
            [self.actionAlert dismissViewControllerAnimated:YES completion:nil];
            self.actionAlert = nil;
            _lastRequestRoomID = 0;
            _isOnCalling = NO;
            _currentRoomID = 0;
        }
        else if (state == VIDEOCALL_USER_HANUGUP) { //对方挂断
            [self quitRoom: YES];
        }
    }  else { //本方
        
    }
}

- (void)videoCall:(TUIChatController *)chatController {
    if (_isOnCalling) {
        [self quitRoom: NO];
    }
    
    UInt32 roomID = arc4random();
    [self sendVideoCallAction:roomID requestUser:[self currentUserIdentifier] state:VIDEOCALL_REQUESTING];
    [self enterVideoWaitting:roomID];
}

- (void)sendVideoCallAction:(UInt32)roomID requestUser:(NSString*)user state:(videoCallState)videoState {
    TIMMessage *imMsg = [[TIMMessage alloc] init];
    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
    custom_elem.data = [TCUtil dictionary2JsonData:@{@"roomID":@(roomID), @"version":@(2), @"videoState":@(videoState), @"requestUser":user}];
    [imMsg addElem:custom_elem];
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:self.conversationData.convType receiver:self.conversationData.convId];
    [conv sendMessage:imMsg succ:^{
        if (videoState == VIDEOCALL_REQUESTING) { //发起请求需要隐藏
            [imMsg remove];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(VIDEOCALL_TIMEOUT * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ //超时发送超时消息
                if (![self.getResultRoomIDs containsObject:@(roomID)]) { //没有任何结果 发送超时消息
                    [self sendVideoCallResult:roomID requestUser:user state:VIDEOCALL_USER_NO_RESP];
                    self.isOnCalling = NO;
                    [self dismissRequestAlert];
                } else {
                    
                }
            });
        }
    } fail:^(int code, NSString *desc) { //失败应该展示结果
        dispatch_async(dispatch_get_main_queue(), ^{
            [THelper makeToastError:code msg:desc];
        });
    }];
}

- (void)sendVideoCallResult:(UInt32)roomID  requestUser:(NSString*)user state:(videoCallState)videoState {
    TIMMessage *imMsg = [[TIMMessage alloc] init];
    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:@{@"roomID":@(roomID), @"version":@(2), @"videoState":@(videoState), @"requestUser":user}];
    UInt32 duration = 0;
    if (videoState == VIDEOCALL_USER_HANUGUP && _enterRoomDate != nil) {
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:_enterRoomDate];
        duration = MAX(1, secondsBetween);
        [resultDict setObject:@(secondsBetween) forKey:@"duration"];
    }
    custom_elem.data = [TCUtil dictionary2JsonData:resultDict];
    [imMsg addElem:custom_elem];
    if (self.currentChatVC &&
        self.currentChatVC.conversationData.convType == self.conversationData.convType &&
        self.currentChatVC.conversationData.convId == self.conversationData.convId) {
        BOOL isOutGoing = YES;
        if (videoState == VIDEOCALL_USER_REJECT ||
            videoState == VIDEOCALL_USER_ONCALLING) { //由我发起请求，对方发送结果
            isOutGoing = !isOutGoing;
        }
        
        if (user != nil) {
            NSString *currentUser = [self currentUserIdentifier];
            isOutGoing = (user == currentUser);
        }
        
        VideoCallCellData *cellResult = [[VideoCallCellData alloc] initWithDirection:isOutGoing
                                       ? MsgDirectionOutgoing : MsgDirectionIncoming];
        cellResult.isSelf = imMsg.isSelf;
        cellResult.requestUser = user;
        cellResult.roomID = roomID;
        cellResult.videoState = videoState;
        cellResult.innerMessage = imMsg;
        cellResult.duration = duration;
        [self.currentChatVC sendMessage:cellResult];
        
    } else {
        TIMConversation *conv = [[TIMManager sharedInstance] getConversation:self.conversationData.convType
                                                                    receiver:self.conversationData.convId];
        [conv sendMessage:imMsg succ:^{
            NSLog(@"success");
        } fail:^(int code, NSString *desc) { //失败应该展示结果
            dispatch_async(dispatch_get_main_queue(), ^{
                [THelper makeToastError:code msg:desc];
            });
        }];
    }
}

- (void)enterVideoWaitting: (UInt32)roomID {
    _isOnCalling = YES;
    _lastRequestRoomID = roomID;
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"正在请求通话"] preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
         [self sendVideoCallResult:roomID requestUser:[self currentUserIdentifier] state:VIDEOCALL_USER_CANCEL];
         [self.getResultRoomIDs addObject:@(roomID)];
         self.isOnCalling = NO;
         [self dismissRequestAlert];
    }];

    [alertController addAction:cancelAction];

    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    self.requestAlert = alertController;
}

- (void)enterVideoRoom: (UInt32)roomID requestUser:(NSString*)user {
    _currentRoomID = roomID;
    _currentRoomRequestUser = user;
    [self dismissRequestAlert];
    
    if (_lastRequestRoomID != 0 && roomID == _lastRequestRoomID) { //当前角色请求并进入
        
    } else {
        
    }
    
    _enterRoomDate = [NSDate date];
    [self _enterMeetingRoom];
}

/// 离开会议室
/// @param passive 被动离开
- (void)quitRoom:(BOOL)passive {
    [self _quitMeetingRoom];
    _lastRequestRoomID = 0;
    _isOnCalling = NO;
    [self dismissRequestAlert];
    if (_currentRoomID != 0 && !passive) { //主动断开发送结果消息
        [self sendVideoCallResult:_currentRoomID requestUser:self.currentRoomRequestUser state:VIDEOCALL_USER_HANUGUP];
    }
    _currentRoomID = 0;
}

- (void)dismissRequestAlert {
    [[VideoCallManager shareInstance].requestAlert dismissViewControllerAnimated:YES completion:nil];
    [VideoCallManager shareInstance].requestAlert = nil;
}

- (NSString*) currentUserIdentifier {
    NSString *user = [[TIMManager sharedInstance] getLoginUser];
    if (user.length > 0) {
        return user;
    }
    int iRandom = arc4random() % 1000;
    return [NSString stringWithFormat:@"%d",iRandom];
}

@end
