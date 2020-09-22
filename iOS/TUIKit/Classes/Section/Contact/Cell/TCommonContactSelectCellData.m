
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

- (void)setProfile:(V2TIMUserFullInfo *)profile {

    self.title = [profile showName];
    if (profile.faceURL.length) {
        self.avatarUrl = [NSURL URLWithString:profile.faceURL];
    }
    self.identifier = profile.userID;
}

- (NSComparisonResult)compare:(TCommonContactSelectCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end
