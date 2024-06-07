//
//  TUIMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import "NSString+TUIEmoji.h"
#import "TUISystemMessageCellData.h"
#import <TUICore/TUICore.h>

@interface TUIMessageCell () <CAAnimationDelegate>
@property(nonatomic, strong) TUIMessageCellData *messageData;

@end

@implementation TUIMessageCell

#pragma mark - Life cycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
        [self setupRAC];
    }
    return self;
}

- (void)setupSubViews {
    // head
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatarView];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
    [_avatarView addGestureRecognizer:tap1];
    UILongPressGestureRecognizer *tap2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongSelectMessageAvatar:)];
    [_avatarView addGestureRecognizer:tap2];
    [_avatarView setUserInteractionEnabled:YES];

    // nameLabel
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [self fontWithSize:13];
    _nameLabel.textColor = [UIColor d_systemGrayColor];
    [self.contentView addSubview:_nameLabel];

    // container
    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessage:)];
    tap.cancelsTouchesInView = NO;
    [_container addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [_container addGestureRecognizer:longPress];
    [self.contentView addSubview:_container];

    // indicator
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_indicator sizeToFit];
    [self.contentView addSubview:_indicator];

    // error
    _retryView = [[UIImageView alloc] init];
    _retryView.userInteractionEnabled = YES;
    UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetryMessage:)];
    [_retryView addGestureRecognizer:resendTap];
    [self.contentView addSubview:_retryView];

    // messageModifyRepliesLabel
    _messageModifyRepliesButton = [[TUIFitButton alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    _messageModifyRepliesButton.imageSize = CGSizeMake(12, 12);
    [_messageModifyRepliesButton addTarget:self action:@selector(onJumpToRepliesDetailPage:) forControlEvents:UIControlEventTouchUpInside];
    [_messageModifyRepliesButton.titleLabel setFont:[self fontWithSize:12]];
    [_messageModifyRepliesButton setTitleColor:TIMCommonDynamicColor(@"chat_message_read_name_date_text_color", @"#999999") forState:UIControlStateNormal];
    [_messageModifyRepliesButton setImage:TIMCommonBundleThemeImage(@"chat_messageReplyIcon_img", @"messageReplyIcon") forState:UIControlStateNormal];
    [self.contentView addSubview:_messageModifyRepliesButton];

    _readReceiptLabel = [[UILabel alloc] init];
    _readReceiptLabel.hidden = YES;
    _readReceiptLabel.font = [self fontWithSize:12];
    _readReceiptLabel.textColor = TIMCommonDynamicColor(@"chat_message_read_status_text_gray_color", @"#BBBBBB");
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
    _timeLabel.font = [self fontWithSize:11.0];
    [self.contentView addSubview:_timeLabel];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    
    [self makeConstraints];
}

- (void)makeConstraints {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(7);
        make.top.mas_equalTo(self.avatarView.mas_top);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(20);
    }];
    
    [self.selectedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(3);
        make.top.mas_equalTo(self.avatarView.mas_centerY).mas_offset(-10);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
        make.top.mas_equalTo(self.avatarView);
        make.width.mas_greaterThanOrEqualTo(10);
        make.height.mas_equalTo(10);
    }];
    
    [self.selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    TUIMessageCellLayout *cellLayout = self.messageData.cellLayout;
    BOOL isInComing = (self.messageData.direction == MsgDirectionIncoming);

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isInComing) {
            make.leading.mas_equalTo(_container.mas_leading).mas_offset(7);
            make.trailing.mas_equalTo(self.contentView).mas_offset(-7);
        } else {
            make.leading.mas_equalTo(self.contentView).mas_offset(7);
            make.trailing.mas_equalTo(self.container.mas_trailing);
        }
        if (self.messageData.showName) {
            make.width.mas_greaterThanOrEqualTo(20);
            make.height.mas_greaterThanOrEqualTo(20);
        } else {
            make.height.mas_equalTo(0);
        }
        make.top.mas_equalTo(self.avatarView.mas_top);
    }];

    [self.selectedIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.messageData.showCheckBox) {
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        } else {
            make.size.mas_equalTo(CGSizeZero);
        }
    }];

    [self.timeLabel sizeToFit];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.messageData.showMessageTime) {
            make.width.mas_equalTo(self.timeLabel.frame.size.width);
            make.height.mas_equalTo(self.timeLabel.frame.size.height);
        } else {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }
    }];

    CGSize csize = [self.class getContentSize:self.messageData];
    CGFloat contentWidth = csize.width;
    CGFloat contentHeight = csize.height;

    if (!CGSizeEqualToSize(self.messageData.messageContainerAppendSize, CGSizeZero)) {
        /**
         * Taking the maximum width between the "emoji reply message" and the text content
         */
        contentWidth = MAX(self.messageData.messageContainerAppendSize.width, csize.width);
        /**
         * Limit the maximum width to Screen_Width *0.25 * 3
         */
        contentWidth = MIN(contentWidth, Screen_Width * 0.25 * 3);
        contentHeight = csize.height + self.messageData.messageContainerAppendSize.height;
    }
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.avatarView.hidden = !self.messageData.showAvatar;
        [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
          if (self.messageData.showCheckBox) {
              make.leading.mas_equalTo(self.selectedIcon.mas_trailing).mas_offset(cellLayout.avatarInsets.left);
          } else {
              make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(cellLayout.avatarInsets.left);
          }
          make.top.mas_equalTo(cellLayout.avatarInsets.top);
          make.size.mas_equalTo(cellLayout.avatarSize);
        }];

        [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(cellLayout.messageInsets.left);
          make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(cellLayout.messageInsets.top);
          make.width.mas_equalTo(contentWidth);
          make.height.mas_equalTo(contentHeight);
        }];

        CGRect indicatorFrame = self.indicator.frame;
        [self.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.leading.mas_equalTo(self.container.mas_trailing).mas_offset(8);
          make.centerY.mas_equalTo(self.container.mas_centerY);
          make.size.mas_equalTo(indicatorFrame.size);
        }];
        self.retryView.frame = self.indicator.frame;
        self.readReceiptLabel.hidden = YES;
    } else {
        if (!self.messageData.showAvatar) {
            cellLayout.avatarSize = CGSizeZero;
        } 
        [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-cellLayout.avatarInsets.right);
          make.top.mas_equalTo(cellLayout.avatarInsets.top);
          make.size.mas_equalTo(cellLayout.avatarSize);
        }];
        [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.trailing.mas_equalTo(self.avatarView.mas_leading).mas_offset(-cellLayout.messageInsets.right);
          make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(cellLayout.messageInsets.top);
          make.width.mas_equalTo(contentWidth);
          make.height.mas_equalTo(contentHeight);
        }];

        CGRect indicatorFrame = self.indicator.frame;
        [self.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.trailing.mas_equalTo(self.container.mas_leading).mas_offset(-8);
          make.centerY.mas_equalTo(self.container.mas_centerY);
          make.size.mas_equalTo(indicatorFrame.size);
        }];

        self.retryView.frame = self.indicator.frame;

        [self.readReceiptLabel sizeToFit];
        [self.readReceiptLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.bottom.mas_equalTo(self.container.mas_bottom);
          make.trailing.mas_equalTo(self.container.mas_leading).mas_offset(-8);
          make.size.mas_equalTo(self.readReceiptLabel.frame.size);
        }];
    }

    if (!self.messageModifyRepliesButton.isHidden) {
        self.messageModifyRepliesButton.mm_sizeToFit();
        CGFloat repliesBtnTextWidth = self.messageModifyRepliesButton.frame.size.width;
        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
          if (isInComing) {
              make.leading.mas_equalTo(self.container.mas_leading);
          } else {
              make.trailing.mas_equalTo(self.container.mas_trailing);
          }
          make.top.mas_equalTo(self.container.mas_bottom);
          make.size.mas_equalTo(CGSizeMake(repliesBtnTextWidth + 10, 30));
        }];
    }


    // according to apple super should be called at end of method
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupRAC {
    @weakify(self);
    [RACObserve(self, readReceiptLabel.text) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      if ([self shouldHighlightReadReceiptLabel]) {
          self.readReceiptLabel.textColor = TIMCommonDynamicColor(@"chat_message_read_status_text_color", @"#147AFF");
      } else {
          self.readReceiptLabel.textColor = TIMCommonDynamicColor(@"chat_message_read_status_text_gray_color", @"#BBBBBB");
      }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    /**
     * In the future, any UI problems caused by reuse can be solved by coding here.
     */

    /**
     * Once the message is reused, it means that a new message is about to appear, and the label content is changed to empty string.
     */
    _readReceiptLabel.text = @"";
    _readReceiptLabel.hidden = YES;
}

#pragma mark - Public
- (void)fillWithData:(TUIMessageCellData *)data {
    [super fillWithData:data];
    self.messageData = data;

    [self loadAvatar:data];

    if (self.messageData.showName) {
        _nameLabel.hidden = NO;
    } else {
        _nameLabel.hidden = YES;
    }

    if (self.messageData.showCheckBox) {
        _selectedIcon.hidden = NO;
        _selectedView.hidden = NO;
    } else {
        _selectedIcon.hidden = YES;
        _selectedView.hidden = YES;
    }

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = data.cellLayout.avatarSize.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    self.nameLabel.text = data.name;
    
    if (data.direction == MsgDirectionIncoming) {
        self.nameLabel.textColor = self.class.incommingNameColor;
        self.nameLabel.font = self.class.incommingNameFont;
    } else {
        self.nameLabel.textColor = self.class.outgoingNameColor;
        self.nameLabel.font = self.class.outgoingNameFont;
    }


    self.retryView.image = [UIImage imageNamed:TUIChatImagePath(@"msg_error")];

    if (data.status == Msg_Status_Fail) {
        [_indicator stopAnimating];
        _readReceiptLabel.hidden = YES;
        self.retryView.hidden = NO;
    } else {
        if (data.status == Msg_Status_Sending_2) {
            [_indicator startAnimating];
            _readReceiptLabel.hidden = YES;
        } else if (data.status == Msg_Status_Succ) {
            [_indicator stopAnimating];
            /**
             * The message is sent successfully, indicating that the indicator and error are no longer displayed on the label, and the read receipt label can be
             * displayed.
             */
            if (self.messageData.showReadReceipt && self.messageData.direction == MsgDirectionOutgoing && self.messageData.innerMessage.needReadReceipt &&
                (self.messageData.innerMessage.userID || self.messageData.innerMessage.groupID) &&
                ![self.messageData isKindOfClass:TUISystemMessageCellData.class]) {
                [self updateReadLabelText];
                _readReceiptLabel.hidden = NO;
            }
        } else if (data.status == Msg_Status_Sending) {
            [_indicator startAnimating];
            _readReceiptLabel.hidden = YES;
        }
        self.retryView.hidden = YES;
    }

    self.messageModifyRepliesButton.hidden = !data.showMessageModifyReplies;
    if (data.showMessageModifyReplies) {
        NSString *title = [NSString stringWithFormat:@"%ld%@", data.messageModifyReplies.count, TIMCommonLocalizableString(TUIKitRepliesNum)];
        [self.messageModifyRepliesButton setTitle:title forState:UIControlStateNormal];
        [self.messageModifyRepliesButton sizeToFit];
        [self.messageModifyRepliesButton setNeedsUpdateConstraints];
        [self.messageModifyRepliesButton updateConstraintsIfNeeded];
        [self.messageModifyRepliesButton layoutIfNeeded];
    }

    NSString *imageName = (data.showCheckBox && data.selected) ? TIMCommonImagePath(@"icon_select_selected") : TIMCommonImagePath(@"icon_select_normal");
    self.selectedIcon.image = [UIImage imageNamed:imageName];

    _timeLabel.text = [TUITool convertDateToStr:data.innerMessage.timestamp];
    [_timeLabel sizeToFit];
    _timeLabel.hidden = !data.showMessageTime;

    /**
     * Text highlighting - asynchronous operations are here to keep the order of execution consistent with subclasses
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf highlightWhenMatchKeyword:data.highlightKeyword];
    });
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (void)loadAvatar:(TUIMessageCellData *)data {
    [self.avatarView setImage:DefaultAvatarImage];
    @weakify(self);
    [[[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] ignore:nil] subscribeNext:^(NSURL *url) {
      @strongify(self);
      [self.avatarView sd_setImageWithURL:url placeholderImage:DefaultAvatarImage];
    }];

    if (data.isUseMsgReceiverAvatar) {
        NSString *userId = @"";
        if ([data.innerMessage.sender isEqualToString:V2TIMManager.sharedInstance.getLoginUser]) {
            userId = data.innerMessage.userID;
        } else {
            userId = V2TIMManager.sharedInstance.getLoginUser;
        }

        [V2TIMManager.sharedInstance getUsersInfo:@[ userId?:@"" ]
                                             succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                               @strongify(self);
                                               V2TIMUserFullInfo *info = infoList.firstObject;
                                               if (info && [data isEqual:self.messageData]) {
                                                   data.avatarUrl = [NSURL URLWithString:info.faceURL];
                                                   [self.avatarView sd_setImageWithURL:data.avatarUrl placeholderImage:DefaultAvatarImage];
                                               }
                                             }
                                             fail:^(int code, NSString *desc){

                                             }];
    }
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword {
    static NSString *const key = @"highlightAnimation";
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
        NSString *text = TIMCommonLocalizableString(Unread);
        if (self.messageData.messageReceipt == nil) {
            // haven't received the message receipt yet
            return;
        }
        NSInteger readCount = self.messageData.messageReceipt.readCount;
        NSInteger unreadCount = self.messageData.messageReceipt.unreadCount;
        if (unreadCount == 0) {
            // show "All read"
            text = TIMCommonLocalizableString(TUIKitMessageReadAllRead);
        } else if (readCount > 0) {
            // show "x read"
            text = [NSString stringWithFormat:@"%ld %@", (long)readCount, TIMCommonLocalizableString(TUIKitMessageReadPartRead)];
        }
        self.readReceiptLabel.text = text;
    } else {
        // c2c message
        BOOL isPeerRead = self.messageData.messageReceipt.isPeerRead;
        NSString *text = isPeerRead ? TIMCommonLocalizableString(TUIKitMessageReadC2CRead) : TIMCommonLocalizableString(TUIKitMessageReadC2CUnRead);
        self.readReceiptLabel.text = text;
    }
    
    [self.readReceiptLabel sizeToFit];
    [self.readReceiptLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.bottom.mas_equalTo(self.container.mas_bottom);
      make.trailing.mas_equalTo(self.container.mas_leading).mas_offset(-8);
      make.size.mas_equalTo(self.readReceiptLabel.frame.size);
    }];
    self.readReceiptLabel.textColor = [self shouldHighlightReadReceiptLabel] ? TIMCommonDynamicColor(@"chat_message_read_status_text_color", @"#147AFF")
                                                                             : TIMCommonDynamicColor(@"chat_message_read_status_text_gray_color", @"#BBBBBB");
}

- (UIView *)highlightAnimateView {
    return self.container;
}

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data {
    return 60.f;
}

+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    CGFloat height = 0;
    if (data.showName) height += kScale375(20);
    if (data.showMessageModifyReplies) height += kScale375(22);
    
    if (data.messageContainerAppendSize.height > 0) {
        height += data.messageContainerAppendSize.height;
    }
    
    CGSize containerSize = [self getContentSize:data];
    height += containerSize.height;
    height += data.cellLayout.messageInsets.top;
    height += data.cellLayout.messageInsets.bottom;
    
    if (height < 55) height = 55;
    return height;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    return CGSizeZero;
}

#pragma mark - Private
- (void)animationDidStart:(CAAnimation *)anim {
    self.highlightAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.highlightAnimating = NO;
}

#pragma mark-- Event
- (void)onLongPress:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(onLongPressMessage:)]) {
            [_delegate onLongPressMessage:self];
        }
    }
}

- (void)onRetryMessage:(UIGestureRecognizer *)recognizer {
    if (_messageData.status == Msg_Status_Fail)
        if (_delegate && [_delegate respondsToSelector:@selector(onRetryMessage:)]) {
            [_delegate onRetryMessage:self];
        }
}

- (void)onSelectMessage:(UIGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectMessage:)]) {
        [_delegate onSelectMessage:self];
    }
}

- (void)onSelectMessageAvatar:(UIGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectMessageAvatar:)]) {
        [_delegate onSelectMessageAvatar:self];
    }
}

- (void)onLongSelectMessageAvatar:(UIGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(onLongSelectMessageAvatar:)]) {
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
    NSLog(@"%@", self.messageData.messageModifyReplies);

    if (_delegate && [_delegate respondsToSelector:@selector(onJumpToRepliesDetailPage:)]) {
        [_delegate onJumpToRepliesDetailPage:self.messageData];
    }
}
- (BOOL)shouldHighlightReadReceiptLabel {
    if (self.messageData.innerMessage.groupID.length == 0) {
        return ![self.readReceiptLabel.text isEqualToString:TIMCommonLocalizableString(TUIKitMessageReadC2CRead)];
    } else {
        return ![self.readReceiptLabel.text isEqualToString:TIMCommonLocalizableString(TUIKitMessageReadAllRead)];
    }
}

- (UIFont *)fontWithSize:(CGFloat)size {
    static NSCache *fontCache;
    if (fontCache == nil) {
        fontCache = [[NSCache alloc] init];
    }
    UIFont *font = [fontCache objectForKey:@(size)];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
        [fontCache setObject:font forKey:@(size)];
    }
    return font;
}

- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    // Override by subclass.
}

@end


@implementation TUIMessageCell (TUILayoutConfiguration)

static UIColor *gOutgoingNameColor;

+ (UIColor *)outgoingNameColor {
    if (!gOutgoingNameColor) {
        gOutgoingNameColor = [UIColor d_systemGrayColor];
    }
    return gOutgoingNameColor;
}

+ (void)setOutgoingNameColor:(UIColor *)outgoingNameColor {
    gOutgoingNameColor = outgoingNameColor;
}

static UIFont *gOutgoingNameFont;

+ (UIFont *)outgoingNameFont {
    if (!gOutgoingNameFont) {
        gOutgoingNameFont = [UIFont systemFontOfSize:14];
    }
    return gOutgoingNameFont;
}

+ (void)setOutgoingNameFont:(UIFont *)outgoingNameFont {
    gOutgoingNameFont = outgoingNameFont;
}

static UIColor *gIncommingNameColor;

+ (UIColor *)incommingNameColor {
    if (!gIncommingNameColor) {
        gIncommingNameColor = [UIColor d_systemGrayColor];
    }
    return gIncommingNameColor;
}

+ (void)setIncommingNameColor:(UIColor *)incommingNameColor {
    gIncommingNameColor = incommingNameColor;
}

static UIFont *gIncommingNameFont;

+ (UIFont *)incommingNameFont {
    if (!gIncommingNameFont) {
        gIncommingNameFont = [UIFont systemFontOfSize:14];
    }
    return gIncommingNameFont;
}

+ (void)setIncommingNameFont:(UIFont *)incommingNameFont {
    gIncommingNameFont = incommingNameFont;
}

@end
