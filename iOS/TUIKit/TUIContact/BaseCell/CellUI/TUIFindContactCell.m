//
//  TUIFindContactCell.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFindContactCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIFindContactCell

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

- (void)setData:(TUIFindContactCellModel *)data {
    _data = data;

    self.mainTitleLabel.text = data.mainTitle;
    self.subTitleLabel.text = data.subTitle;
    self.descLabel.text = data.desc;
    UIImage *placeHolder = (data.type == TUIFindContactTypeC2C) ? DefaultAvatarImage : DefaultGroupAvatarImageByGroupType(data.groupInfo.groupType);
    [self.avatarView sd_setImageWithURL:data.avatarUrl placeholderImage:data.avatar ?: placeHolder];

    self.descLabel.hidden = (data.type == TUIFindContactTypeC2C);
    
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
    
    CGFloat imgWidth = kScale390(48);
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.top.mas_equalTo(kScale390(10));
        make.leading.mas_equalTo(kScale390(16));
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.mainTitleLabel sizeToFit];
    [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarView.mas_top);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- kScale390(12));
    }];
    [self.subTitleLabel sizeToFit];
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).mas_offset(2);
        make.leading.mas_equalTo(self.mainTitleLabel.mas_leading);
        make.height.mas_equalTo(self.subTitleLabel.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- kScale390(12));
    }];
    [self.descLabel sizeToFit];
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).mas_offset(2);
        make.leading.mas_equalTo(self.mainTitleLabel.mas_leading);
        make.height.mas_equalTo(self.subTitleLabel.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- kScale390(12));
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
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
        _mainTitleLabel.font = [UIFont systemFontOfSize:18.0 * kScale];
    }
    return _mainTitleLabel;
}

- (UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.text = @"subTitle";
        _subTitleLabel.textColor = TIMCommonDynamicColor(@"form_subtitle_color", @"#888888");
        _subTitleLabel.font = [UIFont systemFontOfSize:13.0 * kScale];
    }
    return _subTitleLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"descLabel";
        _descLabel.textColor = TIMCommonDynamicColor(@"form_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:13.0 * kScale];
    }
    return _descLabel;
}

@end
