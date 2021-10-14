#ifndef __TX_LIVE_SDK_EVENT_DEF_H__
#define __TX_LIVE_SDK_EVENT_DEF_H__

#include "TXLiteAVCode.h"

enum EventID
{
    /**********************************************************************************
     *                               推流事件列表
     **********************************************************************************/
    PUSH_EVT_CONNECT_SUCC                       = EVT_RTMP_PUSH_CONNECT_SUCC,           ///< 直播: 已经连接RTMP推流服务器
    PUSH_EVT_PUSH_BEGIN                         = EVT_RTMP_PUSH_BEGIN,                  ///< 直播: 已经与RTMP服务器握手完毕，开始推流
    PUSH_EVT_OPEN_CAMERA_SUCC                   = EVT_CAMERA_START_SUCC,                ///< 打开摄像头成功
    PUSH_EVT_CHANGE_RESOLUTION                  = EVT_UP_CHANGE_RESOLUTION,             ///< 推流动态调整分辨率
    PUSH_EVT_CHANGE_BITRATE                     = EVT_UP_CHANGE_BITRATE,                ///< 推流动态调整码率
    PUSH_EVT_FIRST_FRAME_AVAILABLE              = EVT_FIRST_FRAME_AVAILABLE,            ///< 首帧画面采集完成
    PUSH_EVT_START_VIDEO_ENCODER                = EVT_START_VIDEO_ENCODER,              ///< 编码器启动
    PUSH_EVT_ROOM_IN                            = EVT_ROOM_ENTER,                       ///< 已经在webrtc房间里面，进房成功后通知
    PUSH_EVT_ROOM_IN_FAILED                     = EVT_ROOM_ENTER_FAILED,                ///< 进房失败通知
    PUSH_EVT_ROOM_OUT                           = EVT_ROOM_EXIT,                        ///< 不在webrtc房间里面，进房失败或者中途退出房间时通知
    PUSH_EVT_ROOM_USERLIST                      = EVT_ROOM_USERLIST,                    ///< 下发webrtc房间成员列表(不包括自己)
    PUSH_EVT_ROOM_NEED_REENTER                  = EVT_ROOM_NEED_REENTER,                ///< WiFi切换到4G会触发断线重连，此时需要重新进入webrtc房间(拉取最优的服务器地址)
    PUSH_EVT_ROOM_USER_ENTER                    = EVT_ROOM_USER_ENTER,                  ///< 进房通知
    PUSH_EVT_ROOM_USER_EXIT                     = EVT_ROOM_USER_EXIT,                   ///< 退房通知
    PUSH_EVT_ROOM_USER_VIDEO_STATE              = EVT_ROOM_USER_VIDEO_STATE,            ///< 视频状态位变化通知
    PUSH_EVT_ROOM_USER_AUDIO_STATE              = EVT_ROOM_USER_AUDIO_STATE,            ///< 音频状态位变化通知
    
    PUSH_ERR_OPEN_CAMERA_FAIL                   = ERR_CAMERA_START_FAIL,                ///< 打开摄像头失败
    PUSH_ERR_OPEN_MIC_FAIL                      = ERR_MIC_START_FAIL,                   ///< 打开麦克风失败
    PUSH_ERR_VIDEO_ENCODE_FAIL                  = ERR_VIDEO_ENCODE_FAIL,                ///< 视频编码失败
    PUSH_ERR_AUDIO_ENCODE_FAIL                  = ERR_AUDIO_ENCODE_FAIL,                ///< 音频编码失败
    PUSH_ERR_UNSUPPORTED_RESOLUTION             = ERR_UNSUPPORTED_RESOLUTION,           ///< 不支持的视频分辨率
    PUSH_ERR_UNSUPPORTED_SAMPLERATE             = ERR_UNSUPPORTED_SAMPLERATE,           ///< 不支持的音频采样率
    PUSH_ERR_NET_DISCONNECT                     = ERR_RTMP_PUSH_NET_DISCONNECT,         ///< 网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流
    PUSH_ERR_AUDIO_SYSTEM_NOT_WORK              = -1308,                                ///< 系统异常,录音失败
    PUSH_ERR_INVALID_ADDRESS                    = ERR_RTMP_PUSH_INVALID_ADDRESS,        ///< 推流地址非法
    
    PUSH_WARNING_NET_BUSY                       = WARNING_NET_BUSY,                     ///< 网络状况不佳：上行带宽太小，上传数据受阻
    PUSH_WARNING_RECONNECT                      = WARNING_RTMP_SERVER_RECONNECT,        ///< 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
    PUSH_WARNING_HW_ACCELERATION_FAIL           = WARNING_HW_ENCODER_START_FAIL,        ///< 硬编码启动失败，采用软编码
    PUSH_WARNING_VIDEO_ENCODE_FAIL              = 1104,                                 ///< 视频编码失败,非致命错,内部会重启编码器
    PUSH_WARNING_BEAUTYSURFACE_VIEW_INIT_FAIL   = 1105,                                 ///< 视频编码码率异常，警告
    PUSH_WARNING_VIDEO_ENCODE_BITRATE_OVERFLOW  = 1106,                                 ///< 视频编码码率异常，警告
    PUSH_WARNING_DNS_FAIL                       = WARNING_RTMP_DNS_FAIL,                ///< RTMP -DNS解析失败
    PUSH_WARNING_SEVER_CONN_FAIL                = WARNING_RTMP_SEVER_CONN_FAIL,         ///< RTMP服务器连接失败
    PUSH_WARNING_SHAKE_FAIL                     = WARNING_RTMP_SHAKE_FAIL,              ///< RTMP服务器握手失败
    PUSH_WARNING_SERVER_DISCONNECT              = WARNING_RTMP_SERVER_BREAK_CONNECT,    ///< RTMP服务器主动断开，请检查推流地址的合法性或防盗链有效期
    PUSH_WARNING_READ_WRITE_FAIL                = WARNING_RTMP_READ_WRITE_FAIL,         ///< RTMP 读/写失败，将会断开连接。
    PUSH_WARNING_HEVC_ENCODE_NOT_SUPPORT        = ERR_HEVC_ENCODE_NOT_SUPPORT,          ///< 265编码判断不支持
    
    /*内部事件*/INNER_EVT_SET_BITRATE_4_SCREEN_CAPTURE = 100001,                         ///< 动态设置录屏编码码率
    /*内部事件*/INNER_EVT_BGM_PLAY_FINISH              = 100002,                         ///< BGM播放完毕
    
    

    /**********************************************************************************
     *                               播放事件列表
     **********************************************************************************/
    PLAY_EVT_CONNECT_SUCC                       = EVT_PLAY_LIVE_STREAM_CONNECT_SUCC,    ///< 直播，已经连接RTMP拉流服务器
    PLAY_EVT_RTMP_STREAM_BEGIN                  = EVT_PLAY_LIVE_STREAM_BEGIN,           ///< 直播，已经与RTMP服务器握手完毕，开始拉流
    PLAY_EVT_RCV_FIRST_I_FRAME                  = EVT_RENDER_FIRST_I_FRAME,             ///< 渲染首个视频数据包(IDR)
    PLAY_EVT_RCV_FIRST_AUDIO_FRAME              = EVT_AUDIO_JITTER_STATE_FIRST_PLAY,    ///< 音频首次播放
    PLAY_EVT_PLAY_BEGIN                         = EVT_VIDEO_PLAY_BEGIN,                 ///< 视频播放开始
    PLAY_EVT_PLAY_PROGRESS                      = EVT_VIDEO_PLAY_PROGRESS,              ///< 视频播放进度
    PLAY_EVT_PLAY_END                           = EVT_VIDEO_PLAY_END,                   ///< 视频播放结束
    PLAY_EVT_PLAY_LOADING                       = EVT_VIDEO_PLAY_LOADING,               ///< 视频播放loading
    PLAY_EVT_START_VIDEO_DECODER                = EVT_START_VIDEO_DECODER,              ///< 解码器启动
    PLAY_EVT_CHANGE_RESOLUTION                  = EVT_DOWN_CHANGE_RESOLUTION,           ///< 视频分辨率改变
    PLAY_EVT_GET_PLAYINFO_SUCC                  = EVT_GET_VODFILE_MEDIAINFO_SUCC,       ///< 获取点播文件信息成功
    PLAY_EVT_CHANGE_ROTATION                    = EVT_VIDEO_CHANGE_ROTATION,            ///< MP4视频旋转角度
    PLAY_EVT_GET_MESSAGE                        = EVT_PLAY_GET_MESSAGE,                 ///< 消息事件
    PLAY_EVT_VOD_PLAY_PREPARED                  = EVT_VOD_PLAY_PREPARED,                ///< 点播，视频加载完毕
    PLAY_EVT_VOD_LOADING_END                    = EVT_VOD_PLAY_LOADING_END,             ///< 点播，loading结束
    PLAY_EVT_STREAM_SWITCH_SUCC                 = EVT_PLAY_LIVE_STREAM_SWITCH_SUCC,     ///< 直播，切流成功（切流可以播放不同画面大小的视频）
    PLAY_EVT_GET_METADATA                       = EVT_PLAY_GET_METADATA,                ///< TXLivePlayer 接收到视频流中的 metadata 头信息（一条视频流仅触发一次）
    PLAY_EVT_GET_FLVSESSIONKEY                  = EVT_PLAY_GET_FLVSESSIONKEY,           ///< TXLivePlayer 接收到http响应头中的 flvSessionKey 信息
    PLAY_EVT_AUDIO_SESSION_INTERRUPT            = EVT_AUDIO_SESSION_INTERRUPT,          ///< Audio Session Interrupt事件

    
    PLAY_ERR_NET_DISCONNECT                     = ERR_PLAY_LIVE_STREAM_NET_DISCONNECT,  ///< 直播，网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放

    PLAY_ERR_GET_RTMP_ACC_URL_FAIL              = ERR_GET_RTMP_ACC_URL_FAIL,            ///< 直播，获取加速拉流地址失败。这是由于您传给 liveplayer 的加速流地址中没有携带 txTime 和 txSecret 签名，或者是签名计算的不对。出现这个错误时，liveplayer 会放弃拉取加速流转而拉取 CDN 上的视频流，从而导致延迟很大。
    PLAY_ERR_FILE_NOT_FOUND                     = ERR_FILE_NOT_FOUND,                   ///< 播放文件不存在
    PLAY_ERR_HEVC_DECODE_FAIL                   = ERR_HEVC_DECODE_FAIL,                 ///< H265解码失败
    PLAY_ERR_HLS_KEY                            = ERR_VOD_DECRYPT_FAIL,                 ///< HLS解码key获取失败
    PLAY_ERR_GET_PLAYINFO_FAIL                  = ERR_GET_VODFILE_MEDIAINFO_FAIL,       ///< 获取点播文件信息失败
    PLAY_ERR_STREAM_SWITCH_FAIL                 = ERR_PLAY_LIVE_STREAM_SWITCH_FAIL,     ///< 直播，切流失败（切流可以播放不同画面大小的视频）
    
    PLAY_WARNING_VIDEO_DECODE_FAIL              = WARNING_VIDEO_FRAME_DECODE_FAIL,      ///< 当前视频帧解码失败
    PLAY_WARNING_AUDIO_DECODE_FAIL              = WARNING_AUDIO_FRAME_DECODE_FAIL,      ///< 当前音频帧解码失败
    PLAY_WARNING_RECONNECT                      = WARNING_LIVE_STREAM_SERVER_RECONNECT, ///< 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
    PLAY_WARNING_RECV_DATA_LAG                  = WARNING_RECV_DATA_LAG,                ///< 网络来包不稳：可能是下行带宽不足，或由于主播端出流不均匀
    PLAY_WARNING_VIDEO_PLAY_LAG                 = WARNING_VIDEO_PLAY_LAG,               ///< 当前视频播放出现卡顿（用户直观感受）
    PLAY_WARNING_HW_ACCELERATION_FAIL           = WARNING_HW_DECODER_START_FAIL,        ///< 硬解启动失败，采用软解
    PLAY_WARNING_VIDEO_DISCONTINUITY            = 2107,                                 ///< 当前视频帧不连续，可能丢帧
    PLAY_WARNING_FIRST_IDR_HW_DECODE_FAIL       = WARNING_VIDEO_DECODER_HW_TO_SW,       ///< 当前流硬解第一个I帧失败，SDK自动切软解
    PLAY_WARNING_DNS_FAIL                       = WARNING_RTMP_DNS_FAIL,                ///< RTMP -DNS解析失败
    PLAY_WARNING_SEVER_CONN_FAIL                = WARNING_RTMP_SEVER_CONN_FAIL,         ///< RTMP服务器连接失败
    PLAY_WARNING_SHAKE_FAIL                     = WARNING_RTMP_SHAKE_FAIL,              ///< RTMP服务器握手失败
    PLAY_WARNING_SERVER_DISCONNECT              = WARNING_RTMP_SERVER_BREAK_CONNECT,    ///< RTMP服务器主动断开
    PLAY_WARNING_READ_WRITE_FAIL                = WARNING_RTMP_READ_WRITE_FAIL,         ///< RTMP 读/写失败，将会断开连接。
    
    /*UGC*/UGC_WRITE_FILE_FAIL                  = 4001,                                 ///< UGC写文件失败
};

#endif // __TX_LIVE_SDK_TYPE_DEF_H__
