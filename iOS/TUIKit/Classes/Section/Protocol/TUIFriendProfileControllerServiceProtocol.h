/******************************************************************************
 *
 *  本文件声明了 TUIFriendProfileControllerServiceProtocol 协议。
 *  便具有 friendProfile 属性，该属性中包含了各类好友信息，包括好友 ID、好友备注、好友的用户信息等。
 *  包含了 friendProfile 属性后，便可以进一步在页面中显示好友信息，进行进一步的操作。
 *
 ******************************************************************************/
#ifndef TUIFriendProfileControllerServiceProtocol_h
#define TUIFriendProfileControllerServiceProtocol_h

#import "TCServiceProtocol.h"

@class V2TIMFriendInfo;

@protocol TUIFriendProfileControllerServiceProtocol <TCServiceProtocol>

/**
 *  本属性为 IM SDK 中声明的类。
 *  包括好友 ID、好友备注、好友的用户信息等。
 *  详细信息请参考 IMSDK\Framework\ImSDK.framework\Headers\TIMComm.h 中关于 TIMFriend 的定义。
 */
@property V2TIMFriendInfo *friendProfile;

@end

#endif /* TUIFriendProfileControllerServiceProtocol_h */
