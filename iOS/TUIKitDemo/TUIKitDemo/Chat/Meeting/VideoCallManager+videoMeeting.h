//
//  VideoCallManager+videoMeeting.h
//  TUIKitDemo
//
//  Created by xcoderliu on 10/14/19.
//  Copyright © 2019 Tencent. All rights reserved.
//



#import "VideoCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCallManager (videoMeeting)
- (void)_enterMeetingRoom;
- (void)_quitMeetingRoom;
@end

NS_ASSUME_NONNULL_END
