
#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"

@interface TUIVideoCollectionCell_Minimalist : TUIMediaCollectionCell_Minimalist

- (void)fillWithData:(TUIVideoMessageCellData_Minimalist *)data;

- (void)stopVideoPlayAndSave;

@end
