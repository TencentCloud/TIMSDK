//
//  TSwitchCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSwitchCellData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) SEL selector;
@end

@interface TSwitchCell : UITableViewCell
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UISwitch *sw;
+ (CGFloat)getHeight;
- (void)setData:(TSwitchCellData *)data;
@end
