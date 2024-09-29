//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TUIMessageCellData.h>
#import "TUIChatConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIChatEventConfig;

typedef NS_ENUM(NSUInteger, TUIChatRegisterCustomMessageStyleType) {
    TUIChatRegisterCustomMessageStyleTypeClassic = 0,
    TUIChatRegisterCustomMessageStyleTypeMinimalist = 1,
};

@class TUICustomActionSheetItem;
@class TUIChatConversationModel;
typedef NS_OPTIONS(NSInteger, TUIChatInputBarMoreMenuItem) {
    TUIChatInputBarMoreMenuItem_None = 0,
    TUIChatInputBarMoreMenuItem_CustomMessage = 1 << 0,
    TUIChatInputBarMoreMenuItem_TakePhoto = 1 << 1,
    TUIChatInputBarMoreMenuItem_RecordVideo = 1 << 2,
    TUIChatInputBarMoreMenuItem_Album = 1 << 3,
    TUIChatInputBarMoreMenuItem_File = 1 << 4,
    TUIChatInputBarMoreMenuItem_Room = 1 << 5,
    TUIChatInputBarMoreMenuItem_Poll = 1 << 6,
    TUIChatInputBarMoreMenuItem_GroupNote = 1 << 7,
    TUIChatInputBarMoreMenuItem_VideoCall = 1 << 8,
    TUIChatInputBarMoreMenuItem_AudioCall = 1 << 9,
};
@protocol TUIChatInputBarConfigDataSource <NSObject>
@optional
/**
 *  Implement this method to hide items in more menu of the specified model.
 */
- (TUIChatInputBarMoreMenuItem)inputBarShouldHideItemsInMoreMenuOfModel:(TUIChatConversationModel *)model;
/**
 *  Implement this method to add new items to the more menu of the specified model.
 */
- (NSArray<TUICustomActionSheetItem *> *)inputBarShouldAddNewItemsToMoreMenuOfModel:(TUIChatConversationModel *)model;
@end

@protocol TUIChatShortcutViewDataSource <NSObject>
@optional
- (NSArray<TUIChatShortcutMenuCellData *> *)itemsInShortcutViewOfModel:(TUIChatConversationModel *)model;
- (UIColor *)shortcutViewBackgroundColorOfModel:(TUIChatConversationModel *)model;
- (CGFloat)shortcutViewHeightOfModel:(TUIChatConversationModel *)model;
@end


@interface TUIChatConfig : NSObject

+ (TUIChatConfig *)defaultConfig;

@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatContextEmojiDetailGroups;

/**
 *  A read receipt is required to send a message,  default is No
 */
@property(nonatomic, assign) BOOL msgNeedReadReceipt;

/**
 *  Display the video call button, if the TUICalling component is integrated, the default is YES
 */
@property(nonatomic, assign) BOOL enableVideoCall;

/**
 *  Whether to display the audio call button, if the TUICalling component is integrated, the default is YES
 */
@property(nonatomic, assign) BOOL enableAudioCall;

/**
 *  Display custom welcome message button, default YES
 */
@property(nonatomic, assign) BOOL enableWelcomeCustomMessage;

/**
 *  In the chat interface, long press the pop-up box to display the emoji interactive message function, the default is YES
 */
@property(nonatomic, assign) BOOL enablePopMenuEmojiReactAction;

/**
 *  Chat long press the pop-up box to display the message reply function entry, the default is YES
 */
@property(nonatomic, assign) BOOL enablePopMenuReplyAction;

/**
 *  Chat long press the pop-up box to display the entry of the message reference function, the default is YES
 */

@property(nonatomic, assign) BOOL enablePopMenuReferenceAction;

@property(nonatomic, assign) BOOL enablePopMenuPinAction;
@property(nonatomic, assign) BOOL enablePopMenuRecallAction;
@property(nonatomic, assign) BOOL enablePopMenuTranslateAction;
@property(nonatomic, assign) BOOL enablePopMenuConvertAction;
@property(nonatomic, assign) BOOL enablePopMenuForwardAction;
@property(nonatomic, assign) BOOL enablePopMenuSelectAction;
@property(nonatomic, assign) BOOL enablePopMenuCopyAction;
@property(nonatomic, assign) BOOL enablePopMenuDeleteAction;
@property(nonatomic, assign) BOOL enablePopMenuInfoAction;
@property(nonatomic, assign) BOOL enablePopMenuAudioPlaybackAction;

/**
 *  Whether the C2C chat dialog box displays "The other party is typing...", the default is YES
 */
@property(nonatomic, assign) BOOL enableTypingStatus;

/**
 *  Whether the  chat dialog box displays "InputBar", the default is YES
 */
@property(nonatomic, assign) BOOL enableMainPageInputBar;

/**
 * Setup the backgroud color of chat page
 */
@property(nonatomic, strong) UIColor *backgroudColor;

/**
 * Setup the backgroud image of chat page
 */
@property(nonatomic, strong) UIImage *backgroudImage;

/**
 * Whether to turn on audio and video call suspension windows, default is YES
 */
@property(nonatomic, assign) BOOL enableFloatWindowForCall;

/**
 * Whether to enable multi-terminal login function for audio and video calls, default is NO
 */
@property(nonatomic, assign) BOOL enableMultiDeviceForCall;

/**
 * Set whether to enable incoming banner when user received audio and video calls, default is false
 */
@property(nonatomic, assign) BOOL enableIncomingBanner;

/**
 * Set whether to enable the virtual background for audio and video calls, default value is false
 */
@property(nonatomic, assign) BOOL enableVirtualBackgroundForCall;

/**
 * The time interval for message recall, in seconds, default is 120 seconds. If you want to adjust this configuration, please modify the IM console settings
 * synchronously.
 * https://cloud.tencent.com/document/product/269/38656#.E6.B6.88.E6.81.AF.E6.92.A4.E5.9B.9E.E8.AE.BE.E7.BD.AE
 */
@property(nonatomic, assign) NSUInteger timeIntervalForMessageRecall;

/**
 不超过 60s
 */
@property (nonatomic, assign) CGFloat maxAudioRecordDuration;

/**
 不超过 15s
 */
@property (nonatomic, assign) CGFloat maxVideoRecordDuration;

@property(nonatomic, assign) BOOL showRoomButton;
@property(nonatomic, assign) BOOL showPollButton;
@property(nonatomic, assign) BOOL showGroupNoteButton;
@property(nonatomic, assign) BOOL showRecordVideoButton;
@property(nonatomic, assign) BOOL showTakePhotoButton;
@property(nonatomic, assign) BOOL showAlbumButton;
@property(nonatomic, assign) BOOL showFileButton;



/**
 * This class is used to register event listeners for Chat from external sources, to listen for various events in Chat and respond accordingly,
 * such as listening for avatar click events, long-press message events, etc.
 * You need to set a delegate for the implementation method: TUIChatConfig.defaultConfig.eventConfig.chatEventListener = "YourDelegateViewController".
 * YourDelegateViewController needs to conform to the <TUIChatEventListener> protocol and implement the protocol method.
 * Taking - (BOOL)onUserIconClicked:messageCellData: as an example, returning NO indicates an insertion behavior, 
 * which is not intercepted and will be further processed by the Chat module.
 * Taking - (BOOL)onUserIconClicked:messageCellData: as an example, returning YES indicates an override behavior, 
 * which will be intercepted and only the overridden method will be executed. The Chat module will not continue to process it.
 */
@property(nonatomic, strong) TUIChatEventConfig * eventConfig;
/**
 *  DataSource for inputBar.
 */
@property (nonatomic, weak) id<TUIChatInputBarConfigDataSource> inputBarDataSource;
/**
 *  DataSource for shortcutView above inputBar.
 */
@property (nonatomic, weak) id<TUIChatShortcutViewDataSource> shortcutViewDataSource;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatEventListener <NSObject>

/**
 * This callback is triggered when a user avatar in the chat list interface is clicked. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserIconClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
/**
 * This callback is triggered when a user avatar in the chat list interface is long-pressed. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onUserIconLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;

/**
 * This callback is triggered when a message in the chat list interface is clicked. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;

/**
 * This callback is triggered when a message in the chat list interface is long-pressed. Returning YES indicates that this event has been intercepted,
 * and Chat will not process it further. Returning NO indicates that this event is not intercepted, and Chat will continue to process it.
 */
- (BOOL)onMessageLongClicked:(UIView *)view messageCellData:(TUIMessageCellData *)celldata;
@end

@interface TUIChatEventConfig : NSObject
@property (nonatomic,weak)id <TUIChatEventListener>chatEventListener;
@end

// Regiser custom message category
// You can call this method like :
//
// [TUIChatConfig.defaultConfig registerCustomMessage:@"YourBusinessID"
//                               messageCellClassName:@"YourCustomCellNameString"
//                           messageCellDataClassName:@"YourCustomCellDataNameString"];
@interface TUIChatConfig (CustomMessageRegiser)

/**
 * Register custom message ,  by default, register to the classic UI.
 * param businessID Custom message businessID (note that it must be unique)
 * param cellName Custom message messagCell  type
 * param cellDataName Custom message  MessagCellData type
 */
- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName;

/**
 * Register custom message
 * param businessID Custom message businessID (note that it must be unique)
 * param cellName Custom message messagCell  type
 * param cellDataName Custom message  MessagCellData type
 * param styleType UI style corresponding to this custom message, for example TUIChatRegisterCustomMessageStyleTypeClassic
 */
- (void)registerCustomMessage:(NSString *)businessID
         messageCellClassName:(NSString *)cellName
     messageCellDataClassName:(NSString *)cellDataName
                    styleType:(TUIChatRegisterCustomMessageStyleType)styleType;
@end



NS_ASSUME_NONNULL_END

