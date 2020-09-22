/******************************************************************************
 *
 *  本文件实现了 TGroupMemberControllerDelegagte 协议和 TUIGroupMemberController 类。
 *  TGroupMemberControllerDelegagte 协议负责实现成员控制器内的时间响应回调，包括添加群成员、删除群成员、取消操作。
 *  TUIGroupMemberController 提供了群成员的视图管理器，能够使用户快速浏览群内成员，同时能使群管理对群成员进行添加、删除等操作。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIGroupMembersView.h"

@class TUIGroupMemberController;


/////////////////////////////////////////////////////////////////////////////////
//
//                     TGroupMemberControllerDelegagte
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TGroupMemberControllerDelegagte <NSObject>

/**
 *  在群成员管理界面点击添加群成员的回调。
 *  群信息界面点击“+”也有类似的回调，但本回调的对应的控制器为群成员控制器，在使用该回调时请注意二者的差别。
 *  您可以通过本回调实现：跳转到相应的 UI 界面进行群成员的添加操作。
 *  当您准备添加群成员时，传入的 members 参数，为您的联系人信息，即您只能邀请您的联系人加入群组。
 */
- (void)groupMemberController:(TUIGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;

/**
 *  在群成员管理界面点击删除群成员的回调。
 *  群信息界面点击“-”也有类似的回调，但本回调的对应的控制器为群成员控制器，在使用该回调时请注意二者的差别。
 *  您可以通过本回调实现：跳转到相应的 UI 界面进行群成员的删除操作。
 *  当您准备删除群成员时，传入的 members 参数，为群组内的群员信息，即只有群内的成员才可以被删除
 */
- (void)groupMemberController:(TUIGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members;

/**
 *  取消本次群成员管理操作的回调。
 *  您可以通过本回调实现：（取消本次操作）返回上一级界面。
 */
- (void)didCancelInGroupMemberController:(TUIGroupMemberController *)controller;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMemberController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TGroupMemberCell
 * 【功能说明】群成员单元，作为在 collectionView 中的显示单元。
 *  负责显示群成员信息，同时作为用户点击操作的响应单元。
 */
@interface TUIGroupMemberController : UIViewController

/**
 *  群成员视图
 *  用于在控制器内显示群内成员信息，以 collectionView 的形式对群成员进行展示，同时能够响应用户的点击操作。
 *  详细信息请参考 Section\Group\TUIGroupMembersView.h
 */
@property (nonatomic, strong) TUIGroupMembersView *groupMembersView;

/**
 *  群组 ID
 *  当前群成员管理器对应群组的群 ID。
 */
@property (nonatomic, strong) NSString *groupId;

/**
 *  委托类，负责实现 TGroupMemberControllerDelegagte 协议中的委托。
 */
@property (nonatomic, weak) id<TGroupMemberControllerDelegagte> delegate;

/**
 *  更新群成员视图管理器数据
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupInfo 获取群信息。
 *  本函数通过 IM SDK 中的 TIMGroupManager 类提供的 getGroupMembers 获取群信息。
 *  第一个接口拉取的群信息中，包含群头像、群主、创建时间、群介绍、加群方式、群类型等，但不包含群成员信息。所以通过第二个接口拉取群成员信息。
 *  在拉取信息成功之后，本函数会将拉取到的信息正确设置并显示在控制器视图中。
 */
- (void)updateData;
@end
