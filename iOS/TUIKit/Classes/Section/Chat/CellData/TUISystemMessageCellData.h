 /******************************************************************************
  *
  *  本文件声明了 TUISystemMessageCellData 类。
  *  本类继承于 TUIMessageCellData，用于存放系统消息单元所需的一系列数据与信息。
  *
  ******************************************************************************/
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 * 【模块名称】TUISystemMessageCellData
 * 【功能说明】系统消息单元数据源。
 *  存放系统消息所需要的信息与数据。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUISystemMessageCellData : TUIMessageCellData

/**
 *  系统消息内容，例如“您撤回了一条消息。”
 */
@property (nonatomic, strong) NSString *content;

/**
 *  内容字体
 *  系统消息显示时的 UI 字体。
 */
@property UIFont *contentFont;

/**
 *  内容颜色
 *  系统消息显示时的 UI 颜色。
 */
@property UIColor *contentColor;

@end

NS_ASSUME_NONNULL_END
