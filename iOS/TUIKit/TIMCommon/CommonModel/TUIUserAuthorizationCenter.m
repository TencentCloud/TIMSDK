//
//  TUIUserAuthorizationCenter.m
//  TUIChat
//
//  Created by wyl on 2022/2/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIUserAuthorizationCenter.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreMotion/CoreMotion.h>
#import <EventKit/EventKit.h>
#import <Photos/Photos.h>
#import <Speech/Speech.h>
#import <TIMCommon/TIMDefine.h>
#import <UserNotifications/UserNotifications.h>

#import <TUICore/TUIGlobalization.h>
@implementation TUIUserAuthorizationCenter

+ (BOOL)isEnableCameraAuthorization {
    if (@available(iOS 7.0, *)) {
        return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized;
    } else {
        return YES;
    }
}

+ (void)cameraStateActionWithPopCompletion:(void (^)(void))completion {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                   if (granted && completion) {
                                       completion();
                                   }
                                 }];
    } else {
        [self showAlert:TUIChatAuthControlTypeCamera];
    }
}

+ (void)openSettingPage {
    if (@available(iOS 8.0, *)) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    } else {
        // Fallback on earlier versions
    }
}

+ (BOOL)isEnableMicroAuthorization {
    if (@available(iOS 7.0, *)) {
        return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized;
    } else {
        return YES;
    }
}

+ (void)microStateActionWithPopCompletion:(void (^)(void))completion {
#if !TARGET_OS_MACCATALYST
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                 completionHandler:^(BOOL granted) {
                                   if (granted && completion) {
                                       completion();
                                   }
                                 }];
    } else {
        [self showAlert:TUIChatAuthControlTypeMicro];
    }
#endif
}

+ (BOOL)isEnableLocationAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (@available(iOS 8.0, *)) {
        return status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
    } else {
        // Fallback on earlier versions
        return YES;
    }
}

+ (void)showAlert:(TUIChatAuthControlType)type {
    NSString *title = @"";
    NSString *message = @"";
    NSString *laterMessage = @"";
    NSString *openSettingMessage = @"";

    if (TUIChatAuthControlTypeMicro == type) {
        title = TIMCommonLocalizableString(TUIKitInputNoMicTitle);
        message = TIMCommonLocalizableString(TUIKitInputNoMicTips);
        laterMessage = TIMCommonLocalizableString(TUIKitInputNoMicOperateLater);
        openSettingMessage = TIMCommonLocalizableString(TUIKitInputNoMicOperateEnable);
    } else if (TUIChatAuthControlTypeCamera == type) {
        title = TIMCommonLocalizableString(TUIKitInputNoCameraTitle);
        message = TIMCommonLocalizableString(TUIKitInputNoCameraTips);
        laterMessage = TIMCommonLocalizableString(TUIKitInputNoCameraOperateLater);
        openSettingMessage = TIMCommonLocalizableString(TUIKitInputNoCameraOperateEnable);
    } else if (TUIChatAuthControlTypePhoto == type) {
        title = TIMCommonLocalizableString(TUIKitInputNoPhotoTitle);
        message = TIMCommonLocalizableString(TUIKitInputNoPhotoTips);
        laterMessage = TIMCommonLocalizableString(TUIKitInputNoPhotoOperateLater);
        openSettingMessage = TIMCommonLocalizableString(TUIKitInputNoPhotoerateEnable);
    } else {
        return;
    }
    if (@available(iOS 8.0, *)) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:laterMessage style:UIAlertActionStyleCancel handler:nil]];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:openSettingMessage
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        UIApplication *app = [UIApplication sharedApplication];
                                                        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                        if ([app canOpenURL:settingsURL]) {
                                                            [app openURL:settingsURL];
                                                        }
                                                      }]];
        dispatch_async(dispatch_get_main_queue(), ^{
          [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
          //        [self presentViewController:ac animated:YES completion:nil];
        });
    } else {
        // Fallback on earlier versions
    }
}

@end
