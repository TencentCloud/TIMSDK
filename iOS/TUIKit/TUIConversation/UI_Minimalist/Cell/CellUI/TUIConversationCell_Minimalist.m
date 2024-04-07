//
//  TUIConversationCell_Minimalist.m
//  TUIConversation
//
//  Created by wyl on 2022/10/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationCell_Minimalist.h"

@implementation TUIConversationCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kScale390(14)];
        self.titleLabel.textColor = TUIDynamicColor(@"", TUIThemeModuleCore_Minimalist, @"#000000");
        self.subTitleLabel.font = [UIFont systemFontOfSize:kScale390(12)];
        self.lastMessageStatusImageView.hidden = NO;
    }
    return self;
}

- (void)fillWithData:(TUIConversationCellData *)convData {
    self.convData = convData;

    self.timeLabel.text = [TUITool convertDateToStr:convData.time];
    self.subTitleLabel.attributedText = convData.subTitle;

    [self configRedPoint:convData];

    [self configHeadImageView:convData];

    @weakify(self);
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
      @strongify(self);
      self.titleLabel.text = x;
    }];

    NSString *imageName =
        (convData.showCheckBox && convData.selected) ? TIMCommonImagePath(@"icon_select_selected") : TIMCommonImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];

    UIImage *image =
        TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist, [UIImage imageNamed:TUIConversationImagePath_Minimalist(@"message_not_disturb")]);
    [self.notDisturbView setImage:image];

    [self configOnlineStatusIcon:convData];

    [self configDisplayLastMessageStatusImage:convData];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)configHeadImageView:(TUIConversationCellData *)convData {
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
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
        ;
    }

    @weakify(self);

    [[RACObserve(convData, faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
      @strongify(self);
      if (self.convData.groupID.length > 0) {
          /**
           * 
           * Group avatar
           */
          if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
              /**
               * 
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
                   *
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
                                                              // When the callback is invoked, the cell is not reused
                                                              [self.headImageView
                                                                  sd_setImageWithURL:nil
                                                                    placeholderImage:success ? image
                                                                                             : DefaultGroupAvatarImageByGroupType(self.convData.groupType)];
                                                          } else {
                                                              // When the callback is invoked, the cell has been reused to other groupIDs.
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
- (void)configOnlineStatusIcon:(TUIConversationCellData *)convData {
    @weakify(self);
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id _Nullable x) {
      @strongify(self);
      if (convData.onlineStatus == TUIConversationOnlineStatusOnline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = NO;
          self.onlineStatusIcon.image = TIMCommonDynamicImage(@"icon_online_status", [UIImage imageNamed:TIMCommonImagePath(@"icon_online_status")]);
      } else if (convData.onlineStatus == TUIConversationOnlineStatusOffline && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
          self.onlineStatusIcon.hidden = YES;
          self.onlineStatusIcon.image = nil;
      } else {
          self.onlineStatusIcon.hidden = YES;
          self.onlineStatusIcon.image = nil;
      }
    }];
}

- (void)configDisplayLastMessageStatusImage:(TUIConversationCellData *)convData {
    UIImage *image = [self getDisplayLastMessageStatusImage:convData];
    self.lastMessageStatusImageView.image = image;
}

- (UIImage *)getDisplayLastMessageStatusImage:(TUIConversationCellData *)convData {
    UIImage *image = nil;
    if (!convData.draftText && (V2TIM_MSG_STATUS_SENDING == convData.lastMessage.status || V2TIM_MSG_STATUS_SEND_FAIL == convData.lastMessage.status)) {
        if (V2TIM_MSG_STATUS_SENDING == convData.lastMessage.status) {
            image = [UIImage imageNamed:TUIConversationImagePath_Minimalist(@"icon_sendingmark")];
        } else {
            image = [UIImage imageNamed:TUIConversationImagePath_Minimalist(@"msg_error_for_conv")];
        }
    }
    return image;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height - 2 * (kScale390(12));

    if (self.convData.isOnTop) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_top_bg_color", @"#F4F4F4");
    } else {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");
    }
    
    CGFloat selectedIconSize = 20;
    if (self.convData.showCheckBox) {
        self.selectedIcon.hidden = NO;
    } else {
        self.selectedIcon.hidden = YES;
    }
    
    [self.selectedIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.convData.showCheckBox) {
            make.width.height.mas_equalTo(selectedIconSize);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(10);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }
    }];
    
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imgHeight);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        if (self.convData.showCheckBox) {
            make.leading.mas_equalTo(self.selectedIcon.mas_trailing).mas_offset(kScale390(16));
        }
        else {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(kScale390(16));
        }
    }];
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.timeLabel sizeToFit];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.timeLabel.frame.size.width);
        make.height.mas_greaterThanOrEqualTo(self.timeLabel.font.lineHeight);
        make.top.mas_equalTo(self.subTitleLabel.mas_top);
        make.trailing.mas_equalTo(self.contentView).mas_offset(- kScale390(8));
    }];
    MASAttachKeys(self.timeLabel);

    [self.lastMessageStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScale390(14));
        make.height.mas_equalTo(14);
        make.trailing.mas_equalTo(self.timeLabel.mas_leading).mas_offset(- (kScale390(1) + kScale390(8)));
        make.bottom.mas_equalTo(self.timeLabel.mas_bottom);
    }];
    MASAttachKeys(self.lastMessageStatusImageView);
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(120);
        make.height.mas_greaterThanOrEqualTo(self.titleLabel.font.lineHeight);
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(kScale390(14));
        make.leading.mas_equalTo(self.headImageView.mas_trailing).mas_offset(kScale390(8));
        make.trailing.mas_equalTo(self.timeLabel.mas_leading).mas_offset(- 2*kScale390(14));
    }];
    MASAttachKeys(self.titleLabel);

    

    [self.subTitleLabel sizeToFit];
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(self.subTitleLabel);
        make.bottom.mas_equalTo(self.contentView).mas_offset(- kScale390(14));
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.timeLabel.mas_leading).mas_offset(-kScale390(8));
    }];
    MASAttachKeys(self.subTitleLabel);

    [self.unReadView.unReadLabel sizeToFit];
    [self.unReadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.timeLabel.mas_trailing);
        make.top.mas_equalTo(self.titleLabel.mas_top);
        make.width.mas_equalTo(kScale375(18));
        make.height.mas_equalTo(kScale375(18));
    }];
    [self.unReadView.unReadLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.unReadView);
        make.size.mas_equalTo(self.unReadView.unReadLabel);
    }];
    self.unReadView.layer.cornerRadius = kScale375(18) * 0.5;
    [self.unReadView.layer masksToBounds];
    
    [self.notDisturbRedDot mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.headImageView.mas_trailing).mas_offset(3);
        make.top.mas_equalTo(self.headImageView.mas_top).mas_offset(1);
        make.width.height.mas_equalTo(TConversationCell_Margin_Disturb_Dot);
    }];

    [self.notDisturbView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(TConversationCell_Margin_Disturb);
        make.trailing.mas_equalTo(self.timeLabel.mas_trailing);
        make.top.mas_equalTo(self.titleLabel.mas_top);
    }];
    
    [self.onlineStatusIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kScale375(15));
        make.leading.mas_equalTo(self.headImageView.mas_trailing).mas_offset(-kScale375(10));
        make.bottom.mas_equalTo(self.headImageView.mas_bottom).mas_offset(-kScale375(1));
    }];
    
    self.onlineStatusIcon.layer.cornerRadius = 0.5 *kScale375(15);
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
