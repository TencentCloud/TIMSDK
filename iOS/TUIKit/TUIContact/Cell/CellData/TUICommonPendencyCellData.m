//
//  TCommonPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUICommonPendencyCellData.h"
#import "TUICommonModel.h"
#import "UIView+TUIToast.h"
#import "TUITool.h"
#import "TUIGlobalization.h"

@implementation TUICommonPendencyCellData

- (instancetype)initWithPendency:(V2TIMFriendApplication *)application {
    self = [super init];

    _identifier = application.userID;
    if (application.nickName.length > 0) {
        _title = application.nickName;
    } else {
        _title = _identifier;
    }
    if (application.addSource) {
        _addSource = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitAddFriendSourceFormat), [application.addSource substringFromIndex:@"AddSource_Type_".length]];
    }
    _addWording = application.addWording;
    _avatarUrl = [NSURL URLWithString:application.faceUrl];
    _isAccepted = NO;
    _application = application;
    _hideSource = NO;
    return self;
}

- (BOOL)isEqual:(TUICommonPendencyCellData *)object
{
    return [self.identifier isEqual:object.identifier];
}

- (void)agree
{
    [[V2TIMManager sharedInstance] acceptFriendApplication:_application type:V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD succ:^(V2TIMFriendOperationResult *result) {
        [TUITool makeToast:TUIKitLocalizableString(TUIKitFriendApplicationApproved)];
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

- (void)reject
{
    [[V2TIMManager sharedInstance] refuseFriendApplication:_application succ:^(V2TIMFriendOperationResult *result) {
        [TUITool makeToast:TUIKitLocalizableString(TUIKitFirendRequestRejected)];
    } fail:^(int code, NSString *msg) {
        [TUITool makeToastError:code msg:msg];
    }];
}

@end
