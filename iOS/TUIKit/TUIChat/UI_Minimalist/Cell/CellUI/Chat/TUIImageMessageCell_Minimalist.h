#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIMessageCell_Minimalist.h"

@interface TUIImageMessageCell_Minimalist : TUIMessageCell_Minimalist

@property (nonatomic, strong) UIImageView *thumb;

@property (nonatomic, strong) UILabel *progress;

@property TUIImageMessageCellData_Minimalist *imageData;

- (void)fillWithData:(TUIImageMessageCellData_Minimalist *)data;
@end
