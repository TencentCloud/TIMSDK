//
//  TUIKit.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/12.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TUIKit.h"
#import "THeader.h"
#import "ImSDK.h"

@interface TUIKit () <TIMRefreshListener, TIMMessageListener, TIMMessageRevokeListener, TIMUploadProgressListener, TIMUserStatusListener, TIMConnListener>
@property (nonatomic, strong) TUIKitConfig *config;
@end

@implementation TUIKit
+ (instancetype)sharedInstance
{
    static TUIKit *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TUIKit alloc] init];
    });
    return instance;
}

- (void)initKit:(NSInteger)sdkAppId accountType:(NSString *)accountType withConfig:(TUIKitConfig *)config
{
    _config = config;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TUIKit_Image_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Image_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Video_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Video_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Voice_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Voice_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_File_Path]){
        [fileManager createDirectoryAtPath:TUIKit_File_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_DB_Path]){
        [fileManager createDirectoryAtPath:TUIKit_DB_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    TIMSdkConfig *sdkConfig = [[TIMSdkConfig alloc] init];
    sdkConfig.sdkAppId = (int)sdkAppId;
    sdkConfig.accountType = accountType;
    sdkConfig.dbPath = TUIKit_DB_Path;
    sdkConfig.connListener = self;
    [[TIMManager sharedInstance] initSdk:sdkConfig];
    
    TIMUserConfig *userConfig = [[TIMUserConfig alloc] init];
    userConfig.refreshListener = self;
    userConfig.messageRevokeListener = self;
    userConfig.uploadProgressListener = self;
    userConfig.userStatusListener = self;
    [[TIMManager sharedInstance] setUserConfig:userConfig];

    [[TIMManager sharedInstance] addMessageListener:self];
    
}


- (void)loginKit:(NSString *)identifier userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail
{
    TIMLoginParam *param = [[TIMLoginParam alloc] init];
    param.identifier = identifier;
    param.userSig = sig;
    [[TIMManager sharedInstance] login:param succ:succ fail:fail];
}

- (void)logoutKit:(TSucc)succ fail:(TFail)fail
{
    [[TIMManager sharedInstance] logout:succ fail:fail];
}

- (void)onRefreshConversations:(NSArray *)conversations
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMRefreshListener object:conversations];
}

- (void)onNewMessage:(NSArray *)msgs
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMMessageListener object:msgs];
}

- (void)onRevokeMessage:(TIMMessageLocator *)locator
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMMessageRevokeListener object:locator];
}

- (void)onUploadProgressCallback:(TIMMessage *)msg elemidx:(uint32_t)elemidx taskid:(uint32_t)taskid progress:(uint32_t)progress
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msg, @"message", [NSNumber numberWithInt:progress], @"progress", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUploadProgressListener object:dic];
}


#pragma mark - user
- (void)onForceOffline
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUserStatusListener object:[NSNumber numberWithInt:TUser_Status_ForceOffline]];
}

- (void)onReConnFailed:(int)code err:(NSString*)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUserStatusListener object:[NSNumber numberWithInt:TUser_Status_ReConnFailed]];
}

- (void)onUserSigExpired
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMUserStatusListener object:[NSNumber numberWithInt:TUser_Status_SigExpired]];
}

#pragma mark - network

- (void)onConnSucc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_Succ]];
}

- (void)onConnFailed:(int)code err:(NSString*)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_ConnFailed]];
}

- (void)onDisconnect:(int)code err:(NSString*)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_Disconnect]];
}

- (void)onConnecting
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMConnListener object:[NSNumber numberWithInt:TNet_Status_Connecting]];
}


- (NSArray *)testUser
{
    NSArray *array = [NSArray arrayWithObjects:@"angie", @"angelie", @"anita", @"ann",
                      @"bailee", @"barbara", @"barbie", @"becky",
                      @"cally", @"candy", @"canny", @"carina",
                      @"dannie", @"dennielle", @"dennise", @"doris",
                      @"elle", @"ellen", @"emi", @"emily",
                      @"fannie", @"faye", @"fiona", @"flora",
                      @"gia", @"gigi", @"gloria", @"grace",
                      @"heidi", @"helen", @"hope",
                      @"irene", @"iris", @"ivy",
                      @"jade", @"jo", @"jill",
                      @"karen", @"kiki", @"kelly",
                      @"leila", @"lily", @"linda",
                      @"olivia", @"ok",
                      @"pace", @"paris", @"penny",
                      @"qe", @"qa", @"qt",
                      @"renee", @"rita", @"ruby",
                      @"sally", @"sky", @"sara",
                      @"tina", @"tori", @"tracy",
                      @"uy", @"uo", @"uu",
                      @"vicki", @"vicky", @"vivien",
                      @"wing", @"wy", @"ww",
                      @"xx", @"xo", @"xa",
                      @"yoyo", @"you", @"yoo",
                      @"zoe", @"zero",
                      nil];
    return array;
}

- (TUIKitConfig *)getConfig
{
    return _config;
}
@end
