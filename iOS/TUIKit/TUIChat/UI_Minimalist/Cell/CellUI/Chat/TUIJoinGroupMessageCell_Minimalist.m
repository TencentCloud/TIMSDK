#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUIDefine.h"

@interface TUIJoinGroupMessageCell_Minimalist()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@end

@implementation TUIJoinGroupMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor d_systemGrayColor];
        _textView.textContainerInset =  UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.layer.cornerRadius = 3;
        _textView.delegate = self;

        _textView.textAlignment = NSTextAlignmentLeft;
        [self.messageLabel removeFromSuperview];
        [self.container addSubview:_textView];
        _textView.delaysContentTouches = NO;
    }
    return self;
}

- (void)fillWithData:(TUIJoinGroupMessageCellData_Minimalist *)data;
{
    [super fillWithData:data];
    self.joinData = data;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",data.content]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributeDict = @{NSFontAttributeName:self.messageLabel.font,
                                    NSForegroundColorAttributeName:[UIColor d_systemGrayColor],
                                    NSParagraphStyleAttributeName:paragraphStyle
                                    };
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    if(data.userNameList.count > 0){
        NSArray *nameRangeList = [self findRightRangeOfAllString:data.userNameList inText:attributeString.string];
        int i = 0;
        for(i = 0; i < nameRangeList.count; i++){
            NSString *nameRangeString = nameRangeList[i];
            NSRange nameRange = NSRangeFromString(nameRangeString);
            [attributeString addAttribute:NSLinkAttributeName
                                    value:[NSString stringWithFormat:@"%d",i]
                                    range:nameRange];
        }
    }
    self.textView.attributedText = attributeString;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.mm_center();
    self.textView.mm_fill();
}

- (void)onSelectUserName:(NSInteger) index{
    if(self.joinGroupDelegate && [self.joinGroupDelegate respondsToSelector:@selector(didTapOnRestNameLabel:withIndex:)])
        [self.joinGroupDelegate didTapOnRestNameLabel:self withIndex:index];
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
        NSArray *userNames = _joinData.userNameList;
        NSURL *urlRecognizer = [[NSURL alloc] init];

        for(int i = 0;i < userNames.count;i++){
            urlRecognizer = [NSURL URLWithString:[NSString stringWithFormat:@"%d",i]];
            if([URL isEqual:urlRecognizer]){
                [self onSelectUserName:i];
            }
        }


    return NO;
}

/**
 * 对于获取文本内容中昵称的准确位置，利用了以下性质：userName 在数组中的存放顺序，和最终文本显示的顺序必定相同。
 * 例如：文本内容为，“A 邀请了 B、C、D 加入群组”，那么 userName 中元素的存放顺序必定为 ABCD。
 * 故使用“从头查找，接力查找”的方式。例如，先查找第一个元素 A，因为 rangeOfString 的特性，必定查找到头部位置的 A。
 * 在查找到头部位置的 A 后，我们把 A 从查找范围中剔除，查找范围变为了 “邀请了 B、C、D 加入群组”，然后继续查找下一个元素，也就是 B。
 *
 * To obtain the exact position of the nickname in the text content, the following properties are used: the storage order of userName in the array must be the same as the order in which the final text is displayed.
 * For example: the text content is, "A invited B, C, D to join the group", then the storage order of the elements in userName must be ABCD.
 * Therefore, the method of "searching from the beginning and searching in succession" is used. For example, find the first element A first, because of the characteristics of rangeOfString, it must find the A at the head position.
 * After finding A at the head position, we remove A from the search range, and the search range becomes "B, C, D are invited to join the group", and then continue to search for the next element, which is B.
 */
- (NSMutableArray *) findRightRangeOfAllString:(NSMutableArray<NSString *> *) stringList inText:(NSString *)text{
    NSMutableArray *rangeList = [NSMutableArray array];
    NSUInteger beginLocation = 0;
    NSEnumerator *enumer=[stringList objectEnumerator];

    NSString *string = [NSString string];
    while (string = [enumer nextObject]){
        NSRange newRange = NSMakeRange(beginLocation, text.length - beginLocation);
        NSRange stringRange = [text rangeOfString:string options:NSLiteralSearch range:newRange];

        if(stringRange.length > 0){
            [rangeList addObject:NSStringFromRange(stringRange)];
            beginLocation = stringRange.location + stringRange.length;
        }
    }
    return rangeList;
}
@end
