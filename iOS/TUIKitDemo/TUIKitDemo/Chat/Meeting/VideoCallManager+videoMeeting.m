//
//  VideoCallManager+videoMeeting.m
//  TUIKitDemo
//
//  Created by xcoderliu on 10/14/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "VideoCallManager+videoMeeting.h"
#import "AppDelegate.h"
#import "GenerateTestUserSig.h"
#import <TRTCCloud.h>
#import <CommonCrypto/CommonCrypto.h>
#import <zlib.h>

@interface VideoCallManager ()<TRTCCloudDelegate>

@end

typedef enum : NSUInteger {
    TRTC_IDLE,       // SDK 没有进入视频通话状态
    TRTC_ENTERED,    // SDK 视频通话进行中
} TRTCStatus;

@implementation VideoCallManager (videoMeeting)
- (void)_enterMeetingRoom {
    // TRTC相关参数设置
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = SDKAPPID;
    param.userId = [self currentUserIdentifier];
    param.roomId = self.currentRoomID;
    param.userSig = [GenerateTestUserSig genTestUserSig:[self currentUserIdentifier]];
    param.privateMapKey = @"";
    if (self.localVideoView) {
        [self.localVideoView removeFromSuperview];
    }
    if (self.remoteVideoView) {
        [self.remoteVideoView removeFromSuperview];
    }
    self.localVideoView = [[UIView alloc] init];
    self.remoteVideoView = [[UIView alloc] init];
    self.hungUP = [[UIButton alloc] init];
    self.localVideoView.backgroundColor = [UIColor grayColor];
    self.remoteVideoView.backgroundColor = [UIColor grayColor];
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [self.remoteVideoView setFrame:window.rootViewController.view.bounds];
    [self.localVideoView setFrame:window.rootViewController.view.bounds];
    
    [self.hungUP addTarget:self action:@selector(userQuit) forControlEvents:UIControlEventTouchUpInside];
    [self.hungUP setImage:[UIImage imageNamed:@"hungup"] forState:UIControlStateNormal];
    [self.hungUP setFrame:CGRectMake((window.rootViewController.view.bounds.size.width - 60) / 2, window.rootViewController.view.bounds.size.height - 120, 60, 60)];
    [self.hungUP.layer setCornerRadius:60 / 2];
    [self.hungUP setClipsToBounds:YES];
    [window.rootViewController.view addSubview:self.remoteVideoView];
    [window.rootViewController.view addSubview:self.localVideoView];
    [window.rootViewController.view addSubview:self.hungUP];
    [[TRTCCloud sharedInstance] setDelegate:self];
    [[TRTCCloud sharedInstance] enterRoom:param appScene:(TRTCAppSceneVideoCall)];
    [[TRTCCloud sharedInstance] startLocalPreview:YES view:self.localVideoView];
    [[TRTCCloud sharedInstance] muteLocalVideo:NO];
    [[TRTCCloud sharedInstance] startLocalAudio];
    [self setRoomStatus:TRTC_ENTERED];
}

-(void)_quitMeetingRoom {
    [self setRoomStatus:TRTC_IDLE];
    [[TRTCCloud sharedInstance] stopLocalPreview];
    [[TRTCCloud sharedInstance] exitRoom];
    if (self.localVideoView) {
        [self.localVideoView removeFromSuperview];
        self.localVideoView = nil;
    }
    if (self.remoteVideoView) {
        [self.remoteVideoView removeFromSuperview];
        self.remoteVideoView = nil;
    }
    if (self.hungUP) {
        [self.hungUP removeFromSuperview];
        self.hungUP = nil;
    }
}

#pragma mark - config

- (NSString *)hmac:(NSString *)plainText
{
    const char *cKey  = [SECRETKEY cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [HMACData base64EncodedStringWithOptions:0];
}

- (NSString *)base64URL:(NSData *)data
{
    NSString *result = [data base64EncodedStringWithOptions:0];
    NSMutableString *final = [[NSMutableString alloc] init];
    const char *cString = [result cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < result.length; ++ i) {
        char x = cString[i];
        switch(x){
            case '+':
                [final appendString:@"*"];
                break;
            case '/':
                [final appendString:@"-"];
                break;
            case '=':
                [final appendString:@"_"];
                break;
            default:
                [final appendFormat:@"%c", x];
                break;
        }
    }
    return final;
}

/**
 * 防止iOS锁屏：如果视频通话进行中，则方式iPhone进入锁屏状态
 */
- (void)setRoomStatus:(TRTCStatus)roomStatus {
    
    switch (roomStatus) {
        case TRTC_IDLE:
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        case TRTC_ENTERED:
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        default:
            break;
    }
}

#pragma mark - callback of TRTC
- (void)onEnterRoom:(NSInteger)result {
    NSLog(@"%ld",(long)result);
}
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if (available && userId != [self currentUserIdentifier])  {
        [[TRTCCloud sharedInstance] startRemoteView:userId view:self.remoteVideoView];
    }
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    if (userId != [self currentUserIdentifier]) { //对方视频
        [UIView animateWithDuration:0.6 animations:^{
            [self.localVideoView setFrame:CGRectMake(self.remoteVideoView.bounds.size.width - 100 - 18, 20, 100, 100.0 / 9.0 * 16.0)];
        }];
    }
}

- (void)onUserExit:(NSString *)userId reason:(NSInteger)reason {
    NSLog(@"%ld",(long)reason);
}

- (void)userQuit {
    [self quitRoom:NO];
}
@end
