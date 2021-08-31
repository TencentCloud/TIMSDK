//
//  TCommonFriendCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonContactCellData.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIKit.h"

@implementation TCommonContactCellData
{
    V2TIMFriendInfo *_friendProfile;
}

- (instancetype)initWithFriend:(V2TIMFriendInfo *)args {
    self = [super init];

    if (args.friendRemark.length) {
        _title = args.friendRemark;
    } else {
        _title = [args.userFullInfo showName];
    }

    _identifier = args.userID;
    _avatarUrl = [NSURL URLWithString:args.userFullInfo.faceURL];
    _friendProfile = args;

    return self;
}

- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args
{
    self = [super init];

    _title = args.groupName;
    _avatarImage = DefaultGroupAvatarImage;
    _avatarUrl = [NSURL URLWithString:args.faceURL];
    _identifier = args.groupID;

    return self;
}

- (NSComparisonResult)compare:(TCommonContactCellData *)data
{
    return [self.title localizedCompare:data.title];
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return 56;
}
@end
