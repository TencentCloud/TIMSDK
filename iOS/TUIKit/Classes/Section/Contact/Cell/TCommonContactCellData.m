//
//  TCommonFriendCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonContactCellData.h"
#import "TIMUserProfile+DataProvider.h"
@import ImSDK;

@implementation TCommonContactCellData
{
    TIMFriend *_friendProfile;
}

- (instancetype)initWithFriend:(TIMFriend *)args {
    self = [super init];
    
    if (args.remark.length) {
        _title = args.remark;
    } else {
        _title = [args.profile showName];
    }
    
    _identifier = args.identifier;
    _friendProfile = args;
    
    return self;
}

- (NSComparisonResult)compare:(TCommonContactCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end
