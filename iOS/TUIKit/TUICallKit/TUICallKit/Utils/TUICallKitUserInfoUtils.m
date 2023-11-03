//
//  TUICallKitUserInfoUtils.m
//  TUICallKit
//
//  Created by noah on 2023/10/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallKitUserInfoUtils.h"
#import "TUICallKitHeader.h"
#import "TUICallingUserModel.h"

@implementation TUICallKitUserInfoUtils

+ (void)getUserInfo:(NSArray<NSString *> *)userList succ:(TUICallUserModelListSucc)succ fail:(TUICallUserModelFail)fail {
    if (!userList || (userList.count <= 0)) {
        if (fail) {
            fail(-1, @"getUserInfo, userIdList is empty");
        }
        return;
    }
    
    [[V2TIMManager sharedInstance] getFriendsInfo:userList succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        NSMutableArray *userModelList = @[].mutableCopy;
        
        for (V2TIMFriendInfoResult *friendInfoResult in resultList) {
            CallingUserModel *userInfo = [[CallingUserModel alloc] init];
            userInfo.userId = friendInfoResult.friendInfo.userID;
            
            NSString *name = friendInfoResult.friendInfo.friendRemark;
            if (!name || (name.length <= 0)) {
                name = friendInfoResult.friendInfo.userFullInfo.nickName;
            }
            if (!name || (name.length <= 0)) {
                name = friendInfoResult.friendInfo.userID;
            }
            
            userInfo.name = name;
            userInfo.avatar = friendInfoResult.friendInfo.userFullInfo.faceURL;
            
            [userModelList addObject:userInfo];
        }
        
        if (succ) {
            succ([userModelList copy]);
        }
    } fail:^(int code, NSString *desc) {
        if (fail) {
            fail(code, desc);
        }
    }];
}

@end
