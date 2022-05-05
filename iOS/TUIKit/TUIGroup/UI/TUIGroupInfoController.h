/******************************************************************************
 *
 *  本文件声明了 TUIGroupInfoControllerDelegate 协议和 TUIGroupInfoController 类。
 *  TUIGroupInfoControllerDelegate 协议负责实现在群控制器内的事件回调，此处的事件有用户交互的回调（选中了某一群成员等），也有信息更新回调（添加/删除群成员、解散/退出群组等）。
 *  TUIGroupInfoController 则存放了群组 ID 等信息，并负责群组信息管理的一系列业务逻辑运算。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

@class TUIGroupInfoController;
@class TUIGroupMemberCellData;
@class V2TIMGroupInfo;

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
 *  信息更新
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupInfo 获取群信息。
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupMembers 获取群信息。
 *  第一个接口拉取的群信息中，包含群头像、群主、创建时间、群介绍、加群方式、群类型等，但不包含群成员信息。所以通过第二个接口拉取群成员信息。
 *  在拉取信息成功之后，本函数会将拉取到的信息正确设置并显示在控制器视图中。
 */
- (void)updateData;
- (void)updateGroupInfo;
@end
