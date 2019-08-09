//
//  TUIConversationDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import "TUIConversationDataProviderService.h"
#import "TCServiceManager.h"
#import "TUIKit.h"
@import ImSDK;

@TCServiceRegister(TUIConversationDataProviderServiceProtocol, TUIConversationDataProviderService)

@implementation TUIConversationDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TUIConversationDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (int)getMessage:(TIMConversation *)conv count:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail
{
    if ([TUIKit sharedInstance].netStatus == TNet_Status_ConnFailed || [TUIKit sharedInstance].netStatus == TNet_Status_Disconnect) {
        return [conv getLocalMessage:count last:last succ:succ fail:fail];
    }
    return [conv getMessage:count last:last succ:succ fail:fail];
}

@end
