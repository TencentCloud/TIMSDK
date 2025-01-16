//
//  TUISettingAdminController.h
//  TUIGroup
//
//  Created by harvy on 2021/12/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISettingAdminController : UIViewController

@property(nonatomic, copy) NSString *groupID;

@property(nonatomic, copy) void (^settingAdminDissmissCallBack)(void);
@end

NS_ASSUME_NONNULL_END
