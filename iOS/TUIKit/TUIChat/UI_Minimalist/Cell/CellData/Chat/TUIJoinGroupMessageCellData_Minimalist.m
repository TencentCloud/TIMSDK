
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIJoinGroupMessageCellData_Minimalist.h"

@implementation TUIJoinGroupMessageCellData_Minimalist

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        self.userNameList = [NSMutableArray array];
        self.userIDList = [NSMutableArray array];
    }
    return self;
}

@end
