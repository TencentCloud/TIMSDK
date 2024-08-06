
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
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
