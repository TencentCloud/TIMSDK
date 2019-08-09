#import "TUIJoinGroupMessageCellData.h"

@implementation TUIJoinGroupMessageCellData

- (instancetype)init{
   self = [super init];
    if(self){
        self.userName = [NSMutableArray array];
        self.userID = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        self.userName = [NSMutableArray array];
        self.userID = [NSMutableArray array];
    }
    return self;
}

@end
