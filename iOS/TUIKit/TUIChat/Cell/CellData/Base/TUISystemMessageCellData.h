 /**
  * 本文件声明了 TUISystemMessageCellData 类。
  * 本类继承于 TUIMessageCellData，用于存放系统消息单元所需的一系列数据与信息。
  *
  * This file declares the TUISystemMessageCellData class.
  * This class inherits from TUIMessageCellData and is used to store a series of data and information required by the system message unit.
  *
  */
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 * 【模块名称】TUISystemMessageCellData
 * 【功能说明】系统消息单元数据源。
 *
 * 【Module name】TUISystemMessageCellData
 * 【Function description】The datasource of system message unit.
 */
@interface TUISystemMessageCellData : TUIMessageCellData

/**
 *  系统消息内容，例如“您撤回了一条消息。”
 *
 *  The content of system message, such as "You recalled a message.".
 */
@property (nonatomic, strong) NSString *content;

/**
 *  是否支持重新编辑
 *
 *  The flag of whether supporting re-edit.
 */
@property (nonatomic, assign) BOOL supportReEdit;

/**
 *  可变字符串
 *  撤回消息可以在 2min 内重新编辑，这里基于 attributedString 做展示。
 *
 *  Mutable string
 *  The recalled message can be re-edited within 2 minutes, which is displayed here based on attributedString.
 */
@property (nonatomic, strong) NSMutableAttributedString *attributedString;

/**
 *  内容字体
 *  系统消息显示时的 UI 字体。
 *
 *  The font of label which displays the system message content.
 */
@property UIFont *contentFont;

/**
 *  内容颜色
 *  系统消息显示时的 UI 颜色。
 *
 *  The color of label which displays the system message content.
 */
@property UIColor *contentColor;

@end

NS_ASSUME_NONNULL_END
