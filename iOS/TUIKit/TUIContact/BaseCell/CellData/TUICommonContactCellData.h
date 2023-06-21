//
//  TCommonFriendCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN
@class V2TIMFriendInfo;
@class V2TIMGroupInfo;

typedef NS_ENUM(NSInteger, TUIContactOnlineStatus) { TUIContactOnlineStatusUnknown = 0, TUIContactOnlineStatusOnline = 1, TUIContactOnlineStatusOffline = 2 };

@interface TUICommonContactCellData : TUICommonCellData

- (instancetype)initWithFriend:(V2TIMFriendInfo *)args;
- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args;

@property V2TIMFriendInfo *friendProfile;
@property NSString *identifier;

@property NSURL *avatarUrl;
@property NSString *title;
@property UIImage *avatarImage;

// The flag of indicating the user's online status
@property(nonatomic, assign) TUIContactOnlineStatus onlineStatus;

@end

NS_ASSUME_NONNULL_END
