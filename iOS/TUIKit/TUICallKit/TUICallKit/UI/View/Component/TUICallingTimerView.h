//
//  TUICallingTimerView.h
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICallingTimerView : UIView

- (void)setTimerTextColor:(UIColor *)textColor;

- (void)updateTimerText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
