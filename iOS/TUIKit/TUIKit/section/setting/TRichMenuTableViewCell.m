//
//  TRichMenuTableViewCell.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TRichMenuCell.h"
#import "TRichMenuCellData.h"
#import "THeader.h"


// 默认TableViewCell高度
#define kDefaultCellHeight 50
// 默认界面之间的间距
#define kDefaultMargin     8


@implementation TRichMenuCell


+ (NSInteger)heightOf:(TRichMenuCellData *)item
{
    switch (item.type)
    {
        case  ERichCell_Text:                 // 普通的显示
        {
            return kDefaultCellHeight;
        }
            break;
        case ERichCell_RichText:            // 有富文内容
        {
            CGSize size = CGSizeMake(Screen_Width - (item.tipMargin + item.tipWidth + kDefaultMargin + kDefaultMargin), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultCellHeight)
            {
                size.height = kDefaultCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_TextNext:             // 普通的显示，有下一步
        {
            return kDefaultCellHeight;
        }
            break;
        case ERichCell_RichTextNext:         // 有富文内容，有下一步
        {
            CGSize size = CGSizeMake(Screen_Width - (item.tipMargin + item.tipWidth + kDefaultMargin  - 64/*》到边界的距*/), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultCellHeight)
            {
                size.height = kDefaultCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_Switch:               // 需要编辑:
        {
            return kDefaultCellHeight;
        }
            
            break;
        case ERichCell_Member:               // 需要编辑:
        {
            return kDefaultCellHeight;
        }
            
            break;
        case ERichCell_MemberPanel:               // 需要编辑:
        {
            return 70;
        }
            
            break;
            
        default:
        {
            return kDefaultCellHeight;
        }
            break;
    }
    return kDefaultCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _tip = [[UILabel alloc] init];
        _tip.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_tip];
        
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
    if (_item.action)
    {
        _item.action(_item, self);
    }
}

- (void)setData:(TRichMenuCellData *)data
{
    _data = data;
    
    _tip.text = _data.tip;
    _tip.textColor = _data.tipColor;
    _tip.font = _data.tipFont;
    
    _value.text = _data.value;
    _value.textColor = _data.valueColor;
    _value.font = _data.valueFont;
    
    BOOL isRichText = item.type == ERichCell_RichText || item.type == ERichCell_RichTextNext;
    BOOL isMem = item.type == ERichCell_Member;
    _value.textAlignment = isMem ? NSTextAlignmentRight : item.valueAlignment;
    _value.numberOfLines = isRichText ? 0 : 1;
    _value.lineBreakMode = isRichText ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;
    
    switch (item.type)
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
            _onSwitch.on = item.switchValue;
            _onSwitch.enabled = item.switchIsEnable;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.contentView.bounds;
    [_tip sizeWith:CGSizeMake(_item.tipWidth, rect.size.height)];
    [_tip alignParentLeftWithMargin:_item.tipMargin];
    
    [_value sameWith:_tip];
    [_value layoutToRightOf:_tip margin:kDefaultMargin];
    [_value scaleToParentRightWithMargin:kDefaultMargin];
}

@end

