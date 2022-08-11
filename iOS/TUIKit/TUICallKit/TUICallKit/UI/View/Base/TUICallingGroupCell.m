//
//  TUICallingGroupCell.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingGroupCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingCommon.h"
#import "Masonry.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"

@interface TUICallingGroupCell ()

@property (nonatomic, strong) UILabel *titleLabel;
/// mask
@property (nonatomic, strong) UIView *maskView;
/// loading
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *volumeImageView;

@end

@implementation TUICallingGroupCell

- (void)setModel:(CallingUserModel *)model {
    _model = model;
    self.titleLabel.text = model.name ?: model.userId;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
    self.avatarImageView.hidden = model.isVideoAvailable;
    
    if (model.isEnter || model.isVideoAvailable || model.isAudioAvailable) {
        self.maskView.hidden = YES;
    } else {
        self.maskView.hidden = NO;
        [self.loadingImageView startAnimating];
    }
    
    if (model.isAudioAvailable) {
        [self.volumeImageView setImage:[TUICallingCommon getBundleImageWithName:@"ic_mute"]];
        
        if (model.volume >= 0.30) {
            self.volumeImageView.hidden = NO;
        } else {
            self.volumeImageView.hidden = YES;
        }
    } else {
        self.volumeImageView.hidden = YES;
    }
}

- (NSBundle *)callingBundle {
    NSURL *callingKitBundleURL = [[NSBundle mainBundle] URLForResource:@"TUICallingKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:callingKitBundleURL];
}

- (UIImage *)getBundleImageWithName:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self callingBundle] compatibleWithTraitCollection:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // renderView
        TUIVideoView *renderView = [[TUIVideoView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:renderView];
        self.renderView = renderView;
        // avatarImageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.avatarImageView = imageView;
        
        UIView *maskView = [[UIView alloc] init];
        maskView.backgroundColor = [UIColor t_colorWithHexString:@"#000000" alpha:0.3];
        [self.contentView addSubview:maskView];
        self.maskView = maskView;
        
        // loadingImageView
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i = 1; i <= 8; i++) {
            NSString *iamgeName = [NSString stringWithFormat:@"loading-%d", i];
            [imageArray addObject:[TUICallingCommon getBundleImageWithName:iamgeName]];
        }
        
        UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        loadingImageView.animationImages = [imageArray copy];
        loadingImageView.animationDuration = 2;
        loadingImageView.animationRepeatCount = 0;
        [loadingImageView startAnimating];
        self.loadingImageView = loadingImageView;
        [self.maskView addSubview:loadingImageView];
        
        // titleLabel
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor t_colorWithHexString:@"#FFFFFF"];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label];
        self.titleLabel = label;
        // volumeImageView
        UIImageView *volumeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        volumeImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:volumeImageView];
        self.volumeImageView.hidden = YES;
        self.volumeImageView = volumeImageView;
        
        [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.maskView);
            make.height.width.equalTo(@(42));
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.right.equalTo(self.volumeImageView.mas_left).offset(-5);
        }];
        [volumeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.contentView).offset(-5);
            make.centerY.equalTo(label);
            make.width.height.equalTo(@(20));
        }];
    }
    return self;
}

@end
