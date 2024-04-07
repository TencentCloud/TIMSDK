//
//  TUITabBarController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/13.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIBadgeView.h"

@class TUIBadgeView;

@interface TUITabBarItem : NSObject
@property(nonatomic, strong) UIImage *normalImage;
@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIViewController *controller;
@property(nonatomic, strong) TUIBadgeView *badgeView;
@property(nonatomic, copy)   NSString *identity;
@end

@interface TUITabBarController : UITabBarController
@property(nonatomic, strong) NSMutableArray *tabBarItems;
- (void)layoutBadgeViewIfNeeded;
@end
