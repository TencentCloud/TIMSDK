//
//  TAddCollectionCell.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAddCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *headImageView;
- (void)setImage:(NSString *)image;
+ (CGSize)getSize;
@end
