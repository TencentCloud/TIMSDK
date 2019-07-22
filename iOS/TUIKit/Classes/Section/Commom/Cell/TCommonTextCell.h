#import <UIKit/UIKit.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCommonTextCellData : TCommonCellData

@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;

@end

@interface TCommonTextCell : TCommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property (readonly) TCommonTextCellData *textData;

- (void)fillWithData:(TCommonTextCellData *)data;

@end

NS_ASSUME_NONNULL_END
