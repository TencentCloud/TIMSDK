//
//  TUIGroupMemberCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberCell.h"
#import "THeader.h"
#import "TUIKit.h"

@implementation TGroupMemberCellData
@end

@implementation TUIGroupMemberCell

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
    CGSize headSize = [[self class] getSize];
    _head.frame = CGRectMake(0, 0, headSize.width, headSize.width);
    _name.frame = CGRectMake(0, _head.frame.origin.y + _head.frame.size.height + TGroupMemberCell_Margin, _head.frame.size.width, TGroupMemberCell_Name_Height);
}

- (void)setData:(TGroupMemberCellData *)data
{
    if (data.avatar == nil) {
        _head.image = [UIImage tk_imageNamed:@"default_head"];
    } else {
        _head.image = data.avatar;
        
    }
    if (data.name.length)
        [_name setText:data.name];
    else
        [_name setText:data.identifier];
    
    [self defaultLayout];
}

+ (CGSize)getSize {
    CGSize headSize = TGroupMemberCell_Head_Size;
    if (headSize.width * TGroupMembersCell_Column_Count + TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1) > Screen_Width) {
        CGFloat wd = (Screen_Width - (TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1))) / TGroupMembersCell_Column_Count;
        headSize = CGSizeMake(wd, wd);
    }
    return CGSizeMake(headSize.width, headSize.height + TGroupMemberCell_Name_Height + TGroupMemberCell_Margin);
}
@end
