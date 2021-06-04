//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TUITextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UILabel alloc] init];
        _content.numberOfLines = 0;
        [self.bubbleView addSubview:_content];
    }
    return self;
}



- (void)fillWithData:(TUITextMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    // 子类重写高亮文本效果
    TUITextMessageCellData *data = (TUITextMessageCellData *)self.data;
    if (data.highlightKeyword == nil) {
        return;
    }
    
    NSRange range = [data.attributedString.string rangeOfString:data.highlightKeyword];
    if (range.location == NSNotFound) {
        return;
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:data.attributedString];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    self.content.attributedText = attr;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

@end
