/******************************************************************************
 *
 *  本文件声明了 TUIMessageCellData 类。
 *  消息单元数据源作为多种细化数据源的父类，提供了各类消息单元数据源属性与行为的基本模板。
 *  本文件中的数据源类是所有消息数据的基类，各个类型的数据源都继承与本类或者本类的子类。
 *  当您想要自定义消息时，也许将自定义消息的数据源继承于本类或者本类的子类。
 *
 ******************************************************************************/
#import "TCommonCell.h"
#import "TUIMessageCellLayout.h"
#import "THeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);

/**
 *  消息状态枚举
 */
typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Init, //消息创建
    Msg_Status_Sending, //消息发送中
    Msg_Status_Sending_2, //消息发送中_2，推荐使用
    Msg_Status_Succ, //消息发送成功
    Msg_Status_Fail, //消息发送失败
};

/**
 *  消息方向枚举
 *  消息方向影响气泡图标、气泡位置等 UI 风格。
 */
typedef NS_ENUM(NSUInteger, TMsgDirection) {
    MsgDirectionIncoming, //消息接收
    MsgDirectionOutgoing, //消息发送
};

/**
 * 【模块名称】TUIMessageCellData
 * 【功能说明】聊天消息单元数据源，配合消息控制器实现消息收发的业务逻辑。
 *  用于存储消息管理与逻辑实现所需要的各类数据与信息。包括消息状态、消息发送者 ID 与头像等一系列数据。
 *  同时信息数据单元整合并调用了 IM SDK，能够通过 SDK 提供的接口实现消息的业务逻辑。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUIMessageCellData : TCommonCellData

// 消息唯一 ID
@property (nonatomic, strong) NSString *msgID;

/**
 *  信息发送者 ID
 */
@property (nonatomic, strong) NSString *identifier;

/**
 *  信息发送者头像 url
 */
@property (nonatomic, strong) NSURL * __nullable avatarUrl;

/**
 *  信息发送者头像图像
 */
@property (nonatomic, strong) UIImage *__nullable avatarImage;

/**
 *  信息发送者昵称
 *  昵称与 ID 不一定相同，在聊天界面默认展示昵称。
 */
@property (nonatomic, strong) NSString *name;

/**
 *  名称展示 flag
 *  好友聊天时，默认不在消息中展示昵称。
 *  群组聊天时，对于群组内其他用户发送的信息，展示昵称。
 *  YES：展示昵称；NO：不展示昵称。
 */
@property (nonatomic, assign) BOOL showName;

/**
 * 显示消息多选flag
 * 消息列表中，默认不显示选择按钮，当长按消息弹出多选按钮并点击后，消息列表变为可多选状态
 * YES: 可多选，展示多选视图；NO:不可多选，展示默认视图
 */
@property (nonatomic, assign) BOOL showCheckBox;

/**
 * 显示是否选中 flag
 */
@property (nonatomic, assign) BOOL selected;

/**
 *  消息 @ 用户列表
 */
@property (nonatomic, strong) NSMutableArray<NSString *>*atUserList;

/**
 *  消息方向
 *  消息方向影响气泡图标、气泡位置等 UI 风格。
 *  MsgDirectionIncoming 消息接收
 *  MsgDirectionOutgoing 消息发送
 */
@property TMsgDirection direction;

/**
 *  消息状态
 *  Msg_Status_Init 消息创建
 *  Msg_Status_Sending 消息发送中
 *  Msg_Status_Sending_2 消息发送中_2，推荐使用
 *  Msg_Status_Succ 消息发送成功
 *  Msg_Status_Fail 消息发送失败
 */
@property (nonatomic, assign) TMsgStatus status;

/**
 *  内层消息
 *  IM SDK 提供的消息对象。内含各种获取消息信息的成员函数，包括获取优先级、获取元素索引、获取离线消息配置信息等。
 *  详细信息请参考 TXIMSDK_iOS\Frameworks\ImSDK.framework\Headers\TIMMessage.h
 */
@property (nonatomic, strong) V2TIMMessage *innerMessage;

/**
 *  昵称字体
 *  当需要显示昵称时，从该变量设置/获取昵称字体。
 */
@property UIFont *nameFont;

/**
 *  昵称颜色
 *  当需要显示昵称时，从该变量设置/获取昵称颜色。
 */
@property UIColor *nameColor;

/**
 *  接收时昵称颜色
 *  当需要显示昵称，且消息 direction 为 MsgDirectionIncoming 时使用
 */
@property (nonatomic, class) UIColor *incommingNameColor;

/**
 *  接收时昵称字体
 *  当需要显示昵称，且消息 direction 为 MsgDirectionIncoming 时使用
 */
@property (nonatomic, class) UIFont *incommingNameFont;


/**
 *  发送时昵称颜色
 *  当需要显示昵称，且消息 direction 为 MsgDirectionOutgoing 时使用。
 */
@property (nonatomic, class) UIColor *outgoingNameColor;

/**
 *  发送时昵称字体
 *  当需要显示昵称，且消息 direction 为 MsgDirectionOutgoing 时使用。
 */
@property (nonatomic, class) UIFont *outgoingNameFont;

/**
 *  消息单元布局
 *  包括消息边距、气泡内边距、头像边距、头像大小等 UI 布局。
 *  详细信息请参考 Section\Chat\CellLayout\TUIMessageCellLayout.h
 */
@property TUIMessageCellLayout *cellLayout;

/**
* 是否显示已读回执
*/
@property (nonatomic, assign) BOOL showReadReceipt;

/**
* 是否显示消息时间
*/
@property (nonatomic, assign) BOOL showMessageTime;

/**
 * 高亮关键字，当改关键字不为空时，会短暂高亮显示，主要用在消息搜索场景中
 */
@property (nonatomic, copy) NSString * __nullable highlightKeyword;

/**
 *  内容大小
 *  返回一个气泡内容的视图大小。
 */
- (CGSize)contentSize;

/**
 *  根据消息方向（收/发）初始化消息单元
 *  除了基本消息的初始化外，还包括根据方向设置方向变量、昵称字体等。
 *  同时为子类提供可继承的行为。
 *
 *  @param direction 消息方向。MsgDirectionIncoming：消息接收；MsgDirectionOutgoing：消息发送。
 */
- (instancetype)initWithDirection:(TMsgDirection)direction;

@end

NS_ASSUME_NONNULL_END
