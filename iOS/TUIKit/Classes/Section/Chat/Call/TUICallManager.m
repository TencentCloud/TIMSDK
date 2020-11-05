//
//  TUICallManager.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import <AVFoundation/AVFoundation.h>
#import "TUICallManager.h"
#import "TUICallUtils.h"
#import "TUISelectMemberViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIVideoCallViewController.h"
#import "TUIAudioCallViewController.h"
#import "THelper.h"
#import "NSBundle+TUIKIT.h"

typedef NS_ENUM(NSInteger,VideoUserRemoveReason){
    VideoUserRemoveReason_Leave = 0,
    VideoUserRemoveReason_Reject,
    VideoUserRemoveReason_Noresp,
    VideoUserRemoveReason_Busy,
};

@interface TUICallManager()<TUICallDelegate>
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,strong)UIViewController *callVC;
@property(nonatomic,assign)CallType type;
@end

@implementation TUICallManager
+(TUICallManager *)shareInstance {
    static dispatch_once_t onceToken;
    static TUICallManager * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICallManager alloc] init];
    });
    return g_sharedInstance;
}

- (void)initCall {
    [[TUICall shareInstance] setDelegate:self];
}

- (void)unInitCall {
    [[TUICall shareInstance] setDelegate:nil];
}

- (void)call:(NSString *)groupID userID:(NSString *)userID callType:(CallType)callType {
    self.groupId = groupID;
    self.userId = userID;
    self.type = callType;
    [self setupUI];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    [[TUICall shareInstance] onReceiveGroupCallAPNs:signalingInfo];
}

-(void)setupUI {
    if (self.groupId.length > 0) {
        TUISelectMemberViewController *selectVC = [[TUISelectMemberViewController alloc] init];
        selectVC.groupId = self.groupId;
        UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav = tab.selectedViewController;
        [nav pushViewController:selectVC animated:YES];
        @weakify(self)
        selectVC.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            @strongify(self)
            NSMutableArray *userIds = [NSMutableArray array];
            NSMutableArray *inviteeList = [NSMutableArray array];
            for (UserModel *model in modelList) {
                [userIds addObject:model.userId];
                [inviteeList addObject:[self covertUser:model isEnter:NO]];
            }
            [self showCallVC:inviteeList sponsor:nil];
            [[TUICall shareInstance] call:userIds groupID:self.groupId type:self.type];
        };
    } else {
        [TUICallUtils getCallUserModel:self.userId finished:^(CallUserModel * _Nonnull model) {
            NSMutableArray *inviteeList = [NSMutableArray array];
            model.userId = self.userId;
            [inviteeList addObject:model];
            [self showCallVC:inviteeList sponsor:nil];
            [[TUICall shareInstance] call:@[self.userId] groupID:nil type:self.type];
        }];
    }
}

- (void)showCallVC:(NSMutableArray<CallUserModel *> *)invitedList sponsor:(CallUserModel *)sponsor {
    if (self.type == CallType_Video) {
        self.callVC = [[TUIVideoCallViewController alloc] initWithSponsor:sponsor userList:invitedList];
        TUIVideoCallViewController *videoVC = (TUIVideoCallViewController *)self.callVC;
        videoVC.dismissBlock = ^{
            self.callVC = nil;
        };
        [videoVC setModalPresentationStyle:UIModalPresentationFullScreen];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:videoVC animated:YES completion:nil];
    } else {
        self.callVC = [[TUIAudioCallViewController alloc] initWithSponsor:sponsor userList:invitedList];
        TUIAudioCallViewController *audioVC = (TUIAudioCallViewController *)self.callVC;
        audioVC.dismissBlock = ^{
            self.callVC = nil;
        };
        [audioVC setModalPresentationStyle:UIModalPresentationFullScreen];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:audioVC animated:YES completion:nil];
    }
}

- (CallUserModel *)covertUser:(UserModel *)user isEnter:(BOOL)isEnter {
    CallUserModel *callModel = [[CallUserModel alloc] init];
    callModel.name = user.name;
    callModel.avatar = user.avatar;
    callModel.userId = user.userId;
    callModel.isEnter = isEnter;
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        TUIVideoCallViewController *videoVC = (TUIVideoCallViewController *)self.callVC;
        CallUserModel *oldUser = [videoVC getUserById:user.userId];
        callModel.isVideoAvaliable = oldUser.isVideoAvaliable;
    }
    return callModel;
}

#pragma mark TUICallDelegate
-(void)onError:(int)code msg:(NSString *)msg {
    NSLog(@"📳 onError: code:%d msg:%@",code,msg);
}
   
-(void)onInvited:(NSString *)sponsor userIds:(NSArray *)userIds isFromGroup:(BOOL)isFromGroup callType:(CallType)callType {
    NSLog(@"📳 onError: sponsor:%@ userIds:%@",sponsor,userIds);
    NSMutableArray *userIdList = [NSMutableArray array];
    [userIdList addObject:sponsor];
    [userIdList addObjectsFromArray:userIds];
    self.type = callType;
    @weakify(self)
    [[V2TIMManager sharedInstance] getUsersInfo:userIdList succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        @strongify(self)
        CallUserModel *sponsorModel = [[CallUserModel alloc] init];
        NSMutableArray *inviteeList = [NSMutableArray array];
        for (V2TIMUserFullInfo *info in infoList) {
            CallUserModel *model = [[CallUserModel alloc] init];
            model.name = info.nickName;
            model.avatar = info.faceURL;
            model.userId = info.userID;
            if ([model.userId isEqualToString:sponsor]) {
                sponsorModel = model;
            } else {
                [inviteeList addObject:model];
            }
            if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
                CallUserModel *oldModel = [(TUIVideoCallViewController *)self.callVC getUserById:model.userId];
                model.isVideoAvaliable = oldModel.isVideoAvaliable;
            }
            if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
                CallUserModel *oldModel = [(TUIAudioCallViewController *)self.callVC getUserById:model.userId];
                model.isVideoAvaliable = oldModel.isVideoAvaliable;
            }
        }
        [self showCallVC:inviteeList sponsor:sponsorModel];
    } fail:nil];
}
   
-(void)onGroupCallInviteeListUpdate:(NSArray *)userIds {
    NSLog(@"📳 onGroupCallInviteeListUpdate userIds:%@",userIds);
}
   
-(void)onUserEnter:(NSString *)uid {
    NSLog(@"📳 onUserEnter uid:%@",uid);
    @weakify(self)
    [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
        @strongify(self)
        if (model) {
            model.isEnter = YES;
        }
        if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
            CallUserModel *oldModel = [(TUIVideoCallViewController *)self.callVC getUserById:model.userId];
            model.isVideoAvaliable = oldModel.isVideoAvaliable;
            [(TUIVideoCallViewController *)self.callVC enterUser:model];
        }
        if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
            CallUserModel *oldModel = [(TUIAudioCallViewController *)self.callVC getUserById:model.userId];
            model.isVideoAvaliable = oldModel.isVideoAvaliable;
            [(TUIAudioCallViewController *)self.callVC enterUser:model];
        }
    }];
}
   
-(void)onUserLeave:(NSString *)uid {
    NSLog(@"📳 onUserLeave uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Leave];
}

-(void)onReject:(NSString *)uid {
    NSLog(@"📳 onReject uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Reject];
}

-(void)onNoResp:(NSString *)uid {
    NSLog(@"📳 onNoResp uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Noresp];
}

-(void)onLineBusy:(NSString *)uid {
    NSLog(@"📳 onLineBusy uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Busy];
}

-(void)onCallingCancel:(NSString *)uid {
    NSLog(@"📳 onCallingCancel");
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        [(TUIVideoCallViewController *)self.callVC disMiss];
    }
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        [(TUIAudioCallViewController *)self.callVC disMiss];
    }
    
    // 获取个人信息
    if (uid.length == 0) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitCallCancelCallingFormat), uid]]; // %@ 取消了通话
        return;
    }
    [V2TIMManager.sharedInstance getUsersInfo:@[uid] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        if (infoList.count == 0) {
            [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitCallCancelCallingFormat), uid]]; // %@ 取消了通话
            return;
        }
        V2TIMUserFullInfo *info = infoList.firstObject;
        NSString *name = info.nickName;
        if (name.length == 0) {
            name = uid;
        }
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitCallCancelCallingFormat), name]]; // %@ 取消了通话
        
    } fail:^(int code, NSString *desc) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitCallCancelCallingFormat), uid]]; // %@ 取消了通话
    }];
    
}
   
-(void)onCallingTimeOut {
    NSLog(@"📳 onCallingTimeOut");
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        [(TUIVideoCallViewController *)self.callVC disMiss];
    }
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        [(TUIAudioCallViewController *)self.callVC disMiss];
    }
}

-(void)onCallEnd {
    NSLog(@"📳 onCallEnd");
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        [(TUIVideoCallViewController *)self.callVC disMiss];
    }
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        [(TUIAudioCallViewController *)self.callVC disMiss];
    }
}

-(void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"📳 onUserVideoAvailable:%@ available:%d",uid,available);
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        TUIVideoCallViewController *videoVC = (TUIVideoCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.isEnter = YES;
            model.isVideoAvaliable = available;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                model.isVideoAvaliable = available;
                [videoVC enterUser:model];
            }];
        }
    }
}
   
-(void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"📳 onUserAudioAvailable:%@ available:%d",uid,available);
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        TUIAudioCallViewController *videoVC = (TUIAudioCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.isEnter = YES;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                [videoVC enterUser:model];
            }];
        }
    }
}
   
-(void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume {
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        TUIAudioCallViewController *videoVC = (TUIAudioCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.volume = (CGFloat)volume / 100;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                model.volume = (CGFloat)volume / 100;
                if ([uid isEqualToString:TUICallUtils.loginUser]) {
                    [videoVC updateUser:model animate:NO];
                }else {
                    [videoVC enterUser:model];
                }
            }];
        }
    }
}
   
- (void)removeUserFromCallVC:(NSString *)uid reason:(VideoUserRemoveReason)reason {
    if ([self.callVC isKindOfClass:[TUIVideoCallViewController class]]) {
        TUIVideoCallViewController *videoVC = (TUIVideoCallViewController *)self.callVC;
        [videoVC leaveUser:uid];
    }
    if ([self.callVC isKindOfClass:[TUIAudioCallViewController class]]) {
        TUIAudioCallViewController *videoVC = (TUIAudioCallViewController *)self.callVC;
        [videoVC leaveUser:uid];
    }
}

#pragma mark - 权限检查
- (BOOL)checkAudioAuthorization {
    return [self checkAuthorizationStatus:AVMediaTypeAudio];
}

- (BOOL)checkVideoAuthorization {
    return [self checkAuthorizationStatus:AVMediaTypeVideo];
}

- (BOOL)checkAuthorizationStatus:(AVMediaType)mediaType {
    AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorStatus == AVAuthorizationStatusRestricted ||
        authorStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

@end
