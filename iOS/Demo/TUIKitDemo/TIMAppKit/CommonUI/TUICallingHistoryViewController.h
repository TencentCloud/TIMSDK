//
//  TUICallingHistoryViewController.h
//  TIMAppKit
//
//  Created by harvy on 2023/3/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingHistoryViewController : UIViewController
@property(nonatomic, copy) void (^viewWillAppear)(BOOL isAppear);
@property(nonatomic, strong) UIViewController *callsVC;
@property(nonatomic, assign) BOOL isMimimalist;
+ (nullable instancetype)createCallingHistoryViewController:(BOOL)isMimimalist;
@end

NS_ASSUME_NONNULL_END
