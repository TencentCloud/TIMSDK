#import "TXLiveRecordTypeDef.h"


/**
 * 短视频录制回调定义
 */
@protocol TXLiveRecordListener <NSObject>
@optional

/**
 * 短视频录制进度
 */
-(void) onRecordProgress:(NSInteger)milliSecond;

/**
 * 短视频录制完成
 */
-(void) onRecordComplete:(TXRecordResult*)result;

/**
 * 短视频录制事件通知
 */
-(void) onRecordEvent:(NSDictionary*)evt;

@end


