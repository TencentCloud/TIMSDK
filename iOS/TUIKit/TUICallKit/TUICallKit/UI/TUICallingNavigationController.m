//
//  TUICallingViewController.m
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/13.
//  Copyright © 2022 Tencent. All rights reserved

#import <Foundation/Foundation.h>
#import "TUICallingNavigationController.h"

@implementation TUICallingNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    return [super initWithRootViewController:rootViewController];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

