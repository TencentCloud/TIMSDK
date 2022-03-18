//
//  TUIUserAuthorizationCenter.h
//  TUIChat
//
//  Created by wyl on 2022/2/16.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, TUIChatAuthControlType) {
    TUIChatAuthControlTypeMicro = 1 << 0,
    TUIChatAuthControlTypeCamera = 1 << 1,
    TUIChatAuthControlTypePhoto = 1 << 2,
};
@interface TUIUserAuthorizationCenter : NSObject
@property (nonatomic, assign, class, readonly) BOOL isEnablePushAuthotization;
@property (nonatomic, assign, class, readonly) BOOL isEnableCameraAuthorization;
@property (nonatomic, assign, class, readonly) BOOL isEnablePhotoAuthorization;
@property (nonatomic, assign, class, readonly) BOOL isEnableAudioRecognizeAuthorization;
@property (nonatomic, assign, class, readonly) BOOL isEnableMicroAuthorization;
@property (nonatomic, assign, class, readonly) BOOL isEnableLocationAuthorization;


+ (void)userIsAllowPush:(void (^)(BOOL))isOpenPushBlock API_AVAILABLE(ios(8.0));
+ (BOOL)isEnablePushAuthotization:(void (^) (BOOL enable))completion API_AVAILABLE(ios(8.0));
+ (void)cameraStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));
+ (void)photoStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));
+ (void)microStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));
+ (void)audioRecogStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));
+ (void)locationStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));

+ (void)openSettingPage;
+ (void)showAlert:(TUIChatAuthControlType)type;
@end

