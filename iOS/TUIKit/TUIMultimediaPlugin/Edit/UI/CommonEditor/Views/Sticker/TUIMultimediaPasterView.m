// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaPasterView.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaStickerView.h"

#define  PASTER_INITIAL_WIDTH 150

@interface TUIMultimediaPasterView () {
    UIImageView *_imgView;
}

@end

@implementation TUIMultimediaPasterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _imgView = [[UIImageView alloc] init];
    _imgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.editButtonHidden = YES;
    self.content = _imgView;
}
- (UIImage *)paster {
    return _imgView.image;
}
- (void)setPaster:(UIImage *)paster {
    self.content = nil;
    _imgView.image = paster;
    int width = MIN(PASTER_INITIAL_WIDTH, paster.size.width);
    int height = width / paster.size.width * paster.size.height;
    _imgView.bounds = CGRectMake(0, 0, width, height);
    self.content = _imgView;
}
@end
