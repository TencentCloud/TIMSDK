//
//  TUIGroupMemberTableViewCell_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupMemberTableViewCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIGroupMemberTableViewCell_Minimalist
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"", @"#FFFFFF");
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"", @"#000000");

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.detailLabel];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        self.detailLabel.textColor = TIMCommonDynamicColor(@"", @"#666666");

        _separtorView = [[UIView alloc] init];
        _separtorView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_separtorView];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.tapAction) {
        self.tapAction();
    }
}
- (void)fillWithData:(TUIGroupMemberCellData_Minimalist *)contactData {
    [super fillWithData:contactData];

    self.titleLabel.text = contactData.name;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:contactData.avatarUrl] placeholderImage:contactData.avatarImage ?: DefaultAvatarImage];

    self.detailLabel.text = contactData.detailName;

    if (contactData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.userInteractionEnabled = YES;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.userInteractionEnabled = NO;
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
    
    CGFloat imgWidth = kScale390(40);
    
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(kScale390(16));
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.titleLabel sizeToFit];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(1);
    }];

    [self.detailLabel sizeToFit];
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.height.mas_equalTo(self.detailLabel.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- kScale390(16));
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];

}
@end
