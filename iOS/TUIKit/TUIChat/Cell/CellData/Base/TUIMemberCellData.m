//
//  TUIMemberCellData.m
//  TUIChat
//
//  Created by summeryxia on 2022/3/14.
//

#import "TUIMemberCellData.h"

@implementation TUIMemberCellData

- (instancetype)initWithMember:(V2TIMGroupMemberInfo *)member {
    self = [super init];

    _member = member;
    _avatarURL = [NSURL URLWithString:member.faceURL];
    
    if (member.nameCard.length > 0) {
        _title = member.nameCard;
    } else if (member.friendRemark.length > 0) {
        _title = member.friendRemark;
    } else if (member.nickName.length > 0) {
        _title = member.nickName;
    } else {
        _title = member.userID;
    }

    return self;
}

@end
