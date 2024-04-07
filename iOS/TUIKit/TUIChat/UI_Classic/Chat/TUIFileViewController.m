//
//  FileViewController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/11/12.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIFileViewController.h"
#import <QuickLook/QuickLook.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/UIView+TUIToast.h>
#import "ReactiveObjC/ReactiveObjC.h"

@interface TUIFileViewController () <UIDocumentInteractionControllerDelegate>
@property(nonatomic, strong) UIImageView *image;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *progress;
@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) UIDocumentInteractionController *document;
@end

@implementation TUIFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(File);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    titleLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    // left
    UIImage *defaultImage = [UIImage imageNamed:TUIChatImagePath(@"back")];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImage *formatImage = [TIMCommonDynamicImage(@"nav_back_img", defaultImage) rtl_imageFlippedForRightToLeftLayoutDirection];

    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:formatImage forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;

    _image = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80) * 0.5, NavBar_Height + StatusBar_Height + 50, 80, 80)];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    _image.image = [UIImage imageNamed:TUIChatImagePath(@"msg_file")];
    [self.view addSubview:_image];

    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, _image.frame.origin.y + _image.frame.size.height + 20, self.view.frame.size.width, 40)];
    _name.textColor = [UIColor blackColor];
    _name.font = [UIFont systemFontOfSize:15];
    _name.textAlignment = NSTextAlignmentCenter;
    _name.text = _data.fileName;
    [self.view addSubview:_name];

    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, _name.frame.origin.y + _name.frame.size.height + 20, self.view.frame.size.width - 200, 40)];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _button.backgroundColor = [UIColor colorWithRed:44 / 255.0 green:145 / 255.0 blue:247 / 255.0 alpha:1.0];
    _button.layer.cornerRadius = 5;
    [_button.layer setMasksToBounds:YES];
    [_button addTarget:self action:@selector(onOpen:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_button];

    @weakify(self);
    [RACObserve(_data, downladProgress) subscribeNext:^(NSNumber *x) {
      @strongify(self);
      int progress = [x intValue];
      if (progress < 100 && progress > 0) {
          [self.button setTitle:[NSString stringWithFormat:TIMCommonLocalizableString(TUIKitDownloadProgressFormat), progress] forState:UIControlStateNormal];
      } else {
          [self.button setTitle:TIMCommonLocalizableString(TUIKitOpenWithOtherApp) forState:UIControlStateNormal];
      }
    }];
    if ([_data isLocalExist]) {
        [self.button setTitle:TIMCommonLocalizableString(TUIKitOpenWithOtherApp) forState:UIControlStateNormal];

    } else {
        [self.button setTitle:TIMCommonLocalizableString(Download) forState:UIControlStateNormal];
    }
}

- (void)onOpen:(id)sender {
    BOOL isExist = NO;
    NSString *path = [_data getFilePath:&isExist];
    if (isExist) {
        NSURL *url = [NSURL fileURLWithPath:path];
        _document = [UIDocumentInteractionController interactionControllerWithURL:url];
        _document.delegate = self;
        [_document presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    } else {
        [_data downloadFile];
    }
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.frame;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
@end
