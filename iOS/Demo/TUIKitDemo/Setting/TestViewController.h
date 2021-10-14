//
//  TestViewController.h
//  TUIKitDemo
//
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *ignoreMsgUnreadSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isExcludedFromLastMessageSwitch;

@end

NS_ASSUME_NONNULL_END
