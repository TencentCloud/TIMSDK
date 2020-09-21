#import "TUIJoinGroupMessageCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"

@interface TUIJoinGroupMessageCell()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end


@implementation TUIJoinGroupMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //此处 textView 的样式按照系统信息的 messageLebel保持一致
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

- (void)fillWithData:(TUIJoinGroupMessageCellData *)data;
{
    [super fillWithData:data];
    self.joinData = data;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];

    //以下代码对 attributeString 进行设置并对对应的名称部分添加识别。
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",data.content]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributeDict = @{NSFontAttributeName:self.messageLabel.font,
                                    NSForegroundColorAttributeName:[UIColor d_systemGrayColor],
                                    NSParagraphStyleAttributeName:paragraphStyle
                                    };
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    ///对于多人，遍历以对其添加URL赋值。
    if(data.userNameList.count > 0){
        //通过下面的函数，获取到每个昵称对应的精确位置。
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


//通过 textView 的委托，实现点击蓝色名称时的回调。
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    //判定被踢或被邀请 user 时，使用 URL 判定，方便获得具体点击的目标。
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

//对于昵称精确位置的查找，利用了以下性质：userName 数组从中的存放顺序，和最终内容中显示的顺序必定相同。
//例如：“A 邀请了 B、C、D 加入群组”，则 userName 中元素的存放顺序必定为 ABCD。
//所以在此采用从头查找，接力查找的方式。例如对于上一行中的例子，先查找第一个元素 A，因为 rangeOfString 的特性，必定查找到头部位置的A。
//在查找到头部位置的 A 后，我们把 A 从查找范围中剔除，查找范围变为了 “邀请了 B、C、D 加入群组”，然后再从新范围中，查找下一个元素，也就是 B。
//因为 userName 中的元素存放顺序和最终的显示顺序必定相同，这样就保证在查找范围内第一次出现的字符串的位置，必定为我们想要的位置，从而不必担心子串的误判定。
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
