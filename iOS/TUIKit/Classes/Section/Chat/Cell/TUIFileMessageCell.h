/******************************************************************************
 *
 *  本文件声明了 TUIFileMessageCell 类，负责实现文件消息的展示，包括文件类型、文件大小等信息。
 *  文件消息单元，即发送/接收文件消息时所使用并显示的消息单元，您可以通过点击该文件单元打开对应文件。
 *  文件消息单元用于展示文件相关信息，并向用户提供文件下载与浏览的操作入口。
 *
 ******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIFileMessageCellData.h"

/**
 * 【模块名称】TUIFileMessageCell
 * 【功能说明】文件消息单元。
 *  文件消息单元，即发送/接收文件消息时所使用并显示的消息单元。
 *  文件消息单元通常由文件名、文件大小与文件图标构成。您也可以根据您的需求对 TUIFileMessageCell 进行自定义修改。
 *  该类继承自 TUIBubbleMessageCell 来实现气泡消息。您可以参考这一继承关系实现自定义气泡。
 */
@interface TUIFileMessageCell : TUIMessageCell

/**
 *  文件气泡视图
 *  用来在UI上包裹消息
 */
@property (nonatomic, strong) UIImageView *bubble;

/**
 *  文件名标签
 *  作为文件消息的主要标签，展示文件信息（包含后缀）。
 */
@property (nonatomic, strong) UILabel *fileName;

/**
 *  文件长度
 *  作为文件消息的小标签，进一步展示文件的次要信息。
 */
@property (nonatomic, strong) UILabel *length;

/**
 *  文件图标
 *  在消息单元中显示的图标，能够使 UI 更形象、更美观。
 */
@property (nonatomic, strong) UIImageView *image;

/**
 *  文件单元消息源
 *  消息源中存放了文件名称、文件路径、文件长度、文件识别码等多种文件消息的相关信息。
 *  详细信息请参考 Section\Chat\CellData\TUIFileMessageCellData.h
 */
@property TUIFileMessageCellData *fileData;

/**
 *  填充数据
 *  根据 data 设置文件消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIFileMessageCellData *)data;
@end
