
@import ImSDK_Plus;
#import <objc/runtime.h>

#import "TUIChatDataProvider_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUICore.h"
#import "NSDictionary+TUISafe.h"
#import "TUIThemeManager.h"

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"

static NSArray *customInputBtnInfo = nil;

@implementation TUIChatDataProvider_Minimalist
+ (void)initialize
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];   
}

+ (void)onChangeLanguage
{
    customInputBtnInfo = nil;
}

+ (NSArray *)customInputBtnInfo
{
    if (customInputBtnInfo == nil) {
        customInputBtnInfo = @[@{Input_SendBtn_Key : TUIInputMoreCellKey_Link,
                                 Input_SendBtn_Title :  TUIKitLocalizableString(TUIKitMoreLink),
                                 Input_SendBtn_ImageName : @"chat_more_link_img"
                                }
        ];
    }
    return customInputBtnInfo;
}

- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg
{
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if(msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = [self.forwardDelegate dataProvider:self mergeForwardMsgAbstactForMessage:msg];
    
    if (display.length == 0) {
        display = [TUIMessageDataProvider_Minimalist getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

#pragma mark - CellData

+ (NSMutableArray<TUIInputMoreCellData_Minimalist *> *)moreMenuCellDataArray:(NSString *)groupID
                                                                      userID:(NSString *)userID
                                                             isNeedVideoCall:(BOOL)isNeedVideoCall
                                                             isNeedAudioCall:(BOOL)isNeedAudioCall
                                                             isNeedGroupLive:(BOOL)isNeedGroupLive
                                                                  isNeedLink:(BOOL)isNeedLink {
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObject:[TUIInputMoreCellData_Minimalist photoData]];
    [moreMenus addObject:[TUIInputMoreCellData_Minimalist pictureData]];
    [moreMenus addObject:[TUIInputMoreCellData_Minimalist videoData]];
    [moreMenus addObject:[TUIInputMoreCellData_Minimalist fileData]];
    
    NSDictionary *param = @{TUICore_TUIChatExtension_GetMoreCellInfo_GroupID : groupID ? groupID : @"",TUICore_TUIChatExtension_GetMoreCellInfo_UserID : userID ? userID : @""};
    if (isNeedVideoCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData_Minimalist *videoCallMenusData = [TUIInputMoreCellData_Minimalist new];
            videoCallMenusData.key = TUIInputMoreCellKey_VideoCall;
            videoCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:videoCallMenusData];
        }
    }

    if (isNeedAudioCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData_Minimalist *audioCallMenusData = [TUIInputMoreCellData_Minimalist new];
            audioCallMenusData.key = TUIInputMoreCellKey_AudioCall;
            audioCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:audioCallMenusData];
        }
    }

    if (isNeedGroupLive && groupID.length > 0) {
        TUIInputMoreCellData_Minimalist *liveMenusData = [TUIInputMoreCellData_Minimalist new];
        liveMenusData.key = TUIInputMoreCellKey_GroupLive;
        liveMenusData.title = TUIKitLocalizableString(TUIKitMoreGroupLive);
        liveMenusData.image = TUIChatBundleThemeImage(@"chat_more_group_live", @"more_group_live");
        [moreMenus addObject:liveMenusData];

    }

    for (NSDictionary *buttonInfo in [self customInputBtnInfo]) {
        NSString *key = buttonInfo[Input_SendBtn_Key];
        NSString *title = buttonInfo[Input_SendBtn_Title];
        NSString *imageName = buttonInfo[Input_SendBtn_ImageName];
        if ([key isEqualToString:TUIInputMoreCellKey_Link] && !isNeedLink) {
            break;
        }
        TUIInputMoreCellData_Minimalist *linkMenusData = [TUIInputMoreCellData_Minimalist new];
        linkMenusData.key = key;
        linkMenusData.title = title;
        linkMenusData.image = TUIChatBundleThemeImage(imageName, imageName);
        [moreMenus addObject:linkMenusData];
    }
    return moreMenus;
}

@end
