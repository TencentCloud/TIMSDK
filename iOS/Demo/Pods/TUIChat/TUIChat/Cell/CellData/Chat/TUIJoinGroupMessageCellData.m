#import "TUIJoinGroupMessageCellData.h"

@implementation TUIJoinGroupMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        self.userNameList = [NSMutableArray array];
        self.userIDList = [NSMutableArray array];
    }
    return self;
}

@end
