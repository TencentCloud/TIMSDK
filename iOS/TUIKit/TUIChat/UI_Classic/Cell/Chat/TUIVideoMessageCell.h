
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This document declares the TUIVideoMessageCell unit, which is responsible for the display of video messages.
 *  The video message unit, a unit displayed when sending and receiving video messages, can display the video cover, video duration, etc. to the user,
 *  and at the same time, can respond to user operations and provide an operation entry for video playback.
 *  When you tap the video message, you will enter the video playback interface.
 */
#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUIMessageCell.h>
#import "TUIVideoMessageCellData.h"
/**
 *
 * 【Module name】TUIVideoMessageCell
 * 【Function description】 Video message unit
 *  - The video message unit provides the function of extracting and displaying thumbnails of video messages, and can display the video length and video
 * download/upload progress.
 *  - At the same time, the network acquisition and local acquisition of video messages (if it exists in the local cache) are integrated in the message unit.
 */
@interface TUIVideoMessageCell : TUIBubbleMessageCell

/**
 *
 *  Video thumbnail
 *  Display the thumbnail of the video when it is not playing, so that users can get general information about the video without playing the video.
 */
@property(nonatomic, strong) UIImageView *thumb;

/**
 *  Label for displaying video duration
 */
@property(nonatomic, strong) UILabel *duration;

/**
 *  Play icon, that is, the "arrow icon" displayed in the UI.
 */
@property(nonatomic, strong) UIImageView *play;

/**
 *  Label for displaying video doadloading/uploading progress
 *
 */
@property(nonatomic, strong) UILabel *progress;

@property TUIVideoMessageCellData *videoData;

- (void)fillWithData:(TUIVideoMessageCellData *)data;
@end
