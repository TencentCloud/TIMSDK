//
//  VoiceRoomListViewController.h
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^VoiceRoomListLoadDataResBlock)(NSArray *roomList, NSError *error);

@protocol VoiceRoomListViewDelegate <NSObject>
- (void)loadVoiceRoomList:(VoiceRoomListLoadDataResBlock)callBack;
@end

@interface VoiceRoomListViewController : UIViewController
@property(nonatomic, weak) id<VoiceRoomListViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
