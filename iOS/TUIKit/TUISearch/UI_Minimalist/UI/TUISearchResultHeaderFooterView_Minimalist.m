//
//  TUISearchResultHeaderFooterView_Minimalist.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchResultHeaderFooterView_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUISearchResultHeaderFooterView_Minimalist ()

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *moreBtn;

@end

@implementation TUISearchResultHeaderFooterView_Minimalist

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    _iconView = [[UIImageView alloc] init];
    _iconView.image = [UIImage imageNamed:TUISearchImagePath(@"search")];
    [self.contentView addSubview:_iconView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    [self.contentView addSubview:_titleLabel];

    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreBtn setTitle:TIMCommonLocalizableString(More) forState:UIControlStateNormal];
    [_moreBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    _moreBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kScale390(12)];
    _moreBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:_moreBtn];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.onTap) {
        self.onTap();
    }
}

- (void)setIsFooter:(BOOL)isFooter {
    _isFooter = isFooter;

    self.iconView.hidden = !self.isFooter;
    self.iconView.hidden = !self.isFooter;
    UIColor *footerColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    self.titleLabel.textColor = self.isFooter ? footerColor : [UIColor darkGrayColor];
}

- (void)setShowMoreBtn:(BOOL)showMoreBtn {
    _showMoreBtn = showMoreBtn;
    self.moreBtn.hidden = !showMoreBtn;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.isFooter) {
        self.iconView.mm_height(20).mm_width(20);
        self.iconView.mm_centerY = self.contentView.mm_centerY;
        self.iconView.mm_x = 10;
        [self.titleLabel sizeToFit];
        self.titleLabel.mm_centerY = self.contentView.mm_centerY;
        self.titleLabel.mm_x = self.iconView.mm_maxX + 10;
    } else {
        [self.titleLabel sizeToFit];
        self.titleLabel.mm_centerY = self.contentView.mm_centerY;
        self.titleLabel.mm_x = kScale390(16);
        [self.moreBtn sizeToFit];
        self.moreBtn.frame = CGRectMake(self.contentView.frame.size.width - self.moreBtn.frame.size.width - kScale390(20),
                                        (self.contentView.frame.size.height - self.moreBtn.frame.size.height) * 0.5, self.moreBtn.frame.size.width,
                                        self.moreBtn.frame.size.height);
    }
}

- (void)setFrame:(CGRect)frame {
    if (self.isFooter) {
        CGSize size = frame.size;
        size.height -= 10;
        frame.size = size;
    }
    [super setFrame:frame];
}

@end

@interface TUISearchChatHistoryResultHeaderView_Minimalist ()
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *rowAccessoryView;
@property(nonatomic, strong) UIView *separtorView;
@end
@implementation TUISearchChatHistoryResultHeaderView_Minimalist
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    _iconView = [[UIImageView alloc] init];
    _iconView.image = [UIImage imageNamed:TUISearchImagePath(@"search")];
    [self.contentView addSubview:_iconView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:_titleLabel];

    _rowAccessoryView = [[UIImageView alloc] init];
    _rowAccessoryView.image = [UIImage imageNamed:TUISearchImagePath(@"right")];
    [self.contentView addSubview:_rowAccessoryView];

    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.contentView addSubview:_separtorView];
}

- (void)configPlaceHolderImage:(UIImage *)img imgUrl:(NSString *)imgurl Text:(NSString *)text {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:imgurl] placeholderImage:img];
    _titleLabel.text = text;
}
- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.onTap) {
        self.onTap();
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.iconView.mm_height(kScale390(40)).mm_width(kScale390(40));
    self.iconView.mm_centerY = self.contentView.mm_centerY;
    self.iconView.mm_x = kScale390(16);

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.iconView.layer.masksToBounds = YES;
        self.iconView.layer.cornerRadius = self.iconView.frame.size.height / 2.0;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.iconView.layer.masksToBounds = YES;
        self.iconView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.titleLabel sizeToFit];
    self.titleLabel.mm_centerY = self.contentView.mm_centerY;
    self.titleLabel.mm_x = self.iconView.mm_maxX + kScale390(8);

    self.rowAccessoryView.mm_height(10).mm_width(10);
    self.rowAccessoryView.mm_centerY = self.contentView.mm_centerY;
    self.rowAccessoryView.mm_r = 10;

    self.separtorView.frame = CGRectMake(kScale390(16), self.contentView.mm_h - 1, self.contentView.mm_w, 1);
}

@end
