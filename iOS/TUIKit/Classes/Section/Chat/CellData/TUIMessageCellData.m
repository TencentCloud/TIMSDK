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

@implementation TUIMessageCellData

- (id)initWithDirection:(TMsgDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _status = Msg_Status_Init;
        _nameFont = [UIFont systemFontOfSize:13];
        _nameColor = [UIColor grayColor];
        
        _avatarImage = DefaultAvatarImage;
                
        if (direction == MsgDirectionIncoming) {
            _cellLayout = [TIncommingCellLayout new];
        } else {
            _cellLayout = [TOutgoingCellLayout new];
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
        sOutgoingNameColor = [UIColor whiteColor];
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
        sOutgoingNameFont = [UIFont systemFontOfSize:15];
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
        sIncommingNameColor = [UIColor blackColor];
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
        sIncommingNameFont = [UIFont systemFontOfSize:15];
    }
    return sIncommingNameFont;
}

+ (void)setIncommingNameFont:(UIFont *)incommingNameFont
{
    sIncommingNameFont = incommingNameFont;
}
@end
