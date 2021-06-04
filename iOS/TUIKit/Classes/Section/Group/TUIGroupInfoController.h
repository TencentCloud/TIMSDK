/******************************************************************************
 *
 *  本文件声明了 TGroupInfoControllerDelegate 协议和 TUIGroupInfoController 类。
 *  TGroupInfoControllerDelegate 协议负责实现在群控制器内的事件回调，此处的事件有用户交互的回调（选中了某一群成员等），也有信息更新回调（添加/删除群成员、解散/退出群组等）。
 *  TUIGroupInfoController 则存放了群组 ID 等信息，并负责群组信息管理的一系列业务逻辑运算。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@class TUIGroupInfoController;
@class TGroupMemberCellData;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIChatControllerListener
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TGroupInfoControllerDelegate <NSObject>

/**
 *  当您在群组信息内点击“群成员”按钮，出发该回调。
 *  您可以通过该回调实现：跳转到群成员视图，同意展示当前群组内的群成员。
 *
 *  @param controller 委托者，即当前的群组信息控制器。
 *  @param groupId 群组 ID，当前群组信息控制器对应的群组 ID，同时也是被点击的成员所在群的群 ID。
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId;

/**
 *  点击群组信息视图内“+”按钮添加群成员时的回调。
 *  您可以通过该回调实现：跳转到相应的 UI 界面进行群成员的添加操作。
 *  当您准备添加群成员时，传入的 members 参数，为您的联系人信息，即您只能邀请您的联系人加入群组。
 *
 *  @param controller 委托者，即当前的群组信息控制器。
 *  @param members 群成员信息数据源，群组内存放的对象为（TGroupMemberCellData）
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members;

/**
 *  点击群组信息视图内“-”删除添加群成员时的回调。
 *  您可以通过该回调实现：跳转到相应的 UI 界面进行群成员的删除操作。
 *  当您准备删除群成员时，传入的 members 参数，为群组内的群员信息，即只有群内的成员才可以被删除。
 *
 *  @param controller 委托者，即当前的群组信息控制器。
 *  @param members 群成员信息数据源，群组内存放的对象为（TGroupMemberCellData）
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members;

/**
 *  删除群组成功后的回调。如果因为网络等各种原因删除失败，该回调不会被调用。
 *  您可以通过该回调实现：（删除成功后）退出当前群组页面，返回消息列表。
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteGroup:(NSString *)groupId;

/**
 *  退出群组成功后的回调。如果因为网络等各种原因退群失败，该回调不会被调用。
 *  您可以通过该回调实现：（退出成功后）退出当前群组页面，返回消息列表。
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didQuitGroup:(NSString *)groupId;
/**
 *  选择修改头像的调用。
 *  如果没有实现改回调，则不会显示修改头像的对话框入口
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectChangeAvatar:(NSString *)groupId;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupInfoController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIGroupInfoController
 * 【功能说明】群组信息控制器，即群组详细信息的视图控制器。
 *  通过本控制器，您可以浏览群组的详细信息，包括群名称、群头像、群成员、加群方式。
 *  如果作为群所有者或者群管理员的话，您还可以对以上信息进行修改与设置。
 *  同时，群管理员也可以通过本控制器添加/删除群成员。
 */
@interface TUIGroupInfoController : UITableViewController

/**
 *  群组 ID，当前群组信息所属的群 ID。
 *  请注意：群组名称和群组 ID 有所区别， 此处为群组 ID，是 IM SDK 定位群组的标识。
 */
@property (nonatomic, strong) NSString *groupId;

/**
 *  协议委托，负责实现上文中说明的 TUIChatControllerListener。
 */
@property (nonatomic, weak) id<TGroupInfoControllerDelegate> delegate;

/**
 *  信息更新
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupInfo 获取群信息。
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupMembers 获取群信息。
 *  第一个接口拉取的群信息中，包含群头像、群主、创建时间、群介绍、加群方式、群类型等，但不包含群成员信息。所以通过第二个接口拉取群成员信息。
 *  在拉取信息成功之后，本函数会将拉取到的信息正确设置并显示在控制器视图中。
 */
- (void)updateData;
@end
