//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"

@implementation TUITextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[TUITextView alloc] init];
        //self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
        self.textView.backgroundColor = [UIColor clearColor];
        //系统会为其默认设置距UITextView上、下边缘各8的页边距
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //textContainer中的文段的上、下、左、右又会被填充5的空白
        self.textView.textContainer.lineFragmentPadding = 0;
        // 这个参数不设置会丢失选中光标
        self.textView.scrollEnabled = NO;
        self.textView.editable = NO;
        self.textView.delegate = self;
        [self.bubbleView addSubview:self.textView];
    }
    return self;
}

- (void)fillWithData:(TUITextMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.selectContent = data.content;
    self.textView.attributedText = data.attributedString;
    self.textView.textColor = data.textColor;
    self.textView.font = data.textFont;
}

//- (void)highlightWhenMatchKeyword:(NSString *)keyword
//{
//    // 子类重写高亮文本效果
//    TUITextMessageCellData *data = (TUITextMessageCellData *)self.data;
//    if (data.highlightKeyword == nil) {
//        return;
//    }
//
//    NSRange range = [data.attributedString.string rangeOfString:data.highlightKeyword];
//    if (range.location == NSNotFound) {
//        return;
//    }
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:data.attributedString];
//    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
//    self.textView.attributedText = attr;
//}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
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
            // 每次 emoji 替换后，字符串的长度都会发生变化，后面 emoji 的实际 location 也要相应改变
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                // selectedRange 如果发生了变化，emoji 实际 location 也要相应改变
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


@implementation TUITextView
- (BOOL)canBecameFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

@end
