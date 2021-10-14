//
//  TUILiveLikeHeartCreator.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveLikeHeartCreator : NSObject
@property(nonatomic, assign) CGFloat createDuration;// 限制频率，默认0.1秒
- (void)createHeartOn:(UIView *)superView startRect:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
