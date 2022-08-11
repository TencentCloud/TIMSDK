//
//  TUICallingCalleeView.h
//  TUICalling
//
//  Created by noah on 2022/5/25.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingCalleeView : UIView

- (void)updateViewWithUserList:(NSArray<CallingUserModel *> *)userList;

- (void)userLeave:(CallingUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
