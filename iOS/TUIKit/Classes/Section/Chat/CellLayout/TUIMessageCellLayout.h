//
//  TUIMessageCellLayout.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageCellLayout : NSObject
/**
 * 消息边距
 */
@property UIEdgeInsets messageInsets;
/**
 * 气泡内部内容边距
 */
@property UIEdgeInsets bubbleInsets;
/**
 * 头像边距
 */
@property UIEdgeInsets avatarInsets;
/**
 * 头像大小
 */
@property CGSize avatarSize;

@property (nonatomic, class) TUIMessageCellLayout *incommingMessageLayout;

@property (nonatomic, class) TUIMessageCellLayout *outgoingMessageLayout;

@property (nonatomic, class) TUIMessageCellLayout *systemMessageLayout;

@property (nonatomic, class) TUIMessageCellLayout *incommingTextMessageLayout;

@property (nonatomic, class) TUIMessageCellLayout *outgoingTextMessageLayout;

@end


@interface TIncommingCellLayout : TUIMessageCellLayout

@end

@interface TOutgoingCellLayout : TUIMessageCellLayout

@end


@interface TIncommingVoiceCellLayout : TIncommingCellLayout

@end

@interface TOutgoingVoiceCellLayout : TOutgoingCellLayout

@end

NS_ASSUME_NONNULL_END
