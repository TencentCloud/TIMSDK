
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMemberCellData;
@interface TUIMemberCell : TUICommonTableViewCell

- (void)fillWithData:(TUIMemberCellData *)cellData;

@end

NS_ASSUME_NONNULL_END
