//
//  TAddHeaderView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAddHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) UILabel *letterLabel;
+ (CGFloat)getHeight;
- (void)setLetter:(NSString *)leter;
@end
