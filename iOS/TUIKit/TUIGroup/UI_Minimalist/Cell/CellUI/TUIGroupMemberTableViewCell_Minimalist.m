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
    }
    return self;
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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarView.frame = CGRectMake(kScale390(16), (self.bounds.size.height - kScale390(40)) * 0.5, kScale390(40), kScale390(40));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.titleLabel.mm_left(self.avatarView.mm_maxX + 12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);

    self.detailLabel.mm_sizeToFit();
    self.detailLabel.mm_right(kScale390(16));
    self.detailLabel.mm_height(20);
    self.detailLabel.mm__centerY(self.avatarView.mm_centerY);
    self.detailLabel.mm_flexToRight(kScale390(16));
    //    self.separtorView.frame = CGRectMake(self.avatarView.mm_maxX, self.contentView.mm_h - 1, self.contentView.mm_w, 1);
}
@end
