//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");

        _headImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = TIMCommonDynamicColor(@"form_desc_color", @"#BBBBBB");
        _timeLabel.layer.masksToBounds = YES;
        [_timeLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [self.contentView addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
        _titleLabel.layer.masksToBounds = YES;
        [_titleLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [self.contentView addSubview:_titleLabel];

        _unReadView = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = TIMCommonDynamicColor(@"form_subtitle_color", @"#888888");
        [_subTitleLabel setRtlAlignment:TUITextRTLAlignmentLeading];
        [self.contentView addSubview:_subTitleLabel];

        _notDisturbRedDot = [[UIView alloc] init];
        _notDisturbRedDot.backgroundColor = [UIColor redColor];
        _notDisturbRedDot.layer.cornerRadius = TConversationCell_Margin_Disturb_Dot / 2.0;
        _notDisturbRedDot.layer.masksToBounds = YES;
        [self.contentView addSubview:_notDisturbRedDot];

        _notDisturbView = [[UIImageView alloc] init];
        [self.contentView addSubview:_notDisturbView];

        [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];

        // selectedIcon
        _selectedIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_selectedIcon];

        _onlineStatusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_onlineStatusIcon];

        _lastMessageStatusImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_lastMessageStatusImageView];
        _lastMessageStatusImageView.hidden = YES;
    }
    return self;
}
- (void)fillWithData:(TUIConversationCellData *)convData {
    self.convData = convData;

    self.timeLabel.text = [TUITool convertDateToStr:convData.time];
    self.subTitleLabel.attributedText = convData.subTitle;
    if (self.convData.showCheckBox) {
        _selectedIcon.hidden = NO;
    } else {
        _selectedIcon.hidden = YES;
    }
    [self configRedPoint:convData];

    if (convData.isOnTop) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_top_bg_color", @"#F4F4F4");
    } else {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");
        ;
    }

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    @weakify(self);
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self);
        self.titleLabel.text = x;
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];
    }];

    /**
     * 
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * , 
         * If it is a group, change the group default avatar to the last used avatar
         */
        UIImage *avatar = nil;
        if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", convData.groupID];
            NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
            avatar = [TUIGroupAvatar getCacheAvatarForGroup:convData.groupID number:(UInt32)member];
        }
        convData.avatarImage = avatar ? avatar : DefaultGroupAvatarImageByGroupType(convData.groupType);
    }

    [[RACObserve(convData, faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
      @strongify(self);
      if (self.convData.groupID.length > 0) {
          /**
           * 
           * Group avatar
           */
          if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
              /**
               * The group avatar has been manually set externally
               */
              [self.headImageView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:self.convData.avatarImage];
          } else {
              /**
               * The group avatar has not been set externally. If the synthetic avatar is allowed, the synthetic avatar will be used; otherwise, the default
               * avatar will be used.
               */
              if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
                  /**
                   * If the synthetic avatar is allowed, the synthetic avatar will be used
                   * 1. Asynchronously obtain the cached synthetic avatar according to the number of group members
                   * 2. If the cache is hit, use the cached synthetic avatar directly
                   * 3. If the cache is not hit, recompose a new avatar
                   *
                   * Note:
                   * 1. Since "asynchronously obtaining cached avatars" and "synthesizing avatars" take a long time, it is easy to cause cell reuse problems, so
                   * it is necessary to confirm whether to assign values directly according to groupID.
                   * 2. Use SDWebImage to implement placeholder, because SDWebImage has already dealt with the problem of cell reuse
                   */

                  // 1. Obtain group avatar from cache

                  // fix: The getCacheGroupAvatar needs to request the
                  // network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation
                  // is moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
                  [self.headImageView sd_setImageWithURL:nil placeholderImage:convData.avatarImage];
                  [TUIGroupAvatar
                      getCacheGroupAvatar:convData.groupID
                                 callback:^(UIImage *avatar, NSString *groupID) {
                                   @strongify(self);
                                   if ([groupID isEqualToString:self.convData.groupID]) {
                                       // 1.1 When the callback is invoked, the cell is not reused

                                       if (avatar != nil) {
                                           // 2. Hit the cache and assign directly
                                           [self.headImageView sd_setImageWithURL:nil placeholderImage:avatar];
                                       } else {
                                           // 3. Synthesize new avatars asynchronously without hitting cache

                                           [self.headImageView sd_setImageWithURL:nil placeholderImage:convData.avatarImage];
                                           [TUIGroupAvatar
                                               fetchGroupAvatars:convData.groupID
                                                     placeholder:convData.avatarImage
                                                        callback:^(BOOL success, UIImage *image, NSString *groupID) {
                                                          @strongify(self);
                                                          if ([groupID isEqualToString:self.convData.groupID]) {
                                                              // callback ，cell 
                                                              // When the callback is invoked, the cell is not reused
                                                              [self.headImageView
                                                                  sd_setImageWithURL:nil
                                                                    placeholderImage:success ? image
                                                                                             : DefaultGroupAvatarImageByGroupType(self.convData.groupType)];
                                                          } else {
                                                              //When the callback is invoked, the cell has been reused to other groupIDs.
                                                              // Since a new callback will be triggered when the new groupID synthesizes new avatar, it is
                                                              // ignored here
                                                          }
                                                        }];
                                       }
                                   } else {
                                       // 1.2 When the callback is invoked, the cell has been reused to other groupIDs. Since a new callback will be triggered
                                       // when the new groupID gets the cache, it is ignored here
                                   }
                                 }];
              } else {
                  /**
                   * Synthetic avatars are not allowed, use the default avatar directly
                   */
                  [self.headImageView sd_setImageWithURL:nil placeholderImage:convData.avatarImage];
              }
          }
      } else {
          /**
           * Personal avatar
           */
          [self.headImageView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:self.convData.avatarImage];
      }
    }];

    if (convData.showCheckBox) {
        NSString *imageName = nil;
        if (convData.disableSelected) {
            imageName = TIMCommonImagePath(@"icon_select_selected_disable");
        } else if (convData.selected) {
            imageName = TIMCommonImagePath(@"icon_select_selected");
        } else {
            imageName = TIMCommonImagePath(@"icon_select_normal");
        }
        self.selectedIcon.image = [UIImage imageNamed:imageName];
    }

    [self configOnlineStatusIcon:convData];

    [self configDisplayLastMessageStatusImage:convData];

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (void)configDisplayLastMessageStatusImage:(TUIConversationCellData *)convData {
    UIImage *image = [self getDisplayLastMessageStatusImage:convData];
    self.lastMessageStatusImageView.image = image;
}

- (UIImage *)getDisplayLastMessageStatusImage:(TUIConversationCellData *)convData {
    UIImage *image = nil;
    if (!convData.draftText && (V2TIM_MSG_STATUS_SENDING == convData.lastMessage.status || V2TIM_MSG_STATUS_SEND_FAIL == convData.lastMessage.status)) {
        if (V2TIM_MSG_STATUS_SENDING == convData.lastMessage.status) {
            image = [UIImage imageNamed:TUIConversationImagePath(@"msg_sending_for_conv")];
        } else {
            image = [UIImage imageNamed:TUIConversationImagePath(@"msg_error_for_conv")];
        }
    }
    return image;
}

- (void)configOnlineStatusIcon:(TUIConversationCellData *)convData {
    @weakify(self);
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id _Nullable x) {
      @strongify(self);
      if (convData.onlineStatus == TUIConversationOnlineStatusOnline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_online_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_online_status")]);
      } else if (convData.onlineStatus == TUIConversationOnlineStatusOffline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_offline_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_offline_status")]);
      } else {
          self.onlineStatusIcon.hidden = YES;
          self.onlineStatusIcon.image = nil;
      }
    }];
}
- (void)configRedPoint:(TUIConversationCellData *)convData {
    if (convData.isNotDisturb) {
        if (0 == convData.unreadCount) {
            self.notDisturbRedDot.hidden = YES;
        } else {
            self.notDisturbRedDot.hidden = NO;
        }
        self.notDisturbView.hidden = NO;
        self.unReadView.hidden = YES;
        UIImage *image = TUIConversationBundleThemeImage(@"conversation_message_not_disturb_img", @"message_not_disturb");
        [self.notDisturbView setImage:image];
    } else {
        self.notDisturbRedDot.hidden = YES;
        self.notDisturbView.hidden = YES;
        self.unReadView.hidden = NO;
        [self.unReadView setNum:convData.unreadCount];
    }

    // Mark As Unread
    if (convData.isMarkAsUnread) {
        // When marked as unread, don't care about 'unreadCount', you need to display red dot/number 1 according to whether do not disturb or not
        if (convData.isNotDisturb) {
            // Displays a red dot when marked as unread and do not disturb
            self.notDisturbRedDot.hidden = NO;
        } else {
            // Marked unread Show number 1
            [self.unReadView setNum:1];
        }
    }

    // Collapsed group chat No need for Do Not Disturb icon
    if (convData.isLocalConversationFoldList) {
        self.notDisturbView.hidden = YES;
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat selectedIconSize = 20;
    [self.selectedIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.convData.showCheckBox) {
            make.width.height.mas_equalTo(selectedIconSize);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(10);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }
    }];
    MASAttachKeys(self.selectedIcon);

    CGFloat imgHeight = height - 2 * (TConversationCell_Margin);
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imgHeight);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        if (self.convData.showCheckBox) {
            make.leading.mas_equalTo(self.selectedIcon.mas_trailing).mas_offset(TConversationCell_Margin + 3);
        }
        else {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(TConversationCell_Margin + 3);
        }
    }];
    MASAttachKeys(self.headImageView);

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    CGFloat titleLabelHeight = 30;
    if (self.convData.isLiteMode) {
        [self.titleLabel sizeToFit];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(120);
            make.height.mas_greaterThanOrEqualTo(titleLabelHeight);
            make.top.mas_equalTo((height - titleLabelHeight) / 2);
            make.leading.mas_equalTo(self.headImageView.mas_trailing).mas_offset(TConversationCell_Margin);
            make.trailing.mas_equalTo(self.contentView).mas_offset(- 2*TConversationCell_Margin_Text);
        }];
        self.timeLabel.hidden = YES;
        self.lastMessageStatusImageView.hidden = YES;
        self.subTitleLabel.hidden = YES;
        self.unReadView.hidden = YES;
        self.notDisturbRedDot.hidden = YES;
        self.notDisturbView.hidden = YES;
        self.onlineStatusIcon.hidden = YES;
    } else {
        [self.timeLabel sizeToFit];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.timeLabel);
            make.height.mas_greaterThanOrEqualTo(self.timeLabel.font.lineHeight);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(TConversationCell_Margin_Text);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- TConversationCell_Margin_Text);
        }];
        MASAttachKeys(self.timeLabel);

        [self.lastMessageStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kScale390(14));
            make.height.mas_equalTo(14);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- (kScale390(1) + TConversationCell_Margin_Disturb + kScale390(8)));
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(kScale390(16));
        }];
        MASAttachKeys(self.lastMessageStatusImageView);

        [self.titleLabel sizeToFit];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(titleLabelHeight);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(TConversationCell_Margin_Text - 5);
            make.leading.mas_equalTo(self.headImageView.mas_trailing).mas_offset(TConversationCell_Margin);
            make.trailing.mas_lessThanOrEqualTo(self.timeLabel.mas_trailing).mas_offset(- 2*TConversationCell_Margin_Text);
        }];
        MASAttachKeys(self.titleLabel);
        [self.subTitleLabel sizeToFit];
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(self.subTitleLabel);
            make.bottom.mas_equalTo(self.contentView).mas_offset(- TConversationCell_Margin_Text);
            make.leading.mas_equalTo(self.titleLabel);
            make.trailing.mas_equalTo(self.contentView).mas_offset(- 2*TConversationCell_Margin_Text);
        }];
        MASAttachKeys(self.subTitleLabel);

        [self.unReadView.unReadLabel sizeToFit];
        [self.unReadView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.headImageView.mas_trailing).mas_offset(kScale375(5));
            make.top.mas_equalTo(self.headImageView.mas_top).mas_offset(-kScale375(5));
            make.width.mas_equalTo(kScale375(20));
            make.height.mas_equalTo(kScale375(20));
        }];
        MASAttachKeys(self.unReadView);

        [self.unReadView.unReadLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.unReadView);
            make.size.mas_equalTo(self.unReadView.unReadLabel);
        }];
        self.unReadView.layer.cornerRadius = kScale375(10);
        [self.unReadView.layer masksToBounds];
        
        [self.notDisturbRedDot mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.headImageView.mas_trailing).mas_offset(3);
            make.top.mas_equalTo(self.headImageView.mas_top).mas_offset(1);
            make.width.height.mas_equalTo(TConversationCell_Margin_Disturb_Dot);
        }];
        MASAttachKeys(self.notDisturbRedDot);

        [self.notDisturbView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(TConversationCell_Margin_Disturb);
            make.trailing.mas_equalTo(self.timeLabel.mas_trailing);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-15);
        }];
        
        [self.onlineStatusIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kScale375(15));
            make.leading.mas_equalTo(self.headImageView.mas_trailing).mas_offset(-kScale375(15));
            make.bottom.mas_equalTo(self.headImageView.mas_bottom).mas_offset(-kScale375(1));
        }];
        self.onlineStatusIcon.layer.cornerRadius = 0.5 * kScale375(15);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
