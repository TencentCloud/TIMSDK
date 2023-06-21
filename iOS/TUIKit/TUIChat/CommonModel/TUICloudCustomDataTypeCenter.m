//
//  TUICloudCustomDataTypeCenter.m
//  TUIChat
//
//  Created by wyl on 2022/4/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICloudCustomDataTypeCenter.h"
#import <TIMCommon/TIMDefine.h>
TUICustomType messageFeature = @"messageFeature";

@implementation V2TIMMessage (CloudCustomDataType)

- (BOOL)hasAnyCloudCustomDataType {
    if (self.cloudCustomData == nil) {
        return NO;
    }
    return YES;
}

- (void)doThingsInContainsCloudCustomOfDataType:(TUICloudCustomDataType)type callback:(void (^)(BOOL isContains, id obj))callback {
    if (self.cloudCustomData == nil) {
        if (callback) {
            callback(NO, nil);
        }
    }

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.cloudCustomData options:0 error:&error];
    NSString *typeStr = [TUICloudCustomDataTypeCenter convertType2String:type];

    if (![typeStr isKindOfClass:[NSString class]] || typeStr.length <= 0) {
        if (callback) {
            callback(NO, nil);
        }
    }
    if (error || dict == nil || ![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:typeStr]) {
        if (callback) {
            callback(NO, nil);
        }
        return;
    }

    // extra condition
    if (type == TUICloudCustomDataType_MessageReply) {
        NSDictionary *reply = [dict valueForKey:typeStr];
        if (reply == nil || ![reply isKindOfClass:NSDictionary.class]) {
            if (callback) {
                callback(NO, nil);
            }
            return;
        }
        if (![reply.allKeys containsObject:@"version"] || [reply[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of message rely");
            if (callback) {
                callback(NO, nil);
            }
            return;
        }
        if (callback) {
            callback(YES, reply);
        }
    }

    if (type == TUICloudCustomDataType_MessageReference) {
        NSDictionary *reply = [dict valueForKey:typeStr];
        if (reply == nil || ![reply isKindOfClass:NSDictionary.class]) {
            if (callback) {
                callback(NO, nil);
            }
            return;
        }

        if (![reply.allKeys containsObject:@"version"] || [reply[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of message rely");
            if (callback) {
                callback(NO, nil);
            }
            return;
        }
        if ([reply.allKeys containsObject:@"messageRootID"]) {
            if (callback) {
                callback(NO, nil);
            }
            return;
        }
        if (callback) {
            callback(YES, reply);
        }
        return;
    }

    if (type == TUICloudCustomDataType_MessageReact) {
        NSDictionary *messageReact = [dict valueForKey:typeStr];
        NSDictionary *reacts = [messageReact valueForKey:@"reacts"];
        if (reacts == nil || ![reacts isKindOfClass:NSDictionary.class]) {
            return;
        }
        if (![messageReact.allKeys containsObject:@"version"] || [messageReact[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of react");
            return;
        }

        if (callback) {
            callback(YES, reacts);
        }
        return;
    }

    if (type == TUICloudCustomDataType_MessageReplies) {
        NSDictionary *messageReplies = [dict valueForKey:typeStr];
        NSArray *reply = [messageReplies valueForKey:@"replies"];
        if (reply == nil || ![reply isKindOfClass:NSArray.class]) {
            if (callback) {
                callback(NO, nil);
            }
            return;
        }
        if (reply.count <= 0) {
            if (callback) {
                callback(NO, nil);
            }
            return;
        }

        if (callback) {
            callback(YES, dict);
        }
        return;
    }

    return;
}
- (BOOL)isContainsCloudCustomOfDataType:(TUICloudCustomDataType)type {
    if (self.cloudCustomData == nil) {
        return NO;
    }

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.cloudCustomData options:0 error:&error];
    NSString *typeStr = [TUICloudCustomDataTypeCenter convertType2String:type];
    //    NSDictionary *customElemDic = [NSJSONSerialization JSONObjectWithData:self.customElem.data options:0 error:&error];

    if (![typeStr isKindOfClass:[NSString class]] || typeStr.length <= 0) {
        return NO;
    }
    if (error || dict == nil || ![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:typeStr]) {
        return NO;
    }

    // extra condition
    if (type == TUICloudCustomDataType_MessageReply) {
        NSDictionary *reply = [dict valueForKey:typeStr];
        if (reply == nil || ![reply isKindOfClass:NSDictionary.class]) {
            return NO;
        }

        if (![reply.allKeys containsObject:@"version"] || [reply[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of message rely");
            return NO;
        }
        if (![reply.allKeys containsObject:@"messageRootID"]) {
            return NO;
        }
        return YES;
    }
    if (type == TUICloudCustomDataType_MessageReference) {
        NSDictionary *reply = [dict valueForKey:typeStr];
        if (reply == nil || ![reply isKindOfClass:NSDictionary.class]) {
            return NO;
        }

        if (![reply.allKeys containsObject:@"version"] || [reply[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of message rely");
            return NO;
        }
        if ([reply.allKeys containsObject:@"messageRootID"]) {
            return NO;
        }
        return YES;
    }

    if (type == TUICloudCustomDataType_MessageReact) {
        NSDictionary *messageReact = [dict valueForKey:typeStr];
        NSDictionary *reacts = [messageReact valueForKey:@"reacts"];
        if (reacts == nil || ![reacts isKindOfClass:NSDictionary.class]) {
            return NO;
        }
        if (![messageReact.allKeys containsObject:@"version"] || [messageReact[@"version"] intValue] > kMessageReplyVersion) {
            NSLog(@"not match the version of react");
            return NO;
        }

        return YES;
    }
    if (type == TUICloudCustomDataType_MessageReplies) {
        NSDictionary *messageReplies = [dict valueForKey:typeStr];
        NSArray *reply = [messageReplies valueForKey:@"replies"];
        if (reply == nil || ![reply isKindOfClass:NSArray.class]) {
            return NO;
        }
        if (reply.count <= 0) {
            return NO;
        }
        return YES;
    }

    return NO;
}

- (NSObject *)parseCloudCustomData:(TUICustomType)customType {
    if (self.cloudCustomData == nil || customType.length == 0) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.cloudCustomData options:0 error:&error];

    if (error || dict == nil || ![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:customType]) {
        return nil;
    }

    return [dict objectForKey:customType];
}

- (void)setCloudCustomData:(NSObject *)jsonData forType:(TUICustomType)customType {
    if (jsonData == nil || customType.length == 0) {
        return;
    }

    NSDictionary *dict = @{};

    if (self.cloudCustomData) {
        dict = [NSJSONSerialization JSONObjectWithData:self.cloudCustomData options:0 error:nil];
        if (dict == nil) {
            dict = @{};
        }
    }

    if (![dict isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSMutableDictionary *originDataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if ([originDataDict.allKeys containsObject:customType]) {
        [originDataDict removeObjectForKey:customType];
    }
    [originDataDict setObject:jsonData forKey:customType];

    NSData *data = [NSJSONSerialization dataWithJSONObject:originDataDict options:0 error:nil];
    if (data) {
        self.cloudCustomData = data;
    }
}

- (void)modifyIfNeeded:(V2TIMMessageModifyCompletion)callback {
    [V2TIMManager.sharedInstance modifyMessage:self completion:callback];
}

@end

@implementation TUICloudCustomDataTypeCenter

+ (NSString *)convertType2String:(TUICloudCustomDataType)type {
    NSString *resultString = @"";
    switch (type) {
        case TUICloudCustomDataType_MessageReply:
        case TUICloudCustomDataType_MessageReference:
            resultString = @"messageReply";
            break;
        case TUICloudCustomDataType_MessageReact:
            resultString = @"messageReact";
            break;
        case TUICloudCustomDataType_MessageReplies:
            resultString = @"messageReplies";
            break;
        default:
            break;
    }
    return resultString;
}
@end

@implementation TUIReactModelMessageReact

- (void)applyWithDic:(NSDictionary *)orignMessageReactDic emojiName:(NSString *)emojiName loginUser:(NSString *)loginUser {
    self.version = orignMessageReactDic[@"version"];
    self.reacts = [NSMutableArray arrayWithCapacity:3];

    if ([orignMessageReactDic[@"reacts"] objectForKey:emojiName]) {
        for (NSString *key in orignMessageReactDic[@"reacts"]) {
            TUIReactModelReacts *react = [[TUIReactModelReacts alloc] init];
            react.emojiKey = key;
            react.emojiIdArray = orignMessageReactDic[@"reacts"][key];
            if ([key isEqualToString:emojiName]) {
                if ([react.emojiIdArray containsObject:loginUser]) {
                    [react.emojiIdArray removeObject:loginUser];
                } else {
                    [react.emojiIdArray addObject:loginUser];
                }
            }
            if (react.emojiIdArray.count > 0) {
                [self.reacts addObject:react];
            }
        }
    } else {
        for (NSString *key in orignMessageReactDic[@"reacts"]) {
            TUIReactModelReacts *react = [[TUIReactModelReacts alloc] init];
            react.emojiKey = key;
            react.emojiIdArray = orignMessageReactDic[@"reacts"][key];
            [self.reacts addObject:react];
        }
        TUIReactModelReacts *react = [[TUIReactModelReacts alloc] init];
        react.emojiKey = emojiName;
        react.emojiIdArray = [NSMutableArray array];
        [react.emojiIdArray addObject:loginUser];
        [self.reacts addObject:react];
    }
}
- (NSDictionary *)descriptionDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    [dic setValue:self.version forKey:@"version"];
    NSMutableDictionary *reacts = [NSMutableDictionary dictionary];
    for (TUIReactModelReacts *react in self.reacts) {
        [reacts setObject:react.emojiIdArray forKey:react.emojiKey];
    }
    [dic setObject:reacts forKey:@"reacts"];
    return dic;
}
@end

@implementation TUIReactModelReacts

@end
