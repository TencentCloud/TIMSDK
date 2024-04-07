
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *
 *  This file declares the TUIFaceMessageCellData class.
 *  This class inherits from TUIMessageCellData and is used to store a series of data and information required by the emoticon message unit.
 */
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】TUIFaceMessageCellData
 * 【Function description】Emoticon message unit data source.
 *  - The emoticon message unit is the message unit used and displayed when displaying animated emoticons.
 *  - The emoticon message unit data source is a class that provides a series of required data for the display of the emoticon message unit.
 */
@interface TUIFaceMessageCellData : TUIBubbleMessageCellData

/**
 *
 *  The index of emoticon groups
 *  - The subscript of the group where the emoticon is located, which is used to locate the emoticon group where the emoticon is located.
 */
@property(nonatomic, assign) NSInteger groupIndex;

/**
 *  The path of the emoticon file
 */
@property(nonatomic, strong) NSString *path;

/**
 *  The name of emoticon.
 */
@property(nonatomic, strong) NSString *faceName;

@end

NS_ASSUME_NONNULL_END
