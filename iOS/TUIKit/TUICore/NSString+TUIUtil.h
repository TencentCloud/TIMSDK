//
//  NSString+TUICommon.h
//
//  Created by Alexi on 12-11-5.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

char tui_pinyinFirstLetter(unsigned short hanzi);

@interface NSString (TUIUtil)

/**
 * Hash the string using md5
 */
+ (NSString *)md5String:(NSString *)str;
- (NSString *)md5;

/**
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
 * Whether the current string contains only whitespace and newlines
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 * Remove whitespace before and after a string, excluding newlines
 */
- (NSString *)trim;

/**
 * Remove all whitespace from a string
 */
- (NSString *)removeWhiteSpace;
- (NSString *)removeNewLine;

/**
 * The string with URL-Encoding
 */
- (NSString *)stringByUrlEncoding;

/**
 * Convert the first letter of a string to uppercase
 */
- (NSString *)capitalize;

/**
 * Determines whether a string starts with the given string, ignoring case
 */
- (BOOL)startsWith:(NSString *)str;
- (BOOL)startsWith:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
 * Determines whether a string ends with the given string, ignoring case
 */
- (BOOL)endsWith:(NSString *)str;
- (BOOL)endsWith:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
 * Determines whether a string contains the given string, ignoring case
 */
- (BOOL)tui_containsString:(NSString *)str;
- (BOOL)tui_containsString:(NSString *)str Options:(NSStringCompareOptions)compareOptions;

/**
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
