// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaImageCell : UICollectionViewCell
@property(nullable, nonatomic) UIImage *image;
- (instancetype)initWithFrame:(CGRect)frame;

+ (NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
