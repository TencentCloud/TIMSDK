
#import <Foundation/Foundation.h>
#import "TUICallModel.h"
#import "TUICall.h"
#import "TUICall+Signal.h"

@interface TUICallManager : NSObject

/**
 *  获取 TUICallManager 管理实例
 */
+(TUICallManager *)shareInstance;

/**
 *  初始化通话模块，TUIKit 初始化的时候调用
 */
- (void)initCall;

/**
 *  反初始化通话模块
 */
- (void)unInitCall;

/**
 *  发起视频通话
 *
 *  @param groupID 群通话的 groupID，如果是 C2C 通话，groupID 传 nil
 *  @param userID C2C 通话的 userID，如果是群通话，userID 传 nil
 *  @param callType 视频通话类型，目前支持视频通话和语音通话
 */
- (void)call:(NSString *)groupID userID:(NSString *)userID callType:(CallType)callType;

/**
 *  收到群通话邀请 APNs
 */
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

/**
 检查麦克风授权
 
 @return 是否具有麦克风权限
 */
- (BOOL)checkAudioAuthorization;

/**
 检测摄像头授权
 
 @return 是否具有摄像头权限
 */
- (BOOL)checkVideoAuthorization;

@end

