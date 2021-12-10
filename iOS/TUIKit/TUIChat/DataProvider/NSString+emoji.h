//
//  NSString+emoji.h
//  TUIChat
//
//  Created by harvy on 2021/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (emoji)

/**
 * 将当前文本中的表情文字本地化，获取本地化后文本
 * 例如：原始文本是@"你好, [大哭]"
 *      如果当前是英文，则该方法将文本转变成了 @"你好,[Cry]"
 *      如果当前是中文，则该方法将文本转变成了 @"你好,[大哭]"
 */
- (NSString *)getLocalizableStringWithFaceContent;

/**
 * 将当前文本中的表情文字国际化，获取国际化后的文本，表情的国际化文本是中文
 */
- (NSString *)getInternationalStringWithfaceContent;

// 获取格式化之后的表情文本（图文混排过后）
- (NSAttributedString *)getFormatEmojiStringWithFont:(UIFont *)textFont;

@end

NS_ASSUME_NONNULL_END
