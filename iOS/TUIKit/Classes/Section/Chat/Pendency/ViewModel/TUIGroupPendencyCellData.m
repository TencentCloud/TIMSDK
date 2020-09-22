//
//  TUIGroupPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TUIGroupPendencyCellData.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import "THeader.h"
#import "THelper.h"
@import ImSDK;

@interface TUIGroupPendencyCellData ()
@property V2TIMUserFullInfo *fromUserProfile;
@property V2TIMGroupApplication *pendencyItem;
@end

@implementation TUIGroupPendencyCellData

- (instancetype)initWithPendency:(V2TIMGroupApplication *)args {
    self = [super init];

    _pendencyItem = args;

    _groupId = args.groupID;
    _fromUser = args.fromUser;
    if (args.fromUserNickName.length > 0) {
        _title = args.fromUserNickName;
    } else {
        _title = args.fromUser;
    }
    _avatarUrl = [NSURL URLWithString:args.fromUserFaceUrl];
    _requestMsg = args.requestMsg;
    if (_requestMsg.length == 0) {
        _requestMsg = [NSString stringWithFormat:@"%@申请加入群聊", _title];
    }

    return self;
}

- (void)accept
{
    [[V2TIMManager sharedInstance] acceptGroupApplication:_pendencyItem reason:@"管理员同意申请" succ:^{
        [THelper makeToast:@"已发送"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    self.isAccepted = YES;
}
- (void)reject
{
    [[V2TIMManager sharedInstance] refuseGroupApplication:_pendencyItem reason:@"管理员拒绝申请" succ:^{
        [THelper makeToast:@"已发送"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    self.isRejectd = YES;
}


@end
