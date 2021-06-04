//
//  TUIGroupPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TUIGroupPendencyCellData.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import "TUIKit.h"
#import "NSBundle+TUIKIT.h"

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
        _requestMsg = [NSString stringWithFormat:TUILocalizableString(TUIKitWhoRequestForJoinGroupFormat), _title];
    }

    return self;
}

- (void)accept
{
    [[V2TIMManager sharedInstance] acceptGroupApplication:_pendencyItem reason:TUILocalizableString(TUIKitAgreedByAdministor) succ:^{
        [THelper makeToast:TUILocalizableString(Have-been-sent)];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    self.isAccepted = YES;
}
- (void)reject
{
    [[V2TIMManager sharedInstance] refuseGroupApplication:_pendencyItem reason:TUILocalizableString(TUIkitDiscliedByAdministor) succ:^{
        [THelper makeToast:TUILocalizableString(Have-been-sent)];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    self.isRejectd = YES;
}


@end
