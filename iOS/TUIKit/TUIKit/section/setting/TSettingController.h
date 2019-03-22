//
//  TSettingController.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIMFriendshipManager.h"

@class TSettingController;
@protocol TSettingControllerDelegate <NSObject>
- (void)didLogoutInSettingController:(TSettingController *)controller;
@end

@interface TSettingController : UITableViewController
@property (nonatomic, weak) id<TSettingControllerDelegate> delegate;
@property TIMUserProfile *profile;
@end
