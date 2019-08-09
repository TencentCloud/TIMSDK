//
//  TUnReadView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUnReadView : UIView
@property (nonatomic, strong) UILabel *unReadLabel;
- (void)setNum:(NSInteger)num;
@end
