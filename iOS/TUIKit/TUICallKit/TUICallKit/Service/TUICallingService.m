//
//  TUICallingService.m
//  TUICalling
//
//  Created by noah on 2021/8/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TUICallingService.h"
#import "TUICore.h"
#import "TUILogin.h"
#import "TUIDefine.h"
#import "TUICallKit.h"
#import "TUICallingCommon.h"
#import "TUIGlobalization.h"
#import "NSDictionary+TUISafe.h"
#import "TUICallEngineHeader.h"

@interface TUICallingService () <TUIServiceProtocol, TUIExtensionProtocol>
@property(nonatomic, strong) NSMutableArray *extentions;
@end

@implementation TUICallingService

+ (void)load {
    [TUICore registerService:TUICore_TUICallingService object:[TUICallingService shareInstance]];
    [TUICore registerExtension:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall object:[TUICallingService shareInstance]];
    [TUICore registerExtension:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall object:[TUICallingService shareInstance]];
}

+ (TUICallingService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUICallingService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICallingService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.extentions = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessNotification)
                                                     name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loginSuccessNotification {
    [TUICallKit createInstance];
    [self adaptiveComponentReport];
}

- (void)startCall:(NSString *)groupID userIDs:(NSArray *)userIDs callingType:(TUICallMediaType)callingType {
    if ([[TUICallEngine createInstance] respondsToSelector:@selector(setOnlineUserOnly:)]) {
        [[TUICallEngine createInstance] performSelector:@selector(setOnlineUserOnly:) withObject:@(0)];
    }
    
    if (groupID && [groupID isKindOfClass:NSString.class]) {
        [[TUICallKit createInstance] groupCall:groupID userIdList:userIDs callMediaType:callingType];
    } else {
        [[TUICallKit createInstance] call:[userIDs firstObject] callMediaType:callingType];
    }
}

#pragma mark - TUIServiceProtocol

- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if (![TUICallingCommon checkDictionaryValid:param]) {
        return nil;
    }
    
    if ([method isEqualToString:TUICore_TUICallingService_EnableFloatWindowMethod]) {
        NSString *keyStr = TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow;
        NSNumber *enableFloatWindow = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [[TUICallKit createInstance] enableFloatWindow:[enableFloatWindow boolValue]];
    } else if ([method isEqualToString:TUICore_TUICallingService_ShowCallingViewMethod]) {
        NSArray *userIDs = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey asClass:NSArray.class];
        NSString *callMediaTypeKey = TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey;
        NSInteger callingMediaValue = (TUICallMediaType)[[param tui_objectForKey:callMediaTypeKey asClass:NSString.class] integerValue];
        TUICallMediaType callingType = TUICallMediaTypeUnknown;
        if (callingMediaValue == 0) {
            callingType = TUICallMediaTypeAudio;
        } else if (callingMediaValue == 1) {
            callingType = TUICallMediaTypeVideo;
        }
        NSString *groupID = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey asClass:NSString.class];
        
        [self startCall:groupID userIDs:userIDs callingType:callingType];
    } else if ([method isEqualToString:TUICore_TUICallingService_ReceivePushCallingMethod]) {
        NSString *keyStr = TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo;
        V2TIMSignalingInfo *signalingInfo = [param tui_objectForKey:keyStr asClass:V2TIMSignalingInfo.class];
        NSString *groupID = signalingInfo.groupID;
        
        if ([[TUICallKit createInstance] respondsToSelector:@selector(setGroupID:)]) {
            [[TUICallKit createInstance] performSelector:@selector(setGroupID:) withObject:groupID];
        }
        
        if ([[TUICallEngine createInstance] respondsToSelector:@selector(onReceiveGroupCallAPNs:)]) {
            [[TUICallEngine createInstance] performSelector:@selector(onReceiveGroupCallAPNs:) withObject:signalingInfo];
        }
    } else if ([method isEqualToString:TUICore_TUICallingService_EnableMultiDeviceAbilityMethod]) {
        NSString *keyStr = TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility;
        NSNumber *enableMultiDeviceAbility = [param tui_objectForKey:keyStr asClass:NSNumber.class];
        [[TUICallEngine createInstance] enableMultiDeviceAbility:[enableMultiDeviceAbility boolValue] succ:^{
        } fail:^(int code, NSString * _Nullable errMsg) {
        }];
    }
    
    return nil;
}

#pragma mark - TUIExtensionProtocol

- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if (!key || ![TUICallingCommon checkDictionaryValid:param]) {
        return nil;
    }
    
    NSString *call_groupID = [param tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_GroupID asClass:NSString.class];
    NSString *call_userID = [param tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_UserID asClass:NSString.class];
    if (call_groupID.length == 0 && call_userID.length == 0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] init];
    CGSize menuSize = TMoreCell_Image_Size;
    view.frame = CGRectMake(0, 0, menuSize.width, menuSize.height + TMoreCell_Title_Height);
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    [view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [titleLabel setTextColor:[UIColor grayColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, imageView.frame.size.width + 10, TMoreCell_Title_Height);
    titleLabel.center = CGPointMake(imageView.center.x, titleLabel.center.y);
    [view addSubview:titleLabel];
    
    if ([key isEqualToString:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall]) {
        titleLabel.text = TUIKitLocalizableString(TUIKitMoreVideoCall);
        imageView.image = TUICoreBundleThemeImage(@"service_more_video_call_img", @"more_video_call");
        // 群通话 view 点击事件交给 chat 处理，chat 需要先选择通话的群成员列表
        if (call_userID.length > 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectC2CVideoCall:)];
            [view addGestureRecognizer:tap];
            [self.extentions addObject:@{@"call_userID" : call_userID, @"view" : view}];
        }
    }
    else if ([key isEqualToString:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall]) {
        titleLabel.text = TUIKitLocalizableString(TUIKitMoreVoiceCall);
        imageView.image = TUICoreBundleThemeImage(@"service_more_voice_call_img", @"more_voice_call");
        if (call_userID.length > 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectC2CAudioCall:)];
            [view addGestureRecognizer:tap];
            [self.extentions addObject:@{@"call_userID" : call_userID, @"view" : view}];
        }
    }
    
    return @{TUICore_TUIChatExtension_GetMoreCellInfo_View : view};
}

- (void)onSelectC2CVideoCall:(UIGestureRecognizer *)tap {
    UIView *view = tap.view;
    for (NSDictionary *extension in self.extentions) {
        if ([extension[@"view"] isEqual:view] && extension[@"call_userID"]) {
            [self startCall:nil userIDs:@[extension[@"call_userID"]] callingType:TUICallMediaTypeVideo];
            return;
        }
    }
}

- (void)onSelectC2CAudioCall:(UIGestureRecognizer *)tap {
    UIView *view = tap.view;
    for (NSDictionary *extension in self.extentions) {
        if ([extension[@"view"] isEqual:view] && extension[@"call_userID"]) {
            [self startCall:nil userIDs:@[extension[@"call_userID"]] callingType:TUICallMediaTypeAudio];
            return;
        }
    }
}

- (void)adaptiveComponentReport {
    if (![TUICore getService:TUICore_TUIChatService]) {
        return;
    }
    
    NSDictionary *jsonDic = @{@"api": @"setFramework",
                              @"params": @{@"framework": @(1),
                                           @"component": @(15)}};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSAssert(NO, @"invalid jsonDic");
        return;
    }
    [[TUICallEngine createInstance] callExperimentalAPI:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

@end
