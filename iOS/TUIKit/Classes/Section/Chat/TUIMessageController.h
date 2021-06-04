/******************************************************************************
 *
 *  本文件声明了用于实现消息收发逻辑的控制器类。
 *  消息控制器负责统一显示您发送/收到的消息，同时在您对这些消息进行交互（点击/长按等）时提供响应回调。
 *  消息控制器还负责对您发送的消息进行统一的数据处理，使其变为可以通过 IM SDK 发送的数据格式并进行发送。
 *  也就是说，当您使用本控制器时，您可以省去很大部分的数据处理上的工作，从而能够更快捷、更方便的接入 IM SDK。
 *
 *  TMessageControllerDelegate 协议和 TUIMessageController 类。
 *  TUIMessageController 是聊天界面的核心类，负责聊天界面大部分核心业务逻辑的处理与运算。
 *  该类的详细属性与功能，请参展本文件中 TUIMessageController 的具体声明。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIMessageCell.h"


@class TUIConversationCellData;
@class TUIMessageController;

typedef NS_ENUM(NSInteger, TUIMultiResultOption) {
    TUIMultiResultOptionAll     = 0,                            // 获取所有选中的结果
    TUIMultiResultOptionFiterUnsupportRelay = 1 << 0,           // 过滤掉不支持转发
};

/////////////////////////////////////////////////////////////////////////////////
//
//                         TMessageControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 我们不建议您直接修改 MessageController 中的回调委托。
 * MessageController 的回调委托在 ChatController 中实现，负责大部分核心功能。如果您对此修改，可能会对一系列回调委托的调用关系造成破坏。
 * 如果您需要实现 onNewMessage、onShowMessageData 的回调，您可以参照 Section\Chat\TUIChatController.h 中的链接与注释进行调用并实现自定义消息处理。
 */
@protocol TMessageControllerDelegate <NSObject>

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 *
 *  @param controller 委托者，消息控制器
 */
- (void)didTapInMessageController:(TUIMessageController *)controller;

/**
 *  隐藏长按菜单后的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 */
- (void)didHideMenuInMessageController:(TUIMessageController *)controller;

/**
 *  显示长按菜单前的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 *  @param view 控制器所在view
 */
- (BOOL)messageController:(TUIMessageController *)controller willShowMenuInCell:(UIView *)view;

/**
 *  收到新消息的函数委托
 *  您可以通过该回调实现：根据传入的 data 初始化新消息并进行新消息提醒。
 *
 *  @param controller 委托者，消息控制器
 *  @param data 新消息
 *
 *  @return 返回需要显示的新消息单元。该消息单元的信息与数据，来自于参数中的 data 参数。
 */
- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(V2TIMMessage *)data;

/**
 *  显示消息数据委托
 *  您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
 *
 *  @param controller 委托者，消息控制器
 *  @param data 需要显示的消息数据
 *
 *  @return 返回需要显示的消息单元。该消息单元的信息与数据，来自于参数中的 data 参数。
 */
- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data;

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 *  1、首先拉取用户信息，如果该用户是当前使用者好友，则初始化相应的好友信息界面并进行跳转。
 *  2、如果该用户不是当前使用者好友，则初始化相应的添加好友界面并进行跳转。
 *
 *  @param controller 委托者，消息控制器
 *  @param cell 所点击的消息单元
 */
- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  点击消息内容委托
 *
 *  @param controller 委托者，消息控制器
 *  @param cell 所点击的消息单元
 */
- (void)messageController:(TUIMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell;

/**
 * 长按消息内容弹窗菜单栏，点击菜单选项
 *
 * @param controller 委托者，消息控制器
 * @param menuType 点击的菜单类型，支持的类型: 0 - 多选；1 - 转发。
 * @param data 当前长按的消息数据
 */
- (void)messageController:(TUIMessageController *)controller onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data;
/**
 *  点击入群消息中用户名称时的回调委托。例如：“小明加入群组”，本回调在用户点击“小明”时触发。
 *
 *  @param controller 委托者，消息控制器
 *  @param cell 所点击的入群消息单元
 */
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIMessageController
//
/////////////////////////////////////////////////////////////////////////////////

/** 腾讯云 TUIKit
 * 【模块名称】TUIMessageController
 * 【功能说明】消息控制器，负责实现消息的接收、发送、显示等一系列业务逻辑。
 *  本类提供了接收/显示新消息、显示/隐藏菜单、点击消息头像等交互操作的回调接口。
 *  同时本类提供了图像、视频、文件信息的发送功能，直接整合调用了 IM SDK 实现发送功能。
 */
@interface TUIMessageController : UITableViewController

/**
 *  执行 TMessageControllerDelegate 协议的委托
 */
@property (nonatomic, weak) id<TMessageControllerDelegate> delegate;
/**
 *  发送消息
 *  本函数整合调用了 IM SDK 的发送接口，可以轻松接入 SDK。
 *
 *  @param msg 消息单元数据
 */
- (void)sendMessage:(TUIMessageCellData *)msg;

/**
 *  转发消息
 *  本函数整合调用了 IM SDK 的消息转发接口，可以轻松接入 SDK。
 *
 *  @param msg 消息单元数据
 */
- (void)forwardMessage:(TUIMessageCellData *)msg;

/**
 *  滚动至底部
 *  通过对 tableView 进行设置，使当前视图滚动至底部。
 *  建议在需要返回至消息视图底部或者需要浏览最新信息时调用，比如每次发送消息、接收消息、撤回消息、删除消息时。
 *  本函数的实现调用了 tableView 的滑动函数：
 * <pre>
 *  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:uiMsgs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
 * </pre>
 *  其中第一个参数出现的 uiMsgs，即当前消息控制器中已接收到并展示的消息数组。
 *
 *  @param animate 动画标志位。YES：启用动画；NO：禁用动画。
 */
- (void)scrollToBottom:(BOOL)animate;

/**
 *  设置会话
 *
 */
- (void)setConversation:(TUIConversationCellData *)conversationData;

/**
 * 开启多选模式
 *
 * @param enable 是否开启多选模式
 */
- (void)enableMultiSelectedMode:(BOOL)enable;

/**
 * 开启多选模式后，获取当前选中的结果
 * 如果多选模式关闭，返回空数组
 *
 * @param option 获取结果的选项
 * @return 选中的数据
 */
- (NSArray<TUIMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option;

/**
 * 批量删除消息
 *
 * @param uiMsgs 待删除的数据
 */
- (void)deleteMessages:(NSArray<TUIMessageCellData *> *)uiMsgs;

#pragma mark - public属性及方法，子类及扩展类可用，主要用于V2TUIMessageController
/**
 * 用来显示时间cell
 */
@property (nonatomic, strong) V2TIMMessage *msgForDate;
/**
 * 是否第一次加载
 */
@property (nonatomic, assign) BOOL firstLoad;

/**
 * 当前会话信息
 */
@property (nonatomic, strong) TUIConversationCellData *conversationData;

/**
 * 当前数据源
 */
@property (nonatomic, strong) NSMutableArray *uiMsgs;

/**
 * 当前cell高度缓存
 */
@property (nonatomic, strong) NSMutableArray *heightCache;

/**
 * 下拉指示器
 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

/**
 * 批量将V2TIMessage转换成TUIMessageCellData
 */
- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs;

/**
 * 没有更多消息
 */
@property (nonatomic, assign) BOOL noMoreMsg;

@end
