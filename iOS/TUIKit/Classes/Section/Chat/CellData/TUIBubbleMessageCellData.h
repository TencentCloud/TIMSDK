//
//  TUIBubbleMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBubbleMessageCellData : TUIMessageCellData

@property CGFloat bubbleTop;
@property UIImage *bubble;
@property UIImage *highlightedBubble;

@property (nonatomic, class) UIImage *outgoingBubble;
@property (nonatomic, class) UIImage *outgoingHighlightedBubble;
@property (nonatomic, class) UIImage *incommingBubble;
@property (nonatomic, class) UIImage *incommingHighlightedBubble;

@property (nonatomic, class) CGFloat outgoingBubbleTop;
@property (nonatomic, class) CGFloat incommingBubbleTop;

@end

NS_ASSUME_NONNULL_END
