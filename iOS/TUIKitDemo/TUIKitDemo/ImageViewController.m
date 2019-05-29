//
//  ImageViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/31.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *progress;
@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.frame = self.view.bounds;
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    __weak typeof(self) ws = self;
    TImageType type = TImage_Type_Thumb;
    BOOL isExist = NO;
    NSString *originPath = [_data getImagePath:TImage_Type_Origin isExist:&isExist];
    if(isExist){
        _imageView.image = [UIImage imageWithContentsOfFile:originPath];
    }
    else{
        [_data downloadImage:type progress:^(NSInteger curSize, NSInteger totalSize) {
        } response:^(int code, NSString *desc, NSString *path) {
            if(code == 0){
                ws.imageView.image = [UIImage imageWithContentsOfFile:path];
            }
        }];
    }
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    
    if(!isExist){
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
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)downloadOrigin:(id)sender
{
    __weak typeof(self) ws = self;
    [_data downloadImage:TImage_Type_Origin progress:^(NSInteger curSize, NSInteger totalSize) {
        ws.progress.text = [NSString stringWithFormat:@"%ld%%", curSize * 100 / totalSize];
    } response:^(int code, NSString *desc, NSString *path) {
        if(code == 0){
            ws.imageView.image = [UIImage imageWithContentsOfFile:path];
            ws.button.hidden = YES;
        }
        ws.progress.hidden = YES;
    }];
}
@end
