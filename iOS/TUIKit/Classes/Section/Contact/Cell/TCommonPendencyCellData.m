//
//  TCommonPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonPendencyCellData.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"

@implementation TCommonPendencyCellData

- (instancetype)initWithPendency:(TIMFriendPendencyItem *)args {
    self = [super init];
    
    _identifier = args.identifier;
    _title = args.identifier;
    if (args.addSource) {
        _addSource = [NSString stringWithFormat:@"来源: %@", [args.addSource substringFromIndex:@"AddSource_Type_".length]];
    }
    _addWording = args.addWording;
    _isAccepted = NO;

    return self;
}

- (BOOL)isEqual:(TCommonPendencyCellData *)object
{
    return [self.identifier isEqual:object.identifier];
}

- (void)agree
{
    TIMFriendResponse *rsp = TIMFriendResponse.new;
    rsp.identifier = _identifier;
    rsp.responseType = TIM_FRIEND_RESPONSE_AGREE_AND_ADD;
    [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result) {
        [self.toastView makeToast:@"已发送"];
    } fail:^(int code, NSString *msg) {
        [self.toastView makeToast:msg];
    }];
}

- (void)reject
{
    TIMFriendResponse *rsp = TIMFriendResponse.new;
    rsp.identifier = _identifier;;
    rsp.responseType = TIM_FRIEND_RESPONSE_REJECT;
    [[TIMFriendshipManager sharedInstance] doResponse:rsp succ:^(TIMFriendResult *result) {
        [self.toastView makeToast:@"已发送"];
    } fail:^(int code, NSString *msg) {
        [self.toastView makeToast:msg];
    }];
}

- (UIView *)toastView
{
    return [UIApplication sharedApplication].keyWindow;
}
@end
