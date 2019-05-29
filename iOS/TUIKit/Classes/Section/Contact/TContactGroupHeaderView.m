//
//  TContactGroupHeaderView.m
//  TUIKit
//
//  Created by annidyfeng on 2019/4/22.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TContactGroupHeaderView.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TContactGroupHeaderData

- (instancetype)init
{
    self = [super init];
    
    _isFold = YES;
    
    return self;
}

@end


@implementation TContactGroupHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self addOwnViews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDrawer:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addOwnViews
{
    _icon = [[UIImageView alloc] init];
    _icon.userInteractionEnabled = YES;
    _icon.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_icon];
    
    _name = [[UILabel alloc] init];
    _name.userInteractionEnabled = YES;
    _name.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_name];
    
    _count = [[UILabel alloc] init];
    _count.userInteractionEnabled = YES;
    _count.textAlignment = NSTextAlignmentRight;
    _count.font = [UIFont systemFontOfSize:14];
    _count.textColor = [UIColor grayColor];
    [self.contentView addSubview:_count];
    
    _line = [[UIView alloc] init];
    _line.backgroundColor = RGB(225, 225, 225);
    [self.contentView addSubview:_line];
}

- (void)onTapDrawer:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        self.data.isFold = !self.data.isFold;
        [self setNeedsLayout];
    }
}

- (void)setData:(TContactGroupHeaderData *)data
{
    _data = data;
    
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _icon.image = [UIImage imageNamed:self.data.isFold ? TUIKitResource(@"subgroup_fold") : TUIKitResource(@"subgroup_unfold")];
    _name.text = self.data.groupName ?: @"我的好友";
    _count.text = [NSString stringWithFormat:@"%d人", (int)self.data.userCnt];
    
    if (_icon)
        _icon.mm_width(20).mm_height(20).mm__centerY(self.mm_h/2).mm_left(20);
    if (_name)
        _name.mm_sizeToFit().mm_hstack(20);
    if (_count)
        _count.mm_sizeToFit().mm_hstack(0).mm_right(15);
    if (_line)
        _line.mm_width(self.mm_w).mm_height(1).mm_bottom(0);
}
@end
