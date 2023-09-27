//
//  TUIFriendProfileHeaderView_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2022/12/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFriendProfileHeaderView_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMConfig.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIFriendProfileHeaderItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}
- (void)setupView {
    self.iconView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.iconView];
    self.iconView.userInteractionEnabled = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;

    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    self.textLabel.textColor = [UIColor tui_colorWithHex:@"#000000"];
    self.textLabel.rtlAlignment = TUITextRTLAlignmentCenter;
    [self addSubview:self.textLabel];
    self.textLabel.text = @"Message";

    self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
    self.layer.cornerRadius = kScale390(12);
    self.layer.masksToBounds = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kScale390(30));
        make.top.mas_equalTo(kScale390(19));
        make.centerX.mas_equalTo(self);
    }];
    [self.textLabel sizeToFit];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kScale390(19));
        make.top.mas_equalTo(self.iconView.mas_bottom).mas_offset(kScale390(11));
        make.centerX.mas_equalTo(self);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];

}
- (void)click {
    if (self.messageBtnClickBlock) {
        self.messageBtnClickBlock();
    }
}
@end

@interface TUIFriendProfileHeaderView_Minimalist ()
@end

@implementation TUIFriendProfileHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.headImg = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.headImg];
    self.headImg.userInteractionEnabled = YES;
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;

    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:kScale390(24)];
    [self addSubview:self.descriptionLabel];

    self.functionListView = [[UIView alloc] init];
    [self addSubview:self.functionListView];
}

- (void)setItemViewList:(NSArray<TUIFriendProfileHeaderItemView *> *)itemList {
    for (UIView *subView in self.functionListView.subviews) {
        [subView removeFromSuperview];
    }

    if (itemList.count > 0) {
        for (TUIFriendProfileHeaderItemView *itemView in itemList) {
            [self.functionListView addSubview:itemView];
        }
        CGFloat width = kScale390(92);
        CGFloat height = kScale390(95);
        CGFloat space = kScale390(24);
        CGFloat contentWidth = itemList.count * width + (itemList.count - 1) * space;
        CGFloat x = 0.5 * (self.bounds.size.width - contentWidth);
        for (TUIFriendProfileHeaderItemView *itemView in itemList) {
            itemView.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(itemView.frame) + space;
        }
    }
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
    CGFloat imgWidth = kScale390(94);
    [self.headImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(kScale390(42));
    }];
    
    MASAttachKeys(self.headImg);

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.headImg.mas_bottom).mas_offset(kScale390(10));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(self.descriptionLabel.frame.size.width);
        make.width.mas_lessThanOrEqualTo(self).multipliedBy(0.5);
    }];
    MASAttachKeys(self.descriptionLabel);

    if (self.functionListView.subviews.count > 0) {
        [self.functionListView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.width.mas_equalTo(self.bounds.size.width);
            make.height.mas_equalTo(kScale390(95));
            make.top.mas_equalTo(self.descriptionLabel.mas_bottom).mas_offset(kScale390(18));
        }];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
