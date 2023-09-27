//
//  TUIContactActionCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactActionCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactCellData.h"

@interface TUIContactActionCell ()
@property TUIContactActionCellData *actionData;
@end

@implementation TUIContactActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
        
        self.unRead = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:self.unRead];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)fillWithData:(TUIContactActionCellData *)actionData {
    [super fillWithData:actionData];
    self.actionData = actionData;

    self.titleLabel.text = actionData.title;
    if (actionData.icon) {
        [self.avatarView setImage:actionData.icon];
    }
    @weakify(self);
    [[RACObserve(self.actionData, readNum) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      [self.unRead setNum:[x integerValue]];
    }];

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
    CGFloat imgWidth = kScale390(34);
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.width.height.mas_equalTo(imgWidth);
      make.centerY.mas_equalTo(self.contentView.mas_centerY);
      make.leading.mas_equalTo(kScale390(12));
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.centerY.mas_equalTo(self.avatarView.mas_centerY);
      make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
      make.height.mas_equalTo(20);
      make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing);
    }];

    [self.unRead.unReadLabel sizeToFit];
    [self.unRead mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.centerY.mas_equalTo(self.avatarView.mas_centerY);
      make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-5);
      make.width.mas_equalTo(kScale375(20));
      make.height.mas_equalTo(kScale375(20));
    }];
    [self.unRead.unReadLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.center.mas_equalTo(self.unRead);
      make.size.mas_equalTo(self.unRead.unReadLabel);
    }];
    self.unRead.layer.cornerRadius = kScale375(10);
    [self.unRead.layer masksToBounds];
}

@end
