//
//  TUIContactCommonSwitchCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import "TUICommonContactSwitchCell.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUICommonContactSwitchCellData

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

@interface TUICommonContactSwitchCell()

@property TUICommonContactSwitchCellData *switchData;

@end

@implementation TUICommonContactSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
        //将开关开启时的颜色改为蓝色
        _switcher.onTintColor = TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
        self.accessoryView = _switcher;
        [self.contentView addSubview:_switcher];
        [_switcher addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventValueChanged];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)fillWithData:(TUICommonContactSwitchCellData *)switchData {
    [super fillWithData:switchData];

    self.switchData = switchData;
    _titleLabel.text = switchData.title;
    [_switcher setOn:switchData.isOn];
    
    if (switchData.desc.length > 0) {
        _descLabel.text = switchData.desc;
        _descLabel.hidden = NO;
        
        NSString *str = switchData.desc;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;

        _titleLabel.mm_width(size.width).mm_height(24).mm_left(switchData.margin).mm_top(12);
        _descLabel.mm_width(size.width).mm_height(size.height).mm_left(_titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + 2);
    } else {
        _titleLabel.mm_sizeToFit().mm_left(switchData.margin).mm__centerY(self.contentView.mm_h / 2);
    }

}

- (void)switchClick {
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
