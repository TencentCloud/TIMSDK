//
//  TUIBaseChatViewController+AuthControl.h
//  TUIChat
//
//  Created by wyl on 2022/2/14.
//

#import "TUIBaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController (AuthControl)

/**
 * 支持了iOS隐私14新API，使用了全新的 PHPickerViewController 提供隐私安全。
 * 同时向下兼容使用 UIImagePickerController 进行图片发送
 * 注：模拟器上因为一张图片含有heic的存在可能导致无法正常发送，https://developer.apple.com/forums/thread/658135
 *
 * It supports the new API of iOS privacy 14, and uses the new PHPickerViewController to provide privacy security.
 * At the same time, it is backward compatible to use UIImagePickerController for image message sending
 * Note: There is a separate JEPG transcoding issue that only affects the simulator (63426347), please refer to https://developer.apple.com/forums/thread/658135 for more information.
 */
- (void)selectPhotoForSendV2;
- (void)selectPhotoForSend;

- (void)takePictureForSend;

- (void)takeVideoForSend;

- (void)selectFileForSend;

@end

NS_ASSUME_NONNULL_END
