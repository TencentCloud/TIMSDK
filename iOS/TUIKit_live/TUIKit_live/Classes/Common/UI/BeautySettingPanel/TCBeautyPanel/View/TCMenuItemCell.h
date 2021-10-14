// Copyright (c) 2019 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

@interface  TCMenuItemCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

- (void)setSelected:(BOOL)selected;
+ (NSString *)reuseIdentifier;
@end
