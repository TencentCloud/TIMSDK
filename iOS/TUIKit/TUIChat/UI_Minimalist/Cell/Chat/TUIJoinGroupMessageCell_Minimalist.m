
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIJoinGroupMessageCell_Minimalist () <UITextViewDelegate>
@property(nonatomic, strong) UITextView *textView;
@end

@implementation TUIJoinGroupMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor d_systemGrayColor];
        _textView.textContainerInset = UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.layer.cornerRadius = 3;
        _textView.delegate = self;

        _textView.textAlignment = NSTextAlignmentLeft;
        [self.messageLabel removeFromSuperview];
        [self.container addSubview:_textView];
        _textView.delaysContentTouches = NO;
    }
    return self;
}

- (void)fillWithData:(TUIJoinGroupMessageCellData *)data;
{
    [super fillWithData:data];
    self.joinData = data;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", data.content]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributeDict = @{
        NSFontAttributeName : self.messageLabel.font,
        NSForegroundColorAttributeName : [UIColor d_systemGrayColor],
        NSParagraphStyleAttributeName : paragraphStyle
    };
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    if (data.userNameList.count > 0) {
        NSArray *nameRangeList = [self findRightRangeOfAllString:data.userNameList inText:attributeString.string];
        int i = 0;
        for (i = 0; i < nameRangeList.count; i++) {
            NSString *nameRangeString = nameRangeList[i];
            NSRange nameRange = NSRangeFromString(nameRangeString);
            [attributeString addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%d", i] range:nameRange];
        }
    }
    self.textView.attributedText = attributeString;
    [self setNeedsLayout];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.contentView);
    }];

    if(self.textView.superview) {
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.container);
            make.size.mas_equalTo(self.contentView);
        }];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)onSelectUserName:(NSInteger)index {
    if (self.joinGroupDelegate && [self.joinGroupDelegate respondsToSelector:@selector(didTapOnRestNameLabel:withIndex:)])
        [self.joinGroupDelegate didTapOnRestNameLabel:self withIndex:index];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSArray *userNames = _joinData.userNameList;
    NSURL *urlRecognizer = [[NSURL alloc] init];

    for (int i = 0; i < userNames.count; i++) {
        urlRecognizer = [NSURL URLWithString:[NSString stringWithFormat:@"%d", i]];
        if ([URL isEqual:urlRecognizer]) {
            [self onSelectUserName:i];
        }
    }

    return NO;
}

/**
 * To obtain the exact position of the nickname in the text content, the following properties are used: the storage order of userName in the array must be the
 * same as the order in which the final text is displayed. For example: the text content is, "A invited B, C, D to join the group", then the storage order of
 * the elements in userName must be ABCD. Therefore, the method of "searching from the beginning and searching in succession" is used. For example, find the
 * first element A first, because of the characteristics of rangeOfString, it must find the A at the head position. After finding A at the head position, we
 * remove A from the search range, and the search range becomes "B, C, D are invited to join the group", and then continue to search for the next element, which
 * is B.
 */
- (NSMutableArray *)findRightRangeOfAllString:(NSMutableArray<NSString *> *)stringList inText:(NSString *)text {
    NSMutableArray *rangeList = [NSMutableArray array];
    NSUInteger beginLocation = 0;
    NSEnumerator *enumer = [stringList objectEnumerator];

    NSString *string = [NSString string];
    while (string = [enumer nextObject]) {
        NSRange newRange = NSMakeRange(beginLocation, text.length - beginLocation);
        NSRange stringRange = [text rangeOfString:string options:NSLiteralSearch range:newRange];

        if (stringRange.length > 0) {
            [rangeList addObject:NSStringFromRange(stringRange)];
            beginLocation = stringRange.location + stringRange.length;
        }
    }
    return rangeList;
}
@end
