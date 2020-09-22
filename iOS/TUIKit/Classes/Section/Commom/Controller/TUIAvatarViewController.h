#import <UIKit/UIKit.h>
#import "TCommonAvatarCell.h"
#import "TUIProfileCardCell.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  头像大图的显示界面
 *  本类的整体逻辑与图片消息的大图显示界面类似。
 */
@interface TUIAvatarViewController : UIViewController

@property (nonatomic, strong) TUIProfileCardCellData *avatarData;

@end

NS_ASSUME_NONNULL_END
