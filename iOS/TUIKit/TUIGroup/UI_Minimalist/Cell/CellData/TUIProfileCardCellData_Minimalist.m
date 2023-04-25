//
//  TUIProfileCardCellData_Minimalist.m
//  Masonry
//
//  Created by wyl on 2022/12/6.
//

#import "TUIProfileCardCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIProfileCardCellData_Minimalist

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return kScale390(86);
}

@end
