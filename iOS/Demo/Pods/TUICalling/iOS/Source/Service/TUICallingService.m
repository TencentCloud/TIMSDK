//
//  TUICallingService.m
//  TUICalling
//
//  Created by noah on 2021/8/20.
//

#import "TUICallingService.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import "TUICallingManager.h"
#import "TUICommonUtil.h"
#import "TUIGlobalization.h"
#import "NSDictionary+TUISafe.h"
#import "TRTCCalling+Signal.h"

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
        [TUICallingManager shareInstance];
        self.extentions = [NSMutableArray array];
    }
    return self;
}

- (void)startCall:(NSString *)groupID userIDs:(NSArray *)userIDs callingType:(TUICallingType)callingType {
    if ([[TUICallingManager shareInstance] respondsToSelector:@selector(setGroupID:onlineUserOnly:)]) {
        [[TUICallingManager shareInstance] performSelector:@selector(setGroupID:onlineUserOnly:) withObject:groupID withObject:false];
    }
    
    [[TUICallingManager shareInstance] call:userIDs type:callingType];
}

#pragma mark - TUIServiceProtocol

- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if (![TUICommonUtil checkDictionaryValid:param]) {
        return nil;
    }
    
    if ([method isEqualToString:TUICore_TUICallingService_ShowCallingViewMethod]) {
        NSArray *userIDs = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey asClass:NSArray.class];
        TUICallingType callingType = (TUICallingType)[[param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey asClass:NSString.class] integerValue];
        NSString *groupID = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey asClass:NSString.class];
        
        [self startCall:groupID userIDs:userIDs callingType:callingType];
    } else if ([method isEqualToString:TUICore_TUICallingService_ReceivePushCallingMethod]) {
        V2TIMSignalingInfo *signalingInfo = [param tui_objectForKey:TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo asClass:V2TIMSignalingInfo.class];
        NSString *groupID = signalingInfo.groupID;
        
        if ([[TUICallingManager shareInstance] respondsToSelector:@selector(setGroupID:)]) {
            [[TUICallingManager shareInstance] performSelector:@selector(setGroupID:) withObject:groupID];
        }
        
        [[TRTCCalling shareInstance] onReceiveGroupCallAPNs:signalingInfo];
    }
    
    return nil;
}

#pragma mark - TUIExtensionProtocol
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if (!key || ![TUICommonUtil checkDictionaryValid:param]) {
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
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor grayColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, imageView.frame.size.width + 10, TMoreCell_Title_Height);
    titleLabel.center = CGPointMake(imageView.center.x, titleLabel.center.y);
    [view addSubview:titleLabel];
    
    if ([key isEqualToString:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall]) {
        titleLabel.text = TUIKitLocalizableString(TUIKitMoreVideoCall);
        imageView.image = [UIImage d_imageNamed:@"more_video_call" bundle:TUIChatBundle];
        // 群通话 view 点击事件交给 chat 处理，chat 需要先选择通话的群成员列表
        if (call_userID.length > 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectC2CVideoCall:)];
            [view addGestureRecognizer:tap];
            [self.extentions addObject:@{@"call_userID" : call_userID, @"view" : view}];
        }
    }
    else if ([key isEqualToString:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall]) {
        titleLabel.text = TUIKitLocalizableString(TUIKitMoreVoiceCall);
        imageView.image = [UIImage d_imageNamed:@"more_voice_call" bundle:TUIChatBundle];
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
            [self startCall:nil userIDs:@[extension[@"call_userID"]] callingType:TUICallingTypeVideo];
            return;
        }
    }
}

- (void)onSelectC2CAudioCall:(UIGestureRecognizer *)tap {
    UIView *view = tap.view;
    for (NSDictionary *extension in self.extentions) {
        if ([extension[@"view"] isEqual:view] && extension[@"call_userID"]) {
            [self startCall:nil userIDs:@[extension[@"call_userID"]] callingType:TUICallingTypeAudio];
            return;
        }
    }
}
@end
