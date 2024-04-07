//
//  TUIReactPreview_Minimalist.m
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/29.
//

#import "TUIReactPreview_Minimalist.h"
#import <TUICore/TUIDefine.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import "TUIReactModel.h"

@interface TUIReactPreview_Minimalist ()
@property(nonatomic, strong) UIImageView *replyEmojiView;
@property(nonatomic, strong) UILabel *replyEmojiCount;
@property(nonatomic, strong) NSMutableArray *replyEmojiImageViews;
@end

@implementation TUIReactPreview_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    _replyEmojiView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _replyEmojiView.layer.borderWidth = 1;
    _replyEmojiView.layer.borderColor = RGBA(221, 221, 221, 1).CGColor;
    _replyEmojiView.layer.masksToBounds = true;
    _replyEmojiView.layer.cornerRadius = 10;
    _replyEmojiView.backgroundColor = [UIColor whiteColor];
    _replyEmojiView.userInteractionEnabled = YES;
    [self addSubview:_replyEmojiView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJumpToReactEmojiPage)];
    [self addGestureRecognizer:tap];
    
    _replyEmojiCount = [[UILabel alloc] init];
    [_replyEmojiCount setTextColor:RGBA(153, 153, 153, 1)];
    _replyEmojiCount.rtlAlignment = TUITextRTLAlignmentLeading;
    [_replyEmojiCount setFont:[UIFont systemFontOfSize:12]];
    [_replyEmojiView addSubview:_replyEmojiCount];
    
    _replyEmojiImageViews = [NSMutableArray array];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateView {
    // emoji 
    if (_replyEmojiImageViews.count > 0) {
        for (UIImageView *emojiView in _replyEmojiImageViews) {
            [emojiView removeFromSuperview];
        }
        [_replyEmojiImageViews removeAllObjects];
    }
    _replyEmojiView.hidden = YES;
    _replyEmojiCount.hidden = YES;
    if (self.reactlistArr.count > 0) {
        _replyEmojiView.hidden = NO;
        _replyEmojiCount.hidden = NO;

        NSInteger emojiCount = 0;
        NSInteger emojiMaxCount = 6;
        NSInteger replyEmojiTotalCount = 0;
        NSMutableDictionary *existEmojiMap = [NSMutableDictionary dictionary];
        for (TUIReactModel *model in self.reactlistArr) {
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
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}
// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    if (_replyEmojiImageViews.count > 0) {
        CGFloat emojiSize = 12;
        CGFloat emojiSpace = kScale390(4);
        __block UIImageView * preEmojiView = nil;
        for (int i = 0; i < _replyEmojiImageViews.count; ++i) {
            UIImageView *emojiView = _replyEmojiImageViews[i];
            if (i == 0) {
                preEmojiView = nil;
            }
            else {
                preEmojiView = _replyEmojiImageViews[i-1];
            }
            [emojiView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (i == 0){
                    make.leading.mas_equalTo(_replyEmojiView.mas_leading).mas_offset(kScale390(8));
                }
                else {
                    make.leading.mas_equalTo(preEmojiView.mas_trailing).mas_offset(emojiSpace);
                }
                make.width.height.mas_equalTo(emojiSize);
                make.centerY.mas_equalTo(_replyEmojiView.mas_centerY);
            }];
            emojiView.layer.masksToBounds = YES;
            emojiView.layer.cornerRadius = emojiSize / 2.0;
        }
        UIImageView * lastEmojiView = _replyEmojiImageViews.lastObject;
        [_replyEmojiCount mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(lastEmojiView.mas_trailing).mas_offset(kScale390(8));
            make.trailing.mas_equalTo(_replyEmojiView.mas_trailing);
            make.width.mas_equalTo(emojiSize + 10);
            make.height.mas_equalTo(emojiSize);
            make.centerY.mas_equalTo(_replyEmojiView.mas_centerY);
        }];
        
        [_replyEmojiView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.delegateCell.messageData.direction == MsgDirectionIncoming) {
                make.leading.mas_greaterThanOrEqualTo(self);
            } else {
                make.trailing.mas_lessThanOrEqualTo(self);
            }
            make.top.mas_equalTo(self);
            make.height.mas_equalTo(self);
        }];
    } else {
        _replyEmojiCount.frame = CGRectZero;
        _replyEmojiView.frame = CGRectZero;
    }
}

- (NSMutableArray *)reactlistArr {
    if (!_reactlistArr) {
        _reactlistArr = [NSMutableArray array];
    }
    return _reactlistArr;
}

- (void)refreshByArray:(NSMutableArray *)tagsArray {
    if (tagsArray && tagsArray.count > 0) {
        self.reactlistArr = [NSMutableArray arrayWithArray:tagsArray];
        [UIView animateWithDuration:1 animations:^{
            [self updateView];
        }completion:^(BOOL finished) {
            
        }];
        self.delegateCell.messageData.messageContainerAppendSize = CGSizeMake(0, kScale375(16));
        [self notifyReactionChanged];
    }
    else {
        self.reactlistArr = [NSMutableArray array];
        [UIView animateWithDuration:1 animations:^{
            [self updateView];
        }completion:^(BOOL finished) {
            
        }];
        self.delegateCell.messageData.messageContainerAppendSize = CGSizeMake(0, 0);
        [self notifyReactionChanged];
    }
}
- (void)notifyReactionChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : self.delegateCell.messageData,
                            TUICore_TUIPluginNotify_DidChangePluginViewSubKey_VC : self,
                            TUICore_TUIPluginNotify_DidChangePluginViewSubKey_isAllowScroll2Bottom:@"0"};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                  object:nil
                   param:param];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];
    });
}
- (void)onJumpToReactEmojiPage {
    if (self.emojiClickCallback) {
        self.emojiClickCallback(nil);
    }
}
@end
