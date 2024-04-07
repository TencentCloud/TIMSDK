
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  1. This file declares the TUIVideoItem class, TUISnapshotItem class, and TUIVideoMessageCellData class.
 *    - TUIVideoItem corresponds to V2TIMVideoElem in the IM SDK. We convert the classes in the SDK to TUIVideoItem, which is convenient for us to further
 * process and operate the data.
 *    - TUISnapshotItem corresponds to the video cover class in the IM SDK. It is still an image in essence, but is bound to the corresponding Video.
 *    - TUIVideoMessageCellData inherits from the TUIMessageCellData class and is used to store a series of data and information required by the image message
 * unit.
 *  2. The business logic for obtaining video information and cover information has been implemented in this document. When you need to get video and cover
 * data, you can directly call the relevant member functions declared in this file
 */

#import <TIMCommon/TUIBubbleMessageCellData.h>
#import "TUIChatDefine.h"
#import "TUIMessageItem.h"

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIVideoMessageCellData
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIVideoMessageCellData : TUIBubbleMessageCellData <TUIMessageCellDataFileUploadProtocol>

@property(nonatomic, strong) UIImage *thumbImage;
@property(nonatomic, strong) NSString *videoPath;
@property(nonatomic, strong) NSString *snapshotPath;
@property(nonatomic, strong) TUIVideoItem *videoItem;
@property(nonatomic, strong) TUISnapshotItem *snapshotItem;
@property(nonatomic, assign) NSUInteger uploadProgress;
@property(nonatomic, assign) NSUInteger thumbProgress;
@property(nonatomic, assign) NSUInteger videoProgress;
/// Is the current message a custom message
@property(nonatomic, assign) BOOL isPlaceHolderCellData;

+ (TUIMessageCellData *)placeholderCellDataWithSnapshotUrl:(NSString *)snapshotUrl thubImage:(UIImage *)thubImage;

- (void)getVideoUrl:(void (^)(NSString *url))urlCallBack;

/**
 *  Downloading the cover image of the video. It will download from server if the image not exist in local.
 */
- (void)downloadThumb;
- (void)downloadThumb:(TUIVideoMessageDownloadCallback)finish;

/**
 *  Downloading the video file. It will download from server if the video not exist  in local.
 */
- (void)downloadVideo;

- (BOOL)isVideoExist;

@end

NS_ASSUME_NONNULL_END
