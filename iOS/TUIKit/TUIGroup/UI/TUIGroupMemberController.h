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
@class V2TIMGroupInfo;

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


@property (nonatomic, strong) UITableView *tableView;

/**
 *  群组 ID
 *  当前群成员管理器对应群组的群 ID。
 */
@property (nonatomic, strong) NSString *groupId;

/*
 *  群信息
 */
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;

/**
 * 刷新数据源
 */
- (void)refreshData;

@end
