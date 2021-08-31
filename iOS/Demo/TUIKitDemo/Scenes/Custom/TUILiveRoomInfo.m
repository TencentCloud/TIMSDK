//
//  TUILiveRoomInfo.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveRoomInfo.h"

@implementation TUILiveRoomInfo

-(instancetype)initWithRoomID:(NSInteger)roomID ownerId:(NSString *)ownerId memberCount:(NSInteger)memberCount {
    self = [super init];
    if (self) {
        self.roomID = roomID;
        self.ownerId = ownerId;
        self.memberCount = memberCount;
    }
    return self;
}

@end
