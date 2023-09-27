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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    if (self.isFooter) {
        [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.height.width.mas_equalTo(20);
            if(isRTL()){
                make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-10);
            }
            else {
                make.left.mas_equalTo(self.contentView.mas_left).mas_offset(10);
            }
        }];
        [self.titleLabel sizeToFit];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if(isRTL()) {
                make.right.mas_equalTo(self.iconView.mas_left).mas_offset(-10);
            }
            else{
                make.left.mas_equalTo(self.iconView.mas_right).mas_offset(10);
            }
            make.centerY.mas_equalTo(self.contentView);
            make.width.mas_equalTo(self.titleLabel.frame.size.width);
            make.height.mas_equalTo(self.titleLabel.font.lineHeight);
        }];
    
        MASAttachKeys(self.iconView,self.titleLabel);
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if(isRTL()) {
                make.left.mas_equalTo(self.moreBtn.mas_right).mas_offset(kScale390(16));
                make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-kScale390(16));
            }
            else{
                make.left.mas_equalTo(self.contentView.mas_left).mas_offset(kScale390(16));
                make.right.mas_equalTo(self.moreBtn.mas_left).mas_offset(-kScale390(16));
                
            }
//            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(kScale390(16));
            make.centerY.mas_equalTo(self.contentView);
//            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
            make.height.mas_equalTo(self.titleLabel.font.lineHeight);
        }];
        [self.moreBtn sizeToFit];
        [self.moreBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            if(isRTL()) {
                make.left.mas_equalTo(self.contentView).mas_offset(kScale390(10));
            }
            else{
                make.right.mas_equalTo(self.contentView).mas_offset(-kScale390(10));
            }
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(self.moreBtn.frame.size.width);
            make.height.mas_equalTo(self.moreBtn.frame.size.height);
        }];
        
        MASAttachKeys(self.titleLabel,self.moreBtn);
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
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
    _rowAccessoryView.image = [[UIImage imageNamed:TUISearchImagePath(@"right")] rtl_imageFlippedForRightToLeftLayoutDirection];
    [self.contentView addSubview:_rowAccessoryView];

    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.contentView addSubview:_separtorView];
}

- (void)configPlaceHolderImage:(UIImage *)img imgUrl:(NSString *)imgurl Text:(NSString *)text {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:imgurl] placeholderImage:img];
    _titleLabel.text = text;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
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

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];

    CGFloat imgWitdh = kScale390(40);
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.height.width.mas_equalTo(kScale390(40));
        if(isRTL()){
            make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-kScale390(16));
        }
        else {
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(kScale390(16));
        }
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.iconView.layer.masksToBounds = YES;
        self.iconView.layer.cornerRadius = imgWitdh / 2.0;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.iconView.layer.masksToBounds = YES;
        self.iconView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.titleLabel sizeToFit];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(isRTL()){
            make.right.mas_equalTo(self.iconView.mas_left).mas_offset(-kScale390(8));
        }
        else {
            make.left.mas_equalTo(self.iconView.mas_right).mas_offset(kScale390(8));
        }
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.titleLabel.frame.size.width);
        make.height.mas_equalTo(self.titleLabel.frame.size.height);
    }];
    
    [self.rowAccessoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(10);
        make.centerY.mas_equalTo(self.contentView);
        
        if(isRTL()){
            make.left.mas_equalTo(self.contentView.mas_left).mas_offset(10);
        }
        else {
            make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-10);
        }
//        make.trailing.mas_equalTo(self.contentView).mas_offset(-10);
    }];
    
    [self.separtorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-1);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
