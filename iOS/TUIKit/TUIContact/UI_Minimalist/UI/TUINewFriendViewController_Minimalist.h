
#import <UIKit/UIKit.h>
#import "TUICommonPendencyCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】好友申请界面（TUINewFriendViewController）
 * 【功能说明】负责拉取好友申请信息，并在界面中显示。
 *  通过本界面，您可以查看自己收到的好友请求，并进行同意/拒绝申请的操作。
 *
 * 【Module name】The interface that displays the received friend request (TUINewFriendViewController)
 * 【Function description】Responsible for pulling friend application information and displaying it in the interface.
 *  Through this interface, you can view the friend requests you have received, and perform the operations of agreeing/rejecting the application.
 */
@interface TUINewFriendViewController_Minimalist : UIViewController

@property (nonatomic) void (^cellClickBlock)(TUICommonPendencyCell_Minimalist *cell);

@end

NS_ASSUME_NONNULL_END
