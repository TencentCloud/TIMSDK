//
//  TKeyValueCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TKeyValueCellData : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) SEL selector;
@end

@interface TKeyValueCell : UITableViewCell
@property (nonatomic, strong) UILabel *key;
@property (nonatomic, strong) UILabel *value;
@property (nonatomic, strong) UIImageView *indicator;
- (void)setData:(TKeyValueCellData *)data;
+ (CGFloat)getHeight;
@end
