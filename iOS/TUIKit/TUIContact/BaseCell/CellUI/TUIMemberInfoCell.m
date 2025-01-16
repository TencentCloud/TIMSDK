//
//  TUIMemberInfoCell.m
//  TUIGroup
//
//  Created by harvy on 2021/12/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMemberInfoCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIMemberInfoCellData.h"
#import "UIImageView+WebCache.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0
@implementation TUIMemberTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tui_colorWithHex:@"#E7F3FC"];
        self.layer.borderWidth = kScale390(1);
        self.layer.cornerRadius = kScale390(3);
        self.layer.borderColor = [UIColor tui_colorWithHex:@"#1890FF"].CGColor;
        [self addSubview:self.tagname];
    }
    return self;
}

- (UILabel *)tagname {
    if (!_tagname) {
        _tagname = [[UILabel alloc] init];
        _tagname.text = @"";
        _tagname.textColor = [UIColor tui_colorWithHex:@"#1890FF"];
        _tagname.font = [UIFont systemFontOfSize:kScale390(10)];
    }
    return _tagname;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_tagname sizeToFit];
    _tagname.frame = CGRectMake(kScale390(8), 0, _tagname.frame.size.width, self.frame.size.height);
}

@end

@implementation TUIMemberInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.tagView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setData:(TUIMemberInfoCellData *)data {
    _data = data;
    
    UIImage *defaultImage = DefaultAvatarImage;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatar ?: defaultImage];
    self.nameLabel.text = data.name;
    self.tagView.hidden = NO;
    if (data.role == V2TIM_GROUP_MEMBER_ROLE_SUPER) {
        self.tagView.tagname.text = TIMCommonLocalizableString(TUIKitMembersRoleSuper);
    } else if (data.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
        self.tagView.tagname.text = TIMCommonLocalizableString(TUIKitMembersRoleAdmin);
    } else {
        self.tagView.tagname.text = @"";
        self.tagView.hidden = YES;
    }
    
    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }

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
    
    if (self.data.style == TUIMemberInfoCellStyleAdd) {
        
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(18.0 * kScale);
            make.centerY.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(20.0 * kScale);
        }];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
    } else {
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(16.0 * kScale);
            make.centerY.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(34.0 * kScale);
        }];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
    }

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.nameLabel sizeToFit];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).mas_offset(14);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.nameLabel.frame.size);
        if (self.tagView.tagname.text.length > 0) {
            make.trailing.mas_lessThanOrEqualTo(self.tagView.mas_trailing).mas_offset(- 2.0 * kScale);
        }
        else {
            make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- 2.0 * kScale);
        }
    }];
    [self.tagView.tagname sizeToFit];
    [self.tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_trailing).mas_offset(kScale390(10));
        make.width.mas_equalTo(self.tagView.tagname.frame.size.width + kScale390(16));
        make.height.mas_equalTo(kScale390(15));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
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

- (TUIMemberTagView *)tagView {
    if (_tagView == nil) {
        _tagView = [[TUIMemberTagView alloc] init];
    }
    return _tagView;
}

@end
