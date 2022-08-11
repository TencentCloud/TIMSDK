//
//  UIButton+TUICalling.h
//  TUICalling
//
//  Created by noah on 2022/5/31.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUIButtonEdgeInsetsStyle) {
    TUIButtonEdgeInsetsStyleTop,
    TUIButtonEdgeInsetsStyleLeft,
    TUIButtonEdgeInsetsStyleBottom,
    TUIButtonEdgeInsetsStyleRight
};

@interface UIButton (TUICalling)

- (void)layoutButtonWithEdgeInsetsStyle:(TUIButtonEdgeInsetsStyle)style imageTitleSpace:(CGFloat)space NS_SWIFT_NAME(layoutButtonWithEdgeInsetsStyle(style:space:));;

@end

NS_ASSUME_NONNULL_END
