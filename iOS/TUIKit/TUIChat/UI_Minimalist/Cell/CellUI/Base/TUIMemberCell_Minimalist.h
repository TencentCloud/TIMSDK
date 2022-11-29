
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN
@class  TUIMemberDescribeCellData_Minimalist;
@class TUIMemberCellData_Minimalist;

@interface TUIMemberDescribeCell_Minimalist : TUICommonTableViewCell

- (void)fillWithData:(TUIMemberDescribeCellData_Minimalist *)cellData;

@end

@interface TUIMemberCell_Minimalist : TUICommonTableViewCell

- (void)fillWithData:(TUIMemberCellData_Minimalist *)cellData;

@end

NS_ASSUME_NONNULL_END
