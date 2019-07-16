/******************************************************************************
 *
 *  本文件声明了 TUIVideoMessageCell 单元，负责实现视频消息的显示。
 *  视频消息单元，在收发视频消息时展示的单元，能够向用户展示视频封面、视频时长等，同时能够响应用户操作，提供视频播放的操作入口。
 *  当您轻点视频消息时，便会进入视频播放界面。
 *
 ******************************************************************************/
#import "TUIMessageCell.h"
#import "TUIVideoMessageCellData.h"

/**
 * 【模块名称】TUIVideoMessageCell
 * 【功能说明】视频消息单元
 *  视频消息单元，提供了视频消息的缩略图提取与显示，并能够将视频长度、视频下载/上传进度展现出来。
 *  同时消息单元内整合了视频消息的网络获取与本地获取（如果本地缓存中存在的话）。
 *  是您能够方便的在 UI 界面展示并播放视频消息。
 */
@interface TUIVideoMessageCell : TUIMessageCell

/**
 *  视频缩略图
 *  在未播放时展示视频的缩略图，方便用户不播放视频就能了解视频大致信息。
 */
@property (nonatomic, strong) UIImageView *thumb;

/**
 *  视频时长标签
 *  在聊天视图的消息单元内展示视频时长，方便用户不播放视频就能了解视频大致信息。
 */
@property (nonatomic, strong) UILabel *duration;

/**
 *  播放图标
 *  即在 UI 中显示的“箭头图标”。
 */
@property (nonatomic, strong) UIImageView *play;

/**
 *  视频进度标签
 *  根据当前视频的下载/上传状态，展示视频下载/上传进度。
 */
@property (nonatomic, strong) UILabel *progress;
//@property (nonatomic, strong) UIActivityIndicatorView *videoIndicator;

/**
 *  视频消息单元数据源
 *  数据源存放了视频的类型、时长、大小、识别码、缩略图、进度数值等一系列视频消息所需信息。
 *  详细信息请参考 Section\Chat\CellData\TUIVideoMessageCellData.h
 */
@property TUIVideoMessageCellData *videoData;

/**
 *  填充数据
 *  根据 data 设置视频消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIVideoMessageCellData *)data;
@end
