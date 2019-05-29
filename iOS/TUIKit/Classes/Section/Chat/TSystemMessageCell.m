//
//  TSystemMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TSystemMessageCell.h"
#import "THeader.h"

@implementation TSystemMessageCellData
@end

@interface TSystemMessageCell ()
@end

@implementation TSystemMessageCell

- (CGFloat)getHeight:(TSystemMessageCellData *)data;
{
    _content.text = data.content;
    CGSize size = [_content sizeThatFits:CGSizeMake(TSystemMessageCell_Text_Width_Max, MAXFLOAT)];
    size.height += 2 * TSystemMessageCell_Margin + 2 * TMessageCell_Margin;
    return size.height;
}


- (void)setData:(TSystemMessageCellData *)data;
{
    //set data
    _content.text = data.content;
    //update layout
    CGSize textSize = [_content sizeThatFits:CGSizeMake(TSystemMessageCell_Text_Width_Max, MAXFLOAT)];
    CGFloat width = textSize.width + 2 * TSystemMessageCell_Margin;
    CGFloat height = textSize.height + 2 * TSystemMessageCell_Margin;
    _content.frame = CGRectMake((Screen_Width - width) * 0.5, TMessageCell_Padding, width, height);
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];
    
    _content = [[UILabel alloc] init];
    _content.font = [UIFont systemFontOfSize:12];
    _content.textColor = [UIColor whiteColor];
    _content.textAlignment = NSTextAlignmentCenter;
    _content.numberOfLines = 0;
    _content.backgroundColor = TSystemMessageCell_Background_Color;
    _content.layer.cornerRadius = 3;
    [_content.layer setMasksToBounds:YES];
    [self addSubview:_content];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
