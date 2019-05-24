//
//  TGroupMemberCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TGroupMemberCell.h"
#import "THeader.h"

@implementation TGroupMemberCellData
@end

@implementation TGroupMemberCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    _head = [[UIImageView alloc] init];
    _head.layer.cornerRadius = 5;
    [_head.layer setMasksToBounds:YES];
    [self addSubview:_head];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:13]];
    [_name setTextColor:[UIColor grayColor]];
    _name.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_name];
}

- (void)defaultLayout
{
    CGSize headSize = TGroupMemberCell_Head_Size;
    _head.frame = CGRectMake(0, 0, headSize.width, headSize.height);
    _name.frame = CGRectMake(0, _head.frame.origin.y + _head.frame.size.height + TGroupMemberCell_Margin, _head.frame.size.width, TGroupMemberCell_Name_Height);
}

- (void)setData:(TGroupMemberCellData *)data
{
    _head.image = [UIImage imageNamed:data.head];
    [_name setText:data.name];
    [self defaultLayout];
}

+ (CGSize)getSize{
    CGSize headSize = TGroupMemberCell_Head_Size;
    return CGSizeMake(headSize.width, headSize.height + TGroupMemberCell_Name_Height + TGroupMemberCell_Margin);
}
@end
