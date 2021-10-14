//
//  TRTCLiveRoomModelDef.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/12.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoomModelDef.h"

@implementation TRTCPKAnchorInfo

- (void)reset {
    self.userId = nil;
    self.roomId = nil;
    self.isResponsed = NO;
    self.uuid = @"";
}

@end

@implementation TRTCJoinAnchorInfo

-(void)reset {
    self.userId = nil;
    self.isResponsed = NO;
    self.uuid = @"";
}

@end
