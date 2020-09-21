 /******************************************************************************
  *
  * 本文件声明了用于实现语音视图的模块。
  * 语音视图，即在用户进行语音消息的录制时提供指导和结果提示的视图。
  * 本文件包含TUIRecordView 类。
  * 本类负责在用户进行录音时，对用户进行操作指导，比如表示录音音量、对当前录音状态进行提醒等。
  *
  ******************************************************************************/
#import <UIKit/UIKit.h>

/**
 *  录音状态枚举
 */
typedef NS_ENUM(NSUInteger, RecordStatus) {
    Record_Status_TooShort, //录音时长过短。
    Record_Status_TooLong, //录音时长超过时间限制。
    Record_Status_Recording, //正在录音。
    Record_Status_Cancel, //录音被取消。
};

/**
 * 【模块名称】TUIRecordView
 * 【功能说明】TUI 录音视图，实现录音时的 UI 交互以及录音引导等。
 *  录音视图一般为点击”按住 说话“按钮后出现的视图。
 *  本视图负责向使用者示意当前语音采集的音量，并显示使用指导、采集结果等。
 */
@interface TUIRecordView : UIView

/**
 *  录音图标视图。
 *  本图标包含了各个音量大小下的对应图标（1 - 8 格音量示意共8个）。
 */
@property (nonatomic, strong) UIImageView *recordImage;

/**
 *  视图标签。
 *  负责基于当前录音状态向用户提示。如“松开发送”、“手指上滑，取消发送”、“说话时间太短”等。
 */
@property (nonatomic, strong) UILabel *title;

/**
 *  背景视图
 *  作为语音当前视图的背景，将其与聊天视图区分开来。
 *  一般背景视图的显示元素（背景颜色等）可以根据当前录音状态改变，区分各个状态。
 */
@property (nonatomic, strong) UIView *background;

/**
 *  设置当前录音的音量。
 *  便于录音图标视图中的图像根据音量进行改变。
 *  例如：power < 25时，使用“一格”图标；power >25时，根据一定的公式计算图标格式并进行替换当前图标。
 *
 *  @param power 想要设置为的音量。
 */
- (void)setPower:(NSInteger)power;

/**
 *  设置当前录音状态。
 *  Record_Status_TooShort 录音时长过短。
 *  Record_Status_TooLong 录音时长超过时间限制。
 *  Record_Status_Recording 正在录音。
 *  Record_Status_Cancel 录音被取消。
 *
 *  @param status 想要设置为的状态。
 */
- (void)setStatus:(RecordStatus)status;
@end
