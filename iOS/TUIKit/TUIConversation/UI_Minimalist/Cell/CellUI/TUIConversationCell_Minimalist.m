//
//  TUIConversationCell_Minimalist.m
//  TUIConversation
//
//  Created by wyl on 2022/10/9.
//

#import "TUIConversationCell_Minimalist.h"

@implementation TUIConversationCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self =   [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
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

    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal]
      distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];


    NSString *imageName = (convData.showCheckBox && convData.selected) ? TUICoreImagePath(@"icon_select_selected") : TUICoreImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];

    UIImage *image = TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist,[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"message_not_disturb")]);
    [self.notDisturbView setImage:image];
    
    [self configOnlineStatusIcon:convData];
    
    [self configDisplayLastMessageStatusImage:convData];
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
     * 修改默认头像
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
         * If it is a group, change the group default avatar to the last used avatar
         */
        UIImage *avatar = nil;
        if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", convData.groupID];
            NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
            avatar = [TUIGroupAvatar getCacheAvatarForGroup:convData.groupID number:(UInt32)member];
        }
        convData.avatarImage = avatar ? avatar : DefaultGroupAvatarImageByGroupType(convData.groupType);;
    }
    
    @weakify(self);

    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
        @strongify(self)
        if (self.convData.groupID.length > 0) {
            /**
             * 群组头像
             * Group avatar
             */
            if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
                /**
                 * 外部有手动设置群头像
                 * The group avatar has been manually set externally
                 */
                [self.headImageView sd_setImageWithURL:[NSURL URLWithString:faceUrl]
                                      placeholderImage:self.convData.avatarImage];
            } else {
                /**
                 * 外部未设置群头像，如果允许合成头像，则采用合成头像；反之则使用默认头像
                 * The group avatar has not been set externally. If the synthetic avatar is allowed, the synthetic avatar will be used; otherwise, the default avatar will be used.
                 */
                if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
                    /**
                     * 允许合成头像，则采用合成头像
                     * 1. 异步根据群成员个数来获取缓存的合成头像
                     * 2. 如果有缓存，则直接使用缓存的合成头像
                     * 3. 如果没有缓存，则重新合成新头像
                     *
                     * 注意：
                     * 1. 由于「异步获取缓存」和「合成头像」耗时较长，容易引起 cell 的复用问题，故需要根据 groupID 来确认是否直接赋值。
                     * 2. 使用 SDWebImage 来实现占位，因为 SDWebImage 内部已经处理了 cell 的复用问题
                     *
                     * If the synthetic avatar is allowed, the synthetic avatar will be used
                     * 1. Asynchronously obtain the cached synthetic avatar according to the number of group members
                     * 2. If the cache is hit, use the cached synthetic avatar directly
                     * 3. If the cache is not hit, recompose a new avatar
                     *
                     * Note:
                     * 1. Since "asynchronously obtaining cached avatars" and "synthesizing avatars" take a long time, it is easy to cause cell reuse problems, so it is necessary to confirm whether to assign values directly according to groupID.
                     * 2. Use SDWebImage to implement placeholder, because SDWebImage has already dealt with the problem of cell reuse
                     */
                    
                    // 1. 获取缓存
                    // 1. Obtain group avatar from cache
                    
                    // fix: 由于 getCacheGroupAvatar 需要请求网络，断网时，由于并没有设置 headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
                    // fix: The getCacheGroupAvatar needs to request the network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation is moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
                    [self.headImageView sd_setImageWithURL:nil
                                          placeholderImage:convData.avatarImage];
                    [TUIGroupAvatar getCacheGroupAvatar:convData.groupID callback:^(UIImage *avatar, NSString *groupID) {
                        @strongify(self)
                        if ([groupID isEqualToString:self.convData.groupID]) {
                            // 1.1 callback 回调时，cell 未被复用
                            // 1.1 When the callback is invoked, the cell is not reused
                            
                            if (avatar != nil) {
                                // 2. 有缓存，直接赋值
                                // 2. Hit the cache and assign directly
                                [self.headImageView sd_setImageWithURL:nil
                                                      placeholderImage:avatar];
                            } else {
                                // 3. 没有缓存，异步合成新头像
                                // 3. Synthesize new avatars asynchronously without hitting cache
                                
                                [self.headImageView sd_setImageWithURL:nil
                                                      placeholderImage:convData.avatarImage];
                                [TUIGroupAvatar fetchGroupAvatars:convData.groupID placeholder:convData.avatarImage callback:^(BOOL success, UIImage *image, NSString *groupID) {
                                    @strongify(self)
                                    if ([groupID isEqualToString:self.convData.groupID]) {
                                        // callback 回调时，cell 未被复用
                                        // When the callback is invoked, the cell is not reused
                                        [self.headImageView sd_setImageWithURL:nil placeholderImage:success?image:DefaultGroupAvatarImageByGroupType(self.convData.groupType)];
                                    } else {
                                        // callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID 合成头像时会触发新的 callback，此处忽略
                                        // When the callback is invoked, the cell has been reused to other groupIDs. Since a new callback will be triggered when the new groupID synthesizes new avatar, it is ignored here
                                    }
                                }];
                            }
                        } else {
                            // 1.2 callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID 获取缓存时会触发新的 callback，此处忽略
                            // 1.2 When the callback is invoked, the cell has been reused to other groupIDs. Since a new callback will be triggered when the new groupID gets the cache, it is ignored here
                        }
                    }];
                } else {
                    /**
                     * 不允许使用合成头像，直接使用默认头像
                     * Synthetic avatars are not allowed, use the default avatar directly
                     */
                    [self.headImageView sd_setImageWithURL:nil
                                          placeholderImage:convData.avatarImage];
                }
            }
        } else {
            /**
             * 个人头像
             * Personal avatar
             */
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:faceUrl]
                                  placeholderImage:self.convData.avatarImage];
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
    
    // 标记未读
    // Mark As Unread
    if (convData.isMarkAsUnread) {
        // 被标记未读时，不关心'未读数' ，需要按照是否免打扰显示红点/数字1
        // When marked as unread, don't care about 'unreadCount', you need to display red dot/number 1 according to whether do not disturb or not
        if (convData.isNotDisturb) {
            // 被标记未读、免打扰时 显示红点
            // Displays a red dot when marked as unread and do not disturb
            self.notDisturbRedDot.hidden = NO;
        }
        else {
            // 被标记未读 显示数字1
            // Marked unread Show number 1
            [self.unReadView setNum:1];
        }
        
    }
    
    // 被折叠的群聊 不需要免打扰图标
    // Collapsed group chat No need for Do Not Disturb icon
    if (convData.isLocalConversationFoldList) {
        self.notDisturbView.hidden = YES;
    }
    
}
- (void)configOnlineStatusIcon:(TUIConversationCellData *)convData {
    @weakify(self)
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (convData.onlineStatus == TUIConversationOnlineStatusOnline &&
            TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TUIDynamicImage(@"", TUIThemeModuleConversation_Minimalist,[UIImage imageNamed:TUIConversationImagePath_Minimalist(@"icon_online_status")]);
        } else if (convData.onlineStatus == TUIConversationOnlineStatusOffline &&
                   TUIConfig.defaultConfig.displayOnlineStatusIcon) {
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
            image =  [UIImage imageNamed:TUIConversationImagePath_Minimalist(@"icon_sendingmark")];
        } else {
            image =  [UIImage imageNamed:TUIConversationImagePath_Minimalist(@"msg_error_for_conv")];
        }
    }
    return image;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height- 2 * (kScale390(12));

    if (self.convData.showCheckBox) {
        self.selectedIcon.mm_width(20).mm_height(20);
        self.selectedIcon.mm_x = 10;
        self.selectedIcon.mm_centerY = self.headImageView.mm_centerY;
        self.selectedIcon.hidden = NO;
    } else {
        self.selectedIcon.mm_width(0).mm_height(0);
        self.selectedIcon.mm_x = 0;
        self.selectedIcon.mm_y = 0;
        self.selectedIcon.hidden = YES;
    }
    
    CGFloat margin = self.convData.showCheckBox ? self.selectedIcon.mm_maxX : 0;
    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(kScale390(16) + margin).mm_top(kScale390(12));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.unReadView.mm_right(self.mm_r + kScale390(8)).mm_top(kScale390(16.5));
    self.timeLabel.mm_sizeToFit().mm_top(self.unReadView.mm_maxY + kScale390(3)).mm_right(kScale390(8));
    self.lastMessageStatusImageView.mm_width(kScale390(14)).mm_height(14).mm_top(self.unReadView.mm_maxY + kScale390(3)).mm_right(kScale390(1) + self.timeLabel.mm_w + kScale390(8));
    self.titleLabel.mm_sizeToFit().mm_top(self.unReadView.mm_y).mm_left(self.headImageView.mm_maxX + kScale390(8) ).mm_flexToRight(self.timeLabel.mm_w + 2 * kScale390(14));
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + kScale390(3)).mm_flexToRight(2 * kScale390(28));
    self.notDisturbRedDot.mm_width(TConversationCell_Margin_Disturb_Dot).mm_height(TConversationCell_Margin_Disturb_Dot).mm_right(self.headImageView.mm_r - 3).mm_top(self.headImageView.mm_y - 3);
    self.notDisturbView.mm_width(TConversationCell_Margin_Disturb).mm_height(TConversationCell_Margin_Disturb).mm_top(kScale390(16)).mm_right( kScale390(8));
    
    self.onlineStatusIcon.mm_width(kScale390(10)).mm_height(kScale390(10));
    self.onlineStatusIcon.mm_x = CGRectGetMaxX(self.headImageView.frame) - 0.5 * self.onlineStatusIcon.mm_w - kScale390(3);
    self.onlineStatusIcon.mm_y = CGRectGetMaxY(self.headImageView.frame) - self.onlineStatusIcon.mm_w;
    self.onlineStatusIcon.layer.cornerRadius = 0.5 * self.onlineStatusIcon.mm_w;
    
    if (self.convData.isOnTop) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_top_bg_color", @"#F4F4F4");
    } else {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");;
    }
    
}

@end
