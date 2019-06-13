//
//  TUITextMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUITextMessageCellData : TUIBubbleMessageCellData

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic) UIColor *textColor;

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (readonly) CGSize textSize;
@property (readonly) CGPoint textOrigin;

@property (nonatomic, class) UIColor *outgoingTextColor;
@property (nonatomic, class) UIFont *outgoingTextFont;
@property (nonatomic, class) UIColor *incommingTextColor;
@property (nonatomic, class) UIFont *incommingTextFont;

@end

NS_ASSUME_NONNULL_END
