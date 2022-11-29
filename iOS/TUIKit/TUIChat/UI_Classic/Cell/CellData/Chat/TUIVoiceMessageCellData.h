
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIVoiceMessageCellData : TUIBubbleMessageCellData

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isPlaying;

/**
 *  播放动画图片
 *  用于实现语音在播放时“声波图像”渐变的动画。
 *  如果您想自定义实现其他种类的动画图标，你可以参照此处 voiceAnimationIamges 的实现。
 *
 *  Play animation image
 *  An animation used to implement the "sonic image" fade of the speech as it plays.
 *  If you want to customize the implementation of other kinds of animation icons, you can refer to the implementation of voiceAnimationIamges here.
 */
@property NSArray<UIImage *> *voiceAnimationImages;

/**
 *  语音图标
 *  用于显示语音未在播放时的动态图标。
 *
 *  voice icon
 *  Animated icon to show when the speech is not playing.
 */
@property UIImage *voiceImage;
@property (nonatomic, assign) CGFloat voiceTop;

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
