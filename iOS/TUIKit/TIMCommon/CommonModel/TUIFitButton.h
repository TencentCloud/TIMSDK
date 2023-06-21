//
//  TUIFitButton.h
//  TUICore
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIFitButton : UIButton
@property(nonatomic, assign) CGRect titleRect;
@property(nonatomic, assign) CGRect imageRect;

@property(nonatomic, assign) CGSize imageSize;
@property(nonatomic, assign) CGSize titleSize;

@property(nonatomic, strong) UIImage* hoverImage;
@property(nonatomic, strong) UIImage* normalImage;

@end

@interface TUIBlockButton : TUIFitButton
@property(nonatomic, copy) void (^clickCallBack)(id button);
@end

NS_ASSUME_NONNULL_END
