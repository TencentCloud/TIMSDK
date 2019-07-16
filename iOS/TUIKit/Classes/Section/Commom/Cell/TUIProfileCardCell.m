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

@implementation TUIProfileCardCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
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
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
    
    [self addSubview:_avatar];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:15]];
    [_name setTextColor:[UIColor blackColor]];
    [self addSubview:_name];
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:14]];
    [_identifier setTextColor:[UIColor grayColor]];
    [self addSubview:_identifier];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:[UIColor grayColor]];
    [self addSubview:_signature];
    
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
        self.identifier.text = [@"帐号: " stringByAppendingString:data.identifier];
    }];   
    
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
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
    
    _name.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_top(_avatar.mm_y).mm_left(_avatar.mm_maxX + TPersonalCommonCell_Margin);
    _identifier.mm_sizeToFitThan(80, _avatar.mm_h/3).mm__centerY(_avatar.mm_centerY).mm_left(_name.mm_x);
    _signature.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_bottom(_avatar.mm_b).mm_left(_name.mm_x);
}


@end
