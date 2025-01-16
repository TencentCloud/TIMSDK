//
//  TUIMemberInfoCell_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMemberInfoCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIMemberInfoCellData.h"
#import "UIImageView+WebCache.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIMemberInfoCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nameLabel];
}

- (void)setData:(TUIMemberInfoCellData_Minimalist *)data {
    _data = data;

    UIImage *defaultImage = DefaultAvatarImage;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatar ?: defaultImage];
    self.nameLabel.text = data.name;

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
    CGFloat imgWidth = kScale390(20);
    if (self.data.style == TUIMemberInfoCellStyleAdd) {
        imgWidth = 20.0 * kScale;
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(20.0 * kScale);
            make.leading.mas_equalTo(kScale390(18));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = [UIColor tui_colorWithHex:@"#147AFF"];
    } else {
        imgWidth = 34.0 * kScale;
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(34.0 * kScale);
            make.leading.mas_equalTo(kScale390(16));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
    }

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.nameLabel sizeToFit];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).mas_offset(14);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.nameLabel.frame.size);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- 2.0 * kScale);
    }];

    
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:18.0 * kScale];
        _nameLabel.textColor = [UIColor colorWithRed:17 / 255.0 green:17 / 255.0 blue:17 / 255.0 alpha:1 / 1.0];
    }
    return _nameLabel;
}

@end
