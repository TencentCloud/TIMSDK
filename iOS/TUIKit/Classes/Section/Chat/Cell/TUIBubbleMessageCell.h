//
//  TUIBubbleMessageCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIMessageCell.h"
#import "TUIBubbleMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIBubbleMessageCell : TUIMessageCell
@property (nonatomic, strong) UIImageView *bubbleView;
@property TUIBubbleMessageCellData *bubbleData;
- (void)fillWithData:(TUIBubbleMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
