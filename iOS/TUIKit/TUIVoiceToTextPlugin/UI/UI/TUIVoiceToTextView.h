
//  Created by Tencent on 2023/08/17.
//  Copyright © 2023 Tencent. All rights reserved.

/**
 *  本文件声明了 TUIVoiceToTextView 类，负责实现语音转文字视图。
 *  语音类消息支持长按后转文字，转文字后视图位于消息气泡下方，展示转文字后文本。
 *
 *  When you long press the sound messages, you can choose to convert it to text.
 *  VoiceToText view will be displayed below the message bubble showing the converted text.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIMessageCellData;

@interface TUIVoiceToTextView : UIView

- (instancetype)initWithData:(TUIMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
