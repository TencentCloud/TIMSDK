//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUIMemberPanelCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation TUIMemberPanelCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)fillWithData:(UserModel *)model
{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
}

@end
