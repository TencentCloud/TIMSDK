//
//  TCommonContactSelectCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import "TCommonContactSelectCellData.h"
#import "TIMUserProfile+DataProvider.h"

@implementation TCommonContactSelectCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (void)updateFromFriend:(TIMFriend *)afriend {

    if (afriend.remark.length) {
        _title = afriend.remark;
    } else {
        _title = [afriend.profile showName];
    }
    if (afriend.profile.faceURL.length) {
        _avatarUrl = [NSURL URLWithString:afriend.profile.faceURL];
    }
    _identifier = afriend.identifier;
}

- (NSComparisonResult)compare:(TCommonContactSelectCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end
