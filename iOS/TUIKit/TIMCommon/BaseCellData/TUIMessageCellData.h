
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 * This file declares the TUIMessageCellData class.
 * - The "message unit" data source, as the parent class of various detailed data sources, provides basic templates for the properties and behaviors of various
 * "message unit" data sources.
 * - The "data source class" in this document is the base class for all message data, and each type of data source inherits from this class or its subclasses.
 * - When you want to customize the message, you need to inherit the data source of the customized message from this class or a subclass of this class.
 */
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIMessageCellLayout.h"
@class TUIRelationUserModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);

/**
 *  The definition of message status
 */
typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Init,       //  message initial
    Msg_Status_Sending,    //  message sending
    Msg_Status_Sending_2,  //  message sending, recommended
    Msg_Status_Succ,       //  message sent successfully
    Msg_Status_Fail,       //  Failed to send message
};

/**
 *
 *  The definition of message direction
 *  Message direction affects UI styles such as bubble icons, bubble positions, etc.
 */
typedef NS_ENUM(NSUInteger, TMsgDirection) {
    MsgDirectionIncoming,
    MsgDirectionOutgoing,
};

/**
 *
 *  The source of message
 *  Different display logic can be done according to the source of the message.
 */
typedef NS_ENUM(NSUInteger, TMsgSource) {
    Msg_Source_Unkown = 0,    // 未知
    Msg_Source_OnlinePush,    // Messages actively pushed in the background
    Msg_Source_GetHistory,    // SDK actively requests historical messages pulled from the background
};

/**
 * 【Module name】TUIMessageCellData
 * 【Function description】The data source of the chat message unit cooperates with the message controller to realize the business logic of message sending and
 * receiving.
 *  - It is used to store various data and information required for message management and logic implementation. Including a series of data such as message
 * status, message sender ID and avatar.
 *  - The chat information data unit integrates and calls the IM SDK, and can implement the business logic of the message through the interface provided by the
 * SDK.
 */
@interface TUIMessageCellData : TUICommonCellData
/**
 *  Getting cellData according to message
 */
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;

/**
 * Getting the display string according to the message
 */
+ (NSString *)getDisplayString:(V2TIMMessage *)message;

/**
 * Class to get the layout of the message reply custom reference and its data
 */
- (Class)getReplyQuoteViewDataClass;
- (Class)getReplyQuoteViewClass;

/**
 *  Message unique id
 */
@property(nonatomic, strong) NSString *msgID;

/**
 *  Message sender ID
 */
@property(nonatomic, strong) NSString *identifier;

/**
 *  Sender's avatar url
 */
@property(nonatomic, strong) NSURL *__nullable avatarUrl;

/**
 *  Sender's avatar
 */
@property(nonatomic, strong) UIImage *__nullable avatarImage __attribute__((deprecated("not supported")));

/**
 * Whether to use the receiver's avatar, default is NO
 */
@property(nonatomic, assign) BOOL isUseMsgReceiverAvatar;

/**
 *
 *  Sender's nickname
 *  The nickname and ID are not necessarily the same, and the nickname is displayed by default in the chat interface.
 */
@property(nonatomic, strong) NSString *name;

/**
 *
 *  The flag of showing name
 *  - In 1 vs 1 chat, the nickname is not displayed in the message by default.
 *  - In group chat, the nickname is displayed for messages sent by other users in the group.
 *  - YES: showing nickname;  NO: hidden nickname
 */
@property(nonatomic, assign) BOOL showName;

/**
 *  Display user avatar
 */
@property(nonatomic, assign) BOOL showAvatar;

/**
 *  Whether the current message is the same as the sender of the next message
 */
@property(nonatomic, assign) BOOL sameToNextMsgSender;

/**
 *
 * The flag of showing message multiple selection
 * - In the message list, the selection button is not displayed by default. When you long press the message to pop up the multi-select button and click it, the
 * message list becomes multi-selectable.
 * - YES: Enable multiple selection, multiple selection views are displayed; NO: Disable multiple selection, the default view is displayed.
 */
@property(nonatomic, assign) BOOL showCheckBox;

/**
 * The flag of selected
 */
@property(nonatomic, assign) BOOL selected;

/**
 * The user list in at message
 */
@property(nonatomic, strong) NSMutableArray<NSString *> *atUserList;

/**
 * Message direction
 * - Message direction affects UI styles such as bubble icons, bubble positions, etc.
 */
@property(nonatomic, assign) TMsgDirection direction;

/**
 * Message status
 */
@property(nonatomic, assign) TMsgStatus status;

/**
 * Message source
 */
@property(nonatomic, assign) TMsgSource source;

/**
 * IMSDK message
 * The Message object provided by IM SDK. Contains various member functions for obtaining message information, including obtaining priority, obtaining element
 * index, obtaining offline message configuration information, etc. For details, please refer to
 * TXIMSDK__Plus_iOS\Frameworks\ImSDK_Plus.framework\Headers\V2TIMMessage.h
 */
@property(nonatomic, strong) V2TIMMessage *innerMessage;

/**
 *  Message unit layout
 *  It includes UI information such as message margins, bubble padding, avatar margins, and avatar size.
 *  For details, please refer to Section\Chat\CellLayout\TUIMessageCellLayout.h
 */
@property(nonatomic, strong) TUIMessageCellLayout *cellLayout;

/**
 * The flag of whether showing read receipts.
 */
@property(nonatomic, assign) BOOL showReadReceipt;

/**
 * The flag of  whether showing message time.
 */
@property(nonatomic, assign) BOOL showMessageTime;

/**
 * The flag of whether showing the button which indicated how many people modiffied.
 */
@property(nonatomic, assign) BOOL showMessageModifyReplies;
/**
 * Highlight keywords, when the keyword is not empty, it will be highlighted briefly, mainly used in message search scenarios.
 */
@property(nonatomic, copy) NSString *__nullable highlightKeyword;

/**
 * Message read receipt
 */
@property(nonatomic, strong) V2TIMMessageReceipt *messageReceipt;

/**
 * List of Reply Messages for the current message
 */
@property(nonatomic, strong) NSArray *messageModifyReplies;

@property(nonatomic, assign) CGSize messageContainerAppendSize;

/// Size for bottom container.
@property(nonatomic, assign) CGSize bottomContainerSize;

/// Placeholder data, to be replaced after data preparation is completed.
@property(nonatomic, strong) TUIMessageCellData* _Nullable placeHolderCellData;

/// Video transcoding progress
@property(nonatomic, assign) CGFloat videoTranscodingProgress;

/// If cell content can be forwarded.
- (BOOL)canForward;

- (BOOL)canLongPress;

- (BOOL)shouldHide;

/// Custom cell refresh when message modified
- (BOOL)customReloadCellWithNewMsg:(V2TIMMessage *)newMessage;

/**
 *  Initialize the message unit according to the message direction (receive/sent)
 *  - In addition to the initialization of basic messages, it also includes setting direction variables, nickname fonts, etc. according to the direction.
 *  - Also provides inheritable behavior for subclasses.
 */
- (instancetype)initWithDirection:(TMsgDirection)direction NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, assign) CGSize msgStatusSize;

/**
 * TUIChat supports batch retrieval of user information except for the message sender's nickname.
 * You can override the requestForAdditionalUserInfo method in your custom TUIMessageCellData to return the user IDs which you want to retrieve, and directly use the additionalUserInfoResult property in your custom TUIMessageCell to render the UI as needed.
 * After TUIChat retrieves the information, it will assign it to the additionalUserInfoResult property and asynchronously refresh your cell.
 */
- (NSArray<NSString *> *)requestForAdditionalUserInfo;
@property(nonatomic, strong) NSDictionary<NSString *, TUIRelationUserModel *> *additionalUserInfoResult;

@end

NS_ASSUME_NONNULL_END

/**
 * 【Module name】TUIMessageCellDataFileUploadProtocol
 * 【Function description】File type message, unified upload (send) progress field
 */
@protocol TUIMessageCellDataFileUploadProtocol <NSObject>

@required
/**
 *  The progress of uploading (sending)
 */
@property(nonatomic, assign) NSUInteger uploadProgress;

@end

@protocol TUIMessageCellDataFileDownloadProtocol <NSObject>

@required
/**
 *  The progress of downloading (receving)
 */
@property(nonatomic, assign) NSUInteger downladProgress;

/**
 *  The flag of whether is downloading
 *  YES: downloading; NO: not download
 */
@property(nonatomic, assign) BOOL isDownloading;

@end
