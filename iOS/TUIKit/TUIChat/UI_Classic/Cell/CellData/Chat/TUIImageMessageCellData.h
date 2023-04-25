#import <TIMCommon/TUIBubbleMessageCellData.h>
#import "TUIMessageItem.h"
#import "TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIImageMessageCellData
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 【模块名称】TUIImageMessageCellData
 * 【功能说明】用于实现聊天窗口中的图片气泡，包括图片消息发送进度的展示也在其中。
 *  同时，该模块已经支持“缩略图”、“大图”和“原图”三种不同的类型，并已经处理好了在合适的情况下展示相应图片类型的业务逻辑：
 *  1. 缩略图 - 默认在聊天窗口中看到的是缩略图，体积较小省流量
 *  2. 大图 - 如果用户点开之后，看到的是分辨率更好的大图
 *  3. 原图 - 如果发送方选择发送原图，那么接收者会看到“原图”按钮，点击下载到原尺寸的图片
 *
 * 【Module name】 TUIImageMessageCellData
 * 【Function description】It is used to realize the picture bubble in the chat window, including the display of picture message sending progress.
 *  At the same time, this module already supports three different types of "thumbnail", "large image" and "original image", and
 *  has handled the business logic of displaying the corresponding image type under appropriate circumstances:
 *  1. Thumbnail - By default, you see thumbnails in the chat window, which is smaller and saves traffic.
 *  2. Large image - If the user clicks on the thumbnail, they see a larger image with a better resolution.
 *  3. Original image - If the sender chooses to send the original image, the recipient will see the "original image" button which can click to download the image with the original size.
 */
@interface TUIImageMessageCellData : TUIBubbleMessageCellData<TUIMessageCellDataFileUploadProtocol>

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIImage *largeImage;

/**
 *  图像路径
 *  The file storage path
 *
 *  @note
 *  - path 由程序默认维护，您可以通过引入 TIMDefine.h 并引用 TUIKit_Image_Path 来直接获取 Demo 存储路径
 *   @path is maintained by the program by default, you can directly obtain the demo storage path by importing TIMDefine.h and referencing TUIKit_Image_Path
 *
 *  - 如果您有进一步的个性化需求，也可使用其他路径
 *   Other routes are also available if you have further individual needs
 */
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger length;

/**
 *  图像项目集
 *  The set of image items
 *
 *  @note
 *  - items 中通常存放三个imageItem，分别为 thumb（缩略图）、origin（原图）、large（大图），方便根据根据需求灵活获取图像
 *   There are usually three imageItems stored in @items, namely thumb (thumbnail), origin (original image), and large (large image), which is convenient to obtain images flexibly according to needs.
 *
 */
@property (nonatomic, strong) NSMutableArray *items;

/**
 *  缩略图加载进度
 *  The progress of loading thumbnail
 */
@property (nonatomic, assign) NSUInteger thumbProgress;

/**
 *  原图加载进度
 *  The progress of loading origin image
 */
@property (nonatomic, assign) NSUInteger originProgress;

/**
 *  大图加载进度
 *  The progress of loading large image
 */
@property (nonatomic, assign) NSUInteger largeProgress;

/**
 *  上传（发送）进度
 *  The progress of uploading (sending)
 */
@property (nonatomic, assign) NSUInteger uploadProgress;

/**
 *  获取图像
 *  本函数整合调用了 IM SDK，通过 SDK 提供的接口在线获取图像。
 *  1、下载前会判断图像是否在本地，若不在本地，则在本地直接获取图像。
 *  2、当图像不在本地时，通过 IM SDK 中 TIMImage 提供的 getImage 接口在线获取。
 *     - 下载进度百分比则通过接口回调的 progress（代码块）参数进行更新。
 *     - 代码块具有 curSize 和 totalSize 两个参数，由回调函数维护 curSize，然后通过 curSize * 100 / totalSize 计算出当前进度百分比。
 *     - 图像消息中存放的格式为 TIMElem，图片列表需通过 TIMElem.imageList 获取，在 imalgelist 中，包含了原图、大图与缩略图，可通过 imageType 进一步获取。
 *  3、通过 SDK 接口获取的图像为二进制文件，需先进行解码，转换为 CGIamge 进行解码操作后包装为 UIImage 才可使用。
 *  4、下载成功后，会生成图像 path 并存储下来。
 *
 *  Downloading image.
 *  This method integrates and calls the IM SDK, and obtains images from sever through the interface provided by the SDK.
 *  1. Before downloading the file from server, it will try to read file from local when the file exists in the local.
 *  2. If the file is not exist in the local, it will download from server through the api named @getImage which provided by the class of TIMImage in the IMSDK.
 *    - The download progress (percentage value) is updated through the callback of the IMSDK.
 *    - There are two parameters which is @curSize and @totalSize in the callback of IMSDK. The progress value equals to curSize * 100 / totalSize.
 *    - The type of items in the image message is TIMElem. You can obtain image list from the paramter named imageList provided by TIMElem, which  including original image、large image and thumbnail and you can obtain the image from it with the @imageType.
 *  3. The image obtained through the SDK interface is a binary file, which needs to be decoded first, converted to CGIamge for decoding, and then packaged as a UIImage before it can be used.
 *  4. When finished download, the image will be storaged to the @path.
 */
- (void)downloadImage:(TUIImageType)type;
- (void)downloadImage:(TUIImageType)type finish:(TUIImageMessageDownloadCallback)finish;

/**
 *  解码图像，并将图像赋值到对应类型的变量（缩略图、大图或者原图）中。
 *
 *  Decode the image and assign the image to a variable of the corresponding type (@thumbImage, @largeImage or @originImage).
 */
- (void)decodeImage:(TUIImageType)type;


/**
 *  获取图像路径
 *  Getting image file path
 */
- (NSString *)getImagePath:(TUIImageType)type isExist:(BOOL *)isExist;
@end

NS_ASSUME_NONNULL_END
