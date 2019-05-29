//
//  TGroupCommonCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGroupCommonCellData : NSObject
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *notification;
@property (nonatomic, assign) SEL selector;
@end

@interface TGroupCommonCell : UITableViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *groupName;
@property (nonatomic, strong) UILabel *groupId;
@property (nonatomic, strong) UILabel *notification;
@property (nonatomic, strong) UIImageView *indicator;
- (void)setData:(TGroupCommonCellData *)data;
+ (CGFloat)getHeight;
@end
