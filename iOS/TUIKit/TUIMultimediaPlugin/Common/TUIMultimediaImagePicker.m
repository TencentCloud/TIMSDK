// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaImagePicker.h"
@interface TUIMultimediaImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImagePickerController *_pickerVC;
}

@end

@implementation TUIMultimediaImagePicker
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _pickerVC = [[UIImagePickerController alloc] init];
        _pickerVC.delegate = self;
    }
    return self;
}

- (void)presentOn:(UIViewController *)viewController {
    [viewController presentViewController:_pickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (_callback != nil) {
        _callback([info objectForKey:UIImagePickerControllerOriginalImage]);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (_callback != nil) {
        _callback(nil);
    }
}
@end
