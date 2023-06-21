//
//  TCommonContactCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonContactCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactCellData.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@interface TUICommonContactCell ()
@property TUICommonContactCellData *contactData;
@end

@implementation TUICommonContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(28).mm_left(12);
        if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
        }

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
        self.titleLabel.mm_left(self.avatarView.mm_maxX + 12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);

        self.onlineStatusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.onlineStatusIcon];
        self.onlineStatusIcon.mm_width(kScale * 15).mm_height(kScale * 15);
        self.onlineStatusIcon.mm_x = CGRectGetMaxX(self.avatarView.frame) - 0.5 * self.onlineStatusIcon.mm_w - 3 * kScale;
        self.onlineStatusIcon.mm_y = CGRectGetMaxY(self.avatarView.frame) - self.onlineStatusIcon.mm_w;
        self.onlineStatusIcon.layer.cornerRadius = 0.5 * self.onlineStatusIcon.mm_w;

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TUICommonContactCellData *)contactData {
    [super fillWithData:contactData];
    self.contactData = contactData;

    self.titleLabel.text = contactData.title;
    [self.avatarView sd_setImageWithURL:contactData.avatarUrl placeholderImage:contactData.avatarImage ?: DefaultAvatarImage];

    @weakify(self);
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id _Nullable x) {
      @strongify(self);
      if (contactData.onlineStatus == TUIContactOnlineStatusOnline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_online_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_online_status")]);
      } else if (contactData.onlineStatus == TUIContactOnlineStatusOffline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_offline_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_offline_status")]);
      } else {
          self.onlineStatusIcon.hidden = YES;
          self.onlineStatusIcon.image = nil;
      }
    }];
}

@end
