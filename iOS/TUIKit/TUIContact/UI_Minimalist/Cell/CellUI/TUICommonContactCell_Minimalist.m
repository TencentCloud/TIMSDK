//
//  TCommonContactCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUICommonContactCell_Minimalist.h"
#import "TUICommonModel.h"
#import "TUICommonContactCellData_Minimalist.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@interface TUICommonContactCell_Minimalist()
@property TUICommonContactCellData_Minimalist *contactData;
@end

@implementation TUICommonContactCell_Minimalist


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TUICoreDynamicColor(@"", @"#FFFFFF");
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = TUICoreDynamicColor(@"", @"#000000");
        
        self.onlineStatusIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.onlineStatusIcon];

        _separtorView = [[UIView alloc] init];
        _separtorView.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#DBDBDB");
        [self.contentView addSubview:_separtorView];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TUICommonContactCellData_Minimalist *)contactData
{
    [super fillWithData:contactData];
    self.contactData = contactData;

    self.titleLabel.text = contactData.title;
    [self.avatarView sd_setImageWithURL:contactData.avatarUrl placeholderImage:contactData.avatarImage?:DefaultAvatarImage];
    
    @weakify(self)
    [[RACObserve(TUIConfig.defaultConfig, displayOnlineStatusIcon) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (contactData.onlineStatus == TUIContactOnlineStatusOnline_Minimalist &&
            TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TUICoreDynamicImage(@"icon_online_status", [UIImage imageNamed:TUICoreImagePath(@"icon_online_status")]);
        } else if (contactData.onlineStatus == TUIContactOnlineStatusOffline_Minimalist &&
                   TUIConfig.defaultConfig.displayOnlineStatusIcon) {
            self.onlineStatusIcon.hidden = NO;
            self.onlineStatusIcon.image = TUICoreDynamicImage(@"icon_offline_status", [UIImage imageNamed:TUICoreImagePath(@"icon_offline_status")]);
        } else {
            self.onlineStatusIcon.hidden = YES;
            self.onlineStatusIcon.image = nil;
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarView.frame = CGRectMake(kScale390(16), (self.bounds.size.height - kScale390(40) )*0.5, kScale390(40), kScale390(40));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);
    
    self.onlineStatusIcon.mm_width(kScale * 15).mm_height(kScale * 15);
    self.onlineStatusIcon.mm_x = CGRectGetMaxX(self.avatarView.frame) - 0.5 * self.onlineStatusIcon.mm_w - 3 * kScale;
    self.onlineStatusIcon.mm_y = CGRectGetMaxY(self.avatarView.frame) - self.onlineStatusIcon.mm_w;
    self.onlineStatusIcon.layer.cornerRadius = 0.5 * self.onlineStatusIcon.mm_w;

    self.separtorView.frame = CGRectMake(self.avatarView.mm_maxX, self.contentView.mm_h - 1, self.contentView.mm_w, 1);
}
@end

