
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VoicePlayTime)(CGFloat);

@interface TUIVoiceMessageCellData_Minimalist : TUIBubbleMessageCellData_Minimalist

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) CGFloat voiceTop;
@property (nonatomic, assign) CGFloat voiceHeight;
@property (nonatomic, copy) VoicePlayTime playTime;

/**
 *  语音图标顶部
 *  该数值用于确定气泡位置，方便气泡内的内容进行 UI 布局。
 *  若该数值出现异常或者随意设置，会出现消息位置错位等 UI 错误。
 *
 *  Top margin of voice message
 *  This value is used to determine the position of the bubble, which is convenient for UI layout of the content in the bubble.
 *  If the value is abnormal or set arbitrarily, UI errors such as message position dislocation will occur.
 */
@property (nonatomic, class) CGFloat incommingVoiceTop;
@property (nonatomic, class) CGFloat outgoingVoiceTop;

- (void)stopVoiceMessage;

/**
 *  开始语音播放。
 *
 *  Begin to play voice. It will download the voice file from server if it not exists in local.
*/
- (void)playVoiceMessage;

@end

NS_ASSUME_NONNULL_END
