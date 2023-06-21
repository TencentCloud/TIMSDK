//
//  TUIFindContactCell.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFindContactCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIFindContactCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.mainTitleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.descLabel];
}

- (void)setData:(TUIFindContactCellModel_Minimalist *)data {
    _data = data;

    self.mainTitleLabel.text = data.mainTitle;
    self.subTitleLabel.attributedText = [self.class attributeStringWithText:[NSString stringWithFormat:@"ID:%@", data.subTitle] key:data.subTitle];
    self.descLabel.text = data.desc;
    UIImage *placeHolder = (data.type == TUIFindContactTypeC2C_Minimalist) ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(data.groupInfo.groupType);
    [self.avatarView sd_setImageWithURL:data.avatarUrl placeholderImage:data.avatar ?: placeHolder];

    self.descLabel.hidden = (data.type == TUIFindContactTypeC2C_Minimalist);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.avatarView.mm_left(16 * kScale).mm_top(10 * kScale).mm_width(43 * kScale).mm_height(43 * kScale);
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.mainTitleLabel.mm_sizeToFit();
    self.mainTitleLabel.mm_x = CGRectGetMaxX(self.avatarView.frame) + 12 * kScale;
    self.mainTitleLabel.mm_y = self.avatarView.mm_y;
    self.mainTitleLabel.mm_flexToRight(12 * kScale);

    self.subTitleLabel.mm_sizeToFit();
    self.subTitleLabel.mm_x = self.mainTitleLabel.mm_x;
    self.subTitleLabel.mm_y = CGRectGetMaxY(self.mainTitleLabel.frame) + kScale390(4);
    self.subTitleLabel.mm_flexToRight(12 * kScale);

    self.descLabel.mm_sizeToFit();
    self.descLabel.mm_x = self.mainTitleLabel.mm_x;
    self.descLabel.mm_y = CGRectGetMaxY(self.subTitleLabel.frame) + kScale390(4);
    self.descLabel.mm_flexToRight(12 * kScale);
}

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 3 * kScale;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)mainTitleLabel {
    if (_mainTitleLabel == nil) {
        _mainTitleLabel = [[UILabel alloc] init];
        _mainTitleLabel.text = @"mainTitle";
        _mainTitleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
        _mainTitleLabel.font = [UIFont boldSystemFontOfSize:kScale390(16)];
    }
    return _mainTitleLabel;
}

- (UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.text = @"subTitle";
        _subTitleLabel.textColor = [UIColor tui_colorWithHex:@"#104EF5"];
        _subTitleLabel.font = [UIFont systemFontOfSize:kScale390(12)];
    }
    return _subTitleLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"descLabel";
        _descLabel.textColor = TIMCommonDynamicColor(@"form_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:kScale390(12)];
    }
    return _descLabel;
}

+ (NSAttributedString *)attributeStringWithText:(NSString *)text key:(NSString *)key {
    if (text.length == 0) {
        return nil;
    }

    if (key == nil || key.length == 0 || ![text.lowercaseString containsString:key.lowercaseString]) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:text
                                                                              attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        return attributeString;
    }

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text
                                                                             attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];

    NSUInteger loc = 0;
    NSUInteger len = text.length;
    while (len > 0) {
        NSRange range = [text.lowercaseString rangeOfString:key.lowercaseString options:NSCaseInsensitiveSearch range:NSMakeRange(loc, len)];
        if (range.length) {
            [attr addAttribute:NSForegroundColorAttributeName value:TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF") range:range];
            loc = range.location + 1;
            len = text.length - loc;
        } else {
            len = 0;
            loc = 0;
        }
    }
    return [[NSAttributedString alloc] initWithAttributedString:attr];
}
@end
