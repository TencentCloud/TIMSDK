#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell.h"
#import "TUIImageMessageCellData.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMediaImageCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIImageCollectionCell : TUIMediaCollectionCell

- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
