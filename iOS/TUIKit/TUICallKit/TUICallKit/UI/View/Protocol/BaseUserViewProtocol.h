//
//  BaseUserViewProtocol.h
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "UIColor+TUICallingHex.h"
#import "CallingLocalized.h"
#import "TUICallingCommon.h"

@class CallingUserModel;

NS_ASSUME_NONNULL_BEGIN

@protocol BaseUserViewProtocol <NSObject>

@optional

- (void)updateUserInfo:(CallingUserModel *)userModel hint:(NSString *)hint;

- (void)updateTextColor:(UIColor *)textColor;

@end

NS_ASSUME_NONNULL_END
