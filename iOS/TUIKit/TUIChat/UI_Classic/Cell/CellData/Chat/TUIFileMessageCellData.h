
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIFileMessageCellData : TUIBubbleMessageCellData<TUIMessageCellDataFileUploadProtocol, TUIMessageCellDataFileDownloadProtocol>

/**
 *  文件存储路径
 *
 *  File path
 */
@property (nonatomic, strong) NSString *path;

/**
 *  文件名称
 *  文件名称包含后缀。
 *
 *  File name, including suffix.
 */
@property (nonatomic, strong) NSString *fileName;

/**
 *  文件内部 ID
 *
 *  Inner ID for file
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  文件长度
 *  文件大小，用于展示文件的数据体积信息。
 *
 *  File size, used to display the data volume information of the file.
 */
@property (nonatomic, assign) int length;

/**
 *  文件上传进度
 *  在上传过程中，cellData 维护该进度值。
 *
 *  The progress of file uploading, which maintained by the cellData.
 */
@property (nonatomic, assign) NSUInteger uploadProgress;

/**
 *  文件下载进度
 *  在下载过程中，cellData 维护该进度值。
 *
 *  The progress of file downloading, which maintained by the cellData.
 */
@property (nonatomic, assign) NSUInteger downladProgress;

/**
 *  下载标识符
 *  YES：正在下载；NO：未在下载
 *
 *  The flag of indicating whether the file is downloading
 *  YES: dowloading;  NO: not download
 */
@property (nonatomic, assign) BOOL isDownloading;

/**
 *  下载文件
 *  本函数整合调用了 IM SDK ，通过 SDK 提供的接口获取文件。
 *  1、下载文件时，会先判断文件是否在本地，如果在本地则直接读取。
 *  2、当文件不在本地时，判断目前是否正在下在，若正在下载，则等待下载完成，否则通过 IM SDK 提供的接口在线获取。
 *     - 下载进度百分比通过接口回调的 progress（代码块）参数进行更新。
 *     - 代码块具有 curSize 和 totalSize 两个参数，由回调函数维护 curSize，然后通过 curSize * 100 / totalSize 计算出当前进度百分比。
 *  3、下载成功后，会生成文件 path 并存储下来。
 *
 *  Downloading the file
 *  This method integrates and calls the IM SDK, and obtains the file through the interface provided by the SDK.
 *  1. Before downloading the file from server, it will try to read file from local when the file exists in the local.
 *  2. When the file not exists in the local, it will download from server through the api provided by IMSDK. But if there is downloading task, it will wait for the task finished.
 *    - The download progress (percentage value) is updated through the callback of the IMSDK.
 *    - There are two parameters which is @curSize and @totalSize in the callback of IMSDK. The progress value equals to curSize * 100 / totalSize.
 *  3. When finished download, the file will be storaged to the @path.
 */
- (void)downloadFile;

/**
 *  判断文件是否已在本地
 *  本函数会先尝试从本地获取文件 path，若获取成功，记录 path 并返回 YES。否则返回 NO。
 *
 *  Determine if the file is already downloaded to local
 *  This method will first try to get the file path from the local, if the acquisition is successful, record the path and return YES. Otherwise return NO.
 */
- (BOOL)isLocalExist;


/**
 *  获取文件路径
 *
 *  Getting the file path and it will return the flag of whether the file exists through @isExist.
 */
- (NSString *)getFilePath:(BOOL *)isExist;

@end

NS_ASSUME_NONNULL_END
