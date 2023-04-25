//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUICore.h>

@implementation TUITextMessageCell

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
        
        self.bottomContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomContainer];
        
        self.voiceReadPoint = [[UIImageView alloc] init];
        self.voiceReadPoint.backgroundColor = [UIColor redColor];
        self.voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        self.voiceReadPoint.hidden = YES;
        [self.voiceReadPoint.layer setCornerRadius:self.voiceReadPoint.frame.size.width/2];
        [self.voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:self.voiceReadPoint];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.bottomContainer.subviews) {
        [view removeFromSuperview];
    }
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData: self.textData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUITextMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.selectContent = data.content;
    self.textView.attributedText = data.attributedString;
    self.textView.textColor = data.textColor;
    self.textView.font = data.textFont;
    self.voiceReadPoint.hidden = !data.showUnreadPoint;
    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
    if (self.voiceReadPoint.hidden == NO) {
        self.voiceReadPoint.frame = CGRectMake(CGRectGetMaxX(self.bubbleView.frame), 0, 5, 5);
    }
    if (self.messageData.messageModifyReactsSize.height > 0) {
        if (self.tagView) {
            CGFloat tagViewTopPadding = 6;
            self.tagView.frame = CGRectMake(0, self.container.mm_h - self.messageData.messageModifyReactsSize.height - tagViewTopPadding , self.container.frame.size.width, self.messageData.messageModifyReactsSize.height);
        }
    }

    [self layoutBottomContainer];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.textData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.textData.bottomContainerSize;
    CGFloat topMargin = self.bubbleView.mm_maxY + self.nameLabel.mm_h + 6;

    if (self.textData.direction == MsgDirectionOutgoing) {
        self.bottomContainer
            .mm_top(topMargin)
            .mm_width(size.width)
            .mm_height(size.height)
            .mm_right(self.mm_w - self.container.mm_maxX);
    } else {
        self.bottomContainer
            .mm_top(topMargin)
            .mm_width(size.width)
            .mm_height(size.height)
            .mm_left(self.container.mm_minX);
    }

    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame),
                                    oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
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

@end

