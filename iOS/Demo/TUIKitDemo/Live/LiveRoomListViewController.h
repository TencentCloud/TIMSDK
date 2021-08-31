//
//  LiveListViewController.h
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LiveRoomListLoadDataResBlock)(NSArray *roomList, NSError *error);
@protocol LiveRoomListViewDelegate <NSObject>
- (void)loadLiveRoomList:(LiveRoomListLoadDataResBlock)callBack;
@end

@interface LiveRoomListViewController : UIViewController
@property(nonatomic, assign) id<LiveRoomListViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
