//
//  TMenuCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMenuCellData : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL isSelected;
@end

@interface TMenuCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *menu;
- (void)setData:(TMenuCellData *)data;
@end
