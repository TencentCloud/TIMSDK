export const ACTION = {
    VIDEO_AUDIO_CALL:1,
    // VIDEO_CALL_ACTION_ERROR: -2,
    // VIDEO_CALL_ACTION_UNKNOWN: -1,
    VIDEO_CALL_ACTION_DIALING: 0, // 正在呼叫
    VIDEO_CALL_ACTION_SPONSOR_CANCEL: 2, // 发起人取消
    VIDEO_CALL_ACTION_REJECT: 4, // 拒接电话
    VIDEO_CALL_ACTION_SPONSOR_TIMEOUT: 5, // 无人接听
    VIDEO_CALL_ACTION_ACCEPTED: 3, // 连接进入通话
    VIDEO_CALL_ACTION_HANGUP: 5, // 挂断
    // VIDEO_CALL_ACTION_LINE_BUSY: 5 // 电话占线
}
/**
 * 1: 仅仅是一个带链接的文本消息
 * 2: iOS支持的视频通话版本，后续已经不兼容
 * 3: Android/iOS/Web互通的视频通话版本
 */
export const VERSION = 3
