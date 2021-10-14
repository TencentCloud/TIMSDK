 /******************************************************************************
  *
  *  本文件声明了 TUIVoiceMessageCellData 类。
  *  本类继承于 TUIBubbleMessageCellData，用于存放文本消息单元所需的一系列数据与信息。
  *  本文件中已经实现了获取语音信息和相关数据处理的业务逻辑。
  *  当您需要获取语音数据时，直接调用本文件中声明的相关成员函数即可
  *
  ******************************************************************************/
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIVoiceMessageCellData
 * 【功能说明】语音消息单元数据源
 *  语音消息单元，即你在发送语音时看到的消息单元。
 *  在TUIKit 的默认情况下，语音消息单元由气泡消息包裹，且内涵一个“声波”状图标。
 *  语音消息单元数据源，即包含了语音消息单元所需的一系列信息于数据，帮助语音消息能够正常显示与播放。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUIVoiceMessageCellData : TUIBubbleMessageCellData

/**
 *  上传时，语音文件的路径，接收时使用 IM SDK 接口中的 getSound 获得数据
 */
@property (nonatomic, strong) NSString *path;

/**
 *  语音消息内部 ID
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  语音消息的时长
 *  用于在消息单元处以 UILable 的形式，以秒为单元展示语音时长。
 */
@property (nonatomic, assign) int duration;

/**
 *  语音消息数据大小
 */
@property (nonatomic, assign) int length;

/**
 *  下载标志位
 *  YES：正在下载；NO：未在下载。
 */
@property (nonatomic, assign) BOOL isDownloading;

/**
 *  播放标志位
 *  YES：正在播放；NO：未在播放。
 */
@property (nonatomic, assign) BOOL isPlaying;

/**
 *  语音动态图标
 *  用于实现语音在播放时“声波图像”渐变的动画。
 *  tips：如果您想自定义实现其他种类的动画图标，你可以参照此处 voiceAnimationIamges 的实现。
 */
@property NSArray<UIImage *> *voiceAnimationImages;

/**
 *  语音图标
 *  用于显示语音未在播放时的动态图标。
 */
@property UIImage *voiceImage;
@property (nonatomic, assign) CGFloat voiceTop;

/**
 *  接收语音图标顶部
 *  该数值用于确定气泡位置，方便气泡内的内容进行 UI 布局。
 *  若该数值出现异常或者随意设置，会出现消息位置错位等 UI 错误。
 */
@property (nonatomic, class) CGFloat incommingVoiceTop;

/**
 *  接收语音图标顶部
 *  该数值用于确定气泡位置，方便气泡内的内容进行 UI 布局。
 *  若该数值出现异常或者随意设置，会出现消息位置错位等 UI 错误。
 */
@property (nonatomic, class) CGFloat outgoingVoiceTop;

/**
 *  停止语音播放。
 *  停止当前气泡中的语音播放
 */
- (void)stopVoiceMessage;

/**
*  开始语音播放。
*  开始当前气泡中的语音播放
*  1-1、播放语音前会检查是否正在播放。若正在播放则不执行本次播放操作。
*  1-2、当前为在播放时，则检查待播放音频是否存放在本地，若本地存在，则直接通过 path 获取音频并开始播放。
*  2、当前音频不存在时，则通过 IM SDK 中 TIMSoundElem 类提供的 getSound 接口进行在线获取。
*  3、语音消息和文件、图像、视频消息有所不同，获取的语音消息在消息中以 TIMSoundElem 存在，但无需进行二级提取即可使用。
*  4、在播放时，只需在路径后添加语音文件后缀，生成 URL，即可根据对应 URL通过 iOS 自带的音频播放库播放。音频文件后缀为 “.wav”。
*  5、下载成功后，会生成语音 path 并存储下来。
*/
- (void)playVoiceMessage;

@end

NS_ASSUME_NONNULL_END
