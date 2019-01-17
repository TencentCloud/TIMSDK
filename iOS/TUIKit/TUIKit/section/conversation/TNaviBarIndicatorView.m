//
//  TNaviBarIndicatorView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/22.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TNaviBarIndicatorView.h"
#import "THeader.h"

@implementation TNaviBarIndicatorView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(0, NavBar_Height * 0.5);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];
    
    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:17];
    _label.textColor = [UIColor blackColor];
    [self addSubview:_label];
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self updateLayout];
}

- (void)updateLayout
{
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(Screen_Width, NavBar_Height)];
    CGFloat labelY = 0;
    CGFloat labelX = _indicator.hidden ? 0 : (_indicator.frame.origin.x + _indicator.frame.size.width + TNaviBarIndicatorView_Margin);
    _label.frame = CGRectMake(labelX, labelY, labelSize.width, NavBar_Height);
    self.frame = CGRectMake(0, 0, labelX + labelSize.width + TNaviBarIndicatorView_Margin, NavBar_Height);
    self.center = CGPointMake(Screen_Width * 0.5, NavBar_Height * 0.5);
}

- (void)startAnimating
{
    [_indicator startAnimating];
    [self updateLayout];
}

- (void)stopAnimating
{
    [_indicator stopAnimating];
    [self updateLayout];
}
@end
