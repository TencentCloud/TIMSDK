//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCell.h"
#import "TUIDefine.h"
#import "TUICommonModel.h"
#import "TUITool.h"
#import "TUIThemeManager.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");

        _headImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = TUICoreDynamicColor(@"form_desc_color", @"#BBBBBB");
        _timeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
        _titleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_titleLabel];

        _unReadView = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = TUICoreDynamicColor(@"form_subtitle_color", @"#888888");
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
    }
    return self;
}
- (void)fillWithData:(TUIConversationCellData *)convData
{
    [super fillWithData:convData];
    self.convData = convData;

    self.timeLabel.text = [TUITool convertDateToStr:convData.time];
    self.subTitleLabel.attributedText = convData.subTitle;
    
    if (convData.isNotDisturb) {
        // 免打扰状态，如果没有未读消息，不展示小红点
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

    if (convData.isOnTop) {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_top_bg_color", @"#F4F4F4");
    } else {
        self.contentView.backgroundColor = TUIConversationDynamicColor(@"conversation_cell_bg_color", @"#FFFFFF");;
    }
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal]
      distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];
    
    // 修改默认头像
    if (convData.groupID.length > 0) {
        // 群组, 则将群组默认头像修改成上次使用的头像
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", convData.groupID];
        NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
        UIImage *avatar = [TUIGroupAvatar getCacheAvatarForGroup:convData.groupID number:(UInt32)member];
        if (avatar) {
            convData.avatarImage = avatar;
        } else {
            convData.avatarImage = DefaultGroupAvatarImage;
        }
    }
    
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
                 * 外部未设置群头像，采用合成头像
                 * 1. 异步根据群成员个数来获取缓存的合成头像
                 * 2. 如果有缓存，则直接使用缓存的合成头像
                 * 3. 如果没有缓存，则重新合成新头像
                 *
                 * 注意：
                 * 1. 由于「异步获取缓存」和「合成头像」耗时较长，容易引起 cell 的复用问题，故需要根据 groupID 来确认是否直接赋值。
                 * 2. 使用 SDWebImage 来实现占位，因为 SDWebImage 内部已经处理了 cell 的复用问题
                 *
                 * The group avatar has not been set externally, and a synthetic avatar is used at this time.
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
                // fix: Th getCacheGroupAvatar needs to request the network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation is moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
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
                                    [self.headImageView sd_setImageWithURL:nil placeholderImage:success?image:DefaultGroupAvatarImage];
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
    
    NSString *imageName = (convData.showCheckBox && convData.selected) ? TUICoreImagePath(@"icon_select_selected") : TUICoreImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];

    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (convData.onlineStatus == TUIConversationOnlineStatusOnline &&
            TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TUICoreDynamicImage(@"icon_online_status", [UIImage imageNamed:TUICoreImagePath(@"icon_online_status")]);
        } else if (convData.onlineStatus == TUIConversationOnlineStatusOffline &&
                   TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TUICoreDynamicImage(@"icon_offline_status", [UIImage imageNamed:TUICoreImagePath(@"icon_offline_status")]);
        } else {
            self.onlineStatusIcon.hidden = YES;
            self.onlineStatusIcon.image = nil;
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height-2*(TConversationCell_Margin);

    if (self.convData.showCheckBox) {
        _selectedIcon.mm_width(20).mm_height(20);
        _selectedIcon.mm_x = 10;
        _selectedIcon.mm_centerY = self.headImageView.mm_centerY;
        _selectedIcon.hidden = NO;
    } else {
        _selectedIcon.mm_width(0).mm_height(0);
        _selectedIcon.mm_x = 0;
        _selectedIcon.mm_y = 0;
        _selectedIcon.hidden = YES;
    }
    
    CGFloat margin = self.convData.showCheckBox ? _selectedIcon.mm_maxX : 0;
    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(TConversationCell_Margin + 3 + margin).mm_top(TConversationCell_Margin);
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.timeLabel.mm_sizeToFit().mm_top(TConversationCell_Margin_Text).mm_right(TConversationCell_Margin + 4);
    self.titleLabel.mm_sizeToFitThan(120, 30).mm_top(TConversationCell_Margin_Text - 5).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin).mm_flexToRight(self.timeLabel.mm_w + 2 * TConversationCell_Margin_Text);;
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_bottom(TConversationCell_Margin_Text).mm_flexToRight(2 * TConversationCell_Margin_Text);
    self.unReadView.mm_right(self.headImageView.mm_r - 5).mm_top(self.headImageView.mm_y - 5);
    self.notDisturbRedDot.mm_width(TConversationCell_Margin_Disturb_Dot).mm_height(TConversationCell_Margin_Disturb_Dot).mm_right(self.headImageView.mm_r - 3).mm_top(self.headImageView.mm_y - 3);
    self.notDisturbView.mm_width(TConversationCell_Margin_Disturb).mm_height(TConversationCell_Margin_Disturb).mm_right(16).mm_bottom(15);
    
    self.onlineStatusIcon.mm_width(kScale * 15).mm_height(kScale * 15);
    self.onlineStatusIcon.mm_x = CGRectGetMaxX(self.headImageView.frame) - 0.5 * self.onlineStatusIcon.mm_w - 3 * kScale;
    self.onlineStatusIcon.mm_y = CGRectGetMaxY(self.headImageView.frame) - self.onlineStatusIcon.mm_w;
    self.onlineStatusIcon.layer.cornerRadius = 0.5 * self.onlineStatusIcon.mm_w;
}

@end

@interface IUConversationView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUConversationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
