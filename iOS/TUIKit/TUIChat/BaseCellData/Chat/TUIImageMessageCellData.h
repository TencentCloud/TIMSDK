
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIBubbleMessageCellData.h>
#import "TUIChatDefine.h"
#import "TUIMessageItem.h"

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIImageMessageCellData
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *
 * 【Module name】 TUIImageMessageCellData
 * 【Function description】It is used to realize the picture bubble in the chat window, including the display of picture message sending progress.
 *  At the same time, this module already supports three different types of "thumbnail", "large image" and "original image", and
 *  has handled the business logic of displaying the corresponding image type under appropriate circumstances:
 *  1. Thumbnail - By default, you see thumbnails in the chat window, which is smaller and saves traffic.
 *  2. Large image - If the user clicks on the thumbnail, they see a larger image with a better resolution.
 *  3. Original image - If the sender chooses to send the original image, the recipient will see the "original image" button which can click to download the
 * image with the original size.
 */
@interface TUIImageMessageCellData : TUIBubbleMessageCellData <TUIMessageCellDataFileUploadProtocol>

@property(nonatomic, strong) UIImage *thumbImage;
@property(nonatomic, strong) UIImage *originImage;
@property(nonatomic, strong) UIImage *largeImage;

/**
 *  
 *  The file storage path
 *
 *  @note
 *   @path is maintained by the program by default, you can directly obtain the demo storage path by importing TIMDefine.h and referencing TUIKit_Image_Path
 *   Other routes are also available if you have further individual needs
 */
@property(nonatomic, strong) NSString *path;
@property(nonatomic, assign) NSInteger length;

/**
 *  
 *  The set of image items
 *
 *  @note
 *  There are usually three imageItems stored in @items, namely thumb (thumb image), origin (original image), and large (large image), which is convenient to
 * obtain images flexibly according to needs.
 *
 */
@property(nonatomic, strong) NSMutableArray *items;

/**
 *  The progress of loading thumbnail
 */
@property(nonatomic, assign) NSUInteger thumbProgress;

/**
 *  The progress of loading origin image
 */
@property(nonatomic, assign) NSUInteger originProgress;

/**
 *  The progress of loading large image
 */
@property(nonatomic, assign) NSUInteger largeProgress;

/**
 *  The progress of uploading (sending)
 */
@property(nonatomic, assign) NSUInteger uploadProgress;

@property(nonatomic, assign) BOOL  isSuperLongImage;

/**

 *  Downloading image.
 *  This method integrates and calls the IM SDK, and obtains images from sever through the interface provided by the SDK.
 *  1. Before downloading the file from server, it will try to read file from local when the file exists in the local.
 *  2. If the file is not exist in the local, it will download from server through the api named @getImage which provided by the class of TIMImage in the IMSDK.
 *    - The download progress (percentage value) is updated through the callback of the IMSDK.
 *    - There are two parameters which is @curSize and @totalSize in the callback of IMSDK. The progress value equals to curSize * 100 / totalSize.
 *    - The type of items in the image message is TIMElem. You can obtain image list from the paramter named imageList provided by TIMElem, which  including
 * original image、large image and thumbnail and you can obtain the image from it with the @imageType.
 *  3. The image obtained through the SDK interface is a binary file, which needs to be decoded first, converted to CGIamge for decoding, and then packaged as a
 * UIImage before it can be used.
 *  4. When finished download, the image will be storaged to the @path.
 */
- (void)downloadImage:(TUIImageType)type;
- (void)downloadImage:(TUIImageType)type finish:(TUIImageMessageDownloadCallback)finish;

/**
 *
 *  Decode the image and assign the image to a variable of the corresponding type (@thumbImage, @largeImage or @originImage).
 */
- (void)decodeImage:(TUIImageType)type;

/**
 *  
 *  Getting image file path
 */
- (NSString *)getImagePath:(TUIImageType)type isExist:(BOOL *)isExist;
@end

NS_ASSUME_NONNULL_END
