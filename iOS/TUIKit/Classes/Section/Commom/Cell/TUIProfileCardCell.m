//
//  TUIProfileCardCell.m
//  UIKit
//
//  Created by annidy on 2019/5/27.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#import "TUIProfileCardCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

@implementation TUIProfileCardCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
        
        if([_genderString isEqualToString:TUILocalizableString(Male)]){
            _genderIconImage = [UIImage tk_imageNamed:@"male"];
        }else if([_genderString isEqualToString:TUILocalizableString(Female)]){
            _genderIconImage = [UIImage tk_imageNamed:@"female"];
        }else{
            //(性别 iCon 在未设置性别时不显示)
            _genderIconImage = nil;
        }
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
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
    //添加点击头像的手势
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
    [self.contentView addSubview:_avatar];
    
    //CGSize genderIconSize = CGSizeMake(20, 20);
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.contentMode = UIViewContentModeScaleAspectFit;
    _genderIcon.image = self.cardData.genderIconImage;
    [self.contentView addSubview:_genderIcon];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:15]];
    [_name setTextColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark]];
    [self.contentView addSubview:_name];
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:14]];
    [_identifier setTextColor:[UIColor d_systemGrayColor]];
    [self.contentView addSubview:_identifier];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:[UIColor d_systemGrayColor]];
    [self.contentView addSubview:_signature];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(TUIProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
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
        if([x isEqualToString:TUILocalizableString(Male)]){
            self.genderIcon.image = [UIImage tk_imageNamed:@"male"];
        }else if([x isEqualToString:TUILocalizableString(Female)]){
            self.genderIcon.image = [UIImage tk_imageNamed:@"female"];
        }else{
            //(性别 iCon 在未设置性别时不显示)
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
    //此处解除 nameLabel 的 fit 宽度，使性别 icon 能够在短昵称情况下和 nameLabel 相邻。
    _name.mm_sizeToFitThan(0, _avatar.mm_h/3).mm_top(_avatar.mm_y).mm_left(_avatar.mm_maxX + TPersonalCommonCell_Margin);
    _identifier.mm_sizeToFitThan(80, _avatar.mm_h/3).mm__centerY(_avatar.mm_centerY).mm_left(_name.mm_x);
    _signature.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_bottom(_avatar.mm_b).mm_left(_name.mm_x);
    //iCon大小 = 字体*0.9，视觉上最为自然
    _genderIcon.mm_sizeToFitThan(_name.font.pointSize * 0.9, _name.font.pointSize * 0.9).mm__centerY(_name.mm_centerY).mm_left(_name.mm_x + _name.mm_w + TPersonalCommonCell_Margin);
}


-(void) onTapAvatar{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)])
        [_delegate didTapOnAvatar:self];
}

@end
