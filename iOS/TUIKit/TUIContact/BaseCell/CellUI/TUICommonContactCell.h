#import <UIKit/UIKit.h>
#import "TUICommonContactCellData.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactCell : TUICommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;

// The icon of indicating the user's online status
@property (nonatomic, strong) UIImageView *onlineStatusIcon;

@property (readonly) TUICommonContactCellData *contactData;

- (void)fillWithData:(TUICommonContactCellData *)contactData;

@end

NS_ASSUME_NONNULL_END
