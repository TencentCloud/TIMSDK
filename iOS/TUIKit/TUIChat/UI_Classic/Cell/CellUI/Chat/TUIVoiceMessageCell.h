/**
 *  本文件声明了 TUIVoiceMessageCell 类，负责实现语音消息的显示。
 *  语音消息，即在发送/接收到语音后显示的消息单元。TUIKit 默认将其显示为气泡中含有“音波”图标的的消息。
 *  语音消息单元还负责响应用户的操作，在用户点击时播放响应的音频信息。
 *
 *  This file declares the TUIVoiceMessageCell class, which is responsible for implementing the display of voice messages.
 *  Voice messages, i.e. message units displayed after voice is sent/received. TUIKit displays it as a message with a "sound wave" icon in a bubble by default.
 *  The voice message unit is also responsible for responding to the user's operation and playing the corresponding audio information when the user clicks.
 */
#import "TUIBubbleMessageCell.h"
#import "TUIVoiceMessageCellData.h"

@import AVFoundation;

/**
 * 【模块名称】TUIVoiceMessageCell
 * 【功能说明】语音消息单元
 *  语音消息，即在发送/接收到语音后显示的消息单元。TUIKit 默认将其显示为气泡中含有“音波”图标的的消息。
 *  语音消息单元提供了语音消息的显示与播放功能。
 *  语音消息单元中的 TUIVoiceMessageCellData 整合调用了 IM SDK 的语音下载与获取，并处理好了相关的业务逻辑。
 *  该类继承自 TUIBubbleMessageCell 来实现气泡消息。您可以参考这一继承关系实现自定义气泡。
 *
 * 【Module name】 TUIVoiceMessageCell
 * 【Function description】 Voice message unit
 *  - Voice messages, i.e. message units displayed after voice is sent/received. TUIKit displays it as a message with a "sound wave" icon in a bubble by default.
 *  - The voice message unit provides the display and playback functions of voice messages.
 *  - The TUIVoiceMessageCellData in the voice message unit integrates and calls the voice download and acquisition of the IM SDK, and handles the related business logic.
 *  - This class inherits from TUIBubbleMessageCell to implement bubble messages. You can implement custom bubbles by referring to this inheritance relationship.
 */
@interface TUIVoiceMessageCell : TUIBubbleMessageCell

/**
 *  语音图标
 *  用于显示语音“声波”图标，同时实现语音在播放时的动画效果。
 *
 *  Voice icon
 *  It is used to display the voice "sound wave" icon, and at the same time realize the animation effect of the voice when it is playing.
 */
@property (nonatomic, strong) UIImageView *voice;

/**
 *  语音时长标签
 *  用于在气泡外侧展示语音时长，默认数值为整数且以秒为单位。
 *
 *  Label for displays video duration
 *  Used to display the duration of the speech outside the bubble, the default value is an integer and the unit is seconds.
 */
@property (nonatomic, strong) UILabel *duration;

@property (nonatomic, strong) UIImageView *voiceReadPoint;

@property TUIVoiceMessageCellData *voiceData;

- (void)fillWithData:(TUIVoiceMessageCellData *)data;

@end
