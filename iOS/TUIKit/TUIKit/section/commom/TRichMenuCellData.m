//
//  TRichMenuCellData.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TRichMenuCellData.h"
#import "THeader.h"

@implementation TRichMenuCellData

- (instancetype)init
{
    if (self = [super init])
    {
        _margin = kDefaultRichCellMargin;
        _tipWidth = 80;
        
        _descColor = kRichCellTipsColor;
        _descFont = kRichCellTextFont;
        
        _valueColor = kRichCellValueColor;
        _valueFont = kRichCellTextFont;
        
        
    }
    return self;
}

- (NSString *)reuseIndentifier
{
    return [TRichMenuCellData reuseIndentifierOf:self.type];
}

+ (NSString *)reuseIndentifierOf:(TRichCellMenuDataType)type
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
