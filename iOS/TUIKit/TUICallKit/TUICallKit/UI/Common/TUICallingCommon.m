//
//  TUICallingCommon.m
//  TUICalling
//
//  Created by noah on 2022/5/31.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUICallingCommon.h"
#import "TUICallEngineHeader.h"
#import "ImSDK_Plus/ImSDK_Plus.h"
#import "TUICallingUserModel.h"
#import "CallingLocalized.h"

@implementation TUICallingCommon

+ (NSBundle *)callingBundle {
    NSURL *callingKitBundleURL = [[NSBundle mainBundle] URLForResource:@"TUICallingKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:callingKitBundleURL];
}

+ (UIImage *)getBundleImageWithName:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self callingBundle] compatibleWithTraitCollection:nil];
}

+ (UIWindow *)getKeyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
    return nil;
}

+ (BOOL)checkDictionaryValid:(id)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkArrayValid:(id)data {
    if (!data || ![data isKindOfClass:[NSArray class]]) {
        return NO;
    }
    return YES;
}

+ (id)fetchModelWithIndex:(NSInteger)index dataArray:(NSArray *)dataArray {
    if (dataArray && [dataArray isKindOfClass:[NSArray class]] && dataArray.count > index) {
        return dataArray[index];
    }
    return nil;
}

+ (NSInteger)fetchIndexWithModel:(id)model dataArray:(NSArray *)dataArray {
    if ([self checkArrayValid:dataArray] && [dataArray containsObject:model]) {
        return [dataArray indexOfObject:model];
    }
    return 0;
}

+ (BOOL)checkIndexInRangeWith:(NSInteger)index dataArray:(NSArray *)dataArray {
    if (dataArray.count > 0 && (dataArray.count > index)) {
        return YES;
    }
    return NO;
}

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user {
    return [self convertUser:user volume:0 isEnter:NO];
}

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user isEnter:(BOOL)isEnter {
    return [self convertUser:user volume:0 isEnter:isEnter];
}

+ (CallingUserModel *)convertUser:(V2TIMUserFullInfo *)user volume:(NSUInteger)volume isEnter:(BOOL)isEnter {
    CallingUserModel *dstUser = [[CallingUserModel alloc] init];
    dstUser.name = user.nickName;
    dstUser.avatar = user.faceURL;
    dstUser.userId = user.userID;
    dstUser.isEnter = isEnter ? YES : NO;
    dstUser.volume = (CGFloat)volume / 100.0f;
    return dstUser;
}

+ (void)showAuthorizationAlert:(AuthorizationDeniedType)deniedType {
    NSString *title = @"";
    NSString *message = @"";
    NSString *laterMessage = @"";
    NSString *openSettingMessage = @"";
    
    switch (deniedType) {
        case AuthorizationDeniedTypeAudio: {
            title = TUICallingLocalize(@"TUICallKit.failedtogetmicrophonepermission.Title");
            message = TUICallingLocalize(@"TUICallKit.failedtogetmicrophonepermission.Tips");
            laterMessage = TUICallingLocalize(@"TUICallKit.failedtogetmicrophonepermission.Later");
            openSettingMessage = TUICallingLocalize(@"TUICallKit.failedtogetmicrophonepermission.Enable");
        } break;
        case AuthorizationDeniedTypeVideo: {
            title = TUICallingLocalize(@"TUICallKit.failedtogetcamerapermission.Title");
            message = TUICallingLocalize(@"TUICallKit.failedtogetcamerapermission.Tips");
            laterMessage = TUICallingLocalize(@"TUICallKit.failedtogetcamerapermission.Later");
            openSettingMessage = TUICallingLocalize(@"TUICallKit.failedtogetcamerapermission.Enable");
        } break;
        default:
            break;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:laterMessage style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:openSettingMessage
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([app canOpenURL:settingsURL]) {
            [app openURL:settingsURL];
        }
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

@end
