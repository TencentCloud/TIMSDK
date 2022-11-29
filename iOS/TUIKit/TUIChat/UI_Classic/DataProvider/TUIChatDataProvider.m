
@import ImSDK_Plus;
#import <objc/runtime.h>

#import "TUIChatDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUICore.h"
#import "NSDictionary+TUISafe.h"
#import "TUIThemeManager.h"

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"

static NSArray *customInputBtnInfo = nil;

@implementation TUIChatDataProvider
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
        display = [TUIMessageDataProvider getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

#pragma mark - CellData

+ (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                  isNeedVideoCall:(BOOL)isNeedVideoCall
                                                  isNeedAudioCall:(BOOL)isNeedAudioCall
                                                  isNeedGroupLive:(BOOL)isNeedGroupLive
                                                       isNeedLink:(BOOL)isNeedLink {
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObject:[TUIInputMoreCellData photoData]];
    [moreMenus addObject:[TUIInputMoreCellData pictureData]];
    [moreMenus addObject:[TUIInputMoreCellData videoData]];
    [moreMenus addObject:[TUIInputMoreCellData fileData]];
    
    NSDictionary *param = @{TUICore_TUIChatExtension_GetMoreCellInfo_GroupID : groupID ? groupID : @"",TUICore_TUIChatExtension_GetMoreCellInfo_UserID : userID ? userID : @""};
    if (isNeedVideoCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData *videoCallMenusData = [TUIInputMoreCellData new];
            videoCallMenusData.key = TUIInputMoreCellKey_VideoCall;
            videoCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:videoCallMenusData];
        }
    }

    if (isNeedAudioCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData *audioCallMenusData = [TUIInputMoreCellData new];
            audioCallMenusData.key = TUIInputMoreCellKey_AudioCall;
            audioCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:audioCallMenusData];
        }
    }

    if (isNeedGroupLive && groupID.length > 0) {
        TUIInputMoreCellData *liveMenusData = [TUIInputMoreCellData new];
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
        TUIInputMoreCellData *linkMenusData = [TUIInputMoreCellData new];
        linkMenusData.key = key;
        linkMenusData.title = title;
        linkMenusData.image = TUIChatBundleThemeImage(imageName, imageName);
        [moreMenus addObject:linkMenusData];
    }
    return moreMenus;
}

@end
