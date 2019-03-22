//
//  TRichMenuCell.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import "TRichMenuCell.h"
#import "TRichMenuCellData.h"
#import "THeader.h"
#import "NSString+Common.h"
#import "UIView+MMLayout.h"

@implementation TRichMenuCell
{
    BOOL _isRunAction;
}


+ (NSInteger)heightOf:(TRichMenuCellData *)item
{
    switch (item.type)
    {
        case ERichCell_RichText:            // 有富文内容
        {
            CGSize size = CGSizeMake(Screen_Width - (item.margin + item.tipWidth + kDefaultRichCellMargin + kDefaultRichCellMargin), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultRichCellHeight)
            {
                size.height = kDefaultRichCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_RichTextNext:         // 有富文内容，有下一步
        {
            CGSize size = CGSizeMake(Screen_Width - (item.margin + item.tipWidth + kDefaultRichCellMargin  - 64/*》到边界的距*/), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultRichCellHeight)
            {
                size.height = kDefaultRichCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_MemberPanel:               // 需要编辑:
        {
            return 70;
        }
            break;
        default:
        {
            return kDefaultRichCellHeight;
        }
            break;
    }
    return kDefaultRichCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _desc = [[UILabel alloc] init];
        _desc.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_desc];
        
        _value = [[UILabel alloc] init];
        _value.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_value];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)onSwitchChanged:(UISwitch *)sw
{
//    sw.on = !sw.on;
    if (_data.action)
    {
        _data.action(_data, self);
    }
}

- (void)setData:(TRichMenuCellData *)data
{
    _data = data;
    _data.assignCell = self;
    
    _desc.text = _data.desc;
    _desc.textColor = _data.descColor;
    _desc.font = _data.descFont;
    
    _value.text = _data.value;
    _value.textColor = _data.valueColor;
    _value.font = _data.valueFont;
    
    BOOL isRichText = _data.type == ERichCell_RichText || _data.type == ERichCell_RichTextNext;
    _value.textAlignment = _data.valueAlignment;
    _value.numberOfLines = isRichText ? 0 : 1;
    _value.lineBreakMode = isRichText ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;
    
    switch (_data.type)
    {
        case ERichCell_Text:                 // 普通的显示
        {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case ERichCell_RichText:            // 有富文内容
        {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case ERichCell_TextNext:             // 普通的显示，有下一步
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_RichTextNext:         // 有富文内容，有下一步
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_Member:
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_Switch:
        {
            if (!_onSwitch) {
                _onSwitch = [[UISwitch alloc] init];
            }
            [_onSwitch addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            self.accessoryView = _onSwitch;
            _onSwitch.on = _data.switchValue;
            _onSwitch.enabled = _data.switchIsEnable;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    
    _desc.m_left(_data.margin).m_width(_data.tipWidth).m_flexToBottom(0).m_centerY();
    _value.m_left(_desc.mm_maxX+_data.margin).m_flexToRight(_data.margin).m_flexToBottom(0).m_centerY();
}

- (void)doAction
{
    if (self.data.action) {
        self.data.action(self.data, self);
    }
}

@end

