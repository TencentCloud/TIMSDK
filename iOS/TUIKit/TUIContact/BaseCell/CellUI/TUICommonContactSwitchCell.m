//
//  TUIContactCommonSwitchCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonContactSwitchCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

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
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;
        height += size.height + 10;
    }
    return height;
}

@end

@interface TUICommonContactSwitchCell ()

@property TUICommonContactSwitchCellData *switchData;

@end

@implementation TUICommonContactSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#444444");
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
        [self.contentView addSubview:_titleLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = TIMCommonDynamicColor(@"group_modify_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 0;
        _descLabel.rtlAlignment = TUITextRTLAlignmentLeading;
        _descLabel.hidden = YES;
        [self.contentView addSubview:_descLabel];

        _switcher = [[UISwitch alloc] init];
        // Change the color when the switch is on to blue
        _switcher.onTintColor = TIMCommonDynamicColor(@"common_switch_on_color", @"#147AFF");
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
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    if (self.switchData.desc.length > 0) {
        _descLabel.text = self.switchData.desc;
        _descLabel.hidden = NO;

        NSString *str = self.switchData.desc;
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
        CGSize size = [str boundingRectWithSize:CGSizeMake(264, 999)
                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil]
                          .size;

        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(24);
            make.leading.mas_equalTo(self.switchData.margin);
            make.top.mas_equalTo(12);
        }];
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(2);
        }];
    } else {
        [self.titleLabel sizeToFit];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.titleLabel.frame.size);
            make.leading.mas_equalTo(self.switchData.margin);
            make.centerY.mas_equalTo(self.contentView);
        }];
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
