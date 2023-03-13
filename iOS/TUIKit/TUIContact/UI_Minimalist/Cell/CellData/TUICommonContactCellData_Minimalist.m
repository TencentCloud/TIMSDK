//
//  TCommonFriendCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUICommonContactCellData_Minimalist.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"

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

    return self;
}

- (instancetype)initWithGroupInfo:(V2TIMGroupInfo *)args
{
    self = [super init];

    _title = args.groupName;
    _avatarImage = DefaultGroupAvatarImageByGroupType(args.groupType);
    _avatarUrl = [NSURL URLWithString:args.faceURL];
    _identifier = args.groupID;

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
