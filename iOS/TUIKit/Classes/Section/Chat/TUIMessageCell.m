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
#import "NSBundle+TUIKIT.h"
#import "NSDate+TUIKIT.h"

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
        [self.contentView addSubview:_avatarView];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
        [_avatarView addGestureRecognizer:tap1];
        [_avatarView setUserInteractionEnabled:YES];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_nameLabel];

        //container
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessage:)];
        [_container addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [_container addGestureRecognizer:longPress];
        [self.contentView addSubview:_container];
        
        //indicator
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.contentView addSubview:_indicator];
        
        //error
        _retryView = [[UIImageView alloc] init];
        _retryView.userInteractionEnabled = YES;
        UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetryMessage:)];
        [_retryView addGestureRecognizer:resendTap];
        [self.contentView addSubview:_retryView];
        
        //已读label,由于 indicator 和 error，所以默认隐藏，消息发送成功后进行显示
        _readReceiptLabel = [[UILabel alloc] init];
        _readReceiptLabel.hidden = YES;
        _readReceiptLabel.font = [UIFont systemFontOfSize:12];
        _readReceiptLabel.textColor = [UIColor d_systemGrayColor];
        _readReceiptLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:_readReceiptLabel];
        
        // selectedIcon
        _selectedIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_selectedIcon];
        
        // selectedView
        _selectedView = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedView.backgroundColor = [UIColor clearColor];
        [_selectedView addTarget:self action:@selector(onSelectMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectedView];
        
        // timeLabel
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor darkGrayColor];
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        [self.contentView addSubview:_timeLabel];
        
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
    self.readReceiptLabel.text = self.messageData.innerMessage.isPeerRead ? TUILocalizableString(Read): TUILocalizableString(Unread);
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
    
    NSString *imageName = (data.showCheckBox && data.selected) ? TUIKitResource(@"icon_contact_select_selected") : TUIKitResource(@"icon_contact_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];
    
    _timeLabel.text = [data.innerMessage.timestamp tk_messageString];
    
    // 高亮文本 - 此处异步是为了让其执行顺序与子类一致
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf highlightWhenMatchKeyword:data.highlightKeyword];
    });
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    // 默认高亮效果，背景颜色加深
    self.contentView.backgroundColor = keyword.length ? [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1] : nil;
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
    
    _selectedView.mm_x = 0;
    _selectedView.mm_y = 0;
    _selectedView.mm_w = self.contentView.mm_w;
    _selectedView.mm_h = self.contentView.mm_h;
    if (self.messageData.showCheckBox) {
        _selectedIcon.mm_width(20).mm_height(20);
        _selectedIcon.mm_x = 10;
        _selectedIcon.mm_centerY = _avatarView.mm_centerY;
        _selectedIcon.hidden = NO;
        _selectedView.hidden = NO;
    } else {
        _selectedIcon.mm_width(0).mm_height(0);
        _selectedIcon.mm_x = 0;
        _selectedIcon.mm_y = 0;
        _selectedIcon.hidden = YES;
        _selectedView.hidden = YES;
    }
    
    if (self.messageData.showMessageTime) {
        _timeLabel.mm_sizeToFit();
        _timeLabel.mm_y = self.avatarView.mm_y;
        _timeLabel.mm_x = self.contentView.bounds.size.width - 10 - _timeLabel.mm_w;
        _timeLabel.hidden = NO;
    } else {
        _timeLabel.mm_y = 0;
        _timeLabel.mm_r = 0;
        _timeLabel.mm_sizeToFit();
        _timeLabel.hidden = YES;
    }
    
    TUIMessageCellLayout *cellLayout = self.messageData.cellLayout;
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.avatarView.mm_x = _selectedIcon.mm_maxX + cellLayout.avatarInsets.left;
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
        .mm_right(cellLayout.messageInsets.right+self.contentView.mm_w-self.avatarView.mm_x).mm_top(ctop);
        
        self.nameLabel.mm_right(_container.mm_r);
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_x - 8 - _indicator.mm_w);
        self.retryView.frame = self.indicator.frame;
        //这里不能像 retryView 一样直接使用 indicator 的设定，否则内容会显示不全。
        self.readReceiptLabel.mm_sizeToFit().mm_bottom(self.container.mm_b + cellLayout.bubbleInsets.bottom).mm_left(_container.mm_x - 8 - _readReceiptLabel.mm_w);
        
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
    _readReceiptLabel.text = TUILocalizableString(Unread); // @"未读";//一但消息复用，说明即将新消息出现，label内容改为未读。
}
@end
