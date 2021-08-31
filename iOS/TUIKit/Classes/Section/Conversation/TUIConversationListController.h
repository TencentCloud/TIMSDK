/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 消息列表组件。
 *
 * 本文件声明了消息列表的视图组件。
 * 消息列表组件能够按照新消息发来时间顺序（越新的消息排序越靠前），展示各个会话的简要信息。
 * 消息列表所展示的会话信息包括：
 * 1、头像信息（用户头像/群头像）
 * 2、会话标题（用户昵称/群名称）
 * 3、会话消息概览（展示最新的一条的消息内容）
 * 4、未读消息数（若有未读消息的话）
 * 5、会话时间（最新消息的收到/发出时间）
 * 消息列表中展示的会话信息，由 TUIConversationCell 具体实现。详细信息请参考 Section\Conversation\Cell\TUIConversationCell.h
 *
 ******************************************************************************/


#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TConversationListViewModel.h"
#import "THeader.h"
@class TUISearchBar;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUISearchType) {
    TUISearchTypeContact     = 0,    // 联系人搜索
    TUISearchTypeGroup       = 1,    // 群聊搜索
    TUISearchTypeChatHistory = 2     // 聊天记录搜索
};


@class TUIConversationListController;

/////////////////////////////////////////////////////////////////////////////////
//
//                  TUIConversationListControllerListener
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIConversationListControllerListener <NSObject>

/**
 *  在会话列表中，获取会话展示信息时候回调。
 *
 *  @param conversation 会话单元数据
 */
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation;

/**
 *  在会话列表中，点击了具体某一会话后的回调。
 *  您可以通过该回调响应用户的点击操作，跳转到该会话对应的聊天界面。
 *
 *  @param conversationController 委托者，当前所在的消息列表。
 *  @param conversationCell 被选中的会话单元
 */
- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversationCell;

/**
 *  全局搜索中，点击了某个具体的搜索项
 *  您可以通过该回调响应用户的点击操作，根据搜索类型跳转到对应界面。
 *
 *  @param searchVC 当前的搜索页面，可通过该页面的导航控制器跳转
 *  @param searchType 点击的搜索类型
 *  @param searchItem 点击的搜索数据类型，联系人-V2TIMFriendInfo，群聊-V2TIMGroupInfo，聊天记录-V2TIMMessage
 *  @param conversationCellData 附加的会话cellData，TUIKit 已经为您构造好了，方便您直接跳转到聊天页面
 */
- (void)searchController:(UIViewController *)searchVC
                withKey:(NSString *)searchKey
           didSelectType:(TUISearchType)searchType
                    item:(NSObject *)searchItem
    conversationCellData:(TUIConversationCellData *)conversationCellData;
@end

/**
 * 【模块名称】消息列表界面组件（TUIConversationListController）
 *
 * 【功能说明】负责按消息的接收顺序展示各个会话，同时响应用户的操作，为用户提供多会话的管理功能。
 *  消息列表所展示的会话信息包括：
 *  1、头像信息（用户头像/群头像）
 *  2、会话标题（用户昵称/群名称）
 *  3、会话消息概览（展示最新的一条的消息内容）
 *  4、未读消息数（若有未读消息的话）
 *  5、会话时间（最新消息的收到/发出时间）
 */
@interface TUIConversationListController : UIViewController

/**
 *  消息列表。
 *  消息列表控制器通过 UITableView 的形式实现会话的统一展示。
 *  UITableView 同时能够提供各个单元的删除、点击响应等管理操作。
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  全局搜索条
 */
@property (nonatomic, strong) TUISearchBar *searchBar;

/**
 *  委托类，负责实现 TUIConversationListControllerListener 的委托函数。（已废弃，请使用 TUIKitListenerManager -> addConversationListControllerListener 方法监听）
 */
//@property (nonatomic, weak) id<TUIConversationListControllerListener> delegate;

/**
 *  消息列表的视图模型
 *  视图模型能够协助消息列表界面实现数据的加载、移除、过滤等多种功能。替界面分摊部分的业务逻辑运算。
 */
@property (nonatomic, strong) TConversationListViewModel *viewModel;

/**
 * 是否显示搜索条，默认显示搜索条
 */
@property (nonatomic, assign) BOOL showSearchBar;

@end

NS_ASSUME_NONNULL_END
