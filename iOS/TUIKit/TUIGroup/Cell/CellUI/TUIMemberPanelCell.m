//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUIMemberPanelCell.h"
#import "TUIDarkModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUIMemberPanelCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#F2F3F5");
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)fillWithData:(TUIUserModel *)model
{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUICoreImagePath(@"default_c2c_head")] options:SDWebImageHighPriority];
}

@end
