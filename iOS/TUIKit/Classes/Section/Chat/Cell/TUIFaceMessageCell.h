/******************************************************************************
 *
 *  本文件声明了 TUIFaceMessageCell 类，负责实现表情消息的展示。
 *  表情消息单元，即显示动画表情时所使用并展示的消息单元。
 *  默认情况下，在消息列表中看到的“[动画消息]”，即为表情消息单元所承载并展示的消息。
 *
 ******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIFaceMessageCellData.h"

/** 
 * 【模块名称】TUIFaceMessageCell
 * 【功能说明】表情消息单元。
 *  表情消息单元，即显示动画表情时所使用并展示的消息单元。
 *  默认情况下，在消息列表中看到的“[动画消息]”，即为表情消息单元所承载并展示的消息。
 */
@interface TUIFaceMessageCell : TUIMessageCell

/**
 *  表情图像视图
 *  存放[动画表情]所对应的图像资源。
 */
@property (nonatomic, strong) UIImageView *face;

/**
 *  表情单元数据源
 *  faceData 中存放了表情所在的分组信息、存储路径以及表情名称。
 */
@property TUIFaceMessageCellData *faceData;

/**
 *  填充数据
 *  根据 data 设置表情消息的数据。
 *
 *  @param  data    填充数据需要的数据源
 */
- (void)fillWithData:(TUIFaceMessageCellData *)data;
@end
