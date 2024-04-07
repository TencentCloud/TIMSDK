//
//  OfflinePushExtBusinessInfo.m
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import "OfflinePushExtBusinessInfo.h"

@implementation OfflinePushExtBusinessInfo

- (void)configWithEntityDic:(NSDictionary *)entityDic {
    if (entityDic == nil || ![entityDic isKindOfClass:NSDictionary.class]) {
        return ;
    }
    
    if ([entityDic.allKeys containsObject:@"version"]) {
        NSInteger version = 0;
        version = [entityDic[@"version"] integerValue];
        self.version = version;
    }

    if ([entityDic.allKeys containsObject:@"chatType"]) {
        NSInteger chatType = 0;
        chatType = [entityDic[@"chatType"] integerValue];
        self.chatType = chatType;
    }
    
    if ([entityDic.allKeys containsObject:@"action"]) {
        NSInteger action = 0;
        action = [entityDic[@"action"] integerValue];
        self.action = action;
    }
    
    if ([entityDic.allKeys containsObject:@"sender"]) {
        NSString *sender = entityDic[@"sender"];
        if (sender.length > 0) {
            self.sender = sender;
        }
    }
    
    if ([entityDic.allKeys containsObject:@"nickname"]) {
        NSString *nickname = entityDic[@"nickname"];
        if (nickname.length > 0) {
            self.nickname = nickname;
        }
    }
    
    if ([entityDic.allKeys containsObject:@"faceUrl"]) {
        NSString *faceUrl = entityDic[@"faceUrl"];
        if (faceUrl.length > 0) {
            self.faceUrl = faceUrl;
        }
    }
    
    if ([entityDic.allKeys containsObject:@"content"]) {
        NSString *content = entityDic[@"content"];
        if (content.length > 0) {
            self.content = content;
        }
    }

    if ([entityDic.allKeys containsObject:@"customData"]) {
        NSData *customData = entityDic[@"customData"];
        if (customData) {
            self.customData = customData;
        }
    }
}

- (NSDictionary *)toReportData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"version"] = @(self.version);
    dict[@"chatType"] = @(self.chatType);
    dict[@"action"] = @(self.action);
    if (self.sender.length > 0) {
        dict[@"sender"] = self.sender;
    }

    if (self.nickname.length > 0) {
        dict[@"nickname"] = self.nickname;
    }
    
    if (self.faceUrl.length > 0) {
        dict[@"faceUrl"] = self.faceUrl;
    }
    
    if (self.content.length > 0) {
        dict[@"content"] = self.content;
    }
    
    if (self.customData) {
        dict[@"customData"] = self.customData;
    }
    
    return dict;
}
@end
