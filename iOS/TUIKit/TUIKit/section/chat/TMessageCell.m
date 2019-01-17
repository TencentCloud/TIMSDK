//
//  TMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TMessageCell.h"
#import "THeader.h"

@implementation TMessageCellData : NSObject
- (id)init
{
    self = [super init];
    if(self){
        _status = Msg_Status_Sending;
    }
    return self;
}
@end

@implementation TMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}


- (void)setupViews{
    self.backgroundColor = [UIColor clearColor];
    //head
    _head = [[UIImageView alloc] init];
    _head.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_head];
    //name
    _name = [[UILabel alloc] init];
    _name.font = [UIFont systemFontOfSize:13];
    _name.textColor = [UIColor grayColor];
    [self addSubview:_name];
    //container
    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [_container addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [_container addGestureRecognizer:longPress];
    [self addSubview:_container];
    //indicator
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:_indicator];
    //error
    _error = [[UIImageView alloc] init];
    _error.userInteractionEnabled = YES;
    UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReSend:)];
    [_error addGestureRecognizer:resendTap];
    
    [self addSubview:_error];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setData:(TMessageCellData *)data
{
    //set data
    _data = data;
    _head.image = [UIImage imageNamed:data.head];
    _name.text = data.name;
    if(data.status == Msg_Status_Fail){
        [_indicator stopAnimating];
        _error.image = [UIImage imageNamed:TUIKitResource(@"msg_error")];
    }
    else{
        if(data.status == Msg_Status_Sending_2){
            [_indicator startAnimating];
        }
        else if(data.status == Msg_Status_Succ){
            [_indicator stopAnimating];
        }
        else if(data.status == Msg_Status_Sending){
            
        }
        _error.image = nil;
    }
    //update layout
    if(!data.isSelf){
        CGSize headSize = TMessageCell_Head_Size;
        _head.frame = CGRectMake(TMessageCell_Margin, TMessageCell_Margin, headSize.width, headSize.height);
        if(data.showName){
            CGFloat namex = _head.frame.origin.x + _head.frame.size.width + TMessageCell_Margin;
            CGSize nameSize = [_name sizeThatFits:CGSizeMake(Screen_Width, MAXFLOAT)];
            _name.frame = CGRectMake(namex, TMessageCell_Margin, nameSize.width, nameSize.height);
        }
        else{
            _name.frame = CGRectZero;
        }
        CGSize containerSize = [self getContainerSize:data];
        CGFloat containerx = _head.frame.origin.x + _head.frame.size.width + TMessageCell_Margin;
        CGFloat containery = _name.frame.origin.y + _name.frame.size.height + TMessageCell_Margin;
        _container.frame = CGRectMake(containerx, containery, containerSize.width, containerSize.height);
        CGSize indicatorSize = TMessageCell_Indicator_Size;
        CGFloat indicatorx = _container.frame.origin.x + _container.frame.size.width + TMessageCell_Margin;
        CGFloat indicatory = _container.frame.origin.y + (_container.frame.size.height - indicatorSize.width) * 0.5;
        _indicator.frame = CGRectMake(indicatorx, indicatory, indicatorSize.width, indicatorSize.height);
        _error.frame = _indicator.frame;
    }
    else{
        CGSize headSize = TMessageCell_Head_Size;
        CGFloat headx = Screen_Width - TMessageCell_Margin - headSize.width;
        _head.frame = CGRectMake(headx, TMessageCell_Margin, headSize.width, headSize.height);
        if(data.showName){
            CGSize nameSize = [_name sizeThatFits:CGSizeMake(Screen_Width, MAXFLOAT)];
            CGFloat namex = _head.frame.origin.x - TMessageCell_Margin - nameSize.width;
            _name.frame = CGRectMake(namex, TMessageCell_Margin, nameSize.width, nameSize.height);
        }
        else{
            _name.frame = CGRectZero;
        }
        CGSize containerSize = [self getContainerSize:data];
        CGFloat containerx = _head.frame.origin.x - TMessageCell_Margin - containerSize.width;
        CGFloat containery = _name.frame.origin.y + _name.frame.size.height + TMessageCell_Margin;
        _container.frame = CGRectMake(containerx, containery, containerSize.width, containerSize.height);
        CGSize indicatorSize = TMessageCell_Indicator_Size;
        CGFloat indicatorx = _container.frame.origin.x - TMessageCell_Margin - indicatorSize.width;
        CGFloat indicatory = _container.frame.origin.y + (_container.frame.size.height - indicatorSize.width) * 0.5;
        _indicator.frame = CGRectMake(indicatorx, indicatory, indicatorSize.width, indicatorSize.height);
        _error.frame = _indicator.frame;
    }
}

- (CGFloat)getHeight:(TMessageCellData *)data
{
    CGSize containerSize = [self getContainerSize:data];
    CGFloat height = containerSize.height + TMessageCell_Margin * 2;
    if(data.showName){
        _name.text = data.name;
        CGSize nameSize = [_name sizeThatFits:CGSizeMake(Screen_Width, MAXFLOAT)];
        height += nameSize.height + TMessageCell_Margin;
    }
    CGFloat minHeight = TMessageCell_Head_Size.height + 2 * TMessageCell_Margin;
    if(height < minHeight){
        height = minHeight;
    }
    return height;
}

- (CGSize)getContainerSize:(TMessageCellData *)data
{
    return CGSizeZero;
}

- (void)onLongPress:(UIGestureRecognizer *)recognizer
{
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
       recognizer.state == UIGestureRecognizerStateBegan){
        if(_delegate && [_delegate respondsToSelector:@selector(didLongPressMessage:inView:)]){
            [_delegate didLongPressMessage:_data inView:_container];
        }
    }
}

- (void)onReSend:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(didReSendMessage:)]){
        [_delegate didReSendMessage:_data];
    }
}


- (void)onTap:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectMessage:)]){
        [_delegate didSelectMessage:_data];
    }
}
@end
