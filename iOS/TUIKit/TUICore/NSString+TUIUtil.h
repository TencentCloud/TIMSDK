//
//  NSString+TUICommon.h
//
//  Created by Alexi on 12-11-5.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

char tui_pinyinFirstLetter(unsigned short hanzi);

@interface NSString (TUIUtil)

/**
 * 对当前字符串 MD5
 * Hash the string using md5
 */
+ (NSString *)md5String:(NSString *)str;
- (NSString *)md5;

/**
 * 获取拼音的首字母
 * Get the first letter of Pinyin
 */
- (NSString *)firstPinYin;

- (NSString *)safePathString;

+ (BOOL)isEmpty:(NSString *)string;

/**
 * compare two version
 *
 * @param sourVersion *.*.*.*
 * @param desVersion *.*.*.*
 * @returns No,sourVersion is less than desVersion; YES, the statue is opposed
 */
+ (BOOL)compareVerison:(NSString *)sourVersion withDes:(NSString *)desVersion;

/**
 * 当前字符串是否只包含空白字符和换行符
 * Whether the current string contains only whitespace and newlines
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 * 去除字符串前后的空白,不包含换行符
 * Remove whitespace before and after a string, excluding newlines
 */
- (NSString *)trim;

/**
 * 去除字符串中所有空白
 * Remove all whitespace from a string
 */
- (NSString *)removeWhiteSpace;
- (NSString *)removeNewLine;

/**
 * 将字符串以 URL 格式编码
 * The string with URL-Encoding
 */
- (NSString *)stringByUrlEncoding;

/**
 * 将字符串第一个字母大写
 * Convert the first letter of a string to uppercase
 */
- (NSString *)capitalize;

/**
 * 以给定字符串开始,忽略大小写
 * Determines whether a string starts with the given string, ignoring case
 */
- (BOOL)startsWith:(NSString *)str;
- (BOOL)startsWith:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
 * 以给定字符串结束,忽略大小写
 * Determines whether a string ends with the given string, ignoring case
 */
- (BOOL)endsWith:(NSString *)str;
- (BOOL)endsWith:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
 * 包含给定的字符串, 忽略大小写
 * Determines whether a string contains the given string, ignoring case
 */
- (BOOL)containsString:(NSString *)str;
- (BOOL)containsString:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
 * 判断字符串是否相同，忽略大小写
 * Determines whether a string equals with the given string, ignoring case
 */
- (BOOL)equalsString:(NSString *)str;

- (NSString *)emjoiText;

#pragma mark Hashing
#if kSupportGTM64
- (NSString *)base64Encoding;
#endif

- (NSString *)valueOfLabel:(NSString *)label;

- (NSString *)substringAtRange:(NSRange)rang;

- (NSUInteger)utf8Length;

- (BOOL)isContainsEmoji;

- (NSString *)cutBeyondTextInLength:(NSInteger)maxLenth;

- (CGSize)textSizeIn:(CGSize)size font:(UIFont *)font;
- (CGSize)textSizeIn:(CGSize)size font:(UIFont *)font breakMode:(NSLineBreakMode)breakMode;
- (CGSize)textSizeIn:(CGSize)size font:(UIFont *)font breakMode:(NSLineBreakMode)breakMode align:(NSTextAlignment)alignment;

- (CGFloat)widthFromFont:(UIFont *)font;

@end
