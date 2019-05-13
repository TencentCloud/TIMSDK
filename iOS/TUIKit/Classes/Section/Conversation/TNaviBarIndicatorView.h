//
//  TNaviBarIndicatorView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/22.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNaviBarIndicatorView : UIView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)setTitle:(NSString *)title;
- (void)startAnimating;
- (void)stopAnimating;
@end
