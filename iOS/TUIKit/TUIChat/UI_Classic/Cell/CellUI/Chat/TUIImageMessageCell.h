#import <TIMCommon/TUIMessageCell.h>
#import "TUIImageMessageCellData.h"
#import <TIMCommon/TUIBubbleMessageCell.h>

@interface TUIImageMessageCell : TUIBubbleMessageCell

@property (nonatomic, strong) UIImageView *thumb;

@property (nonatomic, strong) UILabel *progress;

@property TUIImageMessageCellData *imageData;

- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
