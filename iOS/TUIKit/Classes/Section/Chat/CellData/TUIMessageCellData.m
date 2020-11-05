//
//  TUIMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"
#import "THeader.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUIMessageCellData

- (id)initWithDirection:(TMsgDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _status = Msg_Status_Init;
        _showReadReceipt = YES;//新 Demo 默认显示已读回执
        _avatarImage = DefaultAvatarImage;
        if (direction == MsgDirectionIncoming) {
            _cellLayout = [TUIMessageCellLayout incommingMessageLayout];
            _nameFont = [[self class] incommingNameFont];
            _nameColor = [[self class] incommingNameColor];
        } else {
            _cellLayout = [TUIMessageCellLayout outgoingMessageLayout];
            _nameFont = [[self class] outgoingNameFont];
            _nameColor = [[self class] outgoingNameColor];
        }
    }
    return self;
}


- (CGFloat)heightOfWidth:(CGFloat)width
{
    CGFloat height = 0;


    if (self.showName)
        height += 20;

    CGSize containerSize = [self contentSize];
    height += containerSize.height;
    height += self.cellLayout.messageInsets.top + self.cellLayout.messageInsets.bottom;

    if (height < 55)
        height = 55;

    return height;
}

- (CGSize)contentSize
{
    return CGSizeZero;
}


static UIColor *sOutgoingNameColor;

+ (UIColor *)outgoingNameColor
{
    if (!sOutgoingNameColor) {
        sOutgoingNameColor = [UIColor d_systemGrayColor];
    }
    return sOutgoingNameColor;
}

+ (void)setOutgoingNameColor:(UIColor *)outgoingNameColor
{
    sOutgoingNameColor = outgoingNameColor;
}

static UIFont *sOutgoingNameFont;

+ (UIFont *)outgoingNameFont
{
    if (!sOutgoingNameFont) {
        sOutgoingNameFont = [UIFont systemFontOfSize:14];
    }
    return sOutgoingNameFont;
}

+ (void)setOutgoingNameFont:(UIFont *)outgoingNameFont
{
    sOutgoingNameFont = outgoingNameFont;
}

static UIColor *sIncommingNameColor;

+ (UIColor *)incommingNameColor
{
    if (!sIncommingNameColor) {
        sIncommingNameColor = [UIColor d_systemGrayColor];
    }
    return sIncommingNameColor;
}

+ (void)setIncommingNameColor:(UIColor *)incommingNameColor
{
    sIncommingNameColor = incommingNameColor;
}

static UIFont *sIncommingNameFont;

+ (UIFont *)incommingNameFont
{
    if (!sIncommingNameFont) {
        sIncommingNameFont = [UIFont systemFontOfSize:14];
    }
    return sIncommingNameFont;
}

+ (void)setIncommingNameFont:(UIFont *)incommingNameFont
{
    sIncommingNameFont = incommingNameFont;
}
@end
