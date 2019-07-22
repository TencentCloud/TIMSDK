#import "TCommonContactCellData.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIKit.h"
#import "THeader.h"

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
    _avatarUrl = [NSURL URLWithString:args.profile.faceURL];
    _friendProfile = args;
    
    return self;
}

- (instancetype)initWithGroupInfo:(TIMGroupInfo *)args
{
    self = [super init];
    
    _title = args.groupName;
    _avatarImage = DefaultGroupAvatarImage;
    
    _identifier = args.group;
    
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
