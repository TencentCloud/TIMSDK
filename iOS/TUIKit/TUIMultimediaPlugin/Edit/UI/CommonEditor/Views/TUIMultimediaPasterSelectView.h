// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaPasterSelectViewDelegate;

@interface TUIMultimediaPasterSelectView : UIView
@property(nonatomic) TUIMultimediaPasterConfig *config;
@property(weak, nullable, nonatomic) id<TUIMultimediaPasterSelectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
@end

@protocol TUIMultimediaPasterSelectViewDelegate <NSObject>
- (void)onPasterSelected:(UIImage *)image;
- (void)pasterSelectView:(TUIMultimediaPasterSelectView *)v needAddCustomPaster:(TUIMultimediaPasterGroupConfig *)group completeCallback:(void (^)(void))callback;
- (void)pasterSelectView:(TUIMultimediaPasterSelectView *)v
    needDeleteCustomPasterInGroup:(TUIMultimediaPasterGroupConfig *)group
                            index:(NSInteger)index
                 completeCallback:(void (^)(BOOL deleted))callback;
@end

NS_ASSUME_NONNULL_END
