
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactSelectCellData_Minimalist : TUICommonContactSelectCellData

@end
@interface TUICommonContactSelectCell_Minimalist : TUICommonTableViewCell

@property UIButton *selectButton;
@property UIImageView *avatarView;
@property UILabel *titleLabel;

@property (readonly) TUICommonContactSelectCellData_Minimalist *selectData;

- (void)fillWithData:(TUICommonContactSelectCellData_Minimalist *)selectData;

@end

NS_ASSUME_NONNULL_END
