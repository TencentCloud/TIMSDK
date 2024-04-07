//
//  LoginController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "LoginController.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"
#import "TUIThemeManager.h"
#import "TUIThemeSelectController.h"
#import "TUILanguageSelectController.h"
#import "TCLoginModel.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UIImageView *logView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) UIView *changeStyleView;
@property (nonatomic, strong) UIView *changeSkinView;
@property (nonatomic, strong) UIView *changeLanguageView;

@end

@implementation LoginController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F3F4F5");
    self.logView.image = TUIDemoDynamicImage(@"public_login_logo_img", [UIImage imageNamed:@"public_login_logo"]);
    self.loginButton.backgroundColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    
    
    self.changeStyleView = [self createOptionalView:NSLocalizedString(@"ChangeStyle", nil)
                                          leftIcon:TUIDemoDynamicImage(@"", [UIImage imageNamed:@"icon_style"])
                                         rightIcon:TUIDemoDynamicImage(@"login_drop_img", [UIImage imageNamed:@"icon_drop_arraw"])];
    [self.changeStyleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangeStyle)]];
    
    self.changeSkinView = [self createOptionalView:NSLocalizedString(@"ChangeSkin", nil)
                                          leftIcon:[UIImage imageNamed:@"icon_skin"]
                                         rightIcon:[UIImage imageNamed:@"icon_drop_arraw"]];
    [self.changeSkinView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangeSkin)]];
    self.changeLanguageView = [self createOptionalView:NSLocalizedString(@"CurrentLanguage", nil)
                                              leftIcon:[UIImage imageNamed:@"icon_language"]
                                             rightIcon:[UIImage imageNamed:@"icon_drop_arraw"]];
    [self.changeLanguageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangeLanguage)]];
    
    [self.view addSubview:self.changeStyleView];
    [self.view addSubview:self.changeSkinView];
    [self.view addSubview:self.changeLanguageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.changeLanguageView.mm_right(20);
        if (@available(iOS 11.0, *)) {
            weakSelf.changeLanguageView.mm_y = 10 + weakSelf.view.mm_safeAreaTopGap;
        } else {
            weakSelf.changeLanguageView.mm_y = 10;
        }
        
        if ([TUIStyleSelectViewController isClassicEntrance]) {
            self.changeSkinView.hidden = NO;
            self.changeSkinView.mm_right(20 + self.changeLanguageView.mm_w + 20);
            self.changeSkinView.mm_y = self.changeLanguageView.mm_y;
            
            self.changeStyleView.mm_right(40 + self.changeSkinView.mm_w + self.changeLanguageView.mm_w + 20);
            self.changeStyleView.mm_y = self.changeLanguageView.mm_y;
        }
        else {
            self.changeSkinView.hidden = YES;
            self.changeStyleView.mm_right(20 + self.changeLanguageView.mm_w + 20);
            self.changeStyleView.mm_y = self.changeLanguageView.mm_y;
        }
        
    });
}

- (void)onTap {
    [self.view endEditing:YES];
}

- (void)onChangeLanguage {
    TUILanguageSelectController *vc = [[TUILanguageSelectController alloc] init];
    vc.delegate = AppDelegate.sharedInstance;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onChangeStyle {
    TUIStyleSelectViewController *vc = [[TUIStyleSelectViewController alloc] init];
    vc.delegate = AppDelegate.sharedInstance;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onChangeSkin {
    TUIThemeSelectController *vc = [[TUIThemeSelectController alloc] init];
    vc.delegate = AppDelegate.sharedInstance;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)login:(id)sender {
    [self.view endEditing:YES];
    
    [TCLoginModel sharedInstance].isDirectlyLoginSDK = YES;
    NSString *userid = self.user.text;
    NSString *userSig = [GenerateTestUserSig genTestUserSig:userid];
    [self loginIM:userid userSig:userSig];
}

- (void)loginIM:(NSString *)userId userSig:(NSString *)userSig {
    if (userId.length == 0 || userSig.length == 0) {
        [TUITool hideToastActivity];
        [self alertText:NSLocalizedString(@"TipsLoginErrorWithUserIdfailed", nil)];
        return;
    }
    [[TCLoginModel sharedInstance] saveLoginedInfoWithUserID:userId userSig:userSig];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    @weakify(self)
    [delegate loginSDK:userId userSig:userSig succ:^{
        [TUITool hideToastActivity];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [TUITool hideToastActivity];
        [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsLoginErrorFormat", nil),code,@"Please check whether the SDKAPPID and SECRETKEY are correctly configured (GenerateTestUserSig.h)"]];
    }];
}


- (void)alertText:(NSString *)str {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (UIView *)createOptionalView:(NSString *)title
                      leftIcon:(UIImage *)leftImage
                     rightIcon:(UIImage *)rightImage {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor grayColor];
    label.userInteractionEnabled = YES;
    [contentView addSubview:label];
    
    UIImageView *leftIconView = [[UIImageView alloc] init];
    leftIconView.image = leftImage;
    leftIconView.userInteractionEnabled = YES;
    [contentView addSubview:leftIconView];
    
    UIImageView *rightIconView = [[UIImageView alloc] init];
    rightIconView.image = rightImage;
    rightIconView.userInteractionEnabled = YES;
    [contentView addSubview:rightIconView];

    leftIconView.mm_width(18.0).mm_height(18.0);
    leftIconView.mm_x = 0;
    leftIconView.mm_centerY = 0.5 * (contentView.mm_h - leftIconView.mm_h);
    
    [label sizeToFit];
    label.mm_x = CGRectGetMaxX(leftIconView.frame) + 5.0;
    label.mm_centerY = leftIconView.mm_centerY;
    
    rightIconView.mm_width(10.0).mm_height(7.0);
    rightIconView.mm_x = CGRectGetMaxX(label.frame) + 5.0;
    rightIconView.mm_centerY = leftIconView.mm_centerY;
    
    contentView.mm_w = CGRectGetMaxX(rightIconView.frame);
    
    return contentView;
}


@end
