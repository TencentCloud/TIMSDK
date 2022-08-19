//
//  TUIProfileCardCell.m
//  UIKit
//
//  Created by annidy on 2019/5/27.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIProfileCardCell.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUIProfileCardCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
        
        if([_genderString isEqualToString:TUIKitLocalizableString(Male)]){
            _genderIconImage = TUIGroupCommonBundleImage(@"male");
        }else if([_genderString isEqualToString:TUIKitLocalizableString(Female)]){
            _genderIconImage = TUIGroupCommonBundleImage(@"female");
        }else{
            _genderIconImage = nil;
        }
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin + (self.showSignature ? 24 : 0);
}

@end

@implementation TUIProfileCardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGSize headSize = TPersonalCommonCell_Image_Size;
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
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
    
    //CGSize genderIconSize = CGSizeMake(20, 20);
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.contentMode = UIViewContentModeScaleAspectFit;
    _genderIcon.image = self.cardData.genderIconImage;
    [self.contentView addSubview:_genderIcon];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont boldSystemFontOfSize:18]];
    [_name setTextColor:TUICoreDynamicColor(@"form_title_color", @"#000000")];
    [self.contentView addSubview:_name];
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:13]];
    [_identifier setTextColor:TUICoreDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_identifier];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:TUICoreDynamicColor(@"form_subtitle_color", @"#888888")];
    [self.contentView addSubview:_signature];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(TUIProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
    _signature.hidden = !data.showSignature;
    //set data
    @weakify(self)
    
    RAC(_signature, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, identifier) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.identifier.text = [@"ID: " stringByAppendingString:data.identifier];
    }];
    
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];
    
    [[RACObserve(data, genderString) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *x) {
        @strongify(self)
        if([x isEqualToString:TUIKitLocalizableString(Male)]){
            self.genderIcon.image = TUIGroupCommonBundleImage(@"male");
        }else if([x isEqualToString:TUIKitLocalizableString(Female)]){
            self.genderIcon.image = TUIGroupCommonBundleImage(@"female");
        }else{
            self.genderIcon.image = nil;
        }
    }];
    
    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat maxLabelWidth = self.contentView.mm_w - CGRectGetMaxX(_avatar.frame) - 30;
    _name.mm_sizeToFitThan(0, _avatar.mm_h/3).mm_top(_avatar.mm_y).mm_left(_avatar.mm_maxX + TPersonalCommonCell_Margin);
    if (CGRectGetMaxX(_name.frame) >= self.contentView.mm_w) {
        _name.mm_w = maxLabelWidth;
    }
    
    _identifier.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_left(_name.mm_x);

    if (self.cardData.showSignature) {
        _identifier.mm_y = _name.mm_y + _name.mm_h + 5;
    } else {
        _identifier.mm_bottom(_avatar.mm_b);
    }
    
    _signature.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_left(_name.mm_x);
    _signature.mm_y = CGRectGetMaxY(_identifier.frame) + 5;
    if (CGRectGetMaxX(_signature.frame) >= self.contentView.mm_w) {
        _signature.mm_w = maxLabelWidth;
    }

    _genderIcon.mm_sizeToFitThan(_name.font.pointSize * 0.9, _name.font.pointSize * 0.9).mm__centerY(_name.mm_centerY).mm_left(_name.mm_x + _name.mm_w + TPersonalCommonCell_Margin);
}


-(void) onTapAvatar{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)])
        [_delegate didTapOnAvatar:self];
}

@end
