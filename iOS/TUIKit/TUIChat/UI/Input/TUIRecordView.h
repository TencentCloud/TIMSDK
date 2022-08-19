 /**
  *
  * 本文件声明了语音消息录制组件
  * 语音视图，即在用户进行语音消息的录制时提供指导和结果提示的视图。
  * 本文件包含TUIRecordView 类。
  * 本类负责在用户进行录音时，对用户进行操作指导，比如表示录音音量、对当前录音状态进行提醒等。
  *
  * This document declares the voice message recording component
  * Voice view, that is, a view that provides guidance and result prompts when a user records a voice message.
  * This file contains the TUIRecordView class.
  * This class is responsible for providing operational guidance to the user when the user is recording, such as indicating the recording volume, reminding the current recording status, etc.
  */
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecordStatus) {
    Record_Status_TooShort,
    Record_Status_TooLong,
    Record_Status_Recording,
    Record_Status_Cancel,
};

@interface TUIRecordView : UIView

/**
 *  录音图标视图。
 *  本图标包含了各个音量大小下的对应图标（1 - 8 格音量示意共8个）。
 *
 *  Icon view for recording
 *  This icon contains the corresponding icons under each volume level (a total of 8 volume indications from 1 to 8).
 */
@property (nonatomic, strong) UIImageView *recordImage;

/**
 *  视图标签。
 *  负责基于当前录音状态向用户提示。如“松开发送”、“手指上滑，取消发送”、“说话时间太短”等。
 *
 *  Label for displaying tips
 *  Prompt the user about the current recording status. Such as "release to send", "swipe up to cancel sending", "talk time is too short", etc.
 */
@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIView *background;

/**
 *  设置当前录音的音量。
 *  便于录音图标视图中的图像根据音量进行改变。
 *  例如：power < 25时，使用“一格”图标；power >25时，根据一定的公式计算图标格式并进行替换当前图标。
 *
 *  Sets the volume of the current recording.
 *  It is convenient for the image in the recording icon view to change according to the volume.
 *  For example: when power < 25, use the "one grid" icon; when power > 25, calculate the icon format according to a certain formula and replace the current icon.
 */
- (void)setPower:(NSInteger)power;

- (void)setStatus:(RecordStatus)status;
@end
