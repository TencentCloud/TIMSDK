//
//  TCommonContactCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonContactCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIGroupAvatar+Helper.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactCellData_Minimalist.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@interface TUICommonContactCell_Minimalist ()
@property TUICommonContactCellData_Minimalist *contactData;
@end

@implementation TUICommonContactCell_Minimalist

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

        self.onlineStatusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.onlineStatusIcon];

        _separtorView = [[UIView alloc] init];
        _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
        [self.contentView addSubview:_separtorView];
        _separtorView.hidden = YES;

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TUICommonContactCellData_Minimalist *)contactData {
    [super fillWithData:contactData];
    self.contactData = contactData;

    self.titleLabel.text = contactData.title;
    [self configHeadImageView:contactData];
    @weakify(self);
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id _Nullable x) {
      @strongify(self);
      if (contactData.onlineStatus == TUIContactOnlineStatusOnline_Minimalist && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_online_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_online_status")]);
      } else if (contactData.onlineStatus == TUIContactOnlineStatusOffline_Minimalist && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_offline_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_offline_status")]);
      } else {
          self.onlineStatusIcon.hidden = YES;
          self.onlineStatusIcon.image = nil;
      }
    }];
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

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.trailing.mas_greaterThanOrEqualTo(self.contentView.mas_trailing);
        
    }];
    
    [self.onlineStatusIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kScale375(15));
        make.trailing.mas_equalTo(self.avatarView.mas_trailing).mas_offset(kScale375(5));
        make.bottom.mas_equalTo(self.avatarView.mas_bottom);
    }];
    self.onlineStatusIcon.layer.cornerRadius = 0.5 * kScale375(15);

    [self.separtorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(1);
        make.leading.mas_equalTo(self.avatarView.mas_trailing);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-1);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)configHeadImageView:(TUICommonContactCellData_Minimalist *)convData {
    /**
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * If it is a group, change the group default avatar to the last used avatar
         */
        convData.avatarImage = [TUIGroupAvatar getNormalGroupCacheAvatar:convData.groupID groupType:convData.groupType];
    }

    @weakify(self);

    [[RACObserve(convData, faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
      @strongify(self);
      NSString *groupID = convData.groupID ?: @"";
      NSString *pFaceUrl = convData.faceUrl ?: @"";
      NSString *groupType = convData.groupType ?: @"";
      UIImage *originAvatarImage = nil;
      if (convData.groupID.length > 0) {
          originAvatarImage = convData.avatarImage ?: DefaultGroupAvatarImageByGroupType(groupType);
      } else {
          originAvatarImage = convData.avatarImage ?: DefaultAvatarImage;
      }
      NSDictionary *param = @{
          @"groupID" : groupID,
          @"faceUrl" : pFaceUrl,
          @"groupType" : groupType,
          @"originAvatarImage" : originAvatarImage,
      };
      [TUIGroupAvatar configAvatarByParam:param targetView:self.avatarView];
    }];
}

@end
