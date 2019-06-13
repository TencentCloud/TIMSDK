//
//  TUIImageViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/31.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIImageViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"

@interface TUIImageViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *progress;
@end

@implementation TUIImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.frame = self.view.bounds;
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    BOOL isExist = NO;
    [_data getImagePath:TImage_Type_Origin isExist:&isExist];
    if (isExist) {
        if(_data.originImage) {
            _imageView.image = _data.originImage;
        } else {
            [_data decodeImage:TImage_Type_Origin];
            @weakify(self)
            [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
                @strongify(self)
                self.imageView.image = x;
            }];
        }
    } else {
        _imageView.image = _data.thumbImage;
        
        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_progress];
        
        _button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80) * 0.5, self.view.frame.size.height - 60, 80, 30)];
        [_button setTitle:@"查看原图" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:13];
        _button.backgroundColor = [UIColor clearColor];
        _button.layer.borderColor = [UIColor whiteColor].CGColor;
        _button.layer.borderWidth = 0.5;
        _button.layer.cornerRadius = 3;
        [_button.layer setMasksToBounds:YES];
        [_button addTarget:self action:@selector(downloadOrigin:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }

    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)downloadOrigin:(id)sender
{
    [_data downloadImage:TImage_Type_Origin];
    @weakify(self)
    [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
        @strongify(self)
        if (x) {
            self.imageView.image = x;
            self.progress.hidden = YES;
        }
    }];
    [RACObserve(_data, originProgress) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        int progress = [x intValue];
        self.progress.text =  [NSString stringWithFormat:@"%d%%", progress];
        if (progress >= 100)
            self.progress.hidden = YES;
    }];
    self.button.hidden = YES;
}
@end
