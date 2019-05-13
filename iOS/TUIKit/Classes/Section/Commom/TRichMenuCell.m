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
#import "MMLayout/UIView+MMLayout.h"

NSString *const kRichMenuCellReuseIdentifier = @"RichMenuCellReuseIdentifier";

@implementation TRichMenuCell
{
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _desc = [[UILabel alloc] init];
        _desc.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_desc];
        _desc.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        _value = [[UILabel alloc] init];
        _value.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_value];
        _value.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        _onSwitch = [[UISwitch alloc] init];
        [_onSwitch addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)onSwitchChanged:(UISwitch *)sw
{
    if (_data.onSwitchAction)
    {
        _data.onSwitchAction(_data, self);
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
    _value.textAlignment = _data.valueAlignment;
    
    switch (_data.type)
    {
        case ERichCell_Text:                 // 普通的显示
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.accessoryView = nil;
        }
            break;
        case ERichCell_TextNext:             // 普通的显示，有下一步
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.accessoryView = nil;
        }
            break;
        case ERichCell_Switch:
        {
            self.accessoryView = _onSwitch;
            _onSwitch.on = _data.switchValue;
        }
            break;
            
        default:
            break;
    }
    
    _desc.mm_left(_data.margin).mm_width(_data.descWidth).mm_height(self.contentView.mm_h);
    _value.mm_width(_data.valueWidth).mm_height(self.contentView.mm_h);
    if (self.accessoryView || self.accessoryType != UITableViewCellAccessoryNone) {
        _value.mm_right(0);
    } else {
         _value.mm_right(_data.margin);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
        [self onSelect];
}

- (void)onSelect
{
    if (self.data.onSelectAction) {
        self.data.onSelectAction(self.data, self);
    }
}
@end

