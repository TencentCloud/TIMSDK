//
//  TPopCell.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPopCellData : NSObject
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *title;
@end

@interface TPopCell : UITableViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *title;
+ (CGFloat)getHeight;
- (void)setData:(TPopCellData *)data;
@end
