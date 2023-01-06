//
//  TUITextMessageCell_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell_Minimalist.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"
#import "TUIGlobalization.h"

@implementation TUITextMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[TUITextView alloc] init];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.scrollEnabled = NO;
        self.textView.editable = NO;
        self.textView.delegate = self;
        [self.bubbleView addSubview:self.textView];
        
        self.translationView = [[TUITranslationView alloc] initWithBackgroundColor: TUIChatDynamicColor(@"chat_message_translation_bg_color_minimalist", @"#F2F7FF")];
        self.translationView.delegate = self;
        [self.contentView addSubview:self.translationView];
    }
    return self;
}

- (void)setupRAC {
    @weakify(self);
    [[[RACObserve(self, textData.translationViewData.status) distinctUntilChanged] skip:1] subscribeNext:^(NSNumber *status) {
        @strongify(self);
        if (self.textData == nil) {
            return;
        }
        [self refreshTranslationView];
    }];
}

- (void)fillWithData:(TUITextMessageCellData_Minimalist *)data;
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.selectContent = data.content;
    self.textView.attributedText = data.attributedString;
    self.textView.textColor = data.textColor;
    self.textView.font = data.textFont;
    
    [self.textData.translationViewData setMessage:data.innerMessage];
    [self refreshTranslationView];
}

- (void)refreshTranslationView {
    if (self.textData.translationViewData.status == TUITranslationViewStatusLoading) {
        [self.translationView startLoading];
    } else {
        [self.translationView stopLoading];
    }
    
    self.translationView.hidden = [self.textData.translationViewData isHidden];
    [self.textData.translationViewData calcSize];
    [self.translationView updateTransaltion:self.textData.translationViewData.text];
    [self layoutTranslationView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
    
    [self layoutTranslationView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSAttributedString *selectedString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
    if (self.selectAllContentContent && selectedString.length>0) {
        if (selectedString.length == textView.attributedText.length) {
            self.selectAllContentContent(YES);
        } else {
            self.selectAllContentContent(NO);
        }
    }
    if (selectedString.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:selectedString];
        NSUInteger offsetLocation = 0;
        for (NSDictionary *emojiLocation in self.textData.emojiLocations) {
            NSValue *key = emojiLocation.allKeys.firstObject;
            NSAttributedString *originStr = emojiLocation[key];
            NSRange currentRange = [key rangeValue];
            /**
             * 每次 emoji 替换后，字符串的长度都会发生变化，后面 emoji 的实际 location 也要相应改变
             * After each emoji is replaced, the length of the string will change, and the actual location of the emoji will also change accordingly.
             */
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                currentRange.location -= textView.selectedRange.location;
                if (currentRange.location + currentRange.length <= attributedString.length) {
                    [attributedString replaceCharactersInRange:currentRange withAttributedString:originStr];
                    offsetLocation += originStr.length - currentRange.length;
                }
            }
        }
        self.selectContent = attributedString.string;
    } else {
        self.selectContent = nil;
    }
}

- (void)layoutTranslationView {
    if (self.translationView.hidden) {
        return;
    }
    
    CGSize size = self.textData.translationViewData.size;
    /// TransitionView should not cover the replyView.
    /// Add an extra tiny offset to the left or right of TransitionView if replyView is visible.
    CGFloat offset = self.replyLineView.hidden ? 0 : 1;
    UIView *view = self.replyEmojiView.hidden ? self.bubbleView : self.replyEmojiView;
    CGFloat topMargin = view.mm_maxY + self.nameLabel.mm_h + 6;
    
    if (self.textData.direction == MsgDirectionOutgoing) {
        self.translationView
            .mm_top(topMargin)
            .mm_width(size.width)
            .mm_height(size.height)
            .mm_right(self.mm_w - self.container.mm_maxX + offset);
    } else {
        self.translationView
            .mm_top(topMargin)
            .mm_width(size.width)
            .mm_height(size.height)
            .mm_left(self.container.mm_minX + offset);
    }
    
    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.translationView.frame) + 5,
                                    oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
    for (UIView *view in self.replyAvatarImageViews) {
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.translationView.frame) + 5,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    if (!self.replyLineView.hidden) {
        CGRect oldRect = self.retryView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y,
                                    oldRect.size.width, oldRect.size.height + self.translationView.mm_h);
        self.retryView.frame = newRect;
    }
}

@end

