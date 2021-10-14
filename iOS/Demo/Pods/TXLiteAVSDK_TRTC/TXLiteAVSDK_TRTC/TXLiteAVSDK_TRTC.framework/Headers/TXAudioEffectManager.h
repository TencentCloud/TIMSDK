/**
 * Module:   TRTC 背景音乐、短音效和人声特效的管理类
 * Function: 用于对背景音乐、短音效和人声特效进行设置的管理类
 */
/// @defgroup TXAudioEffectManager_ios TXAudioEffectManager
/// TRTC 背景音乐、短音效和人声特效的管理类
/// @{
#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////
//
//                    音效相关的枚举值定义
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 音效相关的枚举值定义
/// @{

/**
 * 1.1 混响特效
 *
 * 混响特效可以作用于人声之上，通过声学算法对声音进行叠加处理，模拟出各种不同环境下的临场感受，目前支持如下几种混响效果：
 * 0：关闭；1：KTV；2：小房间；3：大会堂；4：低沉；5：洪亮；6：金属声；7：磁性；8：空灵；9：录音棚；10：悠扬。
 */
typedef NS_ENUM(NSInteger, TXVoiceReverbType) {
    TXVoiceReverbType_0 = 0,    ///< disable
    TXVoiceReverbType_1 = 1,    ///< KTV
    TXVoiceReverbType_2 = 2,    ///< small room
    TXVoiceReverbType_3 = 3,    ///< great hall
    TXVoiceReverbType_4 = 4,    ///< deep voice
    TXVoiceReverbType_5 = 5,    ///< loud voice
    TXVoiceReverbType_6 = 6,    ///< metallic sound
    TXVoiceReverbType_7 = 7,    ///< magnetic sound
    TXVoiceReverbType_8 = 8,    ///< ethereal
    TXVoiceReverbType_9 = 9,    ///< studio
    TXVoiceReverbType_10 = 10,  ///< melodious
};

/**
 * 1.2 变声特效
 *
 * 变声特效可以作用于人声之上，通过声学算法对人声进行二次处理，以获得与原始声音所不同的音色，目前支持如下几种变声特效：
 * 0：关闭；1：熊孩子；2：萝莉；3：大叔；4：重金属；5：感冒；6：外语腔；7：困兽；8：肥宅；9：强电流；10：重机械；11：空灵。
 */
typedef NS_ENUM(NSInteger, TXVoiceChangeType) {
    TXVoiceChangeType_0 = 0,    ///< disable
    TXVoiceChangeType_1 = 1,    ///< naughty kid
    TXVoiceChangeType_2 = 2,    ///< Lolita
    TXVoiceChangeType_3 = 3,    ///< uncle
    TXVoiceChangeType_4 = 4,    ///< heavy metal
    TXVoiceChangeType_5 = 5,    ///< catch cold
    TXVoiceChangeType_6 = 6,    ///< foreign accent
    TXVoiceChangeType_7 = 7,    ///< caged animal trapped beast
    TXVoiceChangeType_8 = 8,    ///< indoorsman
    TXVoiceChangeType_9 = 9,    ///< strong current
    TXVoiceChangeType_10 = 10,  ///< heavy machinery
    TXVoiceChangeType_11 = 11,  ///< intangible
};

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    背景音乐的播放事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 背景音乐的事件回调接口
/// @{

// Playback progress block of background music

///背景音乐开始播放
typedef void (^TXAudioMusicStartBlock)(NSInteger errCode);

///背景音乐的播放进度
typedef void (^TXAudioMusicProgressBlock)(NSInteger progressMs, NSInteger durationMs);

///背景音乐已经播放完毕
typedef void (^TXAudioMusicCompleteBlock)(NSInteger errCode);

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    背景音乐的播放控制信息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 背景音乐的播放控制信息
/// @{

/**
 * 背景音乐的播放控制信息
 *
 * 该信息用于在接口 {@link startPlayMusic} 中指定背景音乐的相关信息，包括播放 ID、文件路径和循环次数等：
 * 1. 如果要多次播放同一首背景音乐，请不要每次播放都分配一个新的 ID，我们推荐使用相同的 ID。
 * 2. 若您希望同时播放多首不同的音乐，请为不同的音乐分配不同的 ID 进行播放。
 * 3. 如果使用同一个 ID 播放不同音乐，SDK 会先停止播放旧的音乐，再播放新的音乐。
 */
@interface TXAudioMusicParam : NSObject

///【字段含义】音乐 ID <br/>
///【特殊说明】SDK 允许播放多路音乐，因此需要使用 ID 进行标记，用于控制音乐的开始、停止、音量等。
@property(nonatomic) int32_t ID;

///【字段含义】音效文件的完整路径或 URL 地址。支持的音频格式包括 MP3、AAC、M4A、WAV
@property(nonatomic, copy) NSString *path;

///【字段含义】音乐循环播放的次数 <br/>
///【推荐取值】取值范围为0 - 任意正整数，默认值：0。0表示播放音乐一次；1表示播放音乐两次；以此类推
@property(nonatomic) NSInteger loopCount;

///【字段含义】是否将音乐传到远端 <br/>
///【推荐取值】YES：音乐在本地播放的同时，远端用户也能听到该音乐；NO：主播只能在本地听到该音乐，远端观众听不到。默认值：NO。
@property(nonatomic) BOOL publish;

///【字段含义】播放的是否为短音乐文件 <br/>
///【推荐取值】YES：需要重复播放的短音乐文件；NO：正常的音乐文件。默认值：NO
@property(nonatomic) BOOL isShortFile;

///【字段含义】音乐开始播放时间点，单位：毫秒。
@property(nonatomic) NSInteger startTimeMS;

///【字段含义】音乐结束播放时间点，单位毫秒，0表示播放至文件结尾。
@property(nonatomic) NSInteger endTimeMS;
@end
/// @}

// Definition of audio effect management module
@interface TXAudioEffectManager : NSObject

/**
 * TXAudioEffectManager对象不可直接被创建
 * 要通过 `TRTCCloud` 或 `TXLivePush` 中的 `getAudioEffectManager` 接口获取
 */
- (instancetype)init NS_UNAVAILABLE;

/////////////////////////////////////////////////////////////////////////////////
//
//                    人声相关的特效接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 人声相关的特效接口
/// @{

/**
 * 1.1 开启耳返
 *
 * 主播开启耳返后，可以在耳机里听到麦克风采集到的自己发出的声音，该特效适用于主播唱歌的应用场景中。
 *
 * 需要您注意的是，由于蓝牙耳机的硬件延迟非常高，所以在主播佩戴蓝牙耳机时无法开启此特效，请尽量在用户界面上提示主播佩戴有线耳机。
 * 同时也需要注意，并非所有的手机开启此特效后都能达到优秀的耳返效果，我们已经对部分耳返效果不佳的手机屏蔽了该特效。
 *
 * @note 仅在主播佩戴耳机时才能开启此特效，同时请您提示主播佩戴有线耳机。
 * @param enable true：开启；false：关闭。
 */
- (void)enableVoiceEarMonitor:(BOOL)enable;

/**
 * 1.2 设置耳返音量
 *
 * 通过该接口您可以设置耳返特效中声音的音量大小。
 *
 * @param volume 音量大小，取值范围为0 - 100，默认值：100。
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (void)setVoiceEarMonitorVolume:(NSInteger)volume;

/**
 * 1.3 设置人声的混响效果
 *
 * 通过该接口您可以设置人声的混响效果，具体特效请参考枚举定义{@link TXVoiceReverbType}。
 *
 * @note 设置的效果在退出房间后会自动失效，如果下次进房还需要对应特效，需要调用此接口再次进行设置。
 */
- (void)setVoiceReverbType:(TXVoiceReverbType)reverbType;

/**
 * 1.4 设置人声的变声特效
 *
 * 通过该接口您可以设置人声的变声特效，具体特效请参考枚举定义{@link TXVoiceChangeType}。
 *
 * @note 设置的效果在退出房间后会自动失效，如果下次进房还需要对应特效，需要调用此接口再次进行设置。
 */
- (void)setVoiceChangerType:(TXVoiceChangeType)changerType;

/**
 * 1.5 设置语音音量
 *
 * 该接口可以设置语音音量的大小，一般配合音乐音量的设置接口 {@link setAllMusicVolume} 协同使用，用于调谐语音和音乐在混音前各自的音量占比。
 *
 * @param volume 音量大小，取值范围为0 - 100，默认值：100。
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (void)setVoiceVolume:(NSInteger)volume;

/**
 * 1.6 设置语音音调
 *
 * 该接口可以设置语音音调，用于实现变调不变速的目的。
 *
 * @param pitch 音调，取值范围为-1.0f~1.0f，默认值：0.0f。
 */
- (void)setVoicePitch:(double)pitch;

/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                    背景音乐的相关接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 背景音乐的相关接口
/// @{

/**
 * 2.1 开始播放背景音乐
 *
 * 每个音乐都需要您指定具体的 ID，您可以通过该 ID 对音乐的开始、停止、音量等进行设置。
 *
 * @note
 * 1. 如果要多次播放同一首背景音乐，请不要每次播放都分配一个新的 ID，我们推荐使用相同的 ID。
 * 2. 若您希望同时播放多首不同的音乐，请为不同的音乐分配不同的 ID 进行播放。
 * 3. 如果使用同一个 ID 播放不同音乐，SDK 会先停止播放旧的音乐，再播放新的音乐。
 *
 * @param musicParam 音乐参数
 * @param startBlock 播放开始回调
 * @param progressBlock 播放进度回调
 * @param completeBlock 播放结束回调
 */
- (void)startPlayMusic:(TXAudioMusicParam *)musicParam onStart:(TXAudioMusicStartBlock _Nullable)startBlock onProgress:(TXAudioMusicProgressBlock _Nullable)progressBlock onComplete:(TXAudioMusicCompleteBlock _Nullable)completeBlock;

/**
 * 2.2 停止播放背景音乐
 *
 * @param id  音乐 ID
 */
- (void)stopPlayMusic:(int32_t)id;

/**
 * 2.3 暂停播放背景音乐
 *
 * @param id  音乐 ID
 */
- (void)pausePlayMusic:(int32_t)id;

/**
 * 2.4 恢复播放背景音乐
 *
 * @param id  音乐 ID
 */
- (void)resumePlayMusic:(int32_t)id;

/**
 * 2.5 设置所有背景音乐的本地音量和远端音量的大小
 *
 * 该接口可以设置所有背景音乐的本地音量和远端音量。
 * - 本地音量：即主播本地可以听到的背景音乐的音量大小。
 * - 远端音量：即观众端可以听到的背景音乐的音量大小。
 *
 * @param volume 音量大小，取值范围为0 - 100，默认值：100。
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (void)setAllMusicVolume:(NSInteger)volume;

/**
 * 2.6 设置某一首背景音乐的远端音量的大小
 *
 * 该接口可以细粒度地控制每一首背景音乐的远端音量，也就是观众端可听到的背景音乐的音量大小。
 *
 * @param id     音乐 ID
 * @param volume 音量大小，取值范围为0 - 100；默认值：100
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (void)setMusicPublishVolume:(int32_t)id volume:(NSInteger)volume;

/**
 * 2.7 设置某一首背景音乐的本地音量的大小
 *
 * 该接口可以细粒度地控制每一首背景音乐的本地音量，也就是主播本地可以听到的背景音乐的音量大小。
 *
 * @param id     音乐 ID
 * @param volume 音量大小，取值范围为0 - 100，默认值：100。
 * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
 */
- (void)setMusicPlayoutVolume:(int32_t)id volume:(NSInteger)volume;

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
 * 2.10 获取背景音乐的播放进度（单位：毫秒）
 *
 * @param id    音乐 ID
 * @return 成功返回当前播放时间，单位：毫秒，失败返回-1
 */
- (NSInteger)getMusicCurrentPosInMS:(int32_t)id;

/**
 * 2.11 获取背景音乐的总时长（单位：毫秒）
 *
 * @param path 音乐文件路径。
 * @return 成功返回时长，失败返回-1
 */
- (NSInteger)getMusicDurationInMS:(NSString *)path;

/**
 * 2.12 设置背景音乐的播放进度（单位：毫秒）
 *
 * @note 请尽量避免过度频繁地调用该接口，因为该接口可能会再次读写音乐文件，耗时稍高。
 *       因此，当用户拖拽音乐的播放进度条时，请在用户完成拖拽操作后再调用本接口。
 *       因为 UI 上的进度条控件往往会以很高的频率反馈用户的拖拽进度，如不做频率限制，会导致较差的用户体验。
 *
 * @param id  音乐 ID
 * @param pts 单位: 毫秒
 */
- (void)seekMusicToPosInMS:(int32_t)id pts:(NSInteger)pts;

/// @}
@end  // End of interface TXAudioEffectManager
/// @}
