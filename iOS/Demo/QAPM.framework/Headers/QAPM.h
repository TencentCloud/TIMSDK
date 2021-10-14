//
//  QAPM.h
//  QAPM
//
//  SDK Version 3.3.33 Inner_Version
//
//  Created by Cass on 2018/5/18.
//  Copyright © 2018年 cass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QAPMConfig.h"
#import "QAPMUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface QAPM : NSObject

/**
 使用指定配置初始化QAPM
 
 * @param appKey 注册QAPM分配的唯一标识
 */
+ (void)startWithAppKey:(NSString * __nonnull)appKey;

/**
 注册SDK内部日志回调，用于输出SDK内部日志
 
 @param logger 外部的日志打印方法
 */
+ (void)registerLogCallback:(QAPM_Log_Callback)logger;


/**
 SDK 版本信息

 @return SDK版本号
 */
+ (NSString *)sdkVersion;

 
 /**
 @return 代表的依次是blame_team和blame_reason，根据QAPMUploadEventType的功能类型来自定义返回值
 */

+ (NSDictionary<NSString *, NSString *> *)eventUpSendEventWithTyped:(QAPMUploadEventCallback)callBack;

/**
 监控功能开启状态回调。提供用于Athena SDK使用
 
 @param callback state 功能状态, type 功能类相关。
 */
+ (void)monitorStartCallback:(QAPMMonitorStartCallback)callback;

+ (BOOL)monitorEnableWithType:(QAPMMonitorType)type;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface QAPMLaunchProfile : NSObject

/**
 开启启动耗时监控的调用
 */
+ (void)setupLaunchMonitor;

/**
 【必须调用API】请在AppDidFinishLaunch开始调用时设置。
 */
+ (void)setAppDidFinishLaunchBeginTimestamp;

/**
 【必须调用API】请在第一个页面ViewDidApppear开始调用时设置。
 */
+ (void)setFirtstViewDidApppearTimestamp;

/**
 设置自定义打点区间开始，该区间需要在启动时间区间内。begin与end的scene需要一致。
 当设置了 setFirtstViewDidApppearTimestamp 后，后面设置的自定义打点区间将不会被统计。
 
 @param scene 场景名
 */
+ (void)setBeginTimestampForScene:(NSString *)scene;

/**
 设置自定义打点区间结束，该区间需要在启动时间区间内。begin与end的scene需要一致。
 当设置了 setFirtstViewDidApppearTimestamp 后，后面设置的自定义打点区间将不会被统计。
 
 @param scene 场景名
 */
+ (void)setEndTimestampForScene:(NSString *)scene;


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface QAPMBlueProfile : NSObject

/**
 开始记录掉帧，建议滑动开始时调用
 
 * @param stage 用来标识当前页面(一般为当前VC类名）
 */
+ (void)beginTrackingWithStage:(NSString *)stage;

/**
 结束记录掉帧，滑动结束时调用
 
 * @param stage 用来标识当前页面(一般为当前VC类名）
 */
+ (void)stopTrackingWithStage:(NSString *)stage;

/**
 更新所有场景的掉帧堆栈开关（除滑动外其它场景上报时的关键字为"others"),默认开启。
 更新[QAPMConfig getInstance].blueConfig.monitorOtherStageEnable
 在退后台的时候由于线程优先级降低，会使检测时间产生极大误差，强烈建议退后台的时候调用[QAPMBlueProfile updateMonitorOtherStageEnable:NO]关闭监控，在进前台时可以恢复监控！
 */
+ (void)updateMonitorOtherStageEnable:(BOOL)enable;

/**
 滑动场景区分，如果不需要则设置为0
 滑动结束时调用
 
 * @param type 设置为0时只有“Normal_Scroll"的数据，当设置为其他值时，掉帧数据里面会多一个类型为"UserDefineScollType_x"的数据
 */
+ (void)setScrollType:(int32_t)type;


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol QAPMYellowProfileDelegate <NSObject>

/**
 VC发生泄漏时的回调接口

 @param vc VC类名
 @param seq VC操作序列
 @param stack 内存方法的堆栈信息
 */
- (void)handleVCLeak:(UIViewController *)vc oprSeq:(NSString *)seq stackInfo:(NSString *)stack;

/**
 UIView发生泄漏时的回调接口
 
 @param view   类名
 @param detail   UIView详细信息
 @param hierarchy 发生泄漏的UIView的层级信息
 @param stack 内存方法的堆栈信息
 */

- (void)handleUIViewLeak:(UIView *)view detail:(NSString *)detail hierarchyInfo:(NSString *)hierarchy stackInfo:(NSString *)stack;

@end

@interface QAPMYellowProfile : NSObject

/**
 设置VC白名单类(对于需要在VC退出后驻留内存的VC)

 @param set 白名单VC，set中的对象为NSString对象，是白名单VC类名，如果没有白名单则不设置
 @param array 白名单基类VC，array中的对象为NSString对象，是白名单VC基类名，这些基类对象的所有子类都添加白名单
 */
+ (void)setWhiteVCList:(NSSet *)set baseVCArray:(NSArray *)array;

/**
 针对白名单VC，可自定义检测时机，非白名单VC无需实现
 注意：该方法在VC退出后调用，注意不要在dealloc方法中调用改方法，因为VC内存泄漏时无法执行dealloc

 @param VC 白名单VC
 */
+ (void)startVCLeakObservation:(UIViewController *)VC;

/**
 设置该对象为白名单对象，无需监控

 @param obj 白名单对象
 */
+ (void)markedAsWhiteObj:(NSObject *)obj;


/**
 设置QAPMYellowProfileDelegate

 @param delegate delegate
 */
+ (void)setYellowProfileDelegate:(id<QAPMYellowProfileDelegate>)delegate;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol QAPMVCTimeProfileDelegate <NSObject>

/**
 @param vc             监控的VC
 @param lifeCycleState 所处在的VC生命周期
 @param beginTime      进入该生命周期的时间
 @param endTime        离开该生命周期的时间
 @param timeDiff       在该生命周期的耗时
 @param nowTime        收集信息的时间戳
 @param stack      堆栈信息
 */

- (void)className:(NSString *)vc lifeCycleState:(NSString *)lifeCycleState beginTime:(NSString *)beginTime endTime:(NSString *)endTime timeDiff:(NSString *)timeDiff nowTime:(NSString *)nowTime stackInfo:(NSString *)stack;

@end

@interface QAPMVCTimeProfile : NSObject

/**
 设置QAPMVCTimeProfileDelegate

 @param delegate delegate
 */
+ (void)setQAPMVCTimeProfileDelegate:(id<QAPMVCTimeProfileDelegate>)delegate;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface QAPMQQLeakProfile : NSObject


/**
 开始记录内存分配堆栈，需要开启后才能进行检测。
 */
+ (void)startStackLogging;
    

/**
 停止记录内存分配堆栈
 */
+ (void)stopStackLogging;
    

/**
 执行一次泄露检测，建议在主线程调用，该操作会挂起所有子线程进行泄露检测（该操作较耗时，平均耗时在1s以上，请限制调用频率）
 */
+ (void)executeLeakCheck;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface QAPMWebViewProfile : NSObject

/**
 @param breadCrumbBuckets  自定义上报雅典娜的分桶
 @return 返回注入的基本信息，包含QAPM的初始化信息
*/
+ (NSString *)qapmBaseInfo:(NSString *) breadCrumbBuckets;

/**
 @return 注入js的初始化信息，请在qapmBaseInfo方法调用完之后调用
*/
+ (NSString *)resetConfig;

/**
 @return 注入启动js监控的信息，请在resetConfig方法调用完之后调用
*/
+ (NSString *)qapmJsStart;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface QAPMResourceMonitorProfile : NSObject

/**
 设置资源使用监控起始标记

 @param tag tag名称
 */
+ (void)setBeginTag:(NSString * __nonnull)tag;


/**
 设置资源使用监控结束标记

 @param tag tag名称
 */
+ (void)setStopTag:(NSString * __nonnull)tag;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface QAPMCrashMonitorProfile : NSObject

/**
 Crash监控是否在运行

 @return YES or NO
 */
+ (BOOL)isRunnning;

@end

NS_ASSUME_NONNULL_END
