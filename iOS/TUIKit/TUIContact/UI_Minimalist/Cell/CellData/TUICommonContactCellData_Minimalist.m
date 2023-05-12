//
//  TCommonFriendCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUICommonContactCellData_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUICommonContactCellData_Minimalist
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
    _userID = args.userID;
    _faceUrl = args.userFullInfo.faceURL;
    return self;
}

- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args
{
    self = [super init];

    _title = args.groupName;
    _avatarImage = DefaultGroupAvatarImageByGroupType(args.groupType);
    _avatarUrl = [NSURL URLWithString:args.faceURL];
    _identifier = args.groupID;
    _groupID = args.groupID;
    _groupType = args.groupType;
    _faceUrl = args.faceURL;
    return self;
}

- (NSComparisonResult)compare:(TUICommonContactCellData_Minimalist *)data
{
    return [self.title localizedCompare:data.title];
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return 56;
}
@end
