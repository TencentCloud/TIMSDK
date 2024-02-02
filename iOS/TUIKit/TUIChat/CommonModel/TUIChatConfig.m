//
//  TUIChatConfig.m
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatConfig.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
@implementation TUIChatConfig

- (id)init {
    self = [super init];
    if (self) {
        self.msgNeedReadReceipt = NO;
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableWelcomeCustomMessage = YES;
        self.enablePopMenuEmojiReactAction = YES;
        self.enablePopMenuReplyAction = YES;
        self.enablePopMenuReferenceAction = YES;
        self.enableMainPageInputBar = YES;
        self.enableTypingStatus = YES;
        self.enableFloatWindowForCall = YES;
        self.enableMultiDeviceForCall = NO;
        self.timeIntervalForMessageRecall = 120;
    }
    return self;
}

+ (TUIChatConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static TUIChatConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TUIChatConfig alloc] init];
    });
    return config;
}

- (NSArray<TUIFaceGroup *> *)chatContextEmojiDetailGroups {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    return [service getChatContextEmojiDetailGroups];
}

- (TUIChatEventConfig *)eventConfig {
    if (!_eventConfig) {
        _eventConfig = [[TUIChatEventConfig alloc] init];
    }
    return _eventConfig;
}

@end

@implementation TUIChatEventConfig

@end


@implementation TUIChatConfig (CustomMessageRegiser)

- (void)registerCustomMessage:(NSString *)businessID
             messageCellClassName:(NSString *)cellName
         messageCellDataClassName:(NSString *)cellDataName {
    [self registerCustomMessage:businessID
           messageCellClassName:cellName
       messageCellDataClassName:cellDataName
                      styleType:TUIChatRegisterCustomMessageStyleTypeClassic];
}

- (void)registerCustomMessage:(NSString *)businessID
              messageCellClassName:(NSString *)cellName
          messageCellDataClassName:(NSString *)cellDataName
                    styleType:(TUIChatRegisterCustomMessageStyleType)styleType {
    
    if (businessID.length <0 || cellName.length <0 ||cellDataName.length <0) {
        NSLog(@"registerCustomMessage Error, check info %s", __func__);
        return;
    }
    NSString * serviceName = @"";
    if (styleType == TUIChatRegisterCustomMessageStyleTypeClassic) {
        serviceName = TUICore_TUIChatService;
    }
    else {
        serviceName = TUICore_TUIChatService_Minimalist;
    }
    [TUICore callService:serviceName
                  method:TUICore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : businessID,
                           TMessageCell_Name : cellName,
                           TMessageCell_Data_Name : cellDataName
                         }
    ];
}


@end
