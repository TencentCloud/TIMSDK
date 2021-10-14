
#import <Foundation/Foundation.h>
@class TUIMessageController;
@class TUIMessageCellData;
@class TUIMessageCell;

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                         TMessageControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMessageControllerDelegate <NSObject>

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
 *  cell将要显示事件
 *  @param controller 委托者，消息控制器
 *  @param cell 即将显示的消息Cell
 *  @param cellData 即将显示的消息单元的数据源。
 */
- (void)messageController:(TUIMessageController *)controller willDisplayCell:(TUIMessageCell *)cell withData:(TUIMessageCellData *)cellData;

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

@end

NS_ASSUME_NONNULL_END
