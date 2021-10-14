
#import "TUICommonModel.h"
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactSelectCell : TUICommonTableViewCell

@property UIButton *selectButton;
@property UIImageView *avatarView;
@property UILabel *titleLabel;

@property (readonly) TUICommonContactSelectCellData *selectData;

- (void)fillWithData:(TUICommonContactSelectCellData *)selectData;

@end

NS_ASSUME_NONNULL_END
