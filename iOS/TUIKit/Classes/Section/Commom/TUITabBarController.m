//
//  TUITabBarController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/13.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUITabBarController.h"
#import "THeader.h"


@implementation TUITabBarItem
@end

@interface TUITabBarController ()

@end

@implementation TUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //解决navigationtroller+tabbarcontroller，push是navigationbar变黑问题
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
}

- (void)setTabBarItems:(NSMutableArray *)tabBarItems
{
    _tabBarItems = tabBarItems;
    //tab bar items
    NSMutableArray *controllers = [NSMutableArray array];
    for (TUITabBarItem *item in _tabBarItems) {
        item.controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:item.title image:item.normalImage selectedImage:[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item.controller.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        [controllers addObject:item.controller];
    }
    self.viewControllers = controllers;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = TabBar_Height + 8; //因为tabbar加高了
    CGRect newFrame = CGRectMake(0, self.view.frame.size.height - height,
                                 self.view.frame.size.width, height);
    [self.tabBar setFrame:newFrame];
}
@end
