/******************************************************************************
 *
 *  本文件声明用于实现消息单元的模块与组件。
 *  消息单元（TUIMessageCell），即在聊天视图内显示的气泡消息/图片消息/表情消息/视频消息等的总称。
 *  上述消息，都是通过继承于本类或者本类的子类来实现。
 *  如果您想实现 TUIKit 中未支持的消息类型，即自定义消息，也需要通过继承于本类或者本类的子类进行实现。
 *  XXXX消息单元（TUIXXXXMessageCell）主要负责在页面上的显示和用户交互事件的响应。消息单元内的数据处理与获取，请根据具体消息单元参考 Section\Chat\CellData\TUIXXXXMessageCellData.h
 *
 *  TMessageCellDelegate 协议提供的的交互回调包括：长按、重发、点击消息、点击头像等。
 *  TUIMessageCell 类存储了消息相关的各类信息，比如：发送者头像、发送者昵称、消息内容（支持文本、图片、视频等各种格式）等。
 *  同时，消息单元作为多种细化消息的父类，提供了各类消息单元属性与行为的基本模板。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIMessageCellData.h"

@class TUIMessageCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                              TMessageCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TMessageCellDelegate <NSObject>

/**
 *  长按消息回调
 *  您可以通过该回调实现：在被长按的消息上方弹出删除、撤回（消息发送者长按自己消息时）等二级操作。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onLongPressMessage:(TUIMessageCell *)cell;

/**
 *  重发消息点击回调。
 *  在您点击重发图像（retryView）时执行的回调。
 *  您可以通过该回调实现：对相应的消息单元对应的消息进行重发。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onRetryMessage:(TUIMessageCell *)cell;

/**
 *  点击消息回调
 *  通常情况下：点击声音消息 - 播放；点击文件消息 - 打开文件；点击图片消息 - 展示大图；点击视频消息 - 播放视频。
 *  通常情况仅对函数实现提供参考作用，您可以根据需求个性化实现该委托函数。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onSelectMessage:(TUIMessageCell *)cell;

/**
 *  点击消息单元中消息头像的回调
 *  您可以通过该回调实现：响应用户点击，跳转到相应用户的详细信息界面。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onSelectMessageAvatar:(TUIMessageCell *)cell;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMessageCell
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIMessageCell
 * 【功能说明】用于实现聊天窗口中的消息单元。
 *  消息单元类存储了消息相关的各类信息，比如：发送者头像、发送者昵称、消息内容（支持文本、图片、视频等各种格式）等。
 *  消息单元能够相应用户的多种交互动作。
 *  同时，消息单元作为多种细化消息的父类，提供了各类消息单元属性与行为的基本模板。
 */
@interface TUIMessageCell : TCommonTableViewCell

/**
 * 消息选中图标
 * 多选场景中用来标识是否选中消息
 */
@property (nonatomic, strong) UIImageView *selectedIcon;

/**
 * 消息选择视图
 * 当激活多选时，该视图会覆盖在这个cell上，点击该视图会触发消息的选中/取消选中
 */
@property (nonatomic, strong) UIButton *selectedView;

/**
 *  头像视图
 */
@property (nonatomic, strong) UIImageView *avatarView;

/**
 *  昵称标签
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  容器视图。
 *  包裹了 MesageCell 的各类视图，作为 MessageCell 的“底”，方便进行视图管理与布局。
 */
@property (nonatomic, strong) UIView *container;

/**
 *  活动指示器。
 *  在消息发送中提供转圈图标，表明消息正在发送。
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

/**
 *  重发视图。
 *  在发送失败后显示，点击该视图可以触发 onRetryMessage: 回调。
 */
@property (nonatomic, strong) UIImageView *retryView;

/**
 *  信息数据类。
 *  存储了该massageCell中所需的信息。包括发送者 ID，发送者头像、信息发送状态、信息气泡图标等。
 *  messageData 详细信息请参考：Section\Chat\CellData\TUIMessageCellData.h
 */
@property (readonly) TUIMessageCellData *messageData;

/**
 *  消息已读控件
 */
@property (nonatomic, strong) UILabel *readReceiptLabel;

/**
 * 消息时间标签控件，默认不显示，位于消息 cell 的最右侧
 * 在消息转发场景下，打开转发的消息列表，会在消息的最右侧显示当前消息的时间。
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 * 是否禁用封装在 TUIKit 内部的默认的选中行为，如群直播默认创建直播间等行为，默认：NO
 */
@property (nonatomic, assign) BOOL disableDefaultSelectAction;

/**
 *  协议委托
 *  负责实现 TMessageCellDelegate 协议中的功能。
 */
@property (nonatomic, weak) id<TMessageCellDelegate> delegate;

/**
 *  单元填充函数
 *  根据data填充消息单元
 *
 *  @param  data 填充数据源
 */
- (void)fillWithData:(TCommonCellData *)data;

/**
 * 设置匹配到关键字后的高亮效果，主要用于消息搜索后跳转，子类重写
 * 基类提供默认高亮效果，子类可自由实现
 *
 * @param keyword 高亮关键字
 */
- (void)highlightWhenMatchKeyword:(NSString *)keyword;

@end
