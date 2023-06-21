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
    TUICloudCustomDataType_MessageReact = 1 << 2,
    TUICloudCustomDataType_MessageReplies = 1 << 3,
    TUICloudCustomDataType_MessageReference = 1 << 4,
};

typedef NSString *TUICustomType;

FOUNDATION_EXTERN TUICustomType messageFeature;

@interface V2TIMMessage (CloudCustomDataType)

- (void)doThingsInContainsCloudCustomOfDataType:(TUICloudCustomDataType)type callback:(void (^)(BOOL isContains, id obj))callback;
/**
 * 是否包含了这种状态
 * Whether this state is included
 */
- (BOOL)isContainsCloudCustomOfDataType:(TUICloudCustomDataType)type;

/**
 * 解析指定类型的数据
 * 返回值是：NSDictionary/NSArray/NSString/NSNumber 类型的数据
 *
 * Parse data of specified type
 * The return value is: data of type NSDictionary/NSArray/NSString/NSNumber
 */
- (NSObject *)parseCloudCustomData:(TUICustomType)customType;

/**
 * 设置指定类型的数据
 * jsonData: NSDictionary/NSArray/NSString/NSNumber 类型的数据，可以直接转换成 json 的
 *
 * Set the specified type of data
 * jsonData: NSDictionary/NSArray/NSString/NSNumber type data, which can be directly converted to json
 */
- (void)setCloudCustomData:(NSObject *)jsonData forType:(TUICustomType)customType;

- (void)modifyIfNeeded:(V2TIMMessageModifyCompletion)callback;

@end
@interface TUICloudCustomDataTypeCenter : NSObject
+ (NSString *)convertType2String:(TUICloudCustomDataType)type;
//+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;
//+ (BOOL)versionControl:(int)CurrentVersion
//               ByType :(TUICloudCustomDataType)type;
@end

@class TUIReactModelMessageReact;
@class TUIReactModelReacts;

#pragma mark - Object interfaces

@interface TUIReactModelMessageReact : NSObject

@property(nonatomic, strong) NSMutableArray<TUIReactModelReacts *> *reacts;
@property(nonatomic, nullable, copy) NSString *version;

- (void)applyWithDic:(NSDictionary *)orignMessageReactDic emojiName:(NSString *)emojiName loginUser:(NSString *)loginUser;
- (NSDictionary *)descriptionDic;
@end

@interface TUIReactModelReacts : NSObject
@property(nonatomic, strong) NSMutableArray<NSString *> *emojiIdArray;
@property(nonatomic, nullable, copy) NSString *emojiKey;
- (NSDictionary *)descriptionDic;
@end

NS_ASSUME_NONNULL_END
