//
//  TCommonPendencyCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICommonPendencyCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUICommonPendencyCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        self.addSourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addSourceLabel];
        self.addSourceLabel.textColor = [UIColor tui_colorWithHex:@"#000000" alpha:0.6];
        self.addSourceLabel.font = [UIFont systemFontOfSize:kScale390(12)];

        self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addWordingLabel];
        self.addWordingLabel.textColor = [UIColor tui_colorWithHex:@"#000000" alpha:0.6];
        self.addWordingLabel.font = [UIFont systemFontOfSize:kScale390(12)];

        self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.agreeButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

        self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.rejectButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.rejectButton addTarget:self action:@selector(rejectClick) forControlEvents:UIControlEventTouchUpInside];

        UIStackView *stackView = [[UIStackView alloc] init];
        [stackView addSubview:self.agreeButton];
        [stackView addSubview:self.rejectButton];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentCenter;
        [stackView sizeToFit];
        self.stackView = stackView;
        self.accessoryView = stackView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarView.mm_width(kScale390(40)).mm_height(kScale390(40)).mm__centerY(self.contentView.mm_h / 2).mm_left(kScale390(16));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.titleLabel.mm_left(self.avatarView.mm_maxX + kScale390(12)).mm_top(kScale390(8)).mm_height(20).mm_width(120);

    //    self.addSourceLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(120);

    self.addWordingLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY + 4).mm_height(15).mm_width(120);
}
- (void)fillWithData:(TUICommonPendencyCellData_Minimalist *)pendencyData {
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addSourceLabel.text = pendencyData.addSource;
    self.addWordingLabel.text = pendencyData.addWording;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl];
    }
    if (pendencyData.isAccepted) {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agreed) forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    } else {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    }

    if (pendencyData.isRejected) {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Disclined) forState:UIControlStateNormal];
        self.rejectButton.enabled = NO;
        self.rejectButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.rejectButton.layer.cornerRadius = kScale390(10);
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"", @"#999999") forState:UIControlStateNormal];
        self.rejectButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    } else {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Discline) forState:UIControlStateNormal];
        self.rejectButton.enabled = YES;
        self.rejectButton.layer.borderColor = TIMCommonDynamicColor(@"", @"#DDDDDD").CGColor;
        self.rejectButton.layer.borderWidth = 1;
        self.rejectButton.layer.cornerRadius = kScale390(10);
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"", @"#FF584C") forState:UIControlStateNormal];
    }

    self.agreeButton.mm_sizeToFit().mm_width(kScale390(69));
    self.rejectButton.mm_left(CGRectGetMaxX(self.agreeButton.frame) + 10).mm_sizeToFit().mm_width(kScale390(76));
    self.stackView.bounds = CGRectMake(0, 0, 2 * self.agreeButton.mm_w + 10, self.agreeButton.mm_h);

    if (self.pendencyData.isRejected && !self.pendencyData.isAccepted) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = NO;
    } else if (self.pendencyData.isAccepted && !self.pendencyData.isRejected) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = YES;
    } else {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
    }

    self.addSourceLabel.hidden = self.pendencyData.hideSource;
}

- (void)agreeClick {
    if (self.pendencyData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)rejectClick {
    if (self.pendencyData.cRejectButtonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cRejectButtonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cRejectButtonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.agreeButton)) {
        return NO;
    } else if (touch.view == self.rejectButton) {
        return NO;
    }
    return YES;
}
@end
