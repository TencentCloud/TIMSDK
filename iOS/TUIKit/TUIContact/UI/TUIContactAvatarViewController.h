#import <UIKit/UIKit.h>
#import "TUICommonContactProfileCardCell.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  头像大图的显示界面
 *  本类的整体逻辑与图片消息的大图显示界面类似。
 */
@interface TUIContactAvatarViewController : UIViewController

@property (nonatomic, strong) TUICommonContactProfileCardCellData *avatarData;

@end

NS_ASSUME_NONNULL_END
