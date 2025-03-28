// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaEffectCell : UICollectionViewCell
@property(nonatomic) UIImage *image;
@property(nonatomic) NSString *text;
@property(nonatomic) BOOL effectSelected;
@property(nonatomic) CGSize iconSize;
- (instancetype)initWithFrame:(CGRect)frame;

+ (NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
