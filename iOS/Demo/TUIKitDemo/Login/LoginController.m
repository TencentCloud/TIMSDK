//
//  LoginController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 登录界面
 *  本文件实现了Demo中的登录界面
 *  值得注意的是，实际登录模块与Demo中的登录模块有所不同。
 *  Demo中为了方便用户体验，只需在AppDelegate.h中填用户名和usersig即可（具体获得过程请参照https://github.com/tencentyun/TIMSDK/tree/master/iOS）
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */

#import "LoginController.h"
#import "TUIKit.h"
#import "AppDelegate.h"
#import "TUILoginCache.h"
#import "GenerateTestUserSig.h"


@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *user;
@end

@implementation LoginController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
}

- (void)onTap
{
    [self.view endEditing:YES];
}


- (IBAction)login:(id)sender {
    
    [self.view endEditing:YES];
    
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
    [[TUILoginCache sharedInstance] saveLogin:userId withAppId:SDKAPPID withUserSig:userSig];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    @weakify(self)
    [delegate login:userId userSig:userSig succ:^{
        [TUITool hideToastActivity];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [TUITool hideToastActivity];
        [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsLoginErrorFormat", nil),code,@"Please check whether the SDKAPPID and SECRETKEY are correctly configured (GenerateTestUserSig.h)"]];
    }];
}


- (void)alertText:(NSString *)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];

    [self presentViewController:alert animated:YES completion:nil];
}



@end
