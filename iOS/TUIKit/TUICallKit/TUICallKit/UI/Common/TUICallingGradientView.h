//
//  TUICallingGradientView.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIGradientViewDirection) {
    TUIGradientViewDirectionLeftToRight,
    TUIGradientViewDirectionRightToLeft,
    TUIGradientViewDirectionBottomToTop,
    TUIGradientViewDirectionTopToBottom,
    TUIGradientViewDirectionLeftBottomToRightTop,
    TUIGradientViewDirectionLeftTopToRightBottom,
    TUIGradientViewDirectionRightBottomToLeftTop,
    TUIGradientViewDirectionRightTopToLeftBottom,
};

@interface TUICallingGradientView : UIView

- (void)configWithColors:(NSArray <UIColor *> *_Nullable)colors direction:(TUIGradientViewDirection)direction;

- (void)configWithColors:(NSArray <UIColor *> *_Nullable)colors
               locations:(NSArray <NSNumber *> *_Nullable)locations
              startPoint:(CGPoint)startPoint
                endPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
