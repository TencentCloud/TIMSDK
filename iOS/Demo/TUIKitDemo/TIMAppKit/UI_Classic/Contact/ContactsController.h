//
//  ContactsController.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019 kennethmiao. All rights reserved.
//
/**
 *
 *  Tencent Cloud Chat Demo Friends List View
 *  - This viewcontroller corresponds to the "contact" item on the tabBar.
 *  - This file implements the friend list interface, allowing users to browse their own friends, groups and manage them.
 *  - This class depends on Tencent Cloud TUIKit and IMSDK.
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsController : UIViewController
@property(nonatomic, copy) void (^viewWillAppear)(BOOL isAppear);
@end

NS_ASSUME_NONNULL_END
