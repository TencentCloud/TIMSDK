/******************************************************************************
 *
 *  腾讯云通讯服务界面组件 TUIKIT - 好友信息视图界面
 *
 *  本文件实现了好友简介视图控制器，只在显示好友时使用该视图控制器。
 *  若要显示非好友的用户信息，请查看 TUIUserProfileController.h
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TUIFriendProfileController : UITableViewController

/**
 *  本属性为 IM SDK 中声明的类。
 *  包括好友 ID、好友备注、好友的用户信息等。
 */
@property (nonatomic, strong) V2TIMFriendInfo *friendProfile;

@end

NS_ASSUME_NONNULL_END
