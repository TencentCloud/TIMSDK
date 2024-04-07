
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 *【Module Name】TUIMessageCellLayout
 *【Function description】The layout of message unit
 * - UI layouts for implementing various message units (text, voice, video, images, emoticons, etc.).
 * - When you want to adjust the interface layout in TUIKit, you can modify the corresponding properties in this layout.
 */
@interface TUIMessageCellLayout : NSObject

/**
 * The insets of message
 */
@property(nonatomic, assign) UIEdgeInsets messageInsets;

/**
 * The insets of bubble content.
 */
@property(nonatomic, assign) UIEdgeInsets bubbleInsets;

/**
 * The insets of avatar
 */
@property(nonatomic, assign) UIEdgeInsets avatarInsets;

/**
 * The size of avatar
 */
@property(nonatomic, assign) CGSize avatarSize;

/////////////////////////////////////////////////////////////////////////////////
//                      Text Message Layout
/////////////////////////////////////////////////////////////////////////////////

/**
 *  Getting text message (receive) layout
 */
+ (TUIMessageCellLayout *)incommingTextMessageLayout;

/**
 *  Getting text message (send) layout
 */
+ (TUIMessageCellLayout *)outgoingTextMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      Voice Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  Getting voice message (receive) layout
 */
+ (TUIMessageCellLayout *)incommingVoiceMessageLayout;

/**
 *  Getting voice message (send) layout
 */
+ (TUIMessageCellLayout *)outgoingVoiceMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      System Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  Getting system message layout
 */
+ (TUIMessageCellLayout *)systemMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      Image Message Layout
/////////////////////////////////////////////////////////////////////////////////

/**
 *  Getting Image message layout
 */
+ (TUIMessageCellLayout *)incommingImageMessageLayout;
+ (TUIMessageCellLayout *)outgoingImageMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      Video Message Layout
/////////////////////////////////////////////////////////////////////////////////

/**
 *  Getting video message layout
 */
+ (TUIMessageCellLayout *)incommingVideoMessageLayout;
+ (TUIMessageCellLayout *)outgoingVideoMessageLayout;



/////////////////////////////////////////////////////////////////////////////////
//                     Other Message Layout
/////////////////////////////////////////////////////////////////////////////////
/**
 *  Getting receive message layout
 */
+ (TUIMessageCellLayout *)incommingMessageLayout;

/**
 *  Getting send message layout
 */
+ (TUIMessageCellLayout *)outgoingMessageLayout;

@end

NS_ASSUME_NONNULL_END
