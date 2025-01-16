//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMemberPanelCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>
#import "SDWebImage/UIImageView+WebCache.h"

@implementation TUIMemberPanelCell {
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TUIContactDynamicColor(@"group_controller_bg_color", @"#F2F3F5");
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)fillWithData:(TUIUserModel *)model {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar]
                  placeholderImage:[UIImage imageNamed:TIMCommonImagePath(@"default_c2c_head")]
                           options:SDWebImageHighPriority];
}

@end
