//
//  TUILiveRoomListViewController.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RoomIDListCallback)(NSArray<NSString *> *roomIDList);
typedef void(^TUICreateActionCallback)(void);
@interface TUILiveRoomListViewController : UIViewController

- (void)getRoomIDList:(RoomIDListCallback _Nullable)callback;

- (void)setCreateRoomAction:(TUICreateActionCallback)callback;

@end

NS_ASSUME_NONNULL_END
