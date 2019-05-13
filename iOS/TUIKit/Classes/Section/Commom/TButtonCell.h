//
//  TButtonCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TButtonCell;
@protocol TButtonCellDelegate <NSObject>
- (void)didTouchUpInsideInButtonCell:(TButtonCell *)cell;
@end

@interface TButtonCellData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) SEL selector;
@end

@interface TButtonCell : UITableViewCell
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) id<TButtonCellDelegate> delegate;
+ (CGFloat)getHeight;
- (void)setData:(TButtonCellData *)data;
@end
