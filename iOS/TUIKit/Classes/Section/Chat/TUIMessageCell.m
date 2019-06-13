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

@interface TUIMessageCell()
@property (nonatomic, strong) TUIMessageCellData *messageData;
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
        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
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
    
    if(data.status == Msg_Status_Fail){
        [_indicator stopAnimating];
        self.retryView.image = [UIImage imageNamed:TUIKitResource(@"msg_error")];
    } else {
        if (data.status == Msg_Status_Sending_2) {
            [_indicator startAnimating];
        }
        else if(data.status == Msg_Status_Succ){
            [_indicator stopAnimating];
        }
        else if(data.status == Msg_Status_Sending){
            
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
        
        self.nameLabel.mm_left(_container.mm_x) ;
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_maxX + 8);
        self.retryView.frame = self.indicator.frame;
        
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
    if(_delegate && [_delegate respondsToSelector:@selector(onRetryMessage:)]){
        [_delegate onRetryMessage:self];
    }
}


- (void)onSelectMessage:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onSelectMessage:)]){
        [_delegate onSelectMessage:self];
    }
}
@end
