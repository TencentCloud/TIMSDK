//
//  TUITabBarController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/13.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TUITabBarItem : NSObject
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIViewController *controller;
@end

@interface TUITabBarController : UITabBarController
@property (nonatomic, strong) NSMutableArray *tabBarItems;
@end
