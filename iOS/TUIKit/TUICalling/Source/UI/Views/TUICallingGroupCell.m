//
//  TUICallingGroupCell.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import "TUICallingGroupCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+TUIHex.h"
#import "TUICommonUtil.h"

@interface TUICallingGroupCell ()

/// 用户昵称
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UIImageView *volumeImageView;

@end

@implementation TUICallingGroupCell

- (void)setModel:(CallUserModel *)model {
    _model = model;
    self.titleLabel.text = model.name ?: model.userId;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[TUICommonUtil getBundleImageWithName:@"userIcon"]];
    self.avatarImageView.hidden = model.isVideoAvaliable;
    self.bgView.hidden = model.isEnter || model.isVideoAvaliable || model.isAudioAvaliable;
    
    // 处理麦克风图标问题
    if (model.isAudioAvaliable) {
        [self.volumeImageView setImage:[TUICommonUtil getBundleImageWithName:@"ic_mute"]];
        
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
        UIView *renderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:renderView];
        self.renderView = renderView;
        // avatarImageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.avatarImageView = imageView;
        // 蒙层视图
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor t_colorWithHexString:@"#000000" alpha:0.3];
        [self.contentView addSubview:bgView];
        self.bgView = bgView;
        
        // loadingImageView
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i = 1; i <= 8; i++) {
            NSString *iamgeName = [NSString stringWithFormat:@"loading-%d", i];
            [imageArray addObject:[TUICommonUtil getBundleImageWithName:iamgeName]];
        }
        
        UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        loadingImageView.animationImages = [imageArray copy];
        loadingImageView.animationDuration = 2;
        loadingImageView.animationRepeatCount = 0;
        [loadingImageView  startAnimating];
        [self.bgView addSubview:loadingImageView];
        
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
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.bgView);
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
