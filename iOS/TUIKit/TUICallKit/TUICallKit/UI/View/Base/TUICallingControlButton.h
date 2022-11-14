//
//  TUICallingControlButton.h
//  TUICalling
//
//  Created by noah on 2021/9/14.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUICallingButtonActionBlock) (UIButton *sender);

@interface TUICallingControlButton : UIView

+ (instancetype)createWithFrame:(CGRect)frame
                      titleText:(NSString *)titleText
                   buttonAction:(TUICallingButtonActionBlock)buttonAction
                      imageSize:(CGSize)imageSize;

- (void)updateImage:(UIImage *)image;

- (void)updateTitleColor:(UIColor *)titleColor;

@end

NS_ASSUME_NONNULL_END
