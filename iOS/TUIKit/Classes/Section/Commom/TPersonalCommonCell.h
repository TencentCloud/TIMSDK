//
//  TGroupCommonCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPersonalCommonCellData : NSObject
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, assign) SEL selector;
@end

@interface TPersonalCommonCell : UITableViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *indicator;
- (void)setData:(TPersonalCommonCellData *)data;
+ (CGFloat)getHeight;
@end
