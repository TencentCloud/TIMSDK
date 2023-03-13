#import <UIKit/UIKit.h>
#import "TUICommonContactCellData_Minimalist.h"
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactCell_Minimalist : TUICommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;

// The icon of indicating the user's online status
@property (nonatomic, strong) UIImageView *onlineStatusIcon;

@property (readonly) TUICommonContactCellData_Minimalist *contactData;

@property (nonatomic, strong) UIView *separtorView;

- (void)fillWithData:(TUICommonContactCellData_Minimalist *)contactData;

@end

NS_ASSUME_NONNULL_END
