//
//  QAPMUBSMonitor.h
//  QAPM
//
//  Created by Cass on 2019/10/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QAPMUBSMonitor : NSObject

+ (instancetype)manager;

/**
 额外传入信息
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *map;

- (void)start;

/**
 创建一个用户行为event,并返回该event的uuid

 @param type 功能类型
 @return event uuid
 */
//- (NSString *)eventConnSendEventWithType:(QAPMEventType)type;
- (NSString *)eventConnSendEventWithType:(QAPMEventType)type eventLabel:(NSString *)eventLabel;

/**
 创建一个用户行为event，通过设置时间可以修改该行为的发生时间。可用于crash等非实时上报的事件。

 @param type 功能类型
 @param date 时间
 @return 用户行为event uuid
 */
//- (NSString *)eventConnSendEventWithType:(QAPMEventType)type date:(nullable NSDate *)date;
- (NSString *)eventConnSendEventWithType:(QAPMEventType)type eventLabel:(NSString *)eventLabel date:(nullable NSDate *)date;

/**
 用户自定义用户行为操作调用,外部用户接口，调用该接口时请完成QAPM的一系列初始化操作，设置完QAPM的appKey后调用。
 @param category  类别
 @param label     事件标签
 @param action    操作
 @param value     数据值
 @param tags      字符串的map标记
 @param values    数值的map标记
 @return 用户行为event uuid
*/
- (NSString *)generateUserEvent:(NSString *)category
                    label:(NSString *)label
                   action:(NSString *)action
                    value:(NSNumber *)value
                     tags:(NSDictionary<NSString *, NSString *> *)tags
                   values:(NSDictionary<NSString *, NSNumber *> *)values;


/**
 添加分桶实验(例如A/B test)，可添加多个，多次调用即可.
*/
- (void)addBucket:(NSString *)bucket;


/**
 移除单个bucket.
*/
- (void)removeBucket:(NSString *)bucket;

/**
 移除所有bucket.
*/
- (void)removeAllBuckets;

@end

NS_ASSUME_NONNULL_END

