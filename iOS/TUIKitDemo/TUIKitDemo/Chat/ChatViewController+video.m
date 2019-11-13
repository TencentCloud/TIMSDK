//
//  ChatViewController+video.m
//  TUIKitDemo
//
//  Created by xcoderliu on 9/30/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "ChatViewController+video.h"
#import "TCUtil.h"
#import "THelper.h"
#import "VideoCallManager.h"

@implementation ChatViewController (video)

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewVideoCallMessage:(TIMMessage *)msg {
    TIMElem *elem = [msg getElem:0];
    if([elem isKindOfClass:[TIMCustomElem class]]) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
        UInt32 state = [param[@"videoState"] unsignedIntValue];
        NSString* user = param[@"requestUser"];
        if ( state == VIDEOCALL_REQUESTING ||
            state == VIDEOCALL_USER_CONNECTTING ) { //请求或开始连接

            return nil;
        }
        
        BOOL isOutGoing = msg.isSelf;
        if (state == VIDEOCALL_USER_REJECT ||
            state == VIDEOCALL_USER_ONCALLING) { //由我发起请求，对方发送结果
            isOutGoing = !isOutGoing;
        }
        
        if (user != nil) {
            NSString *currentUser = [[VideoCallManager shareInstance] currentUserIdentifier];
            isOutGoing = (user == currentUser);
        }
        
        VideoCallCellData *cellData = [[VideoCallCellData alloc] initWithDirection:isOutGoing
                                       ? MsgDirectionOutgoing : MsgDirectionIncoming];
        cellData.roomID = [param[@"roomID"] unsignedIntValue];
        cellData.isSelf = msg.isSelf;
        cellData.videoState = state;
        cellData.requestUser = user;
        NSNumber *duration = param[@"duration"];
        if (duration != nil) {
            cellData.duration = [duration unsignedIntValue];
        } else {
            cellData.duration = 0;
        }
        cellData.avatarUrl = [NSURL URLWithString:[[TIMFriendshipManager sharedInstance] querySelfProfile].faceURL];
        
        return cellData;
    }
    return nil;
}

- (BOOL)videoCallTimeOut: (TIMMessage*)message {
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:message.timestamp];
    if ( time >= VIDEOCALL_TIMEOUT) {
        return YES;
    }
    return NO;
}

@end
