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

@interface TUICallingGroupCell ()

/// 用户昵称
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TUICallingGroupCell

- (void)setModel:(CallUserModel *)model {
    _model = model;
    self.titleLabel.text = model.name ?: model.userId;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIColor imageWithColor:[UIColor t_colorWithHexString:@"999999"] andSize:CGSizeMake(1, 1)]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.avatarImageView = imageView;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor t_colorWithHexString:@"#FFFFFF"];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label];
        self.titleLabel = label;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
    return self;
}

@end
