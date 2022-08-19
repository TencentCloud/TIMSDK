//
//  TUICommonSwitchCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TUICommonSwitchCell.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUICommonSwitchCellData
- (instancetype)init {
    self = [super init];
    _margin = 20;
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];
    if (self.desc.length > 0) {
        NSString *str = self.desc;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
        height += size.height + 10;
    }
    return height;
}

@end

@interface TUICommonSwitchCell()

@property TUICommonSwitchCellData *switchData;
@property (nonatomic,strong) UIView * leftSeparatorLine;

@end

@implementation TUICommonSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = TUICoreDynamicColor(@"group_modify_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.hidden = YES;
        [self.contentView addSubview:_descLabel];
        
        _switcher = [[UISwitch alloc] init];
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.accessoryView = _switcher;
        [self.contentView addSubview:_switcher];
        [_switcher addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];

        _leftSeparatorLine = [[UIView alloc] init];
        _leftSeparatorLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
        [self.contentView addSubview:_leftSeparatorLine];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.switchData.disableChecked) {
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.alpha = 0.4;
        _switcher.alpha = 0.4;
        self.userInteractionEnabled = NO;
    }
    else {
        _titleLabel.alpha = 1;
        _switcher.alpha = 1;
        _titleLabel.textColor = TUICoreDynamicColor(@"form_key_text_color", @"#444444");
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.userInteractionEnabled = YES;
    }
    
    CGFloat leftMargin = 0 ;
    CGFloat padding = 5;
    if (self.switchData.displaySeparatorLine) {
        _leftSeparatorLine.mm_width(10).mm_height(2).mm_left(self.switchData.margin).mm__centerY(self.contentView.mm_h / 2);
        leftMargin  = self.switchData.margin + _leftSeparatorLine.mm_w + padding;
    }
    else {
        _leftSeparatorLine.mm_width(0).mm_height(0);
        leftMargin = self.switchData.margin;
    }
    
    if (self.switchData.desc.length > 0) {
        _descLabel.text = self.switchData.desc;
        _descLabel.hidden = NO;
        NSString *str = self.switchData.desc;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
        _titleLabel.mm_width(size.width).mm_height(24).mm_left(leftMargin).mm_top(12);
        _descLabel.mm_width(size.width).mm_height(size.height).mm_left(_titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + 2);
    } else {
        _descLabel.text =  @"";
        _titleLabel.mm_sizeToFit().mm_left(leftMargin).mm__centerY(self.contentView.mm_h / 2);
    }
    
}

- (void)fillWithData:(TUICommonSwitchCellData *)switchData
{
    [super fillWithData:switchData];

    self.switchData = switchData;
    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];
    _descLabel.text = switchData.desc;

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
