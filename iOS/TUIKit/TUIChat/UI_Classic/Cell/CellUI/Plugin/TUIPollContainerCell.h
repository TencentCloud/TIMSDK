//
//  TUIPollContainerCell.h
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIBubbleMessageCell.h"
#import "TUIPollContainerCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIPollContainerCell : TUIBubbleMessageCell

- (void)fillWithData:(TUIPollContainerCellData *)data;

@property (nonatomic, strong) TUIPollContainerCellData *customData;

@end

NS_ASSUME_NONNULL_END
