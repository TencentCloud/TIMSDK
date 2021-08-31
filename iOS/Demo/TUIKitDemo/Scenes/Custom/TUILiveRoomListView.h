//
//  TUILiveRoomListView.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveRoomInfo;
@protocol TUILiveRoomListDelegate <NSObject>

- (NSArray<TUILiveRoomInfo *> *)roomList;
- (void)enterRoom:(TUILiveRoomInfo *)room;
- (void)refreshRoomListData;

@end

@interface TUILiveRoomListView : UIView

@property(nonatomic, weak)id<TUILiveRoomListDelegate> delegate;

-(void)refreshList;
- (void)endRefreshState; // 结束刷新状态

@end

NS_ASSUME_NONNULL_END
