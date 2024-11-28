// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaColorCell : UICollectionViewCell
@property(nullable, nonatomic) UIColor *color;
@property(nonatomic) BOOL colorSelected;

- (instancetype)initWithFrame:(CGRect)frame;

+ (NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
