//
//  TUIMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMessageCell.h"
#import "THeader.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"

@interface TUIMessageCell()
@property (nonatomic, strong) TUIMessageCellData *messageData;
//已读回执 label

@end

@implementation TUIMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        //head
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_avatarView];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
        [_avatarView addGestureRecognizer:tap1];
        [_avatarView setUserInteractionEnabled:YES];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_nameLabel];

        //container
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessage:)];
        [_container addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [_container addGestureRecognizer:longPress];
        [self addSubview:_container];
        
        //indicator
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:_indicator];
        
        //error
        _retryView = [[UIImageView alloc] init];
        _retryView.userInteractionEnabled = YES;
        UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetryMessage:)];
        [_retryView addGestureRecognizer:resendTap];
        [self addSubview:_retryView];
        
        //已读label,由于 indicator 和 error，所以默认隐藏，消息发送成功后进行显示
        _readReceiptLabel = [[UILabel alloc] init];
        _readReceiptLabel.hidden = YES;
        _readReceiptLabel.font = [UIFont systemFontOfSize:12];
        _readReceiptLabel.textColor = [UIColor d_systemGrayColor];
        _readReceiptLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_readReceiptLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(TUIMessageCellData *)data
{
    [super fillWithData:data];
    self.messageData = data;

    [self.avatarView setImage:data.avatarImage];
    @weakify(self)
    [[[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] ignore:nil] subscribeNext:^(NSURL *url) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:url placeholderImage:self.messageData.avatarImage];
    }];


    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = data.cellLayout.avatarSize.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
    
    //set data
    self.nameLabel.text = data.name;
    self.nameLabel.textColor = data.nameColor;
    self.nameLabel.font = data.nameFont;
    
    //由于tableView的刷新策略，导致部分情况下可能会出现未读label未显示的bug。原因是因为在label显示时，内容为空。
    //label内容的变化不会引起tableView的刷新，但是hiddend状态的变化会引起tableView刷新。
    //所以未读标签选择直接赋值，而不是在发送成功时赋值。显示时机由hidden属性控制。
    self.readReceiptLabel.text = self.messageData.innerMessage.isPeerRead ? @"已读":@"未读";
    if(data.status == Msg_Status_Fail){
        [_indicator stopAnimating];
        self.retryView.image = [UIImage imageNamed:TUIKitResource(@"msg_error")];
        _readReceiptLabel.hidden = YES;
    } else {
        if (data.status == Msg_Status_Sending_2) {
            [_indicator startAnimating];
            _readReceiptLabel.hidden = YES;
        }
        else if(data.status == Msg_Status_Succ){
            [_indicator stopAnimating];
            //发送成功，说明 indicator 和 error 已不会显示在 label 中,可以开始显示已读回执label
            if(self.messageData.direction == MsgDirectionOutgoing
               && self.messageData.showReadReceipt
               && self.messageData.innerMessage.userID.length > 0){//只对发送的消息进行label显示。
                _readReceiptLabel.hidden = NO;
            }
            
        }
        else if(data.status == Msg_Status_Sending){
            [_indicator stopAnimating];
            _readReceiptLabel.hidden = YES;
        }
        self.retryView.image = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.messageData.showName) {
        _nameLabel.mm_sizeToFitThan(1, 20);
        _nameLabel.hidden = NO;
    } else {
        _nameLabel.hidden = YES;
        _nameLabel.mm_height(0);
    }
    
    TUIMessageCellLayout *cellLayout = self.messageData.cellLayout;
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.avatarView.mm_x = cellLayout.avatarInsets.left;
        self.avatarView.mm_y = cellLayout.avatarInsets.top;
        self.avatarView.mm_w = cellLayout.avatarSize.width;
        self.avatarView.mm_h = cellLayout.avatarSize.height;
        
        self.nameLabel.mm_top(self.avatarView.mm_y);
        
        CGSize csize = [self.messageData contentSize];
        CGFloat ctop = cellLayout.messageInsets.top + _nameLabel.mm_h;
        self.container.mm_left(cellLayout.messageInsets.left+self.avatarView.mm_maxX)
        .mm_top(ctop).mm_width(csize.width).mm_height(csize.height);
        
        self.nameLabel.mm_left(_container.mm_x + 7) ;//与气泡对齐
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_maxX + 8);
        self.retryView.frame = self.indicator.frame;
        self.readReceiptLabel.hidden = YES;
        
    } else {
        
        self.avatarView.mm_w = cellLayout.avatarSize.width;
        self.avatarView.mm_h = cellLayout.avatarSize.height;
        self.avatarView.mm_top(cellLayout.avatarInsets.top).mm_right(cellLayout.avatarInsets.right);
        
        self.nameLabel.mm_top(self.avatarView.mm_y);
        
        CGSize csize = [self.messageData contentSize];
        CGFloat ctop = cellLayout.messageInsets.top + _nameLabel.mm_h;
        self.container.mm_width(csize.width).mm_height(csize.height)
        .mm_right(cellLayout.messageInsets.right+self.mm_w-self.avatarView.mm_x).mm_top(ctop);
        
        self.nameLabel.mm_right(_container.mm_r);
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_x - 8 - _indicator.mm_w);
        self.retryView.frame = self.indicator.frame;
        //这里不能像 retryView 一样直接使用 indicator 的设定，否则内容会显示不全。
        self.readReceiptLabel.mm_sizeToFitThan(0,self.indicator.mm_w).mm_bottom(self.container.mm_b + cellLayout.bubbleInsets.bottom).mm_left(_container.mm_x - 8 - _indicator.mm_w);
        
    }
}


- (void)onLongPress:(UIGestureRecognizer *)recognizer
{
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
       recognizer.state == UIGestureRecognizerStateBegan){
        if(_delegate && [_delegate respondsToSelector:@selector(onLongPressMessage:)]){
            [_delegate onLongPressMessage:self];
        }
    }
}

- (void)onRetryMessage:(UIGestureRecognizer *)recognizer
{
    if (_messageData.status == Msg_Status_Fail)
        if (_delegate && [_delegate respondsToSelector:@selector(onRetryMessage:)]) {
            [_delegate onRetryMessage:self];
        }
}


- (void)onSelectMessage:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onSelectMessage:)]){
        [_delegate onSelectMessage:self];
    }
}

- (void)onSelectMessageAvatar:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onSelectMessageAvatar:)]){
        [_delegate onSelectMessageAvatar:self];
    }
}

- (void)prepareForReuse{
    [super prepareForReuse];
    //今后任何关于复用产生的 UI 问题，都可以在此尝试编码解决。
    _readReceiptLabel.text = @"未读";//一但消息复用，说明即将新消息出现，label内容改为未读。
}
@end
