//
//  TUIAudioCalledView.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/13.
//

#import "TUIAudioCalledView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUIAudioCalledView
{
    UIImageView *_imageView;
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_imageView];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
        _label.backgroundColor = [UIColor blackColor];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.alpha = 0.4;
        [self addSubview:_label];
    }
    return self;
}

- (void)fillWithData:(CallUserModel *)model {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
    if (model.name.length > 0) {
        _label.text = model.name;
    } else {
        _label.text = model.userId;
    }
}

@end
