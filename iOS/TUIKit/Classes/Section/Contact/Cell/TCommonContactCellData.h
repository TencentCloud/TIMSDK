//
//  TCommonFriendCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import <Foundation/Foundation.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
@class V2TIMFriendInfo;
@class V2TIMGroupInfo;

@interface TCommonContactCellData : TCommonCellData

- (instancetype)initWithFriend:(V2TIMFriendInfo *)args;
- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args;

@property V2TIMFriendInfo *friendProfile;
@property NSString *identifier;

@property NSURL *avatarUrl;
@property NSString *title;
@property UIImage *avatarImage;

@end

NS_ASSUME_NONNULL_END
