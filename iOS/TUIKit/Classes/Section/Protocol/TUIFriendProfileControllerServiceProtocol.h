#ifndef TUIFriendProfileControllerServiceProtocol_h
#define TUIFriendProfileControllerServiceProtocol_h

#import "TCServiceProtocol.h"

@class TIMFriend;

@protocol TUIFriendProfileControllerServiceProtocol <TCServiceProtocol>

@property TIMFriend *friendProfile;

@end

#endif /* TUIFriendProfileControllerServiceProtocol_h */
