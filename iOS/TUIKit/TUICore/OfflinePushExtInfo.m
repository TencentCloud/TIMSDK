//
//  OfflinePushExtInfo.m
//  TUICore
//
//  Created by cologne on 2024/3/19.
//  Copyright © 2024 Tencent. All rights reserved.

#import "OfflinePushExtInfo.h"

@implementation OfflinePushExtInfo

+ (nonnull OfflinePushExtInfo *)createWithExtString:(nonnull NSString *)ext {
    if (ext == nil || ![ext isKindOfClass:NSString.class] || ext.length == 0) {
        return nil;
    }
    
    NSDictionary *extDict = nil;
    BOOL flag = [self.class convertJsonString:ext toObject:&extDict];
    if (!flag || extDict == nil ||
        ![extDict isKindOfClass:NSDictionary.class] ||
        ![extDict.allKeys containsObject:@"entity"]) {
        return nil;
    }
    
    OfflinePushExtInfo * extInfo = [[OfflinePushExtInfo alloc] init];
    OfflinePushExtBusinessInfo * entity = extInfo.entity;
    OfflinePushExtConfigInfo * timPushFeatures = extInfo.timPushFeatures;
    
    NSDictionary *entityDic = extDict[@"entity"];
    if (entityDic) {
        [entity configWithEntityDic:entityDic];
    }
    NSDictionary *featuresDic = extDict[@"timPushFeatures"];
    
    if (featuresDic) {
        [timPushFeatures configWithTIMPushFeaturesDic:featuresDic];
    }
    
    return extInfo;
}


- (OfflinePushExtBusinessInfo *)entity {
    if (!_entity) {
        _entity = [[OfflinePushExtBusinessInfo alloc] init];
    }
    return _entity;
}


- (OfflinePushExtConfigInfo *)timPushFeatures {
    if (!_timPushFeatures) {
        _timPushFeatures = [[OfflinePushExtConfigInfo alloc] init];
    }
    return _timPushFeatures;
}

- (NSDictionary *)toReportData {
    NSMutableDictionary *extDic =  [NSMutableDictionary dictionary];
    NSDictionary *entityDict = nil;
    if (_entity) {
        entityDict = [_entity toReportData];
        [extDic setValue:entityDict forKey:@"entity"];
    }
    
    NSDictionary *timPushFeaturesDict = nil;
    if (_timPushFeatures) {
        timPushFeaturesDict = [_timPushFeatures toReportData];
        [extDic setValue:timPushFeaturesDict forKey:@"timPushFeatures"];
    }
    
    if (extDic) {
        return extDic;
    }
    
    return nil;
}

- (NSString *)toReportExtString {
    NSDictionary * extDic = [self toReportData];
    NSData *data = [NSJSONSerialization dataWithJSONObject:extDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ext;
}



+ (BOOL)convertJsonString:(NSString *)jsonString toObject:(NSObject **)object {
    if (jsonString == nil) {
        return NO;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"json decode failed, error:%@, json:%@", err, jsonString);
    }
    return (err == nil);
}
@end
