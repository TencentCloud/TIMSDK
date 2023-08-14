
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  本文件声明了 TUIVideoMessageCell 单元，负责实现视频消息的显示。
 *  视频消息单元，在收发视频消息时展示的单元，能够向用户展示视频封面、视频时长等，同时能够响应用户操作，提供视频播放的操作入口。
 *  当您轻点视频消息时，便会进入视频播放界面。
 *
 *  This document declares the TUIVideoMessageCell unit, which is responsible for the display of video messages.
 *  The video message unit, a unit displayed when sending and receiving video messages, can display the video cover, video duration, etc. to the user,
 *  and at the same time, can respond to user operations and provide an operation entry for video playback.
 *  When you tap the video message, you will enter the video playback interface.
 */
#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUIMessageCell.h>
#import "TUIVideoMessageCellData.h"
/**
 * 【模块名称】TUIVideoMessageCell
 * 【功能说明】视频消息单元
 *  - 视频消息单元，提供了视频消息的缩略图提取与显示，并能够将视频长度、视频下载/上传进度展现出来。
 *  - 同时消息单元内整合了视频消息的网络获取与本地获取（如果本地缓存中存在的话）。
 *
 * 【Module name】TUIVideoMessageCell
 * 【Function description】 Video message unit
 *  - The video message unit provides the function of extracting and displaying thumbnails of video messages, and can display the video length and video
 * download/upload progress.
 *  - At the same time, the network acquisition and local acquisition of video messages (if it exists in the local cache) are integrated in the message unit.
 */
@interface TUIVideoMessageCell : TUIBubbleMessageCell

/**
 *  视频缩略图
 *  在未播放时展示视频的缩略图，方便用户不播放视频就能了解视频大致信息。
 *
 *  Video thumbnail
 *  Display the thumbnail of the video when it is not playing, so that users can get general information about the video without playing the video.
 */
@property(nonatomic, strong) UIImageView *thumb;

/**
 *  视频时长标签
 *  Label for displaying video duration
 */
@property(nonatomic, strong) UILabel *duration;

/**
 *  播放图标
 *  即在 UI 中显示的“箭头图标”。
 *
 *  Play icon, that is, the "arrow icon" displayed in the UI.
 */
@property(nonatomic, strong) UIImageView *play;

/**
 *  视频进度标签
 *  根据当前视频的下载/上传状态，展示视频下载/上传进度。
 *
 *  Label for displaying video doadloading/uploading progress
 *
 */
@property(nonatomic, strong) UILabel *progress;

@property TUIVideoMessageCellData *videoData;

- (void)fillWithData:(TUIVideoMessageCellData *)data;
@end
