//
//  TUIBaseChatViewController+AuthControl.h
//  TUIChat
//
//  Created by wyl on 2022/2/14.
//

#import "TUIBaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController (AuthControl)
- (void)selectPhotoForSend;//可选 selectPhotoForSendV2
- (void)takePictureForSend;
- (void)takeVideoForSend;
- (void)selectFileForSend;

/*
 // selectPhotoForSendV2 方法 支持了iOS隐私14新API，使用了全新的PHPickerViewController提供隐私安全。
 // 同时向下兼容使用UIImagePickerController进行图文发送
 // 如需支持多选发送，可在v2版本基础上开发.
 // 注：模拟器上因为一张图片含有heic的存在可能导致无法正常发送，真机无误
 //There is a separate JEPG transcoding issue that only affects the simulator (63426347), please refer to https://developer.apple.com/forums/thread/658135 for more information.
 */
- (void)selectPhotoForSendV2;

@end

NS_ASSUME_NONNULL_END
