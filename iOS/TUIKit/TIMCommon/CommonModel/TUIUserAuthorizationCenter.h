//
//  TUIUserAuthorizationCenter.h
//  TUIChat
//
//  Created by wyl on 2022/2/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TUIChatAuthControlType) {
    TUIChatAuthControlTypeMicro = 1 << 0,
    TUIChatAuthControlTypeCamera = 1 << 1,
    TUIChatAuthControlTypePhoto = 1 << 2,
};
@interface TUIUserAuthorizationCenter : NSObject
@property(nonatomic, assign, class, readonly) BOOL isEnableCameraAuthorization;
@property(nonatomic, assign, class, readonly) BOOL isEnableMicroAuthorization;

+ (void)cameraStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));
+ (void)microStateActionWithPopCompletion:(void (^)(void))completion API_AVAILABLE(ios(8.0));

+ (void)openSettingPage;
+ (void)showAlert:(TUIChatAuthControlType)type;
@end
