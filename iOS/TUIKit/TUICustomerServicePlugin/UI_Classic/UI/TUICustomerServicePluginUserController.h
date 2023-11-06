//
//  TUICustomerServicePluginUserController.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class V2TIMUserInfo;

@interface TUICustomerServicePluginUserController : UITableViewController

- (instancetype)initWithUserInfo:(V2TIMUserInfo *)userInfo;

@end

NS_ASSUME_NONNULL_END
