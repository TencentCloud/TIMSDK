
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * This file declares the TUITextMessageCellData class.
 * This class inherits from TUIBubbleMessageCellData and is used to store a series of data and information required by the text message unit.
 */
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

/**
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
 *
 *  Mutable strings.
 *  After the text message receives the content string, it is necessary to convert the string expression (such as [smile]) that may exist in the string into a
 * picture expression. This string is responsible for storing the converted result of the above process.
 *
 */
- (NSAttributedString *)getContentAttributedString:(UIFont *)textFont;

/**
 *
 *  Get the display size of content string
 */
- (CGSize)getContentAttributedStringSize:(NSAttributedString *)attributeString maxTextSize:(CGSize)maxTextSize;

/**
 *  NSValue (NSRange) stores the converted string of emoji at the position of attributedString.
 *  NSAttributedString stores the string before emoji conversion, such as "[呲牙]".
 *  When the text is selected and copied, it is necessary to find the original string of emoji.
 */
@property(nonatomic, strong) NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *emojiLocations;

/**
 *  The size of the label which displays the text message content.
 *  Position the text message with the @textOrigin.
 */
@property(nonatomic, assign) CGSize textSize;

/**
 *  The origin of label which displays the text message content.
 
 */
@property(nonatomic, assign) CGPoint textOrigin;

@end

NS_ASSUME_NONNULL_END
