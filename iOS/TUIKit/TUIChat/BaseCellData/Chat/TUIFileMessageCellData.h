
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCellData.h>
#import <TIMCommon/TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIFileMessageCellData : TUIBubbleMessageCellData <TUIMessageCellDataFileUploadProtocol, TUIMessageCellDataFileDownloadProtocol>

/**
 *  File path
 */
@property(nonatomic, strong) NSString *path;

/**
 *  File name, including suffix.
 */
@property(nonatomic, strong) NSString *fileName;

/**
 *  Inner ID for file
 */
@property(nonatomic, strong) NSString *uuid;

/**
 *  File size, used to display the data volume information of the file.
 */
@property(nonatomic, assign) int length;

/**
 *  The progress of file uploading, which maintained by the cellData.
 */
@property(nonatomic, assign) NSUInteger uploadProgress;

/**
 *  The progress of file downloading, which maintained by the cellData.
 */
@property(nonatomic, assign) NSUInteger downladProgress;

/**
 *  The flag of indicating whether the file is downloading
 *  YES: dowloading;  NO: not download
 */
@property(nonatomic, assign) BOOL isDownloading;

/**
 *  Downloading the file
 *  This method integrates and calls the IM SDK, and obtains the file through the interface provided by the SDK.
 *  1. Before downloading the file from server, it will try to read file from local when the file exists in the local.
 *  2. When the file not exists in the local, it will download from server through the api provided by IMSDK. But if there is downloading task, it will wait for
 * the task finished.
 *    - The download progress (percentage value) is updated through the callback of the IMSDK.
 *    - There are two parameters which is @curSize and @totalSize in the callback of IMSDK. The progress value equals to curSize * 100 / totalSize.
 *  3. When finished download, the file will be storaged to the @path.
 */
- (void)downloadFile;

/**
 *  Determine if the file is already downloaded to local
 *  This method will first try to get the file path from the local, if the acquisition is successful, record the path and return YES. Otherwise return NO.
 */
- (BOOL)isLocalExist;

/**
 *  Getting the file path and it will return the flag of whether the file exists through @isExist.
 */
- (NSString *)getFilePath:(BOOL *)isExist;

@end

NS_ASSUME_NONNULL_END
