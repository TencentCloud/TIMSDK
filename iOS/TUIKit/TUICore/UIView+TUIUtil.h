//
//  UIView+TUIUtil.h
//  TUICore
//
//  Created by gg on 2021/10/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TUIUtil)
- (void)roundedRect:(UIRectCorner)corner withCornerRatio:(CGFloat)cornerRatio;
@end

NS_ASSUME_NONNULL_END
