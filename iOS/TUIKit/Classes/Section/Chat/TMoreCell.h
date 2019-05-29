//
//  TMoreCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMoreCellData : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *title;
@end

@interface TMoreCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *title;
+ (CGSize)getSize;
- (void)setData:(TMoreCellData *)data;
@end
