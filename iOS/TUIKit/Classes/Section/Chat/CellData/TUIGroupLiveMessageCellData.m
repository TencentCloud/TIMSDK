//
//  TUIGroupLiveMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by coddyliu on 2020/9/14.
//

#import "TUIGroupLiveMessageCellData.h"
#import "TUIMessageCellData.h"
#import "THeader.h"

@implementation TUIGroupLiveMessageCellData

- (V2TIMMessage *)generateInnerMessage {
    NSMutableDictionary *jsonInfo = @{
        @"version": @(AVCall_Version),
        @"businessID": @"group_live",
        @"anchorName":self.anchorName,
    }.mutableCopy;
    if (self.roomInfo) {
        /*
         @"roomId":roomInfo.roomId?:@"",
         @"version":@1,
         @"roomName":roomInfo.roomName?:@"",
         @"roomCover":roomInfo.coverUrl?:@"",
         @"roomType":@"liveRoom",
         @"roomStatus":@1,
         @"anchorId":roomInfo.ownerId?:@"",
         @"anchorName":roomInfo.ownerName?:@""
         */
        [jsonInfo addEntriesFromDictionary:self.roomInfo];
    }
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:jsonInfo options:NSJSONWritingFragmentsAllowed error:nil];
    if (msgData) {
        return [[V2TIMManager sharedInstance] createCustomMessage:msgData];
    } else {
        return nil;
    }
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super initWithDirection:MsgDirectionOutgoing];
    if (self) {
        self.anchorName = dict[@"anchorName"];
        self.roomInfo = dict;
        self.status = [dict[@"cellStatus"] longValue];
    }
    return self;
}

- (CGSize)contentSize {
    return CGSizeMake(180, 100);
}


@end
