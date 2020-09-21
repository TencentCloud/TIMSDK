//
//  TUIVideoCallViewController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VideoCallState) {
    VideoCallState_Dailing,      //呼叫
    VideoCallState_OnInvitee,    //被呼叫
    VideoCallState_Calling,      //通话中
};

@interface TUIVideoCallViewController : UIViewController
@property(nonatomic,strong) DismissBlock dismissBlock;
///如果是自己主动发起的邀请，sponsor 传 nil，如果是自己被其他人然邀请，sponsor 传邀请人的 userModel
- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList;

///有用户进入通话
- (void)enterUser:(CallUserModel *)user;

///通话用户状态更新
- (void)updateUser:(CallUserModel *)user animate:(BOOL)animate;

///有用户离开通话
- (void)leaveUser:(NSString *)userId;

///关闭 VC
- (void)disMiss;

///通过 userID 获取通话用户的 model 信息
- (CallUserModel *)getUserById:(NSString *)userID;
@end

NS_ASSUME_NONNULL_END
