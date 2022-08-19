
#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell.h"
#import "TUIVideoMessageCellData.h"

@interface TUIVideoCollectionCell : TUIMediaCollectionCell

- (void)fillWithData:(TUIVideoMessageCellData *)data;

- (void)stopVideoPlayAndSave;

@end
