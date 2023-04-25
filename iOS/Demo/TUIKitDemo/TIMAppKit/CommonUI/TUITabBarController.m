//
//  TUITabBarController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/13.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUITabBarController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>


@implementation TUITabBarItem
@end

@interface TUITabBarController ()

@end

@implementation TUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //解决navigationtroller+tabbarcontroller，push是navigationbar变黑问题
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    
    self.tabBar.backgroundColor = self.backgroudColor;
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.tintColor = self.selectTextColor;
    self.tabBar.barTintColor = self.backgroudColor;
    self.tabBar.shadowImage = [UIImage new];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    
        [NSNotificationCenter.defaultCenter postNotificationName:@"TUITabBarControllerViewDidLoad" object:nil];
    });
}

- (void)setTabBarItems:(NSMutableArray *)tabBarItems
{
    _tabBarItems = tabBarItems;
    //tab bar items
    NSMutableArray *controllers = [NSMutableArray array];
    for (TUITabBarItem *item in _tabBarItems) {
        item.controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:item.title image:[item.normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item.controller.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        [controllers addObject:item.controller];
    }
    self.viewControllers = controllers;
}

- (UIColor *)backgroudColor
{
    return TUIDemoDynamicColor(@"tab_bg_color", @"#EBF0F6");
}

- (UIColor *)selectTextColor
{
    return TUIDemoDynamicColor(@"tab_title_text_select_color", @"#147AFF");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 因为tabbar加高了
    // Cause of increaing tabbar height
    CGFloat height = TabBar_Height + 8;
    CGRect newFrame = CGRectMake(0, self.view.frame.size.height - height,
                                 self.view.frame.size.width, height);
    [self.tabBar setFrame:newFrame];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (TUITabBarItem *item in _tabBarItems) {
        UIView *tabItemView = [self getTabBarContentView:item.controller.tabBarItem];
        CGRect frame = [self.tabBar convertRect:tabItemView.frame fromView:tabItemView.superview];
        item.badgeView.center = CGPointMake(CGRectGetMaxX(frame), frame.origin.y);
        [self.tabBar addSubview:item.badgeView];
    }
}

- (void)layoutBadgeViewIfNeeded {
    // async to relocate badgeview
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (TUITabBarItem *item in weakSelf.tabBarItems) {
            UIView *tabItemView = [weakSelf getTabBarContentView:item.controller.tabBarItem];
            CGRect frame = [weakSelf.tabBar convertRect:tabItemView.frame fromView:tabItemView.superview];
            item.badgeView.center = CGPointMake(CGRectGetMaxX(frame), frame.origin.y);
            [item.badgeView removeFromSuperview];
            [weakSelf.tabBar addSubview:item.badgeView];
        }
    });
}


- (UIView *)getTabBarContentView:(UITabBarItem *)tabBarItem {
    UIView *bottomView = [tabBarItem valueForKeyPath:@"_view"];
    UIView *contentView = bottomView;
    if (bottomView) {
        __block UIView *targetView = bottomView;
        [bottomView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subview isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                targetView = subview;
                *stop = YES;
            }
        }];
        contentView = targetView;
    }
    return contentView;
}

@end
