//
//  TCommonPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonPendencyCellData.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUITool.h>
#import <TUICore/UIView+TUIToast.h>

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
        _addSource = [NSString
            stringWithFormat:TIMCommonLocalizableString(TUIKitAddFriendSourceFormat), [application.addSource substringFromIndex:@"AddSource_Type_".length]];
    }
    _addWording = application.addWording;
    _avatarUrl = [NSURL URLWithString:application.faceUrl];
    _isAccepted = NO;
    _application = application;
    _hideSource = NO;
    return self;
}

- (BOOL)isEqual:(TUICommonPendencyCellData *)object {
    return [self.identifier isEqual:object.identifier];
}

- (void)agree {
    [self agreeWithSuccess:nil failure:nil];
}

- (void)reject {
    [self rejectWithSuccess:nil failure:nil];
}


- (void)agreeWithSuccess:(TUICommonPendencyCellDataSuccessCallback)success failure:(TUICommonPendencyCellDataFailureCallback)failure {
    [[V2TIMManager sharedInstance] acceptFriendApplication:_application
        type:V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD
        succ:^(V2TIMFriendOperationResult *result) {
        if (success) {
            success();
        }
          [TUITool makeToast:TIMCommonLocalizableString(TUIKitFriendApplicationApproved)];
        }
        fail:^(int code, NSString *msg) {
          [TUITool makeToastError:code msg:msg];
            if (failure) {
                failure(code,msg);
            }
        }];
}

- (void)rejectWithSuccess:(TUICommonPendencyCellDataSuccessCallback)success failure:(TUICommonPendencyCellDataFailureCallback)failure {
    [[V2TIMManager sharedInstance] refuseFriendApplication:_application
        succ:^(V2TIMFriendOperationResult *result) {
        if (success) {
            success();
        }
            [TUITool makeToast:TIMCommonLocalizableString(TUIKitFirendRequestRejected)];
        }
        fail:^(int code, NSString *msg) {
            if (failure) {
                failure(code,msg);
            }
            [TUITool makeToastError:code msg:msg];
        }];
}

@end
