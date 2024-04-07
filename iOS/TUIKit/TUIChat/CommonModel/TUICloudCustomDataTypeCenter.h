//
//  TUICloudCustomDataTypeCenter.h
//  TUIChat
//
//  Created by wyl on 2022/4/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK_Plus/ImSDK_Plus.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, TUICloudCustomDataType) {
    TUICloudCustomDataType_None = 1 << 0,
    TUICloudCustomDataType_MessageReply = 1 << 1,
//    TUICloudCustomDataType_MessageReact = 1 << 2,
    TUICloudCustomDataType_MessageReplies = 1 << 3,
    TUICloudCustomDataType_MessageReference = 1 << 4,
};

typedef NSString *TUICustomType;

FOUNDATION_EXTERN TUICustomType messageFeature;

@interface V2TIMMessage (CloudCustomDataType)

- (void)doThingsInContainsCloudCustomOfDataType:(TUICloudCustomDataType)type callback:(void (^)(BOOL isContains, id obj))callback;
/**
 * Whether this state is included
 */
- (BOOL)isContainsCloudCustomOfDataType:(TUICloudCustomDataType)type;

/**
 * Parse data of specified type
 * The return value is: data of type NSDictionary/NSArray/NSString/NSNumber
 */
- (NSObject *)parseCloudCustomData:(TUICustomType)customType;

/**
 * Set the specified type of data
 * jsonData: NSDictionary/NSArray/NSString/NSNumber type data, which can be directly converted to json
 */
- (void)setCloudCustomData:(NSObject *)jsonData forType:(TUICustomType)customType;

- (void)modifyIfNeeded:(V2TIMMessageModifyCompletion)callback;

@end
@interface TUICloudCustomDataTypeCenter : NSObject
+ (NSString *)convertType2String:(TUICloudCustomDataType)type;
@end

NS_ASSUME_NONNULL_END
