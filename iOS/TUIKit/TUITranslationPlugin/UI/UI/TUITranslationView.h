
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  本文件声明了 TUITranslationView 类，负责实现消息文本翻译视图。
 *  文本类消息支持长按后翻译，翻译后视图位于消息气泡下方，展示翻译后文本。
 *
 *  When you long press the text messages, you can choose to translate it.
 *  Translation view will be displayed below the message bubble showing the translated text.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIMessageCellData;

@interface TUITranslationView : UIView

- (instancetype)initWithData:(TUIMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
