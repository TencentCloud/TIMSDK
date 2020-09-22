//
//  TCommonSwitchCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TCommonSwitchCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@implementation TCommonSwitchCellData
- (instancetype)init {
    self = [super init];
    _margin = 15;
    return self;
}

@end

@interface TCommonSwitchCell()
@property TCommonSwitchCellData *switchData;
@end

@implementation TCommonSwitchCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _titleLabel = self.textLabel;
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        
        _switcher = [[UISwitch alloc] init];
        //将开关开启时的颜色改为蓝色
        _switcher.onTintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];

        self.accessoryView = _switcher;
        [self.contentView addSubview:_switcher];
        [_switcher addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)fillWithData:(TCommonSwitchCellData *)switchData
{
    [super fillWithData:switchData];

    self.switchData = switchData;

    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];

    _titleLabel.mm_sizeToFit().mm_left(switchData.margin).mm__centerY(self.contentView.mm_h / 2);
}

- (void)switchClick
{
    if (self.switchData.cswitchSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.switchData.cswitchSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.switchData.cswitchSelector withObject:self];
#pragma clang diagnostic pop
        }
    }

}
@end
