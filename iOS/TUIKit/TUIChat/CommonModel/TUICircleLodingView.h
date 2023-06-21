//
//  TUICircleLodingView.h
//  TUIChat
//
//  Created by wyl on 2023/4/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface TUICircleLodingView : UIView
@property(nonatomic, strong) UILabel *labProgress;
@property(nonatomic, strong) CAShapeLayer *progressLayer;
@property(nonatomic, strong) CAShapeLayer *grayProgressLayer;
// 【0,1.0】
@property(nonatomic, assign) double progress;

@end

NS_ASSUME_NONNULL_END
