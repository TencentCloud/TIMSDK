/******************************************************************************
 *
 *  本文件声明了 TUIVoiceMessageCell 类，负责实现语音消息的显示。
 *  语音消息，即在发送/接收到语音后显示的消息单元。TUIKit 默认将其显示为气泡中含有“音波”图标的的消息。
 *  语音消息单元还负责响应用户的操作，在用户点击时播放响应的音频信息。
 *
 ******************************************************************************/
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
 */
@interface TUIVoiceMessageCell : TUIBubbleMessageCell

/**
 *  语音图标
 *  用于显示语音“声波”图标，同时实现语音在播放时的动画效果。
 */
@property (nonatomic, strong) UIImageView *voice;

/**
 *  语音时长标签
 *  用于在气泡外侧展示语音时长，默认数值为整数且以秒为单位。
 */
@property (nonatomic, strong) UILabel *duration;

@property (nonatomic, strong) UIImageView *voiceReadPoint;

/**
 *  语音消息单元数据源
 *  数据源中存放了语音的存放路径、识别码、时长、大小以及用于实现语音动态图标的图像资源等一系列语音消息需要的资源。
 *  详细信息请参考 Section\Chat\CellData\TUIVoiceMessageCellData.h
 */
@property TUIVoiceMessageCellData *voiceData;

/**
 *  填充数据
 *  根据 data 设置语音消息的数据
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIVoiceMessageCellData *)data;

@end
