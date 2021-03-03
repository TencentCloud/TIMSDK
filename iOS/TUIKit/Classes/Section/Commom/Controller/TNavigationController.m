//
//  TNavigationController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/13.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TNavigationController.h"

@interface TNavigationController ()

@end

@implementation TNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //push的时候隐藏底部tabbar
    if(self.viewControllers.count != 0){
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
    }
    [super pushViewController:viewController animated:animated];
}

// fix: https://developer.apple.com/forums/thread/660750
- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (@available(iOS 14.0, *)) {
        for (UIViewController *vc in self.viewControllers) {
            vc.hidesBottomBarWhenPushed = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    }
    return [super popToRootViewControllerAnimated:animated];
}

@end
