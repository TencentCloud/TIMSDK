/**
 * Module:   TRTCCloudDelegate @ TXLiteAVSDK
 * Function: 腾讯云实时音视频的事件回调接口
 */
/// @defgroup TRTCCloudCallback_cplusplus TRTCCloudCallback
/// 腾讯云实时音视频的事件回调接口
/// @{
#ifndef __TRTCCLOUDCALLBACK_H__
#define __TRTCCLOUDCALLBACK_H__

#include "TRTCTypeDef.h"
#include "ITXDeviceManager.h"
#include "TXLiteAVCode.h"
#include "ITRTCStatistics.h"

namespace liteav {

class ITRTCCloudCallback {
   public:
    virtual ~ITRTCCloudCallback() {
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    错误和警告事件
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 错误和警告事件
    /// @{

    /**
     * 1.1 错误事件回调
     *
     * 错误事件，表示 SDK 抛出的不可恢复的错误，比如进入房间失败或设备开启失败等。
     * 参考文档：[错误码表](https://cloud.tencent.com/document/product/647/32257)
     *
     * @param errCode 错误码
     * @param errMsg  错误信息
     * @param extInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
     */
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* extraInfo) = 0;

    /**
     * 1.2 警告事件回调
     *
     * 警告事件，表示 SDK 抛出的提示性问题，比如视频出现卡顿或 CPU 使用率太高等。
     * 参考文档：[错误码表](https://cloud.tencent.com/document/product/647/32257)
     *
     * @param warningCode 警告码
     * @param warningMsg 警告信息
     * @param extInfo 扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
     */
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* extraInfo) = 0;

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    房间相关事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 房间相关事件回调
    /// @{

    /**
     * 2.1 进入房间成功与否的事件回调
     *
     * 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 TRTCCloudDelegate 的 onEnterRoom(result) 回调：
     *  - 如果加入成功，回调 result 会是一个正数（result > 0），代表进入房间所消耗的时间，单位是毫秒（ms）。
     *  - 如果加入失败，回调 result 会是一个负数（result < 0），代表失败原因的错误码。
     *  进房失败的错误码含义请参见[错误码表](https://cloud.tencent.com/document/product/647/32257)。
     *
     * @note
     * 1. 在 Ver6.6 之前的版本，只有进房成功会抛出 onEnterRoom(result) 回调，进房失败由 onError() 回调抛出。
     * 2. 在 Ver6.6 之后的版本：无论进房成功或失败，均会抛出 onEnterRoom(result) 回调，同时进房失败也会有 onError() 回调抛出。
     *
     * @param result result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
     */
    virtual void onEnterRoom(int result) = 0;

    /**
     * 2.2 离开房间的事件回调
     *
     * 调用 TRTCCloud 中的 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。
     * 待 SDK 占用的所有资源释放完毕后，SDK 会抛出 onExitRoom() 回调通知到您。
     *
     * 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来后再执行相关操作。
     * 否则可能会遇到例如摄像头、麦克风设备被强占等各种异常问题。
     *
     * @param reason 离开房间原因，0：主动调用 exitRoom 退出房间；1：被服务器踢出当前房间；2：当前房间整个被解散。
     */
    virtual void onExitRoom(int reason) = 0;

    /**
     * 2.3 切换角色的事件回调
     *
     * 调用 TRTCCloud 中的 switchRole() 接口会切换主播和观众的角色，该操作会伴随一个线路切换的过程，
     * 待 SDK 切换完成后，会抛出 onSwitchRole() 事件回调。
     *
     * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
     * @param errMsg  错误信息。
     */
    virtual void onSwitchRole(TXLiteAVError errCode, const char* errMsg) {
    }

    /**
     * 2.4 切换房间的结果回调
     *
     * 调用 TRTCCloud 中的 switchRoom() 接口可以让用户快速地从一个房间切换到另一个房间，
     * 待 SDK 切换完成后，会抛出 onSwitchRoom() 事件回调。
     *
     * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
     * @param errMsg  错误信息。
     */
    virtual void onSwitchRoom(TXLiteAVError errCode, const char* errMsg) {
    }

    /**
     * 2.5 请求跨房通话的结果回调
     *
     * 调用 TRTCCloud 中的 connectOtherRoom() 接口会将两个不同房间中的主播拉通视频通话，也就是所谓的“主播PK”功能。
     * 调用者会收到 onConnectOtherRoom() 回调来获知跨房通话是否成功，
     * 如果成功，两个房间中的所有用户都会收到来自另一个房间中的 PK 主播的 onUserVideoAvailable() 回调。
     *
     * @param userId  要跨房通话的另一个房间中的主播的用户 ID。
     * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
     * @param errMsg  错误信息。
     */
    virtual void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) {
    }

    /**
     * 2.6 结束跨房通话的结果回调
     */
    virtual void onDisconnectOtherRoom(TXLiteAVError errCode, const char* errMsg) {
    }

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    用户相关事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 用户相关事件回调
    /// @{

    /**
     * 3.1 有用户加入当前房间
     *
     * 出于性能方面的考虑，在 TRTC 两种不同的应用场景（即 AppScene，在 enterRoom 时通过第二个参数指定）下，该通知的行为会有差别：
     *  - 直播类场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：该场景下的用户区分主播和观众两种角色，只有主播进入房间时才会触发该通知，观众进入房间时不会触发该通知。
     *  - 通话类场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下的用户没有角色的区分（可认为都是主播），任何用户进入房间都会触发该通知。
     *
     * @note
     * 1. 事件回调 onRemoteUserEnterRoom 和 onRemoteUserLeaveRoom 只适用于维护当前房间里的“用户列表”，有此事件回调不代表一定有视频画面。
     * 2. 如果需要显示远程画面，请监听代表某个用户是否有视频画面的 onUserVideoAvailable() 事件回调。
     * @param userId 远端用户的用户标识
     */
    virtual void onRemoteUserEnterRoom(const char* userId) {
    }

    /**
     * 3.2 有用户离开当前房间
     *
     * 与 onRemoteUserEnterRoom 相对应，在两种不同的应用场景（即 AppScene，在 enterRoom 时通过第二个参数指定）下，该通知的行为会有差别：
     *  - 直播类场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：只有主播离开房间时才会触发该通知，观众离开房间不会触发该通知。
     *  - 通话类场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户的离开都会触发该通知。
     *
     * @param userId 远端用户的用户标识
     * @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
     */
    virtual void onRemoteUserLeaveRoom(const char* userId, int reason) {
    }

    /**
     * 3.3 某远端用户发布/取消了主路视频画面
     *
     * “主路画面”一般被用于承载摄像头画面。当您收到 onUserVideoAvailable(userId, true) 通知时，表示该路画面已经有可播放的视频帧到达。
     * 此时，您需要调用 {@link startRemoteView} 接口订阅该用户的远程画面，订阅成功后，您会继续收到该用户的首帧画面渲染回调 onFirstVideoFrame(userid)。
     *
     * 当您收到 onUserVideoAvailable(userId, false) 通知时，表示该路远程画面已经被关闭，关闭的原因可能是该用户调用了 {@link muteLocalVideo} 或 {@link stopLocalPreview}。
     *
     * @param userId 远端用户的用户标识
     * @param available 该用户是否发布（或取消发布）了主路视频画面，true: 发布；false：取消发布。
     */
    virtual void onUserVideoAvailable(const char* userId, bool available) {
    }

    /**
     * 3.4 某远端用户发布/取消了辅路视频画面
     *
     * “辅路画面”一般被用于承载屏幕分享的画面。当您收到 onUserSubStreamAvailable(userId, true) 通知时，表示该路画面已经有可播放的视频帧到达。
     * 此时，您需要调用 {@link startRemoteSubStreamView} 接口订阅该用户的远程画面，订阅成功后，您会继续收到该用户的首帧画面渲染回调 onFirstVideoFrame(userid)。
     *
     * @note 显示辅路画面使用的函数是 {@link startRemoteSubStreamView} 而非 {@link startRemoteView}。
     *
     * @param userId 远端用户的用户标识
     * @param available 该用户是否发布（或取消发布）了辅路视频画面，true: 发布；false：取消发布。
     */
    virtual void onUserSubStreamAvailable(const char* userId, bool available) {
    }

    /**
     * 3.5 某远端用户发布/取消了自己的音频
     *
     * 当您收到 onUserAudioAvailable(userId, true) 通知时，表示该用户发布了自己的声音，此时 SDK 的表现为：
     * - 在自动订阅模式下，您无需做任何操作，SDK 会自动播放该用户的声音。
     * - 在手动订阅模式下，您可以通过 {@link muteRemoteAudio}(userid, false) 来播放该用户的声音。
     *
     * @note SDK 默认使用自动订阅模式，您可以通过 {@link setDefaultStreamRecvMode} 设置为手动订阅，但需要在您进入房间之前调用才生效。
     *
     * @param userId 远端用户的用户标识
     * @param available 该用户是否发布（或取消发布）了自己的音频，true: 发布；false：取消发布。
     */
    virtual void onUserAudioAvailable(const char* userId, bool available) {
    }

    /**
     * 3.6 SDK 开始渲染自己本地或远端用户的首帧画面
     *
     * SDK 会在渲染自己本地或远端用户的首帧画面时抛出该事件，您可以通过回调事件中的 userId 参数来判断事件来自于“本地”还是来自于“远端”。
     * - 如果 userId 为空值，代表 SDK 已经开始渲染自己本地的视频画面，不过前提是您已经调用了 {@link startLocalPreview} 或 {@link startScreenCapture}。
     * - 如果 userId 不为空，代表 SDK 已经开始渲染远端用户的视频画面，不过前提是您已经调用了 {@link startRemoteView} 订阅了该用户的视频画面。
     *
     * @note
     * 1. 只有当您调用了 {@link startLocalPreview} 或 {@link startScreenCapture} 之后，才会触发自己本地的首帧画面事件回调。
     * 2. 只有当您调用了 {@link startRemoteView} 或 {@link startRemoteSubStreamView} 之后，才会触发远端用户的首帧画面事件回调。
     *
     * @param userId 本地或远端的用户标识，如果 userId 为空值代表自己本地的首帧画面已到来，userId 不为空则代表远端用户的首帧画面已到来。
     * @param streamType 视频流类型：主路（Main）一般用于承载摄像头画面，辅路（Sub）一般用于承载屏幕分享画面。
     * @param width  画面的宽度。
     * @param height 画面的高度。
     */
    virtual void onFirstVideoFrame(const char* userId, const TRTCVideoStreamType streamType, const int width, const int height) {
    }

    /**
     * 3.7 SDK 开始播放远端用户的首帧音频
     *
     * SDK 会在播放远端用户的首帧音频时抛出该事件，本地音频的首帧事件暂不抛出。
     *
     * @param userId 远端用户的用户标识
     */
    virtual void onFirstAudioFrame(const char* userId) {
    }

    /**
     * 3.8 自己本地的首个视频帧已被发布出去
     *
     * 当您成功进入房间并通过 {@link startLocalPreview} 或 {@link startScreenCapture} 开启本地视频采集之后（开启采集和进入房间的先后顺序无影响），
     * SDK 就会开始进行视频编码，并通过自身的网络模块向云端发布自己本地的视频数据。
     * 当 SDK 成功地向云端送出自己的第一帧视频数据帧以后，就会抛出 onSendFirstLocalVideoFrame 事件回调。
     *
     * @param streamType 视频流类型：主路（Main）一般用于承载摄像头画面，辅路（Sub）一般用于承载屏幕分享画面。
     */
    virtual void onSendFirstLocalVideoFrame(const TRTCVideoStreamType streamType) {
    }

    /**
     * 3.9 自己本地的首个音频帧已被发布出去
     *
     * 当您成功进入房间并通过 {@link startLocalAudio} 开启本地音频采集之后（开启采集和进入房间的先后顺序无影响），
     * SDK 就会开始进行音频编码，并通过自身的网络模块向云端发布自己本地的音频数据。
     * 当 SDK 成功地向云端送出自己的第一帧音频数据帧以后，就会抛出 onSendFirstLocalAudioFrame 事件回调。
     */
    virtual void onSendFirstLocalAudioFrame() {
    }

    /**
     * 3.10 远端视频状态变化的事件回调
     *
     * 您可以通过此事件回调获取远端每一路画面的播放状态（包括 Playing、Loading 和 Stopped 三种状态），从而进行相应的 UI 展示。
     * @param userId 用户标识
     * @param streamType 视频流类型：主路（Main）一般用于承载摄像头画面，辅路（Sub）一般用于承载屏幕分享画面。
     * @param status 视频状态：包括 Playing、Loading 和 Stopped 三种状态。
     * @param reason 视频状态改变的原因
     * @param extrainfo 额外信息
     */
    virtual void onRemoteVideoStatusUpdated(const char* userId, TRTCVideoStreamType streamType, TRTCAVStatusType status, TRTCAVStatusChangeReason reason, void* extrainfo) {
    }

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    网络和技术指标统计回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 网络和技术指标统计回调
    /// @{

    /**
     * 4.1 网络质量的实时统计回调
     *
     * 该统计回调每间隔2秒抛出一次，用于通知 SDK 感知到的当前网络的上行和下行质量。
     * SDK 会使用一组内嵌的自研算法对当前网络的延迟高低、带宽大小以及稳定情况进行评估，并计算出一个的评估结果：
     * 如果评估结果为 1（Excellent） 代表当前的网络情况非常好，如果评估结果为 6（Down）代表当前网络无法支撑 TRTC 的正常通话。
     *
     * @note 回调参数 localQuality 和 remoteQuality 中的 userId 如果为空置，代表本组数据统计的是自己本地的网络质量，否则是代表远端用户的网络质量。
     *
     * @param localQuality 上行网络质量
     * @param remoteQuality 下行网络质量
     */
    virtual void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount) {
    }

    /**
     * 4.2 音视频技术指标的实时统计回调
     *
     * 该统计回调每间隔2秒抛出一次，用于通知 SDK 内部音频、视频以及网络相关的专业技术指标，这些信息在 {@link TRTCStatistics} 均有罗列：
     * - 视频统计信息：视频的分辨率（resolution）、帧率（FPS）和比特率（bitrate）等信息。
     * - 音频统计信息：音频的采样率（samplerate）、声道（channel）和比特率（bitrate）等信息。
     * - 网络统计信息：SDK 和云端一次往返（SDK => Cloud => SDK）的网络耗时（rtt）、丢包率（loss）、上行流量（sentBytes）和下行流量（receivedBytes）等信息。
     *
     * @note 如果您只需要获知当前网络质量的好坏，并不需要花太多时间研究本统计回调，更推荐您使用 {@link onNetworkQuality} 来解决问题。
     * @param statistics 统计数据，包括自己本地的统计信息和远端用户的统计信息，详情请参考 {@link TRTCStatistics}。
     */
    virtual void onStatistics(const TRTCStatistics& statistics) {
    }

    /**
     * 4.3 网速测试的结果回调
     *
     * 该统计回调由 {@link startSpeedTest:} 触发。
     *
     * @param result 网速测试数据数据，包括丢包、往返延迟、上下行的带宽速率，详情请参考 {@link TRTCSpeedTestResult}。
     */
    virtual void onSpeedTestResult(const TRTCSpeedTestResult& result) {
    }

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    与云端连接情况的事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 与云端连接情况的事件回调
    /// @{

    /**
     * 5.1 SDK 与云端的连接已经断开
     *
     * SDK 会在跟云端的连接断开时抛出此事件回调，导致断开的原因大多是网络不可用或者网络切换所致，比如用户在通话中走进电梯时就可能会遇到此事件。
     * 在抛出此事件之后，SDK 会努力跟云端重新建立连接，重连过程中会抛出 {@link onTryToReconnect}，连接恢复后会抛出 {@link onConnectionRecovery} 。
     * 所以，SDK 会在如下三个连接相关的事件中按如下规律切换：
     * <pre>
     *         [onConnectionLost] =====> [onTryToReconnect] =====> [onConnectionRecovery]
     *               /|\                                                     |
     *                |------------------------------------------------------|
     * </pre>
     */
    virtual void onConnectionLost() {
    }

    /**
     * 5.2 SDK 正在尝试重新连接到云端
     *
     * SDK 会在跟云端的连接断开时抛出 {@link onConnectionLost}，之后会努力跟云端重新建立连接并抛出本事件，连接恢复后会抛出 {@link onConnectionRecovery}。
     */
    virtual void onTryToReconnect() {
    }

    /**
     * 5.3 SDK 与云端的连接已经恢复
     *
     * SDK 会在跟云端的连接断开时抛出 {@link onConnectionLost}，之后会努力跟云端重新建立连接并抛出{@link onTryToReconnect}，连接恢复后会抛出本事件回调。
     */
    virtual void onConnectionRecovery() {
    }

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    硬件设备相关事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 硬件设备相关事件回调
    /// @{

    /**
     * 6.1 摄像头准备就绪
     *
     * 当您调用 {@link startLocalPreivew} 之后，SDK 会尝试启动摄像头，如果摄像头能够启动成功就会抛出本事件。
     * 如果启动失败，大概率是因为当前应用没有获得访问摄像头的权限，或者摄像头当前正在被其他程序独占使用中。
     * 您可以通过捕获 {@link onError} 事件回调获知这些异常情况并通过 UI 界面提示用户。
     */
    virtual void onCameraDidReady() {
    }

    /**
     * 6.2 麦克风准备就绪
     *
     * 当您调用 {@link startLocalAudio} 之后，SDK 会尝试启动麦克风，如果麦克风能够启动成功就会抛出本事件。
     * 如果启动失败，大概率是因为当前应用没有获得访问麦克风的权限，或者麦克风当前正在被其他程序独占使用中。
     * 您可以通过捕获 {@link onError} 事件回调获知这些异常情况并通过 UI 界面提示用户。
     */
    virtual void onMicDidReady() {
    }

    /**
     * 6.4 音量大小的反馈回调
     *
     * SDK 可以评估每一路音频的音量大小，并每隔一段时间抛出该事件回调，您可以根据音量大小在 UI 上做出相应的提示，比如“波形图”或“音量槽”。
     * 要完成这个功能， 您需要先调用 {@link enableAudioVolumeEvaluation} 开启这个能力并设定事件抛出的时间间隔。
     * 需要补充说明的是，无论当前房间中是否有人说话，SDK 都会按照您设定的时间间隔定时抛出此事件回调，只不过当没有人说话时，userVolumes 为空，totalVolume 为 0。
     *
     * @note userVolumes 为一个数组，对于数组中的每一个元素，当 userId 为空时表示本地麦克风采集的音量大小，当 userId 不为空时代表远端用户的音量大小。
     *
     * @param userVolumes 是一个数组，用于承载所有正在说话的用户的音量大小，取值范围 0 - 100。
     * @param totalVolume 所有远端用户的总音量大小, 取值范围 0 - 100。
     */
    virtual void onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) {
    }

/**
 * 6.5 本地设备的通断状态发生变化（仅适用于桌面系统）
 *
 * 当本地设备（包括摄像头、麦克风以及扬声器）被插入或者拔出时，SDK 便会抛出此事件回调。
 *
 * @param deviceId 设备 ID
 * @param deviceType 设备类型
 * @param state 通断状态，0：设备已添加；1：设备已被移除；1：设备已启用。
 */
#if TARGET_PLATFORM_DESKTOP
    virtual void onDeviceChange(const char* deviceId, TRTCDeviceType type, TRTCDeviceState state) {
    }
#endif

/**
 * 6.6 当前麦克风的系统采集音量发生变化
 *
 * 在 Mac 或 Windows 这样的桌面操作系统上，用户可以在设置中心找到声音相关的设置面板，并设置麦克风的采集音量大小。
 * 用户将麦克风的采集音量设置得越大，麦克风采集到的声音的原始音量也就会越大，反之就会越小。
 * 在有些型号的键盘以及笔记本电脑上，用户还可以通过按下“禁用麦克风”按钮（图标是一个话筒上上叠加了一道代表禁用的斜线）来将麦克风静音。
 *
 * 当用户通过系统设置界面或者通过键盘上的快捷键设定操作系统的麦克风采集音量时，SDK 便会抛出此事件。
 *
 * @note 您需要调用 {@link enableAudioVolumeEvaluation} 接口并设定（interval>0）开启次事件回调，设定（interval == 0）关闭此事件回调。
 *
 * @param volume 系统采集音量，取值范围 0 - 100，用户可以在系统的声音设置面板上进行拖拽调整。
 * @param muted 麦克风是否被用户禁用了：true 被禁用，false 被启用。
 */
#if TARGET_PLATFORM_DESKTOP
    virtual void onAudioDeviceCaptureVolumeChanged(uint32_t volume, bool muted) {
    }
#endif

/**
 * 6.7 当前系统的播放音量发生变化
 *
 * 在 Mac 或 Windows 这样的桌面操作系统上，用户可以在设置中心找到声音相关的设置面板，并设置系统的播放音量大小。
 * 在有些型号的键盘以及笔记本电脑上，用户还可以通过按下“静音”按钮（图标是一个喇叭上叠加了一道代表禁用的斜线）来将系统静音。
 *
 * 当用户通过系统设置界面或者通过键盘上的快捷键设定操作系统的播放音量时，SDK 便会抛出此事件。
 *
 * @note 您需要调用 {@link enableAudioVolumeEvaluation} 接口并设定（interval>0）开启次事件回调，设定（interval == 0）关闭此事件回调。
 *
 * @param volume 系统播放音量，取值范围 0 - 100，用户可以在系统的声音设置面板上进行拖拽调整。
 * @param muted 系统是否被用户静音了：true 被静音，false 已恢复。
 */
#if TARGET_PLATFORM_DESKTOP
    virtual void onAudioDevicePlayoutVolumeChanged(uint32_t volume, bool muted) {
    }
#endif

/**
 * 6.8 系统声音采集是否被成功开启的事件回调（仅适用于 Mac 系统）
 *
 * 在 Mac 系统上，您可以通过调用 {@link startSystemAudioLoopback} 为当前系统安装一个音频驱动，并让 SDK 通过该音频驱动捕获当前 Mac 系统播放出的声音。
 * 当用于播片教学或音乐直播中，比如老师端可以使用此功能，让 SDK 能够采集老师所播放的电影中的声音，使同房间的学生端也能听到电影中的声音。
 * SDK 会将统声音采集是否被成功开启的结果，通过本事件回调抛出，需要您关注参数中的错误码。
 *
 * @param err ERR_NULL 表示成功，其余值表示失败。
 */
#if TARGET_PLATFORM_MAC
    virtual void onSystemAudioLoopbackError(TXLiteAVError errCode) {
    }
#endif

/**
 * 6.9 测试麦克风时的音量回调
 *
 * 当您调用 {@link startMicDeviceTest} 测试麦克风是否正常工作时，SDK 会不断地抛出此回调，参数中的 volume 代表当前麦克风采集到的音量大小。
 * 如果在测试期间 volume 出现了大小波动的情况，说明麦克风状态健康；如果 volume 的数值始终是 0，说明麦克风的状态异常，需要提示用户进行更换。
 *
 * @param volume 麦克风采集到的音量值，取值范围0 - 100
 */
#if TARGET_PLATFORM_DESKTOP
    virtual void onTestMicVolume(uint32_t volume) {
    }
#endif

/**
 * 6.10 测试扬声器时的音量回调
 *
 * 当您调用 {@link startSpeakerDeviceTest} 测试扬声器是否正常工作时，SDK 会不断地抛出此回调。
 * 参数中的 volume 代表的是 SDK 提交给系统扬声器去播放的声音的音量值大小，如果该数值持续变化，但用户反馈听不到声音，则说明扬声器状态异常。
 *
 * @param volume SDK 提交给扬声器去播放的声音的音量，取值范围0 - 100
 */
#if TARGET_PLATFORM_DESKTOP
    virtual void onTestSpeakerVolume(uint32_t volume) {
    }
#endif

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    自定义消息的接收事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 自定义消息的接收事件回调
    /// @{

    /**
     * 7.1 收到自定义消息的事件回调
     *
     * 当房间中的某个用户使用 {@link sendCustomCmdMsg} 发送自定义 UDP 消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 事件回调接收到该条消息。
     *
     * @param userId 用户标识
     * @param cmdID 命令 ID
     * @param seq   消息序号
     * @param message 消息数据
     */
    virtual void onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) {
    }

    /**
     * 7.2 自定义消息丢失的事件回调
     *
     * 当您使用 {@link sendCustomCmdMsg} 发送自定义 UDP 消息时，即使设置了可靠传输（reliable），也无法确保100@%不丢失，只是丢消息概率极低，能满足常规可靠性要求。
     * 在发送端设置了可靠运输（reliable）后，SDK 都会通过此回调通知过去时间段内（通常为5s）传输途中丢失的自定义消息数量统计信息。
     *
     * @note  只有在发送端设置了可靠传输（reliable），接收方才能收到消息的丢失回调
     * @param userId 用户标识
     * @param cmdID 命令 ID
     * @param errCode 错误码
     * @param missed 丢失的消息数量
     */
    virtual void onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed) {
    }

    /**
     * 7.3 收到 SEI 消息的回调
     *
     * 当房间中的某个用户使用 {@link sendSEIMsg} 借助视频数据帧发送 SEI 消息时，房间中的其它用户可以通过 onRecvSEIMsg 事件回调接收到该条消息。
     *
     * @param userId   用户标识
     * @param message  数据
     */
    virtual void onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize){};

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    CDN 相关事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name CDN 相关事件回调
    /// @{

    /**
     * 8.1 开始向腾讯云直播 CDN 上发布音视频流的事件回调
     *
     * 当您调用 {@link startPublishing} 开始向腾讯云直播 CDN 上发布音视频流时，SDK 会立刻将这一指令同步给云端服务器。
     * 随后 SDK 会收到来自云端服务器的处理结果，并将指令的执行结果通过本事件回调通知给您。
     *
     * @param err 0表示成功，其余值表示失败
     * @param errMsg 具体错误原因
     */
    virtual void onStartPublishing(int err, const char* errMsg){};

    /**
     * 8.2 停止向腾讯云直播 CDN 上发布音视频流的事件回调
     *
     * 当您调用 {@link stopPublishing} 停止向腾讯云直播 CDN 上发布音视频流时，SDK 会立刻将这一指令同步给云端服务器。
     * 随后 SDK 会收到来自云端服务器的处理结果，并将指令的执行结果通过本事件回调通知给您。
     *
     * @param err 0表示成功，其余值表示失败
     * @param errMsg 具体错误原因
     */
    virtual void onStopPublishing(int err, const char* errMsg){};

    /**
     * 8.3 开始向非腾讯云 CDN 上发布音视频流的事件回调
     *
     * 当您调用 {@link startPublishCDNStream} 开始向非腾讯云直播 CDN 上发布音视频流时，SDK 会立刻将这一指令同步给云端服务器。
     * 随后 SDK 会收到来自云端服务器的处理结果，并将指令的执行结果通过本事件回调通知给您。
     *
     * @note 当您收到成功的事件回调时，只是说明您的发布指令已经同步到腾讯云后台服务器，但如果目标 CDN 厂商的服务器不接收该条视频流，依然可能导致发布失败。
     * @param err 0表示成功，其余值表示失败
     * @param errMsg 具体错误原因
     */
    virtual void onStartPublishCDNStream(int errCode, const char* errMsg){};

    /**
     * 8.4 停止向非腾讯云 CDN 上发布音视频流的事件回调
     *
     * 当您调用 {@link stopPublishCDNStream} 开始向非腾讯云直播 CDN 上发布音视频流时，SDK 会立刻将这一指令同步给云端服务器。
     * 随后 SDK 会收到来自云端服务器的处理结果，并将指令的执行结果通过本事件回调通知给您。
     *
     * @param err 0表示成功，其余值表示失败
     * @param errMsg 具体错误原因
     */
    virtual void onStopPublishCDNStream(int errCode, const char* errMsg){};

    /**
     * 8.5 设置云端混流的排版布局和转码参数的事件回调
     *
     * 当您调用 {@link setMixTranscodingConfig} 调整云端混流的排版布局和转码参数时，SDK 会立刻将这一调整指令同步给云端服务器。
     * 随后 SDK 会收到来自云端服务器的处理结果，并将指令的执行结果通过本事件回调通知给您。
     *
     * @param err 错误码：0表示成功，其余值表示失败。
     * @param errMsg 具体的错误原因。
     */
    virtual void onSetMixTranscodingConfig(int err, const char* errMsg){};

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    屏幕分享相关事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 屏幕分享相关事件回调
    /// @{

    /**
     * 9.1 屏幕分享开启的事件回调
     *
     * 当您通过 {@link startScreenCapture} 等相关接口启动屏幕分享时，SDK 便会抛出此事件回调。
     */
    virtual void onScreenCaptureStarted(){};

    /**
     * 9.2 屏幕分享暂停的事件回调
     *
     * 当您通过 {@link pauseScreenCapture} 暂停屏幕分享时，SDK 便会抛出此事件回调。
     * @param reason 原因。
     * - 0：用户主动暂停。
     * - 1：注意此字段的含义在 MAC 和 Windows 平台有稍微差异。屏幕窗口不可见暂停（Mac）。表示设置屏幕分享参数导致的暂停（Windows）。
     * - 2：表示屏幕分享窗口被最小化导致的暂停（仅 Windows）。
     * - 3：表示屏幕分享窗口被隐藏导致的暂停（仅 Windows）。
     */
    virtual void onScreenCapturePaused(int reason){};

    /**
     * 9.3 屏幕分享恢复的事件回调
     *
     * 当您通过 {@link resumeScreenCapture} 恢复屏幕分享时，SDK 便会抛出此事件回调。
     * @param reason 恢复原因。
     * - 0：用户主动恢复。
     * - 1：注意此字段的含义在 MAC 和 Windows 平台有稍微差异。屏幕窗口恢复可见从而恢复分享（Mac）。屏幕分享参数设置完毕后自动恢复（Windows）
     * - 2：表示屏幕分享窗口从最小化被恢复（仅 Windows）。
     * - 3：表示屏幕分享窗口从隐藏被恢复（仅 Windows）。
     */
    virtual void onScreenCaptureResumed(int reason){};

    /**
     * 9.4 屏幕分享停止的事件回调
     *
     * 当您通过 {@link stopScreenCapture} 停止屏幕分享时，SDK 便会抛出此事件回调。
     * @param reason 停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止；2：表示屏幕分享的显示屏状态变更（如接口被拔出、投影模式变更等）。
     */
    virtual void onScreenCaptureStoped(int reason){};

/**
 * 9.5 屏幕分享的目标窗口被遮挡的事件回调（仅适用于 Windows 操作系统）
 *
 * 当屏幕分享的目标窗口被遮挡无法正常捕获时，SDK 会抛出此事件回调，你可以在捕获到该事件回调后，通过 UI 上的一些变化来提示用户移开遮盖窗口。
 */
#ifdef _WIN32
    virtual void onScreenCaptureCovered(){};
#endif

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    本地录制和本地截图的事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 本地录制和本地截图的事件回调
    /// @{

    /**
     * 10.1 本地录制任务已经开始的事件回调
     *
     * 当您调用 {@link startLocalRecording} 启动本地媒体录制任务时，SDK 会抛出该事件回调，用于通知您录制任务是否已经顺利启动。
     * @param errCode 错误码 0：初始化录制成功；-1：初始化录制失败；-2: 文件后缀名有误。
     * @param storagePath 录制文件存储路径
     */
    virtual void onLocalRecordBegin(int errCode, const char* storagePath) {
    }

    /**
     * 10.2 本地录制任务正在进行中的进展事件回调
     *
     * 当您调用 {@link startLocalRecording} 成功启动本地媒体录制任务后，SDK 变会定时地抛出本事件回调。
     * 您可通过捕获该事件回调来获知录制任务的健康状况。
     * 您可以在 {@link startLocalRecording} 时设定本事件回调的抛出间隔。
     *
     * @param duration 已经录制的累计时长，单位毫秒
     * @param storagePath 录制文件存储路径
     */
    virtual void onLocalRecording(long duration, const char* storagePath) {
    }

    /**
     * 10.3 本地录制任务已经结束的事件回调
     *
     * 当您调用 {@link stopLocalRecording} 停止本地媒体录制任务时，SDK 会抛出该事件回调，用于通知您录制任务的最终结果。
     * @param errCode 错误码 0：录制成功；-1：录制失败；-2：切换分辨率或横竖屏导致录制结束。
     * @param storagePath 录制文件存储路径
     */
    virtual void onLocalRecordComplete(int errCode, const char* storagePath) {
    }

    /**
     * 10.4 本地截图完成的事件回调
     *
     * @param userId 用户标识，如果 userId 为空字符串，则代表截取的是本地画面。
     * @param type   视频流类型
     * @param data   截图数据，为 nullptr 表示截图失败
     * @param length 截图数据长度，对于BGRA32而言，length = width * height * 4
     * @param width  截图画面的宽度
     * @param height 截图画面的高度
     * @param format 截图数据格式，目前只支持 TRTCVideoPixelFormat_BGRA32
     */
    virtual void onSnapshotComplete(const char* userId, TRTCVideoStreamType type, char* data, uint32_t length, uint32_t width, uint32_t height, TRTCVideoPixelFormat format) {
    }

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    废弃的事件回调（建议使用对应的新回调）
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 废弃的事件回调（建议使用对应的新回调）
/// @{

/**
 * 有主播加入当前房间（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link onRemoteUserEnterRoom} 替代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use onRemoteUserEnterRoom instead")) void onUserEnter(const char* userId) {
    }
#endif

/**
 * 有主播离开当前房间（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link onRemoteUserLeaveRoom} 替代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use onRemoteUserLeaveRoom instead")) void onUserExit(const char* userId, int reason) {
    }
#endif

/**
 * 音效播放已结束（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link ITXAudioEffectManager} 接口替代之。
 * 新的接口中不再区分背景音乐和音效，而是统一用 {@link startPlayMusic} 取代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use ITXAudioEffectManager.ITXMusicPlayObserver instead")) void onAudioEffectFinished(int effectId, int code){};
#endif

/**
 * 开始播放背景音乐（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link ITXMusicPlayObserver} 接口替代之。
 * 新的接口中不再区分背景音乐和音效，而是统一用 {@link startPlayMusic} 取代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use ITXAudioEffectManager.ITXMusicPlayObserver instead")) void onPlayBGMBegin(TXLiteAVError errCode) {
    }
#endif

/**
 * 背景音乐的播放进度回调（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link ITXMusicPlayObserver} 接口替代之。
 * 新的接口中不再区分背景音乐和音效，而是统一用 {@link startPlayMusic} 取代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use ITXAudioEffectManager.ITXMusicPlayObserver instead")) void onPlayBGMProgress(uint32_t progressMS, uint32_t durationMS) {
    }
#endif

/**
 * 背景音乐播放已经结束（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link ITXMusicPlayObserver} 接口替代之。
 * 新的接口中不再区分背景音乐和音效，而是统一用 {@link startPlayMusic} 取代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use ITXAudioEffectManager.ITXMusicPlayObserver instead")) void onPlayBGMComplete(TXLiteAVError errCode) {
    }
#endif

/**
 * 服务器测速的结果回调（已废弃）
 *
 * @deprecated 新版本开始不推荐使用，建议使用 {@link onSpeedTestResult:} 接口替代之。
 */
#ifdef _WIN32
    virtual __declspec(deprecated("use onSpeedTestResult instead")) void onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) {
    }
#elif defined(__APPLE__)
    virtual void onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) {
    }
    __attribute__((deprecated("use onSpeedTestResult instead")));
#else
    virtual void onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) {
    }
#endif

    /// @}
};  // End of interface ITRTCCloudCallback

/////////////////////////////////////////////////////////////////////////////////
//
//                    视频数据自定义回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 视频数据自定义回调
/// @{

class ITRTCVideoRenderCallback {
   public:
    virtual ~ITRTCVideoRenderCallback() {
    }

    /**
     * 自定义视频渲染回调
     *
     * 当您设置了本地或者远端的视频自定义渲染回调之后，SDK 就会将原本要交给渲染控件进行渲染的视频帧通过此回调接口抛送给您，以便于您进行自定义渲染。
     * @param frame  待渲染的视频帧信息
     * @param userId 视频源的 userId，如果是本地视频回调（setLocalVideoRenderDelegate），该参数可以忽略
     * @param streamType 频流类型：主路（Main）一般用于承载摄像头画面，辅路（Sub）一般用于承载屏幕分享画面。
     */
    virtual void onRenderVideoFrame(const char* userId, TRTCVideoStreamType streamType, TRTCVideoFrame* frame) {
    }

};  // End of interface ITRTCVideoRenderCallback

class ITRTCVideoFrameCallback {
   public:
    virtual ~ITRTCVideoFrameCallback() {
    }

    /**
     * 用于对接第三方美颜组件的视频处理回调
     *
     * 如果您选购了第三方美颜组件，就需要在 TRTCCloud 中设置第三方美颜回调，之后 TRTC 就会将原本要进行预处理的视频帧通过此回调接口抛送给您。
     * 之后您就可以将 TRTC 抛出的视频帧交给第三方美颜组件进行图像处理，由于抛出的数据是可读且可写的，因此第三方美颜的处理结果也可以同步给 TRTC 进行后续的编码和发送。
     *
     * @param srcFrame 用于承载 TRTC 采集到的摄像头画面
     * @param dstFrame 用于接收第三方美颜处理过的视频画面
     * @note 目前仅支持 OpenGL 纹理方案（ PC 仅支持 TRTCVideoBufferType_Buffer 格式）。
     *
     * 情况一：美颜组件自身会产生新的纹理
     * 如果您使用的美颜组件会在处理图像的过程中产生一帧全新的纹理（用于承载处理后的图像），那请您在回调函数中将 dstFrame.textureId 设置为新纹理的 ID：
     *
     * 情况二：美颜组件需要您提供目标纹理
     * 如果您使用的第三方美颜模块并不生成新的纹理，而是需要您设置给该模块一个输入纹理和一个输出纹理，则可以考虑如下方案：
     * ```ObjectiveC
     * uint32_t onProcessVideoFrame(TRTCVideoFrame * _Nonnull)srcFrame dstFrame:(TRTCVideoFrame * _Nonnull)dstFrame{
     *     thirdparty_process(srcFrame.textureId, srcFrame.width, srcFrame.height, dstFrame.textureId);
     *     return 0;
     * }
     * ```
     * ```java
     * int onProcessVideoFrame(TRTCCloudDef.TRTCVideoFrame srcFrame, TRTCCloudDef.TRTCVideoFrame dstFrame) {
     *     thirdparty_process(srcFrame.texture.textureId, srcFrame.width, srcFrame.height, dstFrame.texture.textureId);
     *     return 0;
     * }
     * ```
     */
    virtual int onProcessVideoFrame(TRTCVideoFrame* srcFrame, TRTCVideoFrame* dstFrame) {
        return 0;
    }

};  // End of class ITRTCVideoFrameCallback

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    音频数据自定义回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 音频数据自定义回调
/// @{

class ITRTCAudioFrameCallback {
   public:
    virtual ~ITRTCAudioFrameCallback() {
    }

    /**
     * 本地麦克风采集到的原始音频数据回调
     *
     * 当您设置完音频数据自定义回调之后，SDK 内部会把刚从麦克风采集到的原始音频数据，以 PCM 格式的形式通过本接口回调给您。
     * - 此接口回调出的音频时间帧长固定为0.02s，格式为 PCM 格式。
     * - 由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
     * - 以 TRTC 默认的音频录制格式48000采样率、单声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
     *
     * @param frame PCM 格式的音频数据帧
     * @note
     * 1. 请不要在此回调函数中做任何耗时操作，由于 SDK 每隔 20ms 就要处理一帧音频数据，如果您的处理时间超过 20ms，就会导致声音异常。
     * 2. 此接口回调出的音频数据是可读写的，也就是说您可以在回调函数中同步修改音频数据，但请保证处理耗时。
     * 3. 此接口回调出的音频数据**不包含**背景音、音效、混响等前处理效果，延迟极低。
     */
    virtual void onCapturedRawAudioFrame(TRTCAudioFrame* frame){};

    /**
     * 本地采集并经过音频模块前处理后的音频数据回调
     *
     * 当您设置完音频数据自定义回调之后，SDK 内部会把刚采集到并经过前处理(ANS、AEC、AGC）之后的数据，以 PCM 格式的形式通过本接口回调给您。
     * - 此接口回调出的音频时间帧长固定为0.02s，格式为 PCM 格式。
     * - 由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
     * - 以 TRTC 默认的音频录制格式48000采样率、单声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
     *
     * 特殊说明：
     * 您可以通过设置接口中的 `TRTCAudioFrame.extraData` 字段，达到传输信令的目的。
     * 由于音频帧头部的数据块不能太大，建议您写入 `extraData` 时，尽量将信令控制在几个字节的大小，如果超过 100 个字节，写入的数据不会被发送。
     * 房间内其他用户可以通过 {@link TRTCAudioFrameDelegate} 中的 `onRemoteUserAudioFrame` 中的 `TRTCAudioFrame.extraData` 字段回调接收数据。
     *
     * @param frame PCM 格式的音频数据帧
     * @note
     * 1. 请不要在此回调函数中做任何耗时操作，由于 SDK 每隔 20ms 就要处理一帧音频数据，如果您的处理时间超过 20ms，就会导致声音异常。
     * 2. 此接口回调出的音频数据是可读写的，也就是说您可以在回调函数中同步修改音频数据，但请保证处理耗时。
     * 3. 此接口回调出的数据已经经过了回声抑制（AEC）处理，但声音的延迟相比于 {@link onCapturedRawAudioFrame} 要高一些。
     */
    virtual void onLocalProcessedAudioFrame(TRTCAudioFrame* frame){};

    /**
     * 混音前的每一路远程用户的音频数据
     *
     * 当您设置完音频数据自定义回调之后，SDK 内部会把远端的每一路原始数据，在最终混音之前，以 PCM 格式的形式通过本接口回调给您。
     * - 此接口回调出的音频时间帧长固定为0.02s，格式为 PCM 格式。
     * - 由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
     * - 以 TRTC 默认的音频录制格式48000采样率、单声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
     *
     * @param frame PCM 格式的音频数据帧
     * @param userId 用户标识
     * @note 此接口回调出的音频数据是只读的，不支持修改
     */
    virtual void onPlayAudioFrame(TRTCAudioFrame* frame, const char* userId){};

    /**
     * 将各路待播放音频混合之后并在最终提交系统播放之前的数据回调
     *
     * 当您设置完音频数据自定义回调之后，SDK 内部会把各路待播放的音频混合之后的音频数据，在提交系统播放之前，以 PCM 格式的形式通过本接口回调给您。
     * - 此接口回调出的音频时间帧长固定为0.02s，格式为 PCM 格式。
     * - 由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
     * - 以 TRTC 默认的音频录制格式48000采样率、单声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
     *
     * @param frame PCM 格式的音频数据帧
     * @note
     * 1. 请不要在此回调函数中做任何耗时操作，由于 SDK 每隔 20ms 就要处理一帧音频数据，如果您的处理时间超过 20ms，就会导致声音异常。
     * 2. 此接口回调出的音频数据是可读写的，也就是说您可以在回调函数中同步修改音频数据，但请保证处理耗时。
     * 3. 此接口回调出的是对各路待播放音频数据的混合，但其中并不包含耳返的音频数据。
     */
    virtual void onMixedPlayAudioFrame(TRTCAudioFrame* frame){};

};  // End of interface ITRTCAudioFrameCallback

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    更多事件回调接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 更多事件回调接口
/// @{

class ITRTCLogCallback {
   public:
    virtual ~ITRTCLogCallback() {
    }

    /**
     * 本地 LOG 的打印回调
     *
     * 如果您希望捕获 SDK 的本地日志打印行为，可以通过设置日志回调，让 SDK 将要打印的日志都通过本回调接口抛送给您。
     * @param log 日志内容
     * @param level 日志等级 参见 TRTC_LOG_LEVEL
     * @param module 保留字段，暂无具体意义，目前为固定值 TXLiteAVSDK
     */
    virtual void onLog(const char* log, TRTCLogLevel level, const char* module) {
    }

};  // End of interface ITRTCLogCallback

/// @}
} /* namespace liteav*/
#endif /* __TRTCCLOUDCALLBACK_H__ */
/// @}
