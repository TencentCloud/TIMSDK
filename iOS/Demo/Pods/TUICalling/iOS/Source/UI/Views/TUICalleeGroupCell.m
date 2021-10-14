//
//  TUICalleeGroupCell.m
//  TUICalling
//
//  Created by noah on 2021/9/23.
//

#import "TUICalleeGroupCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+TUIHex.h"

@interface TUICalleeGroupCell ()

@property (nonatomic, strong) UIImageView *userIcon;

@end

@implementation TUICalleeGroupCell

- (void)setModel:(CallUserModel *)model {
    _model = model;
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIColor imageWithColor:[UIColor t_colorWithHexString:@"#999999"] andSize:CGSizeMake(1, 1)]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.userIcon = imageView;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

@end
