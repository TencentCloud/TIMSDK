//
//  TUIMessageCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIMessageCell_Minimalist.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"
#import "NSString+emoji.h"

@interface TUIMessageCell_Minimalist()
@property (nonatomic, assign) TUIMessageStatus status;
@property (nonatomic, strong) NSMutableArray *animationImages;
@end

@implementation TUIMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _replyLineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _replyLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_replyLineView];
        
        _replyEmojiView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _replyEmojiView.layer.borderWidth = 1;
        _replyEmojiView.layer.borderColor = RGBA(221, 221, 221, 1).CGColor;
        _replyEmojiView.layer.masksToBounds = true;
        _replyEmojiView.layer.cornerRadius = 10;
        _replyEmojiView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJumpToRepliesEmojiPage)];
        [_replyEmojiView addGestureRecognizer:tap];
        _replyEmojiView.userInteractionEnabled = YES;
        [self.contentView addSubview:_replyEmojiView];
        
        _replyEmojiCount = [[UILabel alloc] init];
        [_replyEmojiCount setTextColor:RGBA(153, 153, 153, 1)];
        [_replyEmojiCount setTextAlignment:NSTextAlignmentLeft];
        [_replyEmojiCount setFont:[UIFont systemFontOfSize:12]];
        [_replyEmojiView addSubview:_replyEmojiCount];
        
        [self.messageModifyRepliesButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.messageModifyRepliesButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.messageModifyRepliesButton setTitleColor:RGBA(0, 95, 255, 1) forState:UIControlStateNormal];
        
        _msgStatusView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _msgStatusView.contentMode = UIViewContentModeScaleAspectFit;
        _msgStatusView.layer.zPosition = CGFLOAT_MAX;
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJumpToMessageInfoPage)];
        [_msgStatusView addGestureRecognizer:tap2];
        _msgStatusView.userInteractionEnabled = YES;
        [self.container addSubview:_msgStatusView];
        
        _msgTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgTimeLabel.textColor = RGB(102, 102, 102);
        _msgTimeLabel.font = [UIFont systemFontOfSize:12];
        _msgTimeLabel.textAlignment = NSTextAlignmentRight;
        _msgTimeLabel.layer.zPosition = CGFLOAT_MAX;
        [self.container addSubview:_msgTimeLabel];
        
        self.animationImages = [NSMutableArray array];
        for(int i = 1; i <= 45; ++i) {
            NSString *imageName = [NSString stringWithFormat:@"msg_status_sending_%d", i];
            NSString *imagePath = TUIChatImagePath_Minimalist(imageName);
            UIImage *image = [[TUIImageCache sharedInstance] getResourceFromCache:imagePath];
            [self.animationImages addObject:image];
        }
        
        _replyEmojiImageViews = [NSMutableArray array];
        _replyAvatarImageViews = [NSMutableArray array];
    }
    return self;
}

- (void)onJumpToRepliesEmojiPage {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onJumpToRepliesEmojiPage:faceList:)]) {
        [self.delegate onJumpToRepliesEmojiPage:self.messageData faceList:self.reactlistArr];
    }
}

- (void)onJumpToMessageInfoPage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onJumpToMessageInfoPage:selectCell:)]) {
        [self.delegate onJumpToMessageInfoPage:self.messageData selectCell:self];
    }
}

- (void)fillWithData:(TUIMessageCellData_Minimalist *)data
{
    [super fillWithData:data];
    self.messageDataMini = data;
    self.tagView.hidden = YES;
    self.messageModifyRepliesButton.hidden = YES;
    [self.messageModifyRepliesButton setImage:nil forState:UIControlStateNormal];
    
    // emoji 回复
    if (_replyEmojiImageViews.count > 0) {
        for (UIImageView *emojiView in _replyEmojiImageViews) {
            [emojiView removeFromSuperview];
        }
        [_replyEmojiImageViews removeAllObjects];
    }
    _replyEmojiView.hidden = YES;
    _replyEmojiCount.hidden = YES;
    if (self.messageDataMini.messageModifyReacts.count > 0) {
        _replyEmojiView.hidden = NO;
        _replyEmojiCount.hidden = NO;
        
        NSInteger emojiCount = 0;
        NSInteger emojiMaxCount = 6;
        NSInteger replyEmojiTotalCount = 0;
        NSMutableDictionary *existEmojiMap = [NSMutableDictionary dictionary];
        for (TUITagsModel *model in self.reactlistArr) {
            if (!model.emojiKey) {
                continue;
            }
            replyEmojiTotalCount += model.followIDs.count;
            
            if (emojiCount >= emojiMaxCount || existEmojiMap[model.emojiKey]) {
                continue;
            }
            UIImageView *emojiView = [[UIImageView alloc] init];
            if (emojiCount < emojiMaxCount - 1) {
                existEmojiMap[model.emojiKey] = model;
                [emojiView setImage:[model.emojiKey getEmojiImage]];
            } else {
                [emojiView setImage:[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_more_icon")]];
            }
            [_replyEmojiView addSubview:emojiView];
            [_replyEmojiImageViews addObject:emojiView];

            emojiCount++;
        }
        _replyEmojiCount.text = [@(replyEmojiTotalCount) stringValue];
    }
    
    // 文本回复
    if (_replyAvatarImageViews.count > 0) {
        for (UIImageView *imageView in _replyAvatarImageViews) {
            [imageView removeFromSuperview];
        }
        [_replyAvatarImageViews removeAllObjects];
    }
    _replyLineView.hidden = YES;
    if (data.showMessageModifyReplies) {
        _replyLineView.hidden = NO;
        self.messageModifyRepliesButton.hidden = NO;
        
        // line
        UIImage *lineImage = nil;
        if (self.messageDataMini.direction == MsgDirectionIncoming) {
            lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_income")];
        } else {
            lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_outcome")];
        }
        _replyLineView.image = [lineImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{10,0,20,0}") resizingMode:UIImageResizingModeStretch];
        
        // avtar
        NSInteger avatarCount = 0;
        NSInteger avatarMaxCount = 4;
        NSMutableDictionary *existSenderMap = [NSMutableDictionary dictionary];
        for (NSDictionary *senderMap in self.messageDataMini.messageModifyReplies) {
            NSString *sender = senderMap[@"messageSender"];
            
            TUITagsUserModel * userModel = self.messageDataMini.messageModifyUserInfos[sender];
            NSURL *headUrl = [NSURL URLWithString:userModel.faceURL];

            NSString *existSender = existSenderMap[@"messageSender"];
            if (!sender || [sender isEqualToString:existSender]) {
                // 已经存在的用户头像不再重复添加
                continue;
            }
            UIImageView *avatarView = [[UIImageView alloc] init];
            if (avatarCount < avatarMaxCount - 1) {
                existSenderMap[@"messageSender"] = sender;
                [avatarView sd_setImageWithURL:headUrl placeholderImage:DefaultAvatarImage];
            } else {
                [avatarView setImage:[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_more_icon")]];
            }
            [_replyAvatarImageViews addObject:avatarView];
            [self.contentView addSubview:avatarView];

            if (++avatarCount >= avatarMaxCount) {
                break;
            }
        }
    }
    
    _msgTimeLabel.text = [TUITool convertDateToHMStr:self.messageDataMini.innerMessage.timestamp];
    
    self.indicator.hidden = YES;
    _msgStatusView.hidden = YES;
    if(self.messageDataMini.direction == MsgDirectionOutgoing) {
        self.status = TUIMessageStatus_Unkown;
        if(self.messageDataMini.status == Msg_Status_Sending ||
           self.messageDataMini.status == Msg_Status_Sending_2) {
            [self updateMessageStatus:TUIMessageStatus_Sending];
        } else if(self.messageDataMini.status == Msg_Status_Succ) {
            [self updateMessageStatus:TUIMessageStatus_Send_Succ];
        }
        [self updateReadLabelText];
    }
}

- (void)updateReadLabelText {
    if (self.messageDataMini.innerMessage.groupID.length > 0) {
        // group message
        if (self.messageDataMini.messageReceipt == nil) {
            // haven't received the message receipt yet
            return;
        }
        NSInteger readCount = self.messageDataMini.messageReceipt.readCount;
        NSInteger unreadCount = self.messageDataMini.messageReceipt.unreadCount;
        if (unreadCount == 0) {
            // All read
            [self updateMessageStatus:TUIMessageStatus_All_People_Read];
        } else if (readCount > 0) {
            // Some read
            [self updateMessageStatus:TUIMessageStatus_Some_People_Read];
        }
    } else {
        // c2c message
        BOOL isPeerRead = self.messageDataMini.messageReceipt.isPeerRead;
        if(isPeerRead) {
            [self updateMessageStatus:TUIMessageStatus_All_People_Read];
        }
    }
}

- (void)updateMessageStatus:(TUIMessageStatus)status {
    if (status <= self.status) {
        return;
    }
    _msgStatusView.hidden = NO;
    _msgStatusView.image = nil;
    if (_msgStatusView.isAnimating) {
        [_msgStatusView stopAnimating];
        _msgStatusView.animationImages = nil;
    }
    switch (status) {
        case TUIMessageStatus_Sending:
            {
                _msgStatusView.animationImages = self.animationImages;
                [_msgStatusView startAnimating];
            }
            break;
        case TUIMessageStatus_Send_Succ:
            {
                _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_send_succ")];
            }
            break;
        case TUIMessageStatus_Some_People_Read:
            {
                _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];
            }
            break;
        case TUIMessageStatus_All_People_Read:
            {
                _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
            }
            break;
            
        default:
            break;
    }
    self.status = status;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tagView.frame = CGRectZero;
    self.retryView.mm__centerY(self.messageDataMini.contentSize.height / 2);
    self.avatarView.mm_y = self.messageDataMini.contentSize.height - self.avatarView.mm_h + 4;
    
    if (self.messageDataMini.messageModifyReacts.count > 0) {
        CGFloat emojiSize = 12;
        CGFloat emojiY = kScale390(4);
        CGFloat emojiSpace = kScale390(4);
        CGFloat replyEmojiCountX = 0;
        for (int i = 0; i < _replyEmojiImageViews.count; ++i) {
            UIImageView *emojiView = _replyEmojiImageViews[i];
            emojiView.frame = CGRectMake(kScale390(8) + (emojiSpace + emojiSize) * i, emojiY, emojiSize, emojiSize);
            emojiView.layer.masksToBounds = true;
            emojiView.layer.cornerRadius = emojiSize / 2.0;
            replyEmojiCountX = emojiView.mm_maxX + kScale390(8);
        }
        _replyEmojiCount.frame = CGRectMake(replyEmojiCountX, emojiY, emojiSize + 10, emojiSize);
        
        CGFloat emojiViewW = _replyEmojiCount.mm_x + _replyEmojiCount.mm_w;
        CGFloat emojiViewX = (self.messageDataMini.direction == MsgDirectionIncoming ? self.container.mm_x + kScale390(16) : self.container.mm_x + self.container.mm_w - kScale390(16) - emojiViewW);
        _replyEmojiView.frame = CGRectMake(emojiViewX, self.container.mm_maxY - 4, emojiViewW, 20);
    } else {
        _replyEmojiCount.frame = CGRectZero;
        _replyEmojiView.frame = CGRectZero;
    }
    
    if (self.messageDataMini.showMessageModifyReplies) {
        CGFloat lineViewW = 17;
        CGFloat lineViewH = 0;
        CGFloat lineViewX = (self.messageDataMini.direction == MsgDirectionIncoming ? self.container.mm_x - 1 : self.container.mm_maxX - lineViewW);
        _replyLineView.mm_left(lineViewX).mm_width(lineViewW).mm_height(lineViewH).mm_top(self.container.mm_maxY - 14);
    
        CGFloat avatarSize = 16;
        CGFloat repliesBtnW = kScale390(50);
        CGFloat avatarStartX = 0;
        if (self.messageDataMini.direction == MsgDirectionIncoming) {
            avatarStartX = _replyLineView.mm_maxX;
        } else {
            CGFloat avatarTotalW = (_replyAvatarImageViews.count + 1) * avatarSize / 2;
            avatarStartX = self.container.mm_maxX - repliesBtnW - avatarTotalW - 12;
        }
        CGFloat avatarY = self.contentView.mm_h - (self.messageDataMini.sameToNextMsgSender ? avatarSize : avatarSize * 2);
        CGFloat repliesBtnX = 0;
        for (int i = 0; i < _replyAvatarImageViews.count; ++i) {
            UIImageView *avatarView = _replyAvatarImageViews[i];
            avatarView.frame = CGRectMake(avatarStartX + i * avatarSize / 2.0, avatarY, avatarSize, avatarSize);
            avatarView.layer.masksToBounds = true;
            avatarView.layer.cornerRadius = avatarSize / 2.0;
            repliesBtnX = avatarView.mm_maxX;
        }
        self.messageModifyRepliesButton.frame = CGRectMake(repliesBtnX, avatarY, repliesBtnW, avatarSize);
        _replyLineView.mm_h = self.messageModifyRepliesButton.mm_centerY - _replyLineView.mm_y;
    } else {
        _replyLineView.frame = CGRectZero;
        self.messageModifyRepliesButton.frame = CGRectZero;
    }
    
    _msgTimeLabel.mm_width(38).mm_height(self.messageDataMini.msgStatusSize.height).mm_bottom(9). mm_right(kScale390(16));
    _msgStatusView.mm_width(16).mm_height(self.messageDataMini.msgStatusSize.height).mm_bottom(9).mm_left(_msgTimeLabel.mm_x - 16);

    if (self.messageData.showCheckBox) {
        self.selectedIcon.mm_centerY = self.container.mm_centerY;
    }
}

@end
