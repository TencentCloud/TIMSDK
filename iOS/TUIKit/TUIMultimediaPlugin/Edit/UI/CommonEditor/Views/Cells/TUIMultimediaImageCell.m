// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaImageCell.h"
#import <Masonry/Masonry.h>

@interface TUIMultimediaImageCell () {
    UIImageView *_imgView;
}
@end

@implementation TUIMultimediaImageCell

@dynamic image;

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _imgView = [[UIImageView alloc] init];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imgView];

    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];
}
- (UIImage *)image {
    return _imgView.image;
}
- (void)setImage:(UIImage *)image {
    _imgView.image = image;
}

@end
