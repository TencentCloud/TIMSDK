//
//  TUIContactProfileCardCellData_Minimalist.m
//  TUIContact
//
//  Created by cologne on 2023/2/1.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactProfileCardCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIContactProfileCardCellData_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    return kScale390(86);
}

@end
