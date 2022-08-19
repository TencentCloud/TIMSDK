//
//  TUISystemMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUISystemMessageCellData.h"
#import "TUIDefine.h"
#import "NSString+TUIUtil.h"

@implementation TUISystemMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        _contentFont = [UIFont systemFontOfSize:13];
        _contentColor = [UIColor d_systemGrayColor];
        self.cellLayout =  [TUIMessageCellLayout systemMessageLayout];
    }
    return self;
}

- (CGSize)contentSize
{
    CGSize size = [self.attributedString.string textSizeIn:CGSizeMake(TSystemMessageCell_Text_Width_Max, MAXFLOAT) font:self.contentFont];
    size.height += 10;
    size.width += 16;
    return size;
}

- (NSMutableAttributedString *)attributedString {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemGrayColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    if (self.supportReEdit) {
        NSString *reEditStr = TUIKitLocalizableString(TUIKitMessageTipsReEditMessage);
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", reEditStr]]];
        NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemBlueColor]};
        [attributeString setAttributes:attributeDict range:NSMakeRange(self.content.length + 1, reEditStr.length)];
        [attributeString addAttribute:NSUnderlineStyleAttributeName value:
                [NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(self.content.length + 1, reEditStr.length)];
    }
    return attributeString;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return [self contentSize].height + 16;
}
@end
