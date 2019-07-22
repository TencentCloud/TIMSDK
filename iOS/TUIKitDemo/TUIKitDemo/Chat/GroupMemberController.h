/** 腾讯云IM Demo 群成员管理视图
 *  本文件实现了群成员管理视图，在管理员进行群内人员管理时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import <UIKit/UIKit.h>

@interface GroupMemberController : UIViewController
@property (nonatomic, strong) NSString *groupId;
@end
