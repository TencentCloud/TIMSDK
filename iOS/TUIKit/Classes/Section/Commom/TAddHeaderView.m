//
//  TAddHeaderView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddHeaderView.h"
#import "THeader.h"

@implementation TAddHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _letterLabel = [[UILabel alloc] init];
    _letterLabel.font = [UIFont systemFontOfSize:14];
    _letterLabel.textColor = [UIColor grayColor];
    [self addSubview:_letterLabel];
}

- (void)setLetter:(NSString *)letter
{
    _letterLabel.text = letter;
    CGSize size = [_letterLabel sizeThatFits:CGSizeMake(Screen_Width, TAddHeaderView_Height)];
    _letterLabel.frame = CGRectMake(TAddHeaderView_Margin, (TAddHeaderView_Height - size.height) * 0.5, size.width, size.height);
}

+ (CGFloat)getHeight
{
    return TAddHeaderView_Height;
}
@end
