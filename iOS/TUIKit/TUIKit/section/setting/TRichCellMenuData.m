//
//  TRichCellMenuData.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "RichCellMenuData.h"

@implementation TRichMenuCellData

- (instancetype)init
{
    if (self = [super init])
    {
        _tipMargin = kDefaultMargin;
        _tipWidth = 80;
        
        _tipColor = kLightGrayColor;
        _tipFont = kAppMiddleTextFont;
        
        _valueColor = kBlackColor;
        _valueFont = kAppMiddleTextFont;
        
        _switchIsEnable = YES;
    }
    return self;
}

- (NSString *)reuseIndentifier
{
    return [TRichCellMenuData reuseIndentifierOf:self.type];
}

+ (NSString *)reuseIndentifierOf:(RichCellMenuItemType)type
{
    switch (type)
    {
        case ERichCell_Switch:               // 需要编辑:
        {
            return @"RichCellMenuItemSwitch";
        }
            break;
        case ERichCell_Member:
        {
            return @"RichCellMenuItemMember";
        }
            break;
        case ERichCell_MemberPanel:
        {
            return @"RichCellMenuItemMemberPanel";
        }
            break;

            
        default:
        {
            return @"RichCellMenuItem";
        }
            break;
    }
    return @"RichCellMenuItem";
}

@end


@implementation TRichMemersMenuItem


@end
