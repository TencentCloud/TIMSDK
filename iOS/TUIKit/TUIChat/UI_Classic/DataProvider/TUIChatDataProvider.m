
@import ImSDK_Plus;
#import <objc/runtime.h>

#import "TUIChatDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIMessageDataProvider.h"
#import <TUICore/TUICore.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatConfig.h"

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"

@interface TUIChatDataProvider ()
@property(nonatomic,strong) NSArray<TUIInputMoreCellData *> *customInputMoreMenus;
@property(nonatomic,strong) NSArray<TUIInputMoreCellData *> *builtInInputMoreMenus;
@end

@implementation TUIChatDataProvider

- (NSArray<TUIInputMoreCellData *> *)customInputMoreMenus {
    if (_customInputMoreMenus == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        if (TUIChatConfig.defaultConfig.enableWelcomeCustomMessage) {
            // Link
            __weak typeof(self) weakSelf = self;
            TUIInputMoreCellData *linkData = [[TUIInputMoreCellData alloc] init];
            linkData.priority = 100;
            linkData.title = TIMCommonLocalizableString(TUIKitMoreLink);
            linkData.image = TUIChatBundleThemeImage(@"chat_more_link_img", @"chat_more_link_img");
            linkData.onClicked = ^(NSDictionary *actionParam) {
                NSString *text = TIMCommonLocalizableString(TUIKitWelcome);
                NSString *link = TUITencentCloudHomePageEN;
                NSString *language = [TUIGlobalization tk_localizableLanguageKey];
                if ([language containsString:@"zh-"]) {
                    link =  TUITencentCloudHomePageCN;
                }
                NSError *error = nil;
                NSDictionary *param = @{BussinessID: BussinessID_TextLink, @"text":text, @"link":link};
                NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
                if(error)
                {
                    NSLog(@"[%@] Post Json Error", [weakSelf class]);
                    return;
                }
                V2TIMMessage *message = [TUIMessageDataProvider getCustomMessageWithJsonData:data];
                if ([weakSelf.delegate respondsToSelector:@selector(dataProvider:sendMessage:)]) {
                    [weakSelf.delegate dataProvider:weakSelf sendMessage:message];
                }
            };
            [arrayM addObject:linkData];
        }
        _customInputMoreMenus = arrayM;
    }
    return _customInputMoreMenus;
}

- (NSArray<TUIInputMoreCellData *> *)builtInInputMoreMenus  {
    if (_builtInInputMoreMenus == nil) {
        __weak typeof(self) weakSelf = self;
        TUIInputMoreCellData *photoData = [[TUIInputMoreCellData alloc] init];
        photoData.priority = 1000;
        photoData.title = TIMCommonLocalizableString(TUIKitMorePhoto);
        photoData.image = TUIChatBundleThemeImage(@"chat_more_picture_img", @"more_picture");
        photoData.onClicked = ^(NSDictionary *actionParam) {
            if ([weakSelf.delegate respondsToSelector:@selector(onSelectPhotoMoreCellData)]) {
                [weakSelf.delegate onSelectPhotoMoreCellData];
            }
        };
        
        TUIInputMoreCellData *pictureData = [[TUIInputMoreCellData alloc] init];
        pictureData.priority = 900;
        pictureData.title = TIMCommonLocalizableString(TUIKitMoreCamera);
        pictureData.image = TUIChatBundleThemeImage(@"chat_more_camera_img", @"more_camera");
        pictureData.onClicked = ^(NSDictionary *actionParam) {
            if ([weakSelf.delegate respondsToSelector:@selector(onTakePictureMoreCellData)]) {
                [weakSelf.delegate onTakePictureMoreCellData];
            }
        };
        
        TUIInputMoreCellData *videoData = [[TUIInputMoreCellData alloc] init];
        videoData.priority = 800;
        videoData.title = TIMCommonLocalizableString(TUIKitMoreVideo);
        videoData.image = TUIChatBundleThemeImage(@"chat_more_video_img", @"more_video");
        videoData.onClicked = ^(NSDictionary *actionParam) {
            if ([weakSelf.delegate respondsToSelector:@selector(onTakeVideoMoreCellData)]) {
                [weakSelf.delegate onTakeVideoMoreCellData];
            }
        };
        
        TUIInputMoreCellData *fileData = [[TUIInputMoreCellData alloc] init];
        fileData.priority = 700;
        fileData.title = TIMCommonLocalizableString(TUIKitMoreFile);
        fileData.image = TUIChatBundleThemeImage(@"chat_more_file_img", @"more_file");
        fileData.onClicked = ^(NSDictionary *actionParam) {
            if ([weakSelf.delegate respondsToSelector:@selector(onSelectFileMoreCellData)]) {
                [weakSelf.delegate onSelectFileMoreCellData];
            }
        };
        
        _builtInInputMoreMenus = @[photoData, pictureData, videoData, fileData];
    }
    return _builtInInputMoreMenus;
}

- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg {
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if(msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = [self.delegate dataProvider:self mergeForwardMsgAbstactForMessage:msg];
    
    if (display.length == 0) {
        display = [TUIMessageDataProvider getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

#pragma mark - CellData

- (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                  isNeedVideoCall:(BOOL)isNeedVideoCall
                                                  isNeedAudioCall:(BOOL)isNeedAudioCall
                                                  isNeedGroupLive:(BOOL)isNeedGroupLive
                                                       isNeedLink:(BOOL)isNeedLink {
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObjectsFromArray:self.builtInInputMoreMenus];
    [moreMenus addObjectsFromArray:self.customInputMoreMenus];
    
    // Extension menus
    NSMutableDictionary *extensionParam = [NSMutableDictionary dictionary];
    if (userID.length > 0) {
        extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_UserID] = userID;
    } else if (groupID.length > 0) {
        extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] = groupID;
    }
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall] = @(!isNeedVideoCall);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall] = @(!isNeedAudioCall);
    NSArray *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID param:extensionParam];
    for (TUIExtensionInfo *info in extensionList) {
        NSAssert(info.icon && info.text && info.onClicked, @"extension for input view is invalid, check icon/text/onclick");
        if (info.icon && info.text && info.onClicked) {
            TUIInputMoreCellData *data = [[TUIInputMoreCellData alloc] init];
            data.priority = info.weight;
            data.image = info.icon;
            data.title = info.text;
            data.onClicked = info.onClicked;
            [moreMenus addObject:data];
        }
    }
    
    // Sort with priority
    NSArray *sortedMenus = [moreMenus sortedArrayUsingComparator:^NSComparisonResult(TUIInputMoreCellData *obj1, TUIInputMoreCellData *obj2) {
        return obj1.priority > obj2.priority ? NSOrderedAscending : NSOrderedDescending;
    }];
    return [NSMutableArray arrayWithArray:sortedMenus];
}

@end
