//
//  TUIGroupNoteContainerCell.h
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIBubbleMessageCell.h"
#import "TUIGroupNoteContainerCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoteContainerCell : TUIBubbleMessageCell

- (void)fillWithData:(TUIGroupNoteContainerCellData *)data;

@property (nonatomic, strong) TUIGroupNoteContainerCellData *customData;

@end

NS_ASSUME_NONNULL_END
