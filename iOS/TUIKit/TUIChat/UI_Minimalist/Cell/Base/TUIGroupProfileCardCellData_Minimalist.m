//
//  TUIGroupProfileCardCellData_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupProfileCardCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIGroupProfileCardCellData_Minimalist
- (instancetype)init {
    self = [super init];
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    return kScale390(329);
}

@end
