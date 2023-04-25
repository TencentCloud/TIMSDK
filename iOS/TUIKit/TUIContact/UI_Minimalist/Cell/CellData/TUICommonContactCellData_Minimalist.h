//
//  TCommonFriendCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN
@class V2TIMFriendInfo;
@class V2TIMGroupInfo;

typedef NS_ENUM(NSInteger, TUIContactOnlineStatus_Minimalist) {
    TUIContactOnlineStatusUnknown_Minimalist = 0,
    TUIContactOnlineStatusOnline_Minimalist  = 1,
    TUIContactOnlineStatusOffline_Minimalist = 2
};

@interface TUICommonContactCellData_Minimalist : TUICommonCellData

- (instancetype)initWithFriend:(V2TIMFriendInfo *)args;
- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args;

@property V2TIMFriendInfo *friendProfile;
@property NSString *identifier;

@property NSURL *avatarUrl;
@property NSString *title;
@property UIImage *avatarImage;

// The flag of indicating the user's online status
@property (nonatomic, assign) TUIContactOnlineStatus_Minimalist onlineStatus;

@end

NS_ASSUME_NONNULL_END
