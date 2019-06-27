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
@import ImSDK;

@interface TUIGroupPendencyCellData ()
@property TIMUserProfile *fromUserProfile;
@property TIMGroupPendencyItem *pendencyItem;
@end

@implementation TUIGroupPendencyCellData

- (instancetype)initWithPendency:(TIMGroupPendencyItem *)args {
    self = [super init];
    
    _pendencyItem = args;
    
    _groupId = args.groupId;
    _fromUser = args.fromUser;
    _title = _fromUser;
    _requestMsg = args.requestMsg;
    

    
//    [[TIMFriendshipManager sharedInstance] getUsersProfile:@[_fromUser] forceUpdate:NO succ:^(NSArray<TIMUserProfile *> *profiles) {
//        self.fromUserProfile = profiles.firstObject;
//        self.title = [self.fromUserProfile showName];
//    } fail:nil];
    
    if (_requestMsg.length == 0) {
        _requestMsg = [NSString stringWithFormat:@"%@申请加入群聊", _title];
    }
    
    return self;
}

- (void)accept
{
    [_pendencyItem accept:@"管理员同意申请" succ:^{
        [[self toastView] makeToast:@"已发送"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];
    } fail:^(int code, NSString *msg) {
        [[self toastView] makeToast:msg];
    }];
    self.isAccepted = YES;
}
- (void)reject
{
    [_pendencyItem refuse:@"管理员拒绝申请" succ:^{
        [[self toastView] makeToast:@"已发送"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIGroupPendencyCellData_onPendencyChanged object:nil];
    } fail:^(int code, NSString *msg) {
        [[self toastView] makeToast:msg];
    }];
    self.isRejectd = YES;
}


- (UIView *)toastView
{
    return [UIApplication sharedApplication].keyWindow;
}
@end
