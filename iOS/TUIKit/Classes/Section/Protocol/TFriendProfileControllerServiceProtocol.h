#ifndef TFriendProfileControllerServiceProtocol_h
#define TFriendProfileControllerServiceProtocol_h

#import "TCServiceProtocol.h"

@class TIMFriend;

@protocol TFriendProfileControllerServiceProtocol <TCServiceProtocol>

@property TIMFriend *friendProfile;

@end

#endif /* TFriendProfileControllerServiceProtocol_h */
