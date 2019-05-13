//
//  TAddGroupOptionView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddGroupOptionView.h"
#import "THeader.h"

@implementation TAddGroupOptionData
@end

@implementation TAddGroupOptionViewData
@end

@implementation TAddGroupOptionView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:14];
    _title.textColor = [UIColor blackColor];
    [self addSubview:_title];
    
    _subTitle = [[UILabel alloc] init];
    _subTitle.font = [UIFont systemFontOfSize:14];
    _subTitle.textColor = [UIColor lightGrayColor];
    [self addSubview:_subTitle];
    
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - TAddGroupOptionView_Margin - 15, 0, 15, self.frame.size.height)];
    _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    _arrowImageView.image = [UIImage imageNamed:@"right_arrow"];
    [self addSubview:_arrowImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
}

- (void)updateLayout
{
    CGSize titleSize = [_title sizeThatFits:self.frame.size];
    _title.frame = CGRectMake(TAddGroupOptionView_Margin, 0, titleSize.width, self.frame.size.height);
    
    CGSize subTitleSize = [_subTitle sizeThatFits:self.frame.size];
    _subTitle.frame = CGRectMake(_arrowImageView.frame.origin.x - subTitleSize.width - TAddGroupOptionView_Margin, 0, subTitleSize.width, self.frame.size.height);
}

- (void)setData:(TAddGroupOptionViewData *)data
{
    _title.text = data.title;
    _subTitle.text = data.value.title;
    [self updateLayout];
}


- (void)onTap:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapInAddGroupOptionView:)]){
        [_delegate didTapInAddGroupOptionView:self];
    }
}
@end
