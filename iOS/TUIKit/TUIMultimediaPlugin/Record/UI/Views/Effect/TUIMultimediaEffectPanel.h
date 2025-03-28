// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#import "TUIMultimediaEffectCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaEffectItem.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaEffectPanelDelegate;

/**
 美颜和滤镜设置界面
 */
@interface TUIMultimediaEffectPanel : UIView
@property(nonatomic) NSArray<TUIMultimediaEffectItem *> *items;
@property(nonatomic) NSInteger selectedIndex;
@property(nonatomic) CGSize iconSize;
@property(weak, nullable, nonatomic) id<TUIMultimediaEffectPanelDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;
@end

@protocol TUIMultimediaEffectPanelDelegate <NSObject>
- (void)effectPanelSelectionChanged:(TUIMultimediaEffectPanel *)panel;
@end

NS_ASSUME_NONNULL_END
