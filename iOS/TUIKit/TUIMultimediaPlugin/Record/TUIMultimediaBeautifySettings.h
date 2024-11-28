// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <Foundation/Foundation.h>
#import "TUIMultimediaEffectItem.h"

@class TXBeautyManager;

NS_ASSUME_NONNULL_BEGIN

static const float TUIMultimediaBeautifyStrengthMin = 0;
static const float TUIMultimediaBeautifyStrengthMax = 9;
static const float TUIMultimediaFilterStrengthMin = 0;
static const float TUIMultimediaFilterStrengthMax = 1;

static const int TUIMultimediaEffectSliderMin = 0;
static const int TUIMultimediaEffectSliderMax = 9;

/**
 美颜设置
 美颜+滤镜
 */
@interface TUIMultimediaBeautifySettings : NSObject
@property(nonatomic) NSArray<TUIMultimediaEffectItem *> *beautifyItems;
@property(nonatomic) NSArray<TUIMultimediaEffectItem *> *filterItems;
@property(nonatomic) NSInteger activeBeautifyTag;  // 美颜：光滑、自然、P图 三者互斥
@property(nonatomic) NSInteger activeFilterIndex;

- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
