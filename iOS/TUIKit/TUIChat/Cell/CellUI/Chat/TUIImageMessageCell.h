/******************************************************************************
 *
 *  本文件 声明了 TUIImageMessageCell 类
 *  图片消息单元，即在收发图片时所显示的消息单元。同时本消息单元还向用户提供了缩略图、大图、原图三种浏览状态。
 *  在消息界面，默认显示缩略图，当您点击缩略图后，会进一步显示大图。当您在大图界面点击下方的“显示原图”按钮时，会加载并显示原图。
 *
 ******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIImageMessageCellData.h"

/**
 * 【模块名称】TUIImageMessageCell
 * 【功能说明】用于实现聊天窗口中的图片气泡，包括图片消息发送进度的展示也在其中。
 *  同时，该模块已经支持“缩略图”、“大图”和“原图”三种不同的类型，并已经处理好了在合适的情况下展示相应图片类型的业务逻辑：
 *  1. 缩略图 - 默认在聊天窗口中看到的是缩略图，体积较小省流量
 *  2. 大图 - 如果用户点开之后，看到的是分辨率更好的大图
 *  3. 原图 - 如果发送方选择发送原图，那么接收者会看到“原图”按钮，点击下载到原尺寸的图片
 *  其中，三类不同清晰度的视图存储在属性 imageData 中。详细信息请参考 Section\Chat\CellData\TUIIamgeMessageCellData.h
 */
@interface TUIImageMessageCell : TUIMessageCell

/**
 *  缩略图
 *  用于在消息单元内展示的小图，默认优先展示缩略图，省流量。
 */
@property (nonatomic, strong) UIImageView *thumb;

/**
 *  下载进度标签
 *  图像的下载进度标签，用于向用户展示当前图片的获取进度，优化交互体验。
 */
@property (nonatomic, strong) UILabel *progress;

/**
 *  图像消息单元消息源
 *  imageData 中存放了图像路径，图像原图、大图、缩略图，以及三种图像对应的下载进度、上传进度等各种图像消息单元所需信息。
 *  详细信息请参考 Section\Chat\CellData\TUIIamgeMessageCellData.h
 */
@property TUIImageMessageCellData *imageData;

/**
 *  填充数据
 *  根据 data 设置图像消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
