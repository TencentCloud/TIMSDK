/**
 * Module:   TRTC 音视频设备管理模块
 * Function: 用于管理摄像头、麦克风和扬声器等音视频相关的硬件设备
 */
/// @defgroup TXDeviceManager_ios TXDeviceManager
/// TRTC 音视频设备管理模块
/// @{

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

/////////////////////////////////////////////////////////////////////////////////
//
//                    音视频设备相关的类型定义
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 音视频设备相关的类型定义
/// @{

/**
 * 系统音量类型（仅适用于移动设备）
 *
 * 现代智能手机中一般都具备两套系统音量类型，即“通话音量”和“媒体音量”。
 * - 通话音量：手机专门为接打电话所设计的音量类型，自带回声抵消（AEC）功能，并且支持通过蓝牙耳机上的麦克风进行拾音，缺点是音质比较一般。
 *            当您通过手机侧面的音量按键下调手机音量时，如果无法将其调至零（也就是无法彻底静音），说明您的手机当前出于通话音量。
 * - 媒体音量：手机专门为音乐场景所设计的音量类型，无法使用系统的 AEC 功能，并且不支持通过蓝牙耳机的麦克风进行拾音，但具备更好的音乐播放效果。
 *            当您通过手机侧面的音量按键下调手机音量时，如果能够将手机音量调至彻底静音，说明您的手机当前出于媒体音量。
 *
 * SDK 目前提供了三种系统音量类型的控制模式：自动切换模式、全程通话音量模式、全程媒体音量模式。
 */
#if TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TXSystemVolumeType) {

    ///自动切换模式：
    ///也被称为“麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量，适合在线直播场景。
    TXSystemVolumeTypeAuto = 0,

    ///全程媒体音量：
    ///通话全程使用媒体音量，并不是非常常用的音量类型，适用于对音质要求比较苛刻的音乐场景中。
    ///如果您的用户大都使用外接设备（比如外接声卡）为主，可以使用该模式，否则请慎用。
    TXSystemVolumeTypeMedia = 1,

    ///全程通话音量：
    ///该方案的优势在于用户在上下麦时音频模块无需切换工作模式，可以做到无缝上下麦，适合于用户需要频繁上下麦的应用场景。
    TXSystemVolumeTypeVOIP = 2,

};
#endif

/**
 * 音频路由（即声音的播放模式）
 *
 * 音频路由，即声音是从手机的扬声器还是从听筒中播放出来，因此该接口仅适用于手机等移动端设备。
 * 手机有两个扬声器：一个是位于手机顶部的听筒，一个是位于手机底部的立体声扬声器。
 * - 设置音频路由为听筒时，声音比较小，只有将耳朵凑近才能听清楚，隐私性较好，适合用于接听电话。
 * - 设置音频路由为扬声器时，声音比较大，不用将手机贴脸也能听清，因此可以实现“免提”的功能。
 */
#if TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TXAudioRoute) {

    /// Speakerphone：使用扬声器播放（即“免提”），扬声器位于手机底部，声音偏大，适合外放音乐。
    TXAudioRouteSpeakerphone = 0,

    /// Earpiece：使用听筒播放，听筒位于手机顶部，声音偏小，适合需要保护隐私的通话场景。
    TXAudioRouteEarpiece = 1,

};
#endif

/**
 * 设备类型（仅适用于桌面平台）
 *
 * 该枚举值用于定义三种类型的音视频设备，即摄像头、麦克风和扬声器，以便让一套设备管理接口可以操控三种不同类型的设备。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TXMediaDeviceType) {
    TXMediaDeviceTypeUnknown = -1,     ///< undefined device type
    TXMediaDeviceTypeAudioInput = 0,   ///< microphone
    TXMediaDeviceTypeAudioOutput = 1,  ///< speaker or earpiece
    TXMediaDeviceTypeVideoCamera = 2,  ///< camera
};
#endif

/**
 * 设备操作
 *
 * 该枚举值用于本地设备的状态变化通知{@link onDeviceChanged}。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TXMediaDeviceState) {

    ///设备已被插入
    TXMediaDeviceStateAdd = 0,

    ///设备已被移除
    TXMediaDeviceStateRemove = 1,

    ///设备已启用
    TXMediaDeviceStateActive = 2,

};
#endif

/**
 * 音视频设备的相关信息（仅适用于桌面平台）
 *
 * 该结构体用于描述一个音视频设备的关键信息，比如设备ID、设备名称等等，以便用户能够在用户界面上选择自己期望使用的音视频设备。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
@interface TXMediaDeviceInfo : NSObject
/// device type
@property(assign, nonatomic) TXMediaDeviceType type;
/// device id
@property(copy, nonatomic, nullable) NSString *deviceId;
/// device name
@property(copy, nonatomic, nullable) NSString *deviceName;
/// device properties
@property(copy, nonatomic, nullable) NSString *deviceProperties;
@end
#endif
/// @}

/**
 * 本地设备的通断状态发生变化（仅适用于桌面系统）
 *
 * 当本地设备（包括摄像头、麦克风以及扬声器）被插入或者拔出时，SDK 便会抛出此事件回调。
 *
 * @param deviceId 设备 ID
 * @param type 设备类型
 * @param state 通断状态，0：设备已添加；1：设备已被移除；2：设备已启用。
 */
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
@protocol TXDeviceObserver <NSObject>

- (void)onDeviceChanged:(NSString *)deviceId type:(TXMediaDeviceType)mediaType state:(TXMediaDeviceState)mediaState;

@end
#endif

@interface TXDeviceManager : NSObject

/////////////////////////////////////////////////////////////////////////////////
//
//                    移动端设备操作接口（iOS Android）
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 移动端设备操作接口
/// @{

/**
 * 1.1 判断当前是否为前置摄像头（仅适用于移动端）
 */
#if TARGET_OS_IPHONE
- (BOOL)isFrontCamera;

/**
 * 1.2 切换前置或后置摄像头（仅适用于移动端）
 */
- (NSInteger)switchCamera:(BOOL)frontCamera;

/**
 * 1.3 查询当前摄像头是否支持缩放（仅适用于移动端）
 */
- (BOOL)isCameraZoomSupported;

/**
 * 1.3 获取摄像头的最大缩放倍数（仅适用于移动端）
 */
- (CGFloat)getCameraZoomMaxRatio;

/**
 * 1.4 设置摄像头的缩放倍数（仅适用于移动端）
 *
 * @param zoomRatio 取值范围1 - 5，取值为1表示最远视角（正常镜头），取值为5表示最近视角（放大镜头）。
 */
- (NSInteger)setCameraZoomRatio:(CGFloat)zoomRatio;

/**
 * 1.5 查询是否支持自动识别人脸位置（仅适用于移动端）
 */
- (BOOL)isAutoFocusEnabled;

/**
 * 1.6 开启自动对焦功能（仅适用于移动端）
 *
 * 开启后，SDK 会自动检测画面中的人脸位置，并将摄像头的焦点始终对焦在人脸位置上。
 */
- (NSInteger)enableCameraAutoFocus:(BOOL)enabled;

/**
 * 1.7 设置摄像头的对焦位置（仅适用于移动端）
 *
 * 您可以通过该接口实现如下交互：
 * 1. 在本地摄像头的预览画面上，允许用户单击操作。
 * 2. 在用户的单击位置显示一个矩形方框，以示摄像头会在此处对焦。
 * 3. 随后将用户点击位置的坐标通过本接口传递给 SDK，之后 SDK 会操控摄像头按照用户期望的位置进行对焦。
 * @note 使用该接口的前提是先通过 {@link enableCameraAutoFocus} 关闭自动对焦功能。
 * @param position 对焦位置，请传入期望对焦点的坐标值
 * @return 0：操作成功；负数：操作失败。
 */
- (NSInteger)setCameraFocusPosition:(CGPoint)position;

/**
 * 1.8 查询是否支持开启闪光灯（仅适用于移动端）
 */
- (BOOL)isCameraTorchSupported;

/**
 * 1.8 开启/关闭闪光灯，也就是手电筒模式（仅适用于移动端）
 */
- (NSInteger)enableCameraTorch:(BOOL)enabled;

/**
 * 1.9 设置音频路由（仅适用于移动端）
 *
 * 手机有两个音频播放设备：一个是位于手机顶部的听筒，一个是位于手机底部的立体声扬声器。
 * 设置音频路由为听筒时，声音比较小，只有将耳朵凑近才能听清楚，隐私性较好，适合用于接听电话。
 * 设置音频路由为扬声器时，声音比较大，不用将手机贴脸也能听清，因此可以实现“免提”的功能。
 */
- (NSInteger)setAudioRoute:(TXAudioRoute)route;

/**
 * 1.10 设置系统音量类型（仅适用于移动端）
 */
- (NSInteger)setSystemVolumeType:(TXSystemVolumeType)type;
#endif

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    桌面端设备操作接口（Windows Mac）
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 桌面端设备操作接口
/// @{

/**
 * 2.1 获取设备列表（仅适用于桌面端）
 *
 * @param type  设备类型，指定需要获取哪种设备的列表。详见 TXMediaDeviceType 定义。
 * @note
 *   - 使用完毕后请调用 release 方法释放资源，这样可以让 SDK 维护 ITXDeviceCollection 对象的生命周期。
 *   - 不要使用 delete 释放返回的 Collection 对象，delete ITXDeviceCollection* 指针会导致异常崩溃。
 *   - type 只支持 TXMediaDeviceTypeMic、TXMediaDeviceTypeSpeaker、TXMediaDeviceTypeCamera。
 *   - 此接口只支持 Mac 和 Windows 平台
 */
#if !TARGET_OS_IPHONE && TARGET_OS_MAC
- (NSArray<TXMediaDeviceInfo *> *_Nullable)getDevicesList:(TXMediaDeviceType)type;

/**
 * 2.2 设置当前要使用的设备（仅适用于桌面端）
 *
 * @param type 设备类型，详见 TXMediaDeviceType 定义。
 * @param deviceId 设备ID，您可以通过接口 {@link getDevicesList} 获得设备 ID。
 * @return 0：操作成功；负数：操作失败。
 */
- (NSInteger)setCurrentDevice:(TXMediaDeviceType)type deviceId:(NSString *)deviceId;

/**
 * 2.3 获取当前正在使用的设备（仅适用于桌面端）
 */
- (TXMediaDeviceInfo *_Nullable)getCurrentDevice:(TXMediaDeviceType)type;

/**
 * 2.4 设置当前设备的音量（仅适用于桌面端）
 *
 * 这里的音量指的是麦克风的采集音量或者扬声器的播放音量，摄像头是不支持设置音量的。
 *
 * @param volume 音量大小，取值范围为0 - 100，默认值：100。
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (NSInteger)setCurrentDeviceVolume:(NSInteger)volume deviceType:(TXMediaDeviceType)type;

/**
 * 2.5 获取当前设备的音量（仅适用于桌面端）
 *
 * 这里的音量指的是麦克风的采集音量或者扬声器的播放音量，摄像头是不支持获取音量的。
 */
- (NSInteger)getCurrentDeviceVolume:(TXMediaDeviceType)type;

/**
 * 2.6 设置当前设备的静音状态（仅适用于桌面端）
 *
 * 这里的音量指的是麦克风和扬声器，摄像头是不支持静音操作的。
 */
- (NSInteger)setCurrentDeviceMute:(BOOL)mute deviceType:(TXMediaDeviceType)type;

/**
 * 2.7 获取当前设备的静音状态（仅适用于桌面端）
 *
 * 这里的音量指的是麦克风和扬声器，摄像头是不支持静音操作的。
 */
- (BOOL)getCurrentDeviceMute:(TXMediaDeviceType)type;

/**
 * 2.8 开始摄像头测试（仅适用于桌面端）
 *
 * @note 在测试过程中可以使用 {@link setCurrentDevice} 接口切换摄像头。
 */
- (NSInteger)startCameraDeviceTest:(NSView *)view;

/**
 * 2.9 结束摄像头测试（仅适用于桌面端）
 */
- (NSInteger)stopCameraDeviceTest;

/**
 * 2.10 开始麦克风测试（仅适用于桌面端）
 *
 * 该接口可以测试麦克风是否能正常工作，测试到的麦克风采集音量的大小，会以回调的形式通知给您，其中 volume 的取值范围为0 - 100。
 * @param interval 麦克风音量的回调间隔。
 */
- (NSInteger)startMicDeviceTest:(NSInteger)interval testEcho:(void (^)(NSInteger volume))testEcho;

/**
 * 2.11 结束麦克风测试（仅适用于桌面端）
 */
- (NSInteger)stopMicDeviceTest;

/**
 * 2.12 开始扬声器测试（仅适用于桌面端）
 *
 * 该接口通过播放指定的音频文件，用于测试播放设备是否能正常工作。如果用户在测试时能听到声音，说明播放设备能正常工作。
 * @param filePath 声音文件的路径
 */
- (NSInteger)startSpeakerDeviceTest:(NSString *)audioFilePath onVolumeChanged:(void (^)(NSInteger volume, BOOL isLastFrame))volumeBlock;

/**
 * 2.13 结束扬声器测试（仅适用于桌面端）
 */
- (NSInteger)stopSpeakerDeviceTest;

/**
 * 2.14 设备热插拔回调（仅适用于 Mac 系统）
 */
- (void)setObserver:(nullable id<TXDeviceObserver>)observer;
#endif

/// @}
@end
/// @}
