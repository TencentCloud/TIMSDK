//
//  SettingController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "SettingController.h"
#import "TSettingController.h"
#import "LoginController.h"
#import "AppDelegate.h"

@interface SettingController () <TSettingControllerDelegate>

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    TSettingController *set = [[TSettingController alloc] init];
    set.delegate = self;
    [self addChildViewController:set];
    [self.view addSubview:set.view];
}

- (void)didLogoutInSettingController:(TSettingController *)controller
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_User];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Sig];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
    self.view.window.rootViewController = login;
}
@end
