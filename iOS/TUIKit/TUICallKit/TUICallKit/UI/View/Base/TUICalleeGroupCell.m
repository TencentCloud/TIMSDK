//
//  TUICalleeGroupCell.m
//  TUICalling
//
//  Created by noah on 2021/9/23.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICalleeGroupCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingCommon.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"

@interface TUICalleeGroupCell ()

@property (nonatomic, strong) UIImageView *userIcon;

@end

@implementation TUICalleeGroupCell

- (void)setModel:(CallingUserModel *)model {
    _model = model;
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
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
