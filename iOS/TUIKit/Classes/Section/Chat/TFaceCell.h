//
//  TFaceCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/29.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFaceCellData : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@end

@interface TFaceCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *face;
- (void)setData:(TFaceCellData *)data;
@end
