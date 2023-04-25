//
//  TUICallRecordCallsViewController.h
//  TUICallKit
//
//  Created by noah on 2023/2/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallRecordCallsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICallRecordCallsViewController : UIViewController

@property (nonatomic, strong, readonly, nonnull) TUICallRecordCallsViewModel *recordCallsViewModel;

- (instancetype)initWithRecordCallsUIStyle:(TUICallKitRecordCallsUIStyle)recordCallsUIStyle;

@end

NS_ASSUME_NONNULL_END
