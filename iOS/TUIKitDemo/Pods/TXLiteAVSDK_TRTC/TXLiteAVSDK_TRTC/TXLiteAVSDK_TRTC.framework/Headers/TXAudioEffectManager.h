/*
* Module: TXAudioEffectManager 音乐和人声设置类
*
* Function: 用于音乐、短音效和人声效果功能的使用
*
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TXAudioMusicStartBlock)(NSInteger errCode);
typedef void (^TXAudioMusicProgressBlock)(NSInteger progressMs, NSInteger durationMs);
typedef void (^TXAudioMusicCompleteBlock)(NSInteger errCode);

@class TXAudioMusicParam;
typedef NS_ENUM(NSInteger, TXVoiceChangeType);
typedef NS_ENUM(NSInteger, TXVoiceReverbType);

@interface TXAudioEffectManager : NSObject

/// TXAudioEffectManager对象不可直接创建
/// 要通过 `TRTCCloud` 或 `TXLivePush` 的 `getAudioEffectManager` 接口获取
- (instancetype)init NS_UNAVAILABLE;

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）人声相关特效函数
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 人声相关特效函数
/// @{
    
/**
 * 1.1 开启耳返
 *
 * 开启后会在耳机里听到自己的声音。
 *
 * @note 仅在戴耳机时有效，暂时仅支持部分采集延迟较低的机型
 * @param enable true：开启；false：关闭
 */
- (void)enableVoiceEarMonitor:(BOOL)enable;

/**
 * 1.2 设置耳返音量
 *
 * @param volume 音量大小，取值0 - 100，默认值为100
 */
- (void)setVoiceEarMonitorVolume:(NSInteger)volume;

/**
 * 1.3 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
 */
- (void)setVoiceReverbType:(TXVoiceReverbType)reverbType;

/**
 * 1.4 设置人声的变声特效（萝莉、大叔、重金属、外国人...）
 */
- (void)setVoiceChangerType:(TXVoiceChangeType)changerType;

/**
 * 1.5 设置麦克风采集人声的音量
 *
 * @param volume 音量大小，100为正常音量，范围是：[0 ~ 100] 之间的整数
 */
- (void)setVoiceVolume:(NSInteger)volume;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）背景音乐特效函数
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 人声相关特效函数
/// @{
/**
 * 2.1 开始播放背景音乐
 *
 * 每个音乐都需要您指定具体的 ID，您可以通过该 ID 对音乐的开始、停止、音量等进行设置。
 *
 * @note 若您想同时播放多个音乐，请分配不同的 ID 进行播放。
 *       如果使用同一个 ID 播放不同音乐，SDK 会先停止播放旧的音乐，再播放新的音乐。
 * @param musicParam 音乐参数
 * @param startBlock 播放开始回调
 * @param progressBlock 播放进度回调
 * @param completeBlock 播放结束回调
 */
- (void)startPlayMusic:(TXAudioMusicParam *)musicParam
               onStart:(TXAudioMusicStartBlock _Nullable)startBlock
            onProgress:(TXAudioMusicProgressBlock _Nullable)progressBlock
            onComplete:(TXAudioMusicCompleteBlock _Nullable)completeBlock;

/**
 * 2.2 停止播放背景音乐
 *
 * @param id   音乐 ID
 */
- (void)stopPlayMusic:(int32_t)id;

/**
 * 2.3 暂停播放背景音乐
 *
 * @param id   音乐 ID
 */
- (void)pausePlayMusic:(int32_t)id;

/**
 * 2.4 恢复播放背景音乐
 *
 * @param id   音乐 ID
 */
- (void)resumePlayMusic:(int32_t)id;

/**
 * 2.5 设置背景音乐的远端音量大小，即主播可以通过此接口设置远端观众能听到的背景音乐的音量大小。
 *
 * @param id     音乐 ID
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
- (void)setMusicPublishVolume:(int32_t)id volume:(NSInteger)volume;

/**
 * 2.6 设置背景音乐的本地音量大小，即主播可以通过此接口设置主播自己本地的背景音乐的音量大小。
 *
 * @param id     音乐 ID
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
- (void)setMusicPlayoutVolume:(int32_t)id volume:(NSInteger)volume;

/**
 * 2.7 设置全局背景音乐的本地和远端音量的大小
 *
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
- (void)setAllMusicVolume:(NSInteger)volume;

/**
 * 2.8 调整背景音乐的音调高低
 *
 * @param id    音乐 ID
 * @param pitch 音调，默认值是0.0f，范围是：[-1 ~ 1] 之间的浮点数；
 */
- (void)setMusicPitch:(int32_t)id pitch:(double)pitch;

/**
 * 2.9 调整背景音乐的变速效果
 *
 * @param id    音乐 ID
 * @param speedRate 速度，默认值是1.0f，范围是：[0.5 ~ 2] 之间的浮点数；
 */
- (void)setMusicSpeedRate:(int32_t)id speedRate:(double)speedRate;

/**
 * 2.10 获取背景音乐当前的播放进度（单位：毫秒）
 *
 * @param id    音乐 ID
 * @return 成功返回当前播放时间，单位：毫秒，失败返回-1
 */
- (NSInteger)getMusicCurrentPosInMS:(int32_t)id;

/**
 * 2.11 设置背景音乐的播放进度（单位：毫秒）
 *
 * @note 请尽量避免频繁地调用该接口，因为该接口可能会再次读写音乐文件，耗时稍高。
 *       当配合进度条使用时，请在进度条拖动完毕的回调中调用，而避免在拖动过程中实时调用。
 *
 * @param id    音乐 ID
 * @param pts 单位: 毫秒
 */
- (void)seekMusicToPosInMS:(int32_t)id pts:(NSInteger)pts;

/**
 * 2.12 获取景音乐文件的总时长（单位：毫秒）
 *
 * @param path 音乐文件路径，如果 path 为空，那么返回当前正在播放的 music 时长。
 * @return 成功返回时长，失败返回-1
 */
- (NSInteger)getMusicDurationInMS:(NSString *)path;

/// @}

@end


@interface TXAudioMusicParam : NSObject

/// 【字段含义】音乐 ID
/// 【特殊说明】SDK 允许播放多路音乐，因此需要音乐 ID 进行标记，用于控制音乐的开始、停止、音量等
@property (nonatomic) int32_t ID;

/// 【字段含义】音乐文件的绝对路径
@property (nonatomic, copy) NSString *path;

/// 【字段含义】音乐循环播放的次数
/// 【推荐取值】取值范围为0 - 任意正整数，默认值：0。0表示播放音乐一次；1表示播放音乐两次；以此类推
@property (nonatomic) NSInteger loopCount;

/// 【字段含义】是否将音乐传到远端
/// 【推荐取值】YES：音乐在本地播放的同时，会上行至云端，因此远端用户也能听到该音乐；NO：音乐不会上行至云端，因此只能在本地听到该音乐。默认值：NO
@property (nonatomic) BOOL publish;

/// 【字段含义】播放的是否为短音乐文件
/// 【推荐取值】YES：需要重复播放的短音乐文件；NO：正常的音乐文件。默认值：NO
@property (nonatomic) BOOL isShortFile;

/// 【字段含义】音乐开始播放时间点，单位毫秒
@property (nonatomic) NSInteger startTimeMS;

/// 【字段含义】音乐结束播放时间点，单位毫秒，0或者-1表示播放至文件结尾。
@property (nonatomic) NSInteger endTimeMS;

@end

typedef NS_ENUM(NSInteger, TXVoiceReverbType) {
    TXVoiceReverbType_0         = 0,    ///< 关闭混响
    TXVoiceReverbType_1         = 1,    ///< KTV
    TXVoiceReverbType_2         = 2,    ///< 小房间
    TXVoiceReverbType_3         = 3,    ///< 大会堂
    TXVoiceReverbType_4         = 4,    ///< 低沉
    TXVoiceReverbType_5         = 5,    ///< 洪亮
    TXVoiceReverbType_6         = 6,    ///< 金属声
    TXVoiceReverbType_7         = 7,    ///< 磁性
};

typedef NS_ENUM(NSInteger, TXVoiceChangeType) {
    TXVoiceChangeType_0   = 0,    ///< 关闭变声
    TXVoiceChangeType_1   = 1,    ///< 熊孩子
    TXVoiceChangeType_2   = 2,    ///< 萝莉
    TXVoiceChangeType_3   = 3,    ///< 大叔
    TXVoiceChangeType_4   = 4,    ///< 重金属
    TXVoiceChangeType_5   = 5,    ///< 感冒
    TXVoiceChangeType_6   = 6,    ///< 外国人
    TXVoiceChangeType_7   = 7,    ///< 困兽
    TXVoiceChangeType_8   = 8,    ///< 死肥仔
    TXVoiceChangeType_9   = 9,    ///< 强电流
    TXVoiceChangeType_10  = 10,   ///< 重机械
    TXVoiceChangeType_11  = 11,   ///< 空灵
};

NS_ASSUME_NONNULL_END
