//
//  TUIContactAcceptRejectCell_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2023/1/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactAcceptRejectCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIContactAcceptRejectCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.agreeButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

    self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rejectButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    [self.rejectButton addTarget:self action:@selector(rejectClick) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.agreeButton];
    [self.contentView addSubview:self.rejectButton];
}
- (void)fillWithData:(TUIContactAcceptRejectCellData_Minimalist *)data {
    [super fillWithData:data];
    self.acceptRejectData = data;

    if (data.isAccepted) {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agreed) forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"", @"#999999") forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    } else {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    }

    if (data.isRejected) {
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
        self.rejectButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
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
    CGFloat margin = kScale390(25);
    CGFloat padding = kScale390(20);
    CGFloat btnWidth = (self.contentView.frame.size.width - 2 * margin - padding) * 0.5;
    CGFloat btnHeight = kScale390(42);
    
    [self.agreeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(margin);
        make.trailing.mas_equalTo(self.rejectButton.mas_leading).mas_offset(- padding);
        make.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(btnHeight);
    }];
    [self.rejectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.agreeButton);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- margin);
        make.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(btnHeight);
    }];
    if (self.acceptRejectData.isRejected && !self.acceptRejectData.isAccepted) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = NO;
        [self.rejectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(margin);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- margin);
            make.top.mas_equalTo(self.contentView);
            make.height.mas_equalTo(btnHeight);
        }];
    } else if (self.acceptRejectData.isAccepted && !self.acceptRejectData.isRejected) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = YES;
        [self.agreeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(margin);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- margin);
            make.top.mas_equalTo(self.contentView);
            make.height.mas_equalTo(btnHeight);
        }];
    } else {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
    }
    
}
- (void)agreeClick {
    if (self.acceptRejectData.agreeClickCallback) {
        self.acceptRejectData.agreeClickCallback();
    }
}

- (void)rejectClick {
    if (self.acceptRejectData.rejectClickCallback) {
        self.acceptRejectData.rejectClickCallback();
    }
}
@end
