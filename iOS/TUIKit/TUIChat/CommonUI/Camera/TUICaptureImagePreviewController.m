
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICaptureImagePreviewController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@interface TUICaptureImagePreviewController () {
    UIImage *_image;
}

@property(nonatomic) UIImageView *imageView;
@property(nonatomic) UIButton *commitButton;
@property(nonatomic) UIButton *cancelButton;
@property(nonatomic) CGRect lastRect;

@end

@implementation TUICaptureImagePreviewController

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    NSLog(@"%ld--%ld", (long)_image.imageOrientation, UIImageOrientationUp);

    self.commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *commitImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camer_commit")];
    [self.commitButton setImage:commitImage forState:UIControlStateNormal];
    UIImage *commitBGImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camer_commitBg")];
    [self.commitButton setBackgroundImage:commitBGImage forState:UIControlStateNormal];
    [self.commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commitButton];

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cancelButtonBGImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"camera_cancel")];
    [self.cancelButton setBackgroundImage:cancelButtonBGImage forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (!CGRectEqualToRect(self.lastRect, self.view.bounds)) {
        self.lastRect = self.view.bounds;

        self.imageView.frame = self.view.bounds;

        CGFloat commitButtonWidth = 80.0;
        CGFloat buttonDistance = (self.view.bounds.size.width - 2 * commitButtonWidth) / 3.0;
        CGFloat commitButtonY = self.view.bounds.size.height - commitButtonWidth - 50.0;
        CGFloat commitButtonX = 2 * buttonDistance + commitButtonWidth;
        self.commitButton.frame = CGRectMake(commitButtonX, commitButtonY, commitButtonWidth, commitButtonWidth);

        CGFloat cancelButtonX = commitButtonWidth;
        self.cancelButton.frame = CGRectMake(cancelButtonX, commitButtonY, commitButtonWidth, commitButtonWidth);
        
        if (isRTL()) {
            [self.commitButton resetFrameToFitRTL];
            [self.cancelButton resetFrameToFitRTL];
        }
    }
}

- (void)commitButtonClick:(UIButton *)btn {
    if (self.commitBlock) {
        self.commitBlock();
    }
}

- (void)cancelButtonClick:(UIButton *)btn {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end
