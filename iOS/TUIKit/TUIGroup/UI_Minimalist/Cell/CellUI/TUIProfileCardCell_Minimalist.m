//
//  TUIProfileCardCell_Minimalist.m
//  Masonry
//
//  Created by wyl on 2022/12/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIProfileCardCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIProfileCardCell_Minimalist
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    CGSize headSize = CGSizeMake(kScale390(66), kScale390(66));
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(kScale390(16), kScale390(10), headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;
    _avatar.layer.cornerRadius = 4;
    _avatar.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.contentView addSubview:_avatar];

    // CGSize genderIconSize = CGSizeMake(20, 20);
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.contentMode = UIViewContentModeScaleAspectFit;
    _genderIcon.image = self.cardData.genderIconImage;
    [self.contentView addSubview:_genderIcon];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont boldSystemFontOfSize:kScale390(24)]];
    [_name setTextColor:TIMCommonDynamicColor(@"form_title_color", @"#000000")];
    [self.contentView addSubview:_name];

    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:kScale390(12)]];
    [_identifier setTextColor:TIMCommonDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_identifier];

    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:kScale390(12)]];
    [_signature setTextColor:TIMCommonDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_signature];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)fillWithData:(TUIProfileCardCellData_Minimalist *)data {
    [super fillWithData:data];
    self.cardData = data;
    _signature.hidden = !data.showSignature;
    // set data
    @weakify(self);

    RAC(_signature, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];

    [[[RACObserve(data, identifier) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
      @strongify(self);
      self.identifier.text = [@"ID: " stringByAppendingString:data.identifier];
    }];

    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
      @strongify(self);
      self.name.text = x;
      [self.name sizeToFit];
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
      @strongify(self);
      [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];

    [[RACObserve(data, genderString) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
      @strongify(self);
      if ([x isEqualToString:TIMCommonLocalizableString(Male)]) {
          self.genderIcon.image = TUIGroupCommonBundleImage(@"male");
      } else if ([x isEqualToString:TIMCommonLocalizableString(Female)]) {
          self.genderIcon.image = TUIGroupCommonBundleImage(@"female");
      } else {
          self.genderIcon.image = nil;
      }
    }];

    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
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
    CGSize headSize = CGSizeMake(kScale390(66), kScale390(66));

    [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(headSize);
        make.top.mas_equalTo(kScale390(10));
        make.leading.mas_equalTo(kScale390(16));
    }];
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.name sizeToFit];
    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(TPersonalCommonCell_Margin);
        make.leading.mas_equalTo(self.avatar.mas_trailing).mas_offset(15);
        make.width.mas_lessThanOrEqualTo(self.name.frame.size.width);
        make.height.mas_greaterThanOrEqualTo(self.name.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.genderIcon.mas_leading).mas_offset(- 1);
    }];

    [self.genderIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.name.font.pointSize *0.9);
        make.centerY.mas_equalTo(self.name);
        make.leading.mas_equalTo(self.name.mas_trailing).mas_offset(1);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(- 10);
    }];

    [self.identifier sizeToFit];
    [self.identifier mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.name);
        make.top.mas_equalTo(self.name.mas_bottom).mas_offset(5);
        if(self.identifier.frame.size.width > 80) {
            make.width.mas_greaterThanOrEqualTo(self.identifier.frame.size.width);
        }
        else {
            make.width.mas_greaterThanOrEqualTo(@80);
        }
        make.height.mas_greaterThanOrEqualTo(self.identifier.frame.size.height);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(-1);
    }];

    if (self.cardData.showSignature) {
        [self.signature sizeToFit];
        [self.signature mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.name);
            make.top.mas_equalTo(self.identifier.mas_bottom).mas_offset(5);
            if(self.signature.frame.size.width > 80) {
                make.width.mas_greaterThanOrEqualTo(self.signature.frame.size.width);
            }
            else {
                make.width.mas_greaterThanOrEqualTo(@80);
            }
            make.height.mas_greaterThanOrEqualTo(self.signature.frame.size.height);
            make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).mas_offset(-1);
        }];
        
    } else {
        self.signature.frame = CGRectZero;
    }

}

- (void)onTapAvatar {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)]) [_delegate didTapOnAvatar:(id)self];
}

@end
