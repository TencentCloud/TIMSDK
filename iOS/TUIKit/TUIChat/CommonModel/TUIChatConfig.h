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
@class TUIChatEventConfig;

typedef NS_ENUM(NSUInteger, TUIChatRegisterCustomMessageStyleType) {
    TUIChatRegisterCustomMessageStyleTypeClassic = 0,
    TUIChatRegisterCustomMessageStyleTypeMinimalist = 1,
};

NS_ASSUME_NONNULL_BEGIN

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
 * The time interval for message recall, in seconds, default is 120 seconds. If you want to adjust this configuration, please modify the IM console settings
 * synchronously.
 * https://cloud.tencent.com/document/product/269/38656#.E6.B6.88.E6.81.AF.E6.92.A4.E5.9B.9E.E8.AE.BE.E7.BD.AE
 */
@property(nonatomic, assign) NSUInteger timeIntervalForMessageRecall;

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

