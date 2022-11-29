//
//  TAddCell.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIAddCellData.h"

@interface TUIAddCell : UITableViewCell
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
+ (CGFloat)getHeight;
- (void)setData:(TUIAddCellData *)data;
@end
