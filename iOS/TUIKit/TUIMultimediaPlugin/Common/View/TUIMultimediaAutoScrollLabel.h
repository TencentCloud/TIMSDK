// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaAutoScrollLabel : UIView
@property(nonatomic) CGFloat scrollSpeed;
@property(nonatomic) NSTimeInterval pauseInterval;
@property(nonatomic) NSAttributedString *text;
@property(nonatomic) CGFloat fadeInOutRate;
@property(nonatomic) BOOL active;
@end

NS_ASSUME_NONNULL_END
