
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  本文件声明用于实现消息单元的模块与组件。
 *  消息单元（TUIMessageCell），即在聊天视图内显示的气泡消息/图片消息/表情消息/视频消息等的总称。
 *  上述消息，都是通过继承于本类或者本类的子类来实现，如果您想自定义消息，也需要通过继承于本类或者本类的子类进行实现。
 *  XXXX消息单元（TUIXXXXMessageCell）主要负责在页面上的显示和用户交互事件的响应。消息单元内的数据处理与获取，请根据具体消息单元参考
 * TUIChat\CellData\TUIXXXXMessageCellData.h
 *
 *  TUIMessageCellDelegate 协议提供的的交互回调包括：长按、重发、点击消息、点击头像等。
 *  TUIMessageCell 类存储了消息相关的信息，比如：发送者头像、发送者昵称、消息内容（支持文本、图片、视频等各种格式）等。
 *  同时，TUIMessageeCell 作为父类，为子类消息提供了基础属性和行为模板。
 *
 *  This document declares the modules and components used to implement the message unit.
 *  The message unit (TUIMessageCell) is a general term for the bubble message/picture message/emoticon message/video message displayed in the chat view.
 *  The above messages are implemented by inheriting from this class or a subclass of this class. If you want to customize the message, you also need to
 * implement it by inheriting from this class or a subclass of this class. The XXXX message unit (TUIXXXXMessageCell) is mainly responsible for displaying on
 * the page and responding to user interaction events. For data processing and acquisition in the message unit, please refer to
 * TUIChat\CellData\TUIXXXXMessageCellData.h according to the specific message unit
 *
 *  The interaction callbacks provided by the TUIMessageCellDelegate protocol include: long press, resend, click on the message, click on the avatar, etc.
 *  The TUIMessageCell class stores message-related information, such as the sender's avatar, sender's nickname, and message content (supports various formats
 * such as text, pictures, and videos). At the same time, TUIMessageeCell, as a parent class, provides basic properties and behavior templates for subclass
 * messages.
 */

#import <UIKit/UIKit.h>
#import "TUIFitButton.h"
#import "TUIMessageCellData.h"
#import "TUITagsModel.h"
#import "TUITagsView.h"

@class TUIMessageCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMessageCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMessageCellDelegate <NSObject>

/**
 *  长按消息的回调
 *  您可以通过该回调实现：在被长按的消息上方弹出删除、撤回（消息发送者长按自己消息时）等二级操作。
 *
 *  Callback for long press message
 *  You can use this callback to implement secondary operations such as delete and recall (when the sender of the message long-presses his own message) on top
 * of the long-pressed message.
 */
- (void)onLongPressMessage:(TUIMessageCell *)cell;

/**
 *  重发消息点击回调。
 *  在您点击重发图像（retryView）时执行的回调。
 *  您可以通过该回调实现：对相应的消息单元对应的消息进行重发。
 *
 *  Callback for clicking retryView
 *  You can use this callback to implement: resend the message.
 */
- (void)onRetryMessage:(TUIMessageCell *)cell;

/**
 *  点击消息回调
 *  通常情况下：点击声音消息 - 播放；点击文件消息 - 打开文件；点击图片消息 - 展示大图；点击视频消息 - 播放视频。
 *  通常情况仅对函数实现提供参考作用，您可以根据需求个性化实现该委托函数。
 *
 *  Callback for clicking message cell
 *  Usually:
 *  - Clicking on the sound message means playing voice
 *  - Clicking on the file message means opening the file
 *  - Clicking on the picture message means showing the larger image
 *  - Clicking on the video message means playing the video.
 *  Usually, it only provides a reference for the function implementation, and you can implement the delegate function according to your needs.
 */
- (void)onSelectMessage:(TUIMessageCell *)cell;

/**
 *  点击消息单元中消息头像的回调
 *  您可以通过该回调实现：响应用户点击，跳转到相应用户的详细信息界面。
 *
 *  Callback for clicking avatar view of the messageCell
 *  You can use this callback to implement: in response to the user's click, jump to the detailed information interface of the corresponding user.
 */
- (void)onSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  长按消息单元中消息头像的回调
 *  Callback for long pressing avatar view of messageCell
 */
- (void)onLongSelectMessageAvatar:(TUIMessageCell *)cell;

/**
 *  点击消息单元中已读标签回调
 *  Callback for clicking read receipt label
 */
- (void)onSelectReadReceipt:(TUIMessageCellData *)cell;

/**
 * 点击 x 人回复按钮 跳转到多人回复详情页
 * Clicking the x-person reply button to jump to the multi-person reply details page
 */
- (void)onJumpToRepliesDetailPage:(TUIMessageCellData *)data;

/**
 * 点击表情回复 view 跳转到表情回复详情页
 * Clicking the emoji reply view to jump to the multi-person reply details page
 */
- (void)onJumpToRepliesEmojiPage:(TUIMessageCellData *)data faceList:(NSArray<TUITagsModel *> *)listModel;

- (void)onEmojiClickCallback:(TUIMessageCellData *)data faceName:(NSString *)faceName;

- (void)onJumpToMessageInfoPage:(TUIMessageCellData *)data selectCell:(TUIMessageCell *)cell;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMessageCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMessageCell : TUICommonTableViewCell

/**
 * 消息选中图标
 * 多选场景中用来标识是否选中消息
 *
 * Icon that identifies the message selected
 * In the multi-selection scenario, it is used to identify whether the message is selected
 */
@property(nonatomic, strong) UIImageView *selectedIcon;

/**
 * 消息选择视图
 * 当激活多选时，该视图会覆盖在这个cell上，点击该视图会触发消息的选中/取消选中
 *
 * Message selection view
 * When multiple selection is activated, the view will be overlaid on this cell, and clicking on the view will trigger the check/uncheck of the message
 */
@property(nonatomic, strong) UIButton *selectedView;

/**
 *  头像视图
 *  The icon view of displays user's avatar
 */
@property(nonatomic, strong) UIImageView *avatarView;

/**
 *  昵称标签
 *  The label of displays user's displayname
 */
@property(nonatomic, strong) UILabel *nameLabel;

/**
 *  容器视图。
 *  包裹了 MesageCell 的各类视图，作为 MessageCell 的“底”，方便进行视图管理与布局。
 *
 *  Container view
 *  It wraps various views of MesageCell as the "bottom" of MessageCell, which is convenient for view management and layout.
 */
@property(nonatomic, strong) UIView *container;

/**
 *  活动指示器
 *  在消息发送的过程中提供转圈图标，表明消息正在发送。
 *
 *  Activity indicator
 *  A circling icon is provided while the message is being sent to indicate that the message is being sent.
 */
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

/**
 *  重发视图
 *  在发送失败后显示，点击该视图可以触发 onRetryMessage: 回调。
 *
 *  Retry view, displayed after sending failed, click on this view to trigger onRetryMessage: callback.
 */
@property(nonatomic, strong) UIImageView *retryView;

/**
 *  表情回复标签列表
 *
 *  Emoji reply tag list
 */
@property(nonatomic, strong) NSMutableArray<TUITagsModel *> *reactlistArr;

/**
 *  消息回复详情按钮
 *  Message reply details button
 */
@property(nonatomic, strong) TUIFitButton *messageModifyRepliesButton;

/**
 *  消息数据类。
 *  存储了该massageCell中所需的信息。包括发送者 ID，发送者头像、信息发送状态、信息气泡图标等。
 *  messageData 详细信息请参考：TUIChat\Cell\CellData\TUIMessageCellData.h
 *
 *  The message data class which stores the information required in the messageCell, including sender ID, sender avatar, message sending status, message bubble
 * icon, etc. For details of messageData, please refer to: TUIChat\Cell\CellData\TUIMessageCellData.h
 */
@property(readonly) TUIMessageCellData *messageData;

/**
 *  消息已读控件
 *
 *  A control that identifies whether a message has been read
 */
@property(nonatomic, strong) UILabel *readReceiptLabel;

/**
 * 消息时间标签控件，默认不显示，位于消息 cell 的最右侧
 * 在消息转发场景下，打开转发的消息列表，会在消息的最右侧显示当前消息的时间。
 *
 * The message time label control, which is not displayed by default, is located at the far right of the message cell
 * In the message forwarding scenario, open the forwarded message list, and the time of the current message will be displayed on the far right of the message.
 */
@property(nonatomic, strong) UILabel *timeLabel;

/**
 * 是否禁用封装在 TUIKit 内部的默认的选中行为，如群直播默认创建直播间等行为，默认：NO
 * Whether to disable the default selection behavior encapsulated in TUIKit, such as group live broadcast by default to create live room and other behaviors,
 * default: NO
 */
@property(nonatomic, assign) BOOL disableDefaultSelectAction;

@property(nonatomic, weak) id<TUIMessageCellDelegate> delegate;

/**
 * 是否正在进行高亮闪烁动画
 * Whether the highlight flashing animation is in progress
 */
@property(nonatomic, assign) BOOL highlightAnimating;

- (void)fillWithData:(TUICommonCellData *)data;

/**
 * 设置匹配到关键字后的高亮效果，主要用于消息搜索后跳转，子类重写
 * 基类提供默认高亮效果，子类可自由实现
 *
 * Set the highlighting effect after matching the keyword, mainly used for jumping after message search, subclass rewriting
 * The base class provides the default highlighting effect, and the subclass can implement it freely
 *
 * @param keyword 高亮关键字 Highlight keywords
 */
- (void)highlightWhenMatchKeyword:(NSString *)keyword;

/**
 * 返回用于高亮闪烁的 view
 * Returns the view for highlighting
 */
- (UIView *)highlightAnimateView;

/**
 * 更新已读 label 的内容
 * Update the content of the read label
 */
- (void)updateReadLabelText;

/**
 * 「表情互动消息」的容器视图
 * Container view of "Emoji Interactive Message"
 */
@property(nonatomic, strong) TUITagsView *tagView;

/**
 * 添加容器视图到 container 上
 * Add a container view to the container
 */
- (void)prepareReactTagUI:(UIView *)containerView;

/// Preset bottom container in cell, which can be added custom view/viewControllers.
@property(nonatomic, strong) UIView *bottomContainer;

/// When bottom container is layout ready, notify it to add custom extensions.
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData;

/// Callback of SelectCell
@property(nonatomic, copy) TUIValueCallbck pluginMsgSelectCallback;

@end
