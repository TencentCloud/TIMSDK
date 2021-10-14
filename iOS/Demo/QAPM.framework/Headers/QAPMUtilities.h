//
//  QAPMUtilities.h
//  QAPM
//
//  Created by Cass on 2018/11/7.
//  Copyright © 2018 cass. All rights reserved.
//

#ifndef QAPMUtilities_h
#define QAPMUtilities_h

/**
 日志级别
 */
typedef NS_ENUM(NSInteger, QAPMLoggerLevel) {
    ///外发版本log
    QAPMLogLevel_Event,
    ///灰度和内部版本log
    QAPMLogLevel_Info,
    ///内部版本log
    QAPMLogLevel_Debug,
};

/**
 开启功能类型
 */
typedef NS_OPTIONS(NSUInteger, QAPMMonitorType) {
    
    QAPMMonitorTypeNone                     = 1 << 0,
    
    /// Blue(检测卡顿功能)
    QAPMMonitorTypeBlue                     = 1 << 3,
    
    /// 大块内存分配监控功能
    QAPMMonitorTypeBigChunkMemoryMonitor    = 1 << 4,

    /**
     QQLeak(检测内存对象泄露功能)
     开启后，会记录对象分配的堆栈，不支持模拟器。
     执行检测一次检测请调用: [QAPMQQLeakProfile executeLeakCheck];
     执行一次泄露检测，建议在主线程调用，该操作会挂起所有子线程进行泄露检测（该操作较耗时，平均耗时在1s以上，请限制调用频率）。
     建议研发流程内使用。
     */
    QAPMMonitorTypeQQLeak                   = 1 << 5,
    
    /// Yellow(检测VC泄露功能)
    QAPMMonitorTypeYellow                   = 1 << 6,
    
    /// 内存最大使用值监控(触顶率)
    QAPMMonitorTypeMaxMemoryStatistic       = 1 << 7,
    
    
    /// 资源使用情况监控功能（每隔1s采集一次资源）
    QAPMMonitorTypeResourceMonitor          = 1 << 9,
    
    /// KSCrash监控功能
    QAPMMonitorTypeCrash                    = 1 << 10,
    
    /// foom监控功能
    QAPMMonitorTypeFoom                     = 1 << 11,
    
    /// Web Monitor (Web性能监控)
    QAPMMonitorTypeWebMonitor               = 1 << 12,

    
    QAPMMonitorTypeHTTPMonitor              = 1 << 13,
    
    /// JSError
    QAPMMonitorTypeJSError                  = 1 << 14,
        
    /// 用户行为监控功能
    QAPMMonitorTypeIUPMonitor               = 1 << 15,
    
    //耗电监控功能
    QAPMMonitorTypePowerConsume             = 1 << 16,
    
    
    ///VC耗时监控功能
    QAPMMonitorTypeVCTimeProfiler           = 1 << 18,
    
    /// deadlock监控功能
    QAPMMonitorTypeDeadlock                 = 1 << 19,
    
};

/**
 上报事件类型
 */
typedef NS_ENUM(NSInteger, QAPMUploadEventType) {
    /// 卡顿
    QAPMUploadEventTypeLAG                  = 0,
    /// foom
    QAPMUploadEventTypeFoom                 = 1,
    /// deadlock
    QAPMUploadEventTypeDeadlock             = 2,
    //普通奔溃
    QAPMUploadEventTypeCrash                = 3,
    
};

/**
 触发事件类型
 */
typedef NS_ENUM(NSInteger, QAPMEventType) {
    /// 卡顿
    QAPMEventTypeLAG                       = 0,
    /// VC泄露
    QAPMEventTypeVCLeak                    = 1,
    /// Sigkill
    QAPMEventTypeSigkill                   = 2,
    /// Normal crash
    QAPMEventTypeCrash                     = 3,
    /// 大块内存分配
    QAPMEventTypeBigChunkMemory            = 4,
    ///启动耗时
    QAPMEventTypeUITime                    = 5,
    ///资源采集
    QAPMEventTypeGatheringResource         = 6,
    ///触顶率
    QAPMEventTypeCelingRate                = 7,
    ///对象泄漏检测
    QAPMEventTypeObjectLeak                = 8,
    ///网络错误
    QAPMEventTypeNetworkError              = 9,
    ///网络慢请求
    QAPMEventTypeNetworkSlowRequest        = 10,
    ///VC页面耗时
    QAPMEventTypeVCTimeProfiler            = 11,
    ///耗电监控
    QAPMEventTypePowerConsume              = 12,
    ///app进入前台
    QAPMEventTypeForeground                = 13,
    ///appa进入后台
    QAPMEventTypeBackground                = 14,
};


/**
 监控功能状态
 */
typedef NS_ENUM(NSInteger, QAPMMonitorTypeState) {
    /// 用户未设置开启功能
    QAPMMonitorTypeStateUnSetting                = 0,
    /// 用户设置开启，等待获取后台配置中
    QAPMMonitorTypeStateWaittingServerConfig     = 1,
    /// 用户设置开启，但是后台配置不允许开启
    QAPMMonitorTypeStateServerNotAllow           = 2,
    /// 设置开启功能，但是未命中用户抽样率
    QAPMMonitorTypeStateMissSampleRate           = 3,
    /// 功能运行中或者可以使用
    QAPMMonitorTypeStateOpening                  = 4,
};

/**
 用于输出SDK调试log的回调
 */
typedef void(*QAPM_Log_Callback)(QAPMLoggerLevel level, const char* log);

/**
 功能开启时的回调，用于所有输出上报事件标识的回调
 */
typedef void(*QAPMMonitorStartCallback)(NSMutableDictionary *dictionary);

/**
 用于输出上报事件
 */
typedef NSDictionary *(*QAPMUploadEventCallback)(QAPMUploadEventType eventType, id stackInfo);


/**
 触发事件时回调
 */
typedef NSString *(*QAPMEventCallback)(NSString *eventId, NSTimeInterval eventTime, QAPMEventType eventType, NSString *eventLabel);

extern QAPMUploadEventCallback uploadEventCallback;

extern QAPMMonitorStartCallback monitorStartCallback;

extern QAPMEventCallback qapmEventCallback;


#endif /* QAPMUtilities_h */
