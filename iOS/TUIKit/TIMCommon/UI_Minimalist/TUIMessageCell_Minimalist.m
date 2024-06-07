//
//  TUIMessageCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "NSString+TUIEmoji.h"
#import <TUICore/TUICore.h>
#import <TIMCommon/TUIRelationUserModel.h>

@interface TUIMessageCell_Minimalist ()
@property(nonatomic, assign) TUIMessageStatus status;
@property(nonatomic, strong) NSMutableArray *animationImages;
@end

@implementation TUIMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _replyLineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _replyLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_replyLineView];
        [self.messageModifyRepliesButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        if(isRTL()) {
            self.messageModifyRepliesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
        else {
            self.messageModifyRepliesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        [self.messageModifyRepliesButton setTitleColor:RGBA(0, 95, 255, 1) forState:UIControlStateNormal];

        _msgStatusView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _msgStatusView.contentMode = UIViewContentModeScaleAspectFit;
        _msgStatusView.layer.zPosition = FLT_MAX;
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJumpToMessageInfoPage)];
        [_msgStatusView addGestureRecognizer:tap2];
        _msgStatusView.userInteractionEnabled = YES;
        [self.container addSubview:_msgStatusView];

        _msgTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgTimeLabel.textColor = RGB(102, 102, 102);
        _msgTimeLabel.font = [UIFont systemFontOfSize:12];
        _msgTimeLabel.rtlAlignment = TUITextRTLAlignmentTrailing;
        _msgTimeLabel.layer.zPosition = FLT_MAX;
        [self.container addSubview:_msgTimeLabel];

        self.animationImages = [NSMutableArray array];
        for (int i = 1; i <= 45; ++i) {
            NSString *imageName = [NSString stringWithFormat:@"msg_status_sending_%d", i];
            NSString *imagePath = TUIChatImagePath_Minimalist(imageName);
            UIImage *image = [[TUIImageCache sharedInstance] getResourceFromCache:imagePath];
            [self.animationImages addObject:image];
        }
        _replyAvatarImageViews = [NSMutableArray array];
    }
    return self;
}

- (void)prepareReactTagUI:(UIView *)containerView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate: self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_MinimalistExtensionID parentView:containerView param:param];
}


- (void)onJumpToMessageInfoPage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onJumpToMessageInfoPage:selectCell:)]) {
        [self.delegate onJumpToMessageInfoPage:self.messageData selectCell:self];
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    TUIMessageCellLayout *cellLayout = self.messageData.cellLayout;
    BOOL isInComing = (self.messageData.direction == MsgDirectionIncoming);

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isInComing) {
            make.leading.mas_equalTo(self.container.mas_leading).mas_offset(7);
        } else {
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

    [self.selectedIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(3);
        make.centerY.mas_equalTo(self.container.mas_centerY);
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
    

    if (self.messageData.showMessageModifyReplies && _replyAvatarImageViews.count > 0)  {
        CGFloat lineViewW = 17;
        CGFloat avatarSize = 16;
        CGFloat repliesBtnW = kScale390(50);
        CGFloat avatarY = self.contentView.mm_h - (self.messageData.sameToNextMsgSender ? avatarSize : avatarSize * 2);
        if (self.messageData.direction == MsgDirectionIncoming)  {
            UIImageView *preAvatarImageView = nil;
            for (int i = 0; i < _replyAvatarImageViews.count; ++i) {
                UIImageView *avatarView = _replyAvatarImageViews[i];
                if (i == 0) {
                    preAvatarImageView = nil;
                }
                else {
                    preAvatarImageView = _replyAvatarImageViews[i-1];
                }
                [avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (i == 0) {
                        make.leading.mas_equalTo(_replyLineView.mas_trailing);
                    }
                    else {
                        make.leading.mas_equalTo(preAvatarImageView.mas_centerX);
                    }
                    make.top.mas_equalTo(avatarY);
                    make.width.height.mas_equalTo(avatarSize);
                   
                }];
                avatarView.layer.masksToBounds = YES;
                avatarView.layer.cornerRadius = avatarSize / 2.0;
            }
        }
        else {
            __block UIImageView *preAvatarImageView = nil;
            NSInteger count = _replyAvatarImageViews.count;
            for (NSInteger i = (count - 1); i >=0; i--) {
                UIImageView *avatarView = _replyAvatarImageViews[i];
                [avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (!preAvatarImageView) {
                        make.trailing.mas_equalTo(self.messageModifyRepliesButton.mas_leading);
                    }
                    else {
                        make.trailing.mas_equalTo(preAvatarImageView.mas_centerX);
                    }
                    make.top.mas_equalTo(avatarY);
                    make.width.height.mas_equalTo(avatarSize);
                }];
                avatarView.layer.masksToBounds = YES;
                avatarView.layer.cornerRadius = avatarSize / 2.0;
                preAvatarImageView = avatarView;
            }
        }

        UIImageView *lastAvatarImageView = _replyAvatarImageViews.lastObject;

        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.messageData.direction == MsgDirectionIncoming)  {
                make.leading.mas_equalTo(lastAvatarImageView.mas_trailing);
            }
            else {
                make.trailing.mas_equalTo(_replyLineView.mas_leading);
            }
            
            make.top.mas_equalTo(avatarY);
            make.width.mas_equalTo(repliesBtnW);
            make.height.mas_equalTo(avatarSize);
        }];

        [_replyLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.messageData.direction == MsgDirectionIncoming) {
                make.leading.mas_equalTo(self.container.mas_leading).mas_offset(- 1);
            }
            else {
                make.trailing.mas_equalTo(self.container.mas_trailing);
            }
            make.top.mas_equalTo(CGRectGetMaxY(self.container.frame) - 14);
            make.width.mas_equalTo(lineViewW);
            make.bottom.mas_equalTo(self.messageModifyRepliesButton.mas_centerY);
        }];
    } else {
        _replyLineView.frame = CGRectZero;
        self.messageModifyRepliesButton.frame = CGRectZero;
    }

    [_msgTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(self.messageData.msgStatusSize.height);
        make.bottom.mas_equalTo(self.container).mas_offset(-kScale390(9));
        make.trailing.mas_equalTo(self.container).mas_offset(-kScale390(16));
    }];
    [_msgStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(self.messageData.msgStatusSize.height);
        make.bottom.mas_equalTo(self.msgTimeLabel);
        make.trailing.mas_equalTo(_msgTimeLabel.mas_leading);
    }];
    
}

- (void)fillWithData:(TUIMessageCellData *)data {
    [super fillWithData:data];
    self.readReceiptLabel.hidden = YES;
    self.messageModifyRepliesButton.hidden = YES;
    [self.messageModifyRepliesButton setImage:nil forState:UIControlStateNormal];
    //react
    [self prepareReactTagUI:self.contentView];
    
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
        if (self.messageData.direction == MsgDirectionIncoming) {
            lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_income")];
        } else {
            lineImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_reply_line_outcome")];
        }
        lineImage = [lineImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{10,0,20,0}");
        ei = rtlEdgeInsetsWithInsets(ei);
        _replyLineView.image = [lineImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];

        // avtar
        NSInteger avatarCount = 0;
        NSInteger avatarMaxCount = 4;
        NSMutableDictionary *existSenderMap = [NSMutableDictionary dictionary];
        for (NSDictionary *senderMap in self.messageData.messageModifyReplies) {
            NSString *sender = senderMap[@"messageSender"];

            TUIRelationUserModel *userModel = self.messageData.additionalUserInfoResult[sender];
            NSURL *headUrl = [NSURL URLWithString:userModel.faceURL];

            NSString *existSender = existSenderMap[@"messageSender"];
            if (!sender || [sender isEqualToString:existSender]) {
                //exist sender head not add again
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

    _msgTimeLabel.text = [TUITool convertDateToHMStr:self.messageData.innerMessage.timestamp];

    self.indicator.hidden = YES;
    _msgStatusView.hidden = YES;
    self.readReceiptLabel.hidden = YES;
    if (self.messageData.direction == MsgDirectionOutgoing) {
        self.status = TUIMessageStatus_Unkown;
        if (self.messageData.status == Msg_Status_Sending || self.messageData.status == Msg_Status_Sending_2) {
            [self updateMessageStatus:TUIMessageStatus_Sending];
        } else if (self.messageData.status == Msg_Status_Succ) {
            [self updateMessageStatus:TUIMessageStatus_Send_Succ];
        }
        [self updateReadLabelText];
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (void)updateReadLabelText {
    if (self.messageData.innerMessage.groupID.length > 0) {
        // group message
        if (self.messageData.messageReceipt == nil) {
            // haven't received the message receipt yet
            return;
        }
        NSInteger readCount = self.messageData.messageReceipt.readCount;
        NSInteger unreadCount = self.messageData.messageReceipt.unreadCount;
        if (unreadCount == 0) {
            // All read
            [self updateMessageStatus:TUIMessageStatus_All_People_Read];
        } else if (readCount > 0) {
            // Some read
            [self updateMessageStatus:TUIMessageStatus_Some_People_Read];
        }
    } else {
        // c2c message
        BOOL isPeerRead = self.messageData.messageReceipt.isPeerRead;
        if (isPeerRead) {
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
        case TUIMessageStatus_Sending: {
            _msgStatusView.animationImages = self.animationImages;
            [_msgStatusView startAnimating];
        } break;
        case TUIMessageStatus_Send_Succ: {
            _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_send_succ")];
        } break;
        case TUIMessageStatus_Some_People_Read: {
            _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];
        } break;
        case TUIMessageStatus_All_People_Read: {
            _msgStatusView.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
        } break;

        default:
            break;
    }
    self.status = status;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    NSAssert([data isKindOfClass:TUIMessageCellData.class], @"data must be kind of TUIMessageCellData");
    CGFloat height = [super getHeight:data withWidth:width];
    if (data.sameToNextMsgSender) {
        height -= kScale375(16);
    }

    return height;
}

@end
