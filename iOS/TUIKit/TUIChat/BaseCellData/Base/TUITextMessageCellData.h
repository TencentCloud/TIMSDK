
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * 本文件声明了 TUITextMessageCellData 类。
 * 本类继承于 TUIBubbleMessageCellData，用于存放文本消息单元所需的一系列数据与信息。
 *
 * This file declares the TUITextMessageCellData class.
 * This class inherits from TUIBubbleMessageCellData and is used to store a series of data and information required by the text message unit.
 */
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUITextMessageCellData
 * 【功能说明】文本消息单元数据源。
 *  - 文本消息单元，即在多数消息收发情况下最常见的消息单元。
 *  - 文本消息单元数据源则是为文本消息单元提供一系列所需的数据与信息。
 *
 * 【Module name】 TUITextMessageCellData
 * 【Function description】The datasource of text message unit.
 *  - Text message unit, which is the most common message unit in most message sending and receiving situations.
 *  - The text message unit data source provides a series of required data and information for the text message unit.
 */
@interface TUITextMessageCellData : TUIBubbleMessageCellData

/**
 *  Content of text message
 */
@property(nonatomic, strong) NSString *content;

@property(nonatomic, assign) BOOL isAudioCall;
@property(nonatomic, assign) BOOL isVideoCall;
@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic, assign) BOOL showUnreadPoint;

/**
 *  可变字符串
 *  文本消息接收到 content 字符串后，需要将字符串中可能存在的字符串表情（比如[微笑]），转为图片表情。
 *  本字符串则负责存储上述过程转换后的结果。
 *
 *  Mutable strings.
 *  After the text message receives the content string, it is necessary to convert the string expression (such as [smile]) that may exist in the string into a
 * picture expression. This string is responsible for storing the converted result of the above process.
 *
 */
- (NSMutableAttributedString *)getAttributedString:(UIFont *)textFont;

/**
 *  NSValue（NSRange） 存储的 emoji 转换后的字符串在 attributedString 的位置。
 *  NSAttributedString 存储的 emoji 转换前的字符串，比如 "[呲牙]"。
 *  在文本选中复制的时候，要找到 emoji 原始的字符串。
 *
 *  NSValue (NSRange) stores the converted string of emoji at the position of attributedString.
 *  NSAttributedString stores the string before emoji conversion, such as "[呲牙]".
 *  When the text is selected and copied, it is necessary to find the original string of emoji.
 */
@property(nonatomic, strong) NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *emojiLocations;

/**
 *  文本内容尺寸。
 *  配合原点定位文本消息。
 *
 *  The size of the label which displays the text message content.
 *  Position the text message with the @textOrigin.
 */
@property(nonatomic, assign) CGSize textSize;

/**
 *  文本内容原点。
 *  配合尺寸定位文本消息。
 *
 *  The origin of label which displays the text message content.
 
 */
@property(nonatomic, assign) CGPoint textOrigin;

@end

NS_ASSUME_NONNULL_END
