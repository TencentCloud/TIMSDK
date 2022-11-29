//
//  TUIMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMessageCell.h"
#import "TUISystemMessageCellData.h"
#import "TUIDefine.h"
#import "TUITool.h"
#import "TUIThemeManager.h"
#import "NSString+emoji.h"
#import "TUITagsView.h"
@interface TUIMessageCell() <CAAnimationDelegate>
@property (nonatomic, strong) TUIMessageCellData *messageData;

@end

@implementation TUIMessageCell

#pragma mark - Life cycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
        [self setupRAC];
    }
    return self;
}

- (void)setupSubViews {
    //head
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatarView];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
    [_avatarView addGestureRecognizer:tap1];
    UILongPressGestureRecognizer *tap2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongSelectMessageAvatar:)];
    [_avatarView addGestureRecognizer:tap2];
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
    tap.cancelsTouchesInView = NO;
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
    
    //messageModifyRepliesLabel
    _messageModifyRepliesButton = [[TUIFitButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _messageModifyRepliesButton.imageSize = CGSizeMake(12, 12);
    [_messageModifyRepliesButton addTarget:self action:@selector(onJumpToRepliesDetailPage:) forControlEvents:UIControlEventTouchUpInside];

    [_messageModifyRepliesButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_messageModifyRepliesButton setTitleColor:TUIChatDynamicColor(@"chat_message_read_name_date_text_color", @"#999999")forState:UIControlStateNormal];
//    TUIChatDynamicColor(@"chat_drop_down_color", @"#147AFF")
    [self.contentView addSubview:_messageModifyRepliesButton];
    
    _readReceiptLabel = [[UILabel alloc] init];
    _readReceiptLabel.hidden = YES;
    _readReceiptLabel.font = [UIFont systemFontOfSize:12];
    _readReceiptLabel.textColor = [UIColor d_systemGrayColor];
    _readReceiptLabel.lineBreakMode = NSLineBreakByCharWrapping;
    UITapGestureRecognizer *showReadReceiptTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectReadReceipt:)];
    [_readReceiptLabel addGestureRecognizer:showReadReceiptTap];
    _readReceiptLabel.userInteractionEnabled = YES;
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
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.messageData.showName) {
        _nameLabel.mm_sizeToFitThan(1, 20);
        _nameLabel.hidden = NO;
    } else {
        _nameLabel.hidden = YES;
        _nameLabel.mm_height(0);
    }

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
    
    CGSize csize = [self.messageData contentSize];

    _selectedView.mm_x = 0;
    _selectedView.mm_y = 0;
    _selectedView.mm_w = self.contentView.mm_w;
    _selectedView.mm_h = self.contentView.mm_h;
    
    CGFloat contentWidth =  csize.width;
    CGFloat contentHeight = csize.height;

    if (!CGSizeEqualToSize(self.messageData.messageModifyReactsSize, CGSizeZero)) {
        /**
         * 在「表情回复消息」和文本内容中间取最大宽度
         * Taking the maximum width between the "emoji reply message" and the text content
         */
        contentWidth = MAX(self.messageData.messageModifyReactsSize.width, csize.width);
        /**
         * 限制最大宽度为 Screen_Width *0.25 * 3
         * Limit the maximum width to Screen_Width *0.25 * 3
         */
        contentWidth = MIN(contentWidth, Screen_Width *0.25 * 3);
        contentHeight = csize.height+ self.messageData.messageModifyReactsSize.height;
    }

    TUIMessageCellLayout *cellLayout = self.messageData.cellLayout;
    if (self.messageData.direction == MsgDirectionIncoming) {
        if (self.messageData.showAvatar) {
            self.avatarView.hidden = NO;
        } else {
            self.avatarView.hidden = YES;
        }
        self.avatarView.mm_x = _selectedIcon.mm_maxX + cellLayout.avatarInsets.left;
        self.avatarView.mm_y = cellLayout.avatarInsets.top;
        self.avatarView.mm_w = cellLayout.avatarSize.width;
        self.avatarView.mm_h = cellLayout.avatarSize.height;
        
        self.nameLabel.mm_top(self.avatarView.mm_y);
                
        CGFloat ctop = cellLayout.messageInsets.top + _nameLabel.mm_h;
    
        self.container.mm_left(cellLayout.messageInsets.left+self.avatarView.mm_maxX)
        .mm_top(ctop).mm_width(contentWidth).mm_height(contentHeight);
        
        self.nameLabel.mm_left(_container.mm_x + 7) ;
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_maxX + 8);
        self.retryView.frame = self.indicator.frame;
        self.readReceiptLabel.hidden = YES;
        
    } else {
        if (self.messageData.showAvatar) {
            cellLayout.avatarSize = CGSizeMake(40, 40);
        } else {
            cellLayout.avatarSize = CGSizeZero;
        }
        self.avatarView.mm_w = cellLayout.avatarSize.width;
        self.avatarView.mm_h = cellLayout.avatarSize.height;
        self.avatarView.mm_top(cellLayout.avatarInsets.top).mm_right(cellLayout.avatarInsets.right);
        
        self.nameLabel.mm_top(self.avatarView.mm_y);
        
        CGFloat ctop = cellLayout.messageInsets.top + _nameLabel.mm_h;

        self.container.mm_width(contentWidth).mm_height(contentHeight).
        mm_right(cellLayout.messageInsets.right+self.contentView.mm_w-self.avatarView.mm_x).mm_top(ctop);
        
        
        self.nameLabel.mm_right(_container.mm_r);
        self.indicator.mm_sizeToFit().mm__centerY(_container.mm_centerY).mm_left(_container.mm_x - 8 - _indicator.mm_w);
        self.retryView.frame = self.indicator.frame;
        
        self.readReceiptLabel.mm_sizeToFit().mm_bottom(self.container.mm_b).mm_left(_container.mm_x - 8 - _readReceiptLabel.mm_w);
        
    }
        
    self.messageModifyRepliesButton.mm_sizeToFit();
    self.messageModifyRepliesButton.frame = CGRectMake(_container.mm_x, CGRectGetMaxY(_container.frame) , self.messageModifyRepliesButton.frame.size.width +10, 30);
    
    if (self.tagView) {
        self.tagView.frame = CGRectMake(0, _container.frame.size.height - self.messageData.messageModifyReactsSize.height, contentWidth, self.messageData.messageModifyReactsSize.height);
    }
}

- (void)setupRAC {
    @weakify(self);
    [RACObserve(self, readReceiptLabel.text) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([self shouldHighlightReadReceiptLabel]) {
            self.readReceiptLabel.textColor = TUIChatDynamicColor(@"chat_message_read_status_text_color", @"#147AFF");
        } else {
            self.readReceiptLabel.textColor = TUIChatDynamicColor(@"chat_message_read_status_text_gray_color", @"#BBBBBB");
        }
    }];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    /**
     * 今后任何关于复用产生的 UI 问题，都可以在此尝试编码解决。
     * In the future, any UI problems caused by reuse can be solved by coding here.
     */
    
    /**
     * 一旦消息复用，说明即将新消息出现，label 内容改为未读
     * Once the message is reused, it means that a new message is about to appear, and the label content is changed to unread.
     */
    _readReceiptLabel.text = TUIKitLocalizableString(Unread);
    _readReceiptLabel.hidden = YES;
}

#pragma mark - Public
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


    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = data.cellLayout.avatarSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    self.nameLabel.text = data.name;
    self.nameLabel.textColor = data.nameColor;
    self.nameLabel.font = data.nameFont;
    
    [self updateReadLabelText];
    
    if (data.status == Msg_Status_Fail ){
        [_indicator stopAnimating];
        self.retryView.image = [UIImage imageNamed:TUIChatImagePath(@"msg_error")];
        _readReceiptLabel.hidden = YES;
    } else {
        if (data.status == Msg_Status_Sending_2) {
            [_indicator startAnimating];
            _readReceiptLabel.hidden = YES;
        }
        else if(data.status == Msg_Status_Succ) {
            [_indicator stopAnimating];
            /**
             * 消息发送成功，说明 indicator 和 error 已不会显示在 label，可以开始显示已读回执 label
             * The message is sent successfully, indicating that the indicator and error are no longer displayed on the label, and the read receipt label can be displayed.
             */
            if (self.messageData.showReadReceipt
                && self.messageData.direction == MsgDirectionOutgoing
                && self.messageData.innerMessage.needReadReceipt
                && (self.messageData.innerMessage.userID || self.messageData.innerMessage.groupID)
                && ![self.messageData isKindOfClass:TUISystemMessageCellData.class]
               ) {
                _readReceiptLabel.hidden = NO;
            }
        }
        else if (data.status == Msg_Status_Sending) {
            [_indicator stopAnimating];
            _readReceiptLabel.hidden = YES;
        }
        self.retryView.image = nil;
    }
    
    [self.messageModifyRepliesButton setImage:TUIChatBundleThemeImage(@"chat_messageReplyIcon_img", @"messageReplyIcon") forState:UIControlStateNormal];
    
    self.messageModifyRepliesButton.hidden = YES;
    if (data.showMessageModifyReplies) {
        self.messageModifyRepliesButton.hidden = NO;
        NSString *title = [NSString stringWithFormat:@"%ld%@", data.messageModifyReplies.count, TUIKitLocalizableString(TUIKitRepliesNum)];
        [self.messageModifyRepliesButton setTitle:title forState:UIControlStateNormal];
    }
    
    if (data.messageModifyReacts) {
        [self updateMessageModifyReacts:data.messageModifyReacts];
        self.tagView.hidden = NO ;
    }
    else {
        self.tagView.hidden = YES;
    }
    NSString *imageName = (data.showCheckBox && data.selected) ? TUICoreImagePath(@"icon_select_selected") : TUICoreImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];
    
    _timeLabel.text = [TUITool convertDateToStr:data.innerMessage.timestamp];
    
    /**
     * 文本高亮显示 - 此处的异步操作是为了让其执行顺序与子类一致
     * Text highlighting - asynchronous operations are here to keep the order of execution consistent with subclasses
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf highlightWhenMatchKeyword:data.highlightKeyword];
    });
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    static NSString * const key = @"highlightAnimation";
    if (keyword && keyword.length) {
        if (self.highlightAnimating) {
            return;
        }
        self.highlightAnimating = YES;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
        animation.repeatCount = 3;
        animation.values = @[
                                (id)[[UIColor orangeColor] colorWithAlphaComponent:0.2].CGColor,
                                (id)[[UIColor orangeColor] colorWithAlphaComponent:0.5].CGColor,
                                (id)[[UIColor orangeColor] colorWithAlphaComponent:0.2].CGColor,
                            ];
        animation.duration = 0.5;
        animation.removedOnCompletion = YES;
        animation.delegate = self;
        [self.highlightAnimateView.layer addAnimation:animation forKey:key];
    } else {
        [self.highlightAnimateView.layer removeAnimationForKey:key];
    }
}

- (void)updateReadLabelText {
    if (self.messageData.innerMessage.groupID.length > 0) {
        // group message
        NSString *text = TUIKitLocalizableString(Unread);
        if (self.messageData.messageReceipt == nil) {
            // haven't received the message receipt yet
            return;
        }
        NSInteger readCount = self.messageData.messageReceipt.readCount;
        NSInteger unreadCount = self.messageData.messageReceipt.unreadCount;
        if (unreadCount == 0) {
            // show "All read"
            text = TUIKitLocalizableString(TUIKitMessageReadAllRead);
        } else if (readCount > 0) {
            // show "x read"
            text = [NSString stringWithFormat:@"%ld %@", (long)readCount, TUIKitLocalizableString(TUIKitMessageReadPartRead)];
        }
        self.readReceiptLabel.text = text;
    } else {
        // c2c message
        BOOL isPeerRead = self.messageData.messageReceipt.isPeerRead;
        NSString *text = isPeerRead ? TUIKitLocalizableString(TUIKitMessageReadC2CRead) :  TUIKitLocalizableString(TUIKitMessageReadC2CUnRead);
        self.readReceiptLabel.text = text;
    }
    self.readReceiptLabel.mm_sizeToFit().mm_bottom(self.container.mm_b).mm_left(_container.mm_x - 8 - _readReceiptLabel.mm_w);
}

- (UIView *)highlightAnimateView
{
    return self.container;
}

#pragma mark - Private
- (void)animationDidStart:(CAAnimation *)anim
{
    self.highlightAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.highlightAnimating = NO;
}

#pragma mark -- Event
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
    if ([recognizer isKindOfClass:[UIGestureRecognizer class]]) {
        CGPoint point = [recognizer locationInView:self.tagView];
        BOOL result = [self.tagView.layer containsPoint:point];
        if (result) {
            return;
        }
    }

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

- (void)onLongSelectMessageAvatar:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onLongSelectMessageAvatar:)]){
        [_delegate onLongSelectMessageAvatar:self];
    }
}

- (void)onSelectReadReceipt:(UITapGestureRecognizer *)gesture {
    if (![self shouldHighlightReadReceiptLabel]) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectReadReceipt:)]) {
        [_delegate onSelectReadReceipt:self.messageData];
    }
}

- (void)onJumpToRepliesDetailPage:(UIButton *)btn {
    NSLog(@"click onJumpToRepliesDetailPage");
    NSLog(@"%@",self.messageData.messageModifyReplies);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onJumpToRepliesDetailPage:)]) {
        [_delegate onJumpToRepliesDetailPage:self.messageData];
    }
}
- (BOOL)shouldHighlightReadReceiptLabel {
    if (self.messageData.innerMessage.groupID.length == 0) {
        return ![self.readReceiptLabel.text isEqualToString:TUIKitLocalizableString(TUIKitMessageReadC2CRead)];
    } else {
        return ![self.readReceiptLabel.text isEqualToString:TUIKitLocalizableString(TUIKitMessageReadAllRead)];
    }
}


- (void)prepareReactTagUI:(UIView *)containerView {
    
    TUITagsView *tagView = [[TUITagsView alloc] init];
    tagView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:tagView];
    self.tagView = tagView;
    __weak typeof(self) weakSelf = self;
    
    tagView.emojiClickCallback = ^(TUITagsModel * _Nonnull model) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onEmojiClickCallback:faceName:)]) {
            [strongSelf.delegate onEmojiClickCallback:strongSelf.messageData faceName:model.emojiKey];
        }
    };
    tagView.signSelectTag = ^(TUITagsModel * _Nonnull model) {
        NSString *selectTagStr = (model.alias == nil || [model.alias isEqualToString:@""]) ? model.name : model.alias;
        NSLog(@"The name of the selected label is：%@",selectTagStr);
    };
}

- (NSMutableArray *)reactlistArr {
    if (!_reactlistArr) {
        _reactlistArr = [NSMutableArray array];
    }
    return _reactlistArr;
}
- (void)updateMessageModifyReacts:(NSDictionary *)messageModifyReacts {
    
    [self.reactlistArr removeAllObjects];
    if(messageModifyReacts && [messageModifyReacts isKindOfClass:NSDictionary.class]) {

        [messageModifyReacts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if (obj &&[obj isKindOfClass:NSArray.class] ) {
                NSArray *arr = (NSArray *)obj;
                if (arr.count >0) {
                    TUITagsModel *model = [[TUITagsModel alloc] init];
                    model.defaultColor = [TUIChatDynamicColor(@"", @"#DADADA") colorWithAlphaComponent:0.5];
                    model.textColor = TUIChatDynamicColor(@"", @"#888888");
                    model.emojiKey = key;
                    model.emojiPath = [key getEmojiImagePath];
                    model.followIDs =  [NSMutableArray arrayWithArray:obj];
                    
                    for (NSString *userID in obj) {
                        TUITagsUserModel * userModel = [self.messageData.messageModifyUserInfos objectForKey:userID];
                        NSString *name = [userModel getDisplayName];
                        if (name.length >0) {
                            [model.followUserNames addObject:name];
                        }
                        if (userModel) {
                            [model.followUserModels addObject:userModel];
                        }
                    }
                    [self.reactlistArr addObject:model];
                }
                
            }
        }];
    }
    self.tagView.listArrM = self.reactlistArr;
    [self.tagView updateView];
}

@end
