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

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];

        _headImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        _timeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _titleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_titleLabel];

        _unReadView = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
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
        UIImage *image = [UIImage d_imageWithImageLight:TUIConversationImagePath(@"message_not_disturb") dark:TUIConversationImagePath(@"message_not_disturb_dark")];
        [self.notDisturbView setImage:image];
    } else {
        self.notDisturbRedDot.hidden = YES;
        self.notDisturbView.hidden = YES;
        self.unReadView.hidden = NO;
        [self.unReadView setNum:convData.unreadCount];
    }

    if (convData.isOnTop) {
        self.contentView.backgroundColor = [UIColor d_colorWithColorLight:TCell_OnTop dark:TCell_OnTop_Dark];
    } else {
        self.contentView.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
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
        }
    }
    
    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
        @strongify(self)
        if (self.convData.groupID.length > 0) { //群组
            // fix: 由于getCacheGroupAvatar需要请求网络，断网时，由于并没有设置headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
            self.headImageView.image = self.convData.avatarImage;
            [TUIGroupAvatar getCacheGroupAvatar:convData.groupID callback:^(UIImage *avatar) {
                @strongify(self)
                if (avatar != nil) { //已缓存群组头像
                    self.headImageView.image = avatar;
                } else { //未缓存群组头像
                    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:x]
                                          placeholderImage:self.convData.avatarImage];
                    [TUIGroupAvatar fetchGroupAvatars:convData.groupID placeholder:convData.avatarImage callback:^(BOOL success, UIImage *image, NSString *groupID) {
                        @strongify(self)
                        if ([groupID isEqualToString:self.convData.groupID]) {
                            // 需要判断下，防止复用问题
                            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:x] placeholderImage:image];
                        }
                    }];
                }
            }];
        } else {//个人头像
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:x]
                                  placeholderImage:self.convData.avatarImage];
        }
    }];
    
    NSString *imageName = (convData.showCheckBox && convData.selected) ? TUICoreImagePath(@"icon_select_selected") : TUICoreImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];
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
    self.titleLabel.mm_sizeToFitThan(120, 30).mm_top(TConversationCell_Margin_Text - 5).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin);
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_bottom(TConversationCell_Margin_Text).mm_flexToRight(2 * TConversationCell_Margin_Text);
    self.unReadView.mm_right(self.headImageView.mm_r - 5).mm_top(self.headImageView.mm_y - 5);
    self.notDisturbRedDot.mm_width(TConversationCell_Margin_Disturb_Dot).mm_height(TConversationCell_Margin_Disturb_Dot).mm_right(self.headImageView.mm_r - 3).mm_top(self.headImageView.mm_y - 3);
    self.notDisturbView.mm_width(TConversationCell_Margin_Disturb).mm_height(TConversationCell_Margin_Disturb).mm_right(16).mm_bottom(15);
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
