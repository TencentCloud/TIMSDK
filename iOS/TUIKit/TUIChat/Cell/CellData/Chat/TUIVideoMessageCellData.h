 /**
  *
  *  1. 本文件声明了 TUIVideoItem 类、TUISnapshotItem 类和 TUIVideoMessageCellData 类。
  *    - TUIVideoItem 对应 IM SDK 中的 V2TIMVideoElem，我们将 SDK 中的类转换为 TUIVideoItem，方便我们进一步对数据进行处理与操作。
  *    - TUISnapshotItem 对应 IM SDK 中的视频封面类，本质上仍是一个图像，只是与对应 Video 绑定存在。
  *    - TUIVideoMessageCellData 继承于 TUIMessageCellData 类，用于存放图像消息单元所需的一系列数据与信息。
  *  2. 本文件中已经实现了获取视频信息和封面信息的业务逻辑。当您需要获取视频和封面数据时，直接调用本文件中声明的相关成员函数即可
  *
  *  1. This file declares the TUIVideoItem class, TUISnapshotItem class, and TUIVideoMessageCellData class.
  *    - TUIVideoItem corresponds to V2TIMVideoElem in the IM SDK. We convert the classes in the SDK to TUIVideoItem, which is convenient for us to further process and operate the data.
  *    - TUISnapshotItem corresponds to the video cover class in the IM SDK. It is still an image in essence, but is bound to the corresponding Video.
  *    - TUIVideoMessageCellData inherits from the TUIMessageCellData class and is used to store a series of data and information required by the image message unit.
  *  2. The business logic for obtaining video information and cover information has been implemented in this document. When you need to get video and cover data, you can directly call the relevant member functions declared in this file
  */

#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIVideoMessageDownloadCallback)(void);

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIVideoItem
//
/////////////////////////////////////////////////////////////////////////////////
///
@interface TUIVideoItem : NSObject

/**
 *  视频消息内部 ID，不用设置，通过 SDK 拉取的视频实例中获取。
 *  The internal ID of the video message, which does not need to be set, is obtained from the video instance pulled by the SDK.
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  视频类型，即后缀格式，发送消息时设置。比如“mp4”。
 *  The video type - the suffix of the video file - is set when sending a message. For example "mp4".
 */
@property (nonatomic, strong) NSString *type;

/**
 *  视频体积大小，无需设置，通过 SDK 拉取的实例中获取。
 *  The video size, no need to set, is obtained from the instance pulled by the SDK.
 */
@property (nonatomic, assign) NSInteger length;

/**
 *  视频时长
 *  video duration
 */
@property (nonatomic, assign) NSInteger duration;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUISnapshotItem
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUISnapshotItem : NSObject

/**
 *  图片 ID，内部标识，可用于外部缓存key
 *  Image ID, internal identifier, can be used for external cache key
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  封面图片
 *  Cover image type
 */
@property (nonatomic, strong) NSString *type;

/**
 *  封面在 UI 上的大小。
 *  The size of the cover on the UI.
 */
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) NSInteger length;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIVideoMessageCellData
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIVideoMessageCellData : TUIBubbleMessageCellData<TUIMessageCellDataFileUploadProtocol>


@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *snapshotPath;
@property (nonatomic, strong) TUIVideoItem *videoItem;
@property (nonatomic, strong) TUISnapshotItem *snapshotItem;
@property (nonatomic, assign) NSUInteger uploadProgress;
@property (nonatomic, assign) NSUInteger thumbProgress;
@property (nonatomic, assign) NSUInteger videoProgress;

- (void)getVideoUrl:(void(^)(NSString *url))urlCallBack;

/**
 *  获取视频封面
 *
 *  Downloading the cover image of the video. It will download from server if the image not exist in local.
 */
- (void)downloadThumb;
- (void)downloadThumb:(TUIVideoMessageDownloadCallback)finish;

/**
 *  获取视频
 *
 *  Downloading the video file. It will download from server if the video not exist  in local.
 */
- (void)downloadVideo;

- (BOOL)isVideoExist;

@end

NS_ASSUME_NONNULL_END
