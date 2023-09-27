//
//  TUISearchResultHeaderFooterView.m
//  Pods
//
//  Created by harvy on 2020/12/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchResultHeaderFooterView.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUISearchResultHeaderFooterView ()

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *accessoryView;
@property(nonatomic, strong) UIView *separtorView;

@end

@implementation TUISearchResultHeaderFooterView

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
    _titleLabel.font = [UIFont systemFontOfSize:12.0];
    _titleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    [self.contentView addSubview:_titleLabel];

    _accessoryView = [[UIImageView alloc] init];
    _accessoryView.image = [[UIImage imageNamed:TUISearchImagePath(@"right")] rtl_imageFlippedForRightToLeftLayoutDirection];
    [self.contentView addSubview:_accessoryView];

    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.contentView addSubview:_separtorView];
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
    self.accessoryView.hidden = !self.isFooter;
    UIColor *footerColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    self.titleLabel.textColor = self.isFooter ? footerColor : [UIColor darkGrayColor];

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    
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
            make.leading.mas_equalTo(self.iconView.mas_trailing).mas_offset(10);
            make.centerY.mas_equalTo(self.contentView);
            make.width.mas_equalTo(self.titleLabel.frame.size.width);
            make.height.mas_equalTo(self.titleLabel.font.lineHeight);
        }];
        
        [self.accessoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(10);
            make.centerY.mas_equalTo(self.contentView);
            if(isRTL()) {
                make.left.mas_equalTo(self.contentView.mas_left).mas_offset(10);
            }else {
                make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-10);
            }
        }];
        [self.separtorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.bottom.mas_equalTo(self.contentView);
            make.width.mas_equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];

        MASAttachKeys(self.iconView,self.titleLabel,self.accessoryView,self.separtorView);
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(10);
            make.centerY.mas_equalTo(self.contentView);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
            make.height.mas_equalTo(self.titleLabel.font.lineHeight);
        }];
        [self.separtorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.bottom.mas_equalTo(self.contentView).mas_offset(-1);
            make.width.mas_equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
        MASAttachKeys(self.titleLabel,self.separtorView);
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
