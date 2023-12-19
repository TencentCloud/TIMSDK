
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

@import ImSDK_Plus;
#import <objc/runtime.h>

#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "UIAlertController+TUICustomStyle.h"
#import "TUIChatConfig.h"
#import "TUIChatDataProvider.h"
#import "TUIMessageDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIChatConversationModel.h"

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"

@interface TUIChatDataProvider ()
@property(nonatomic, strong) TUIInputMoreCellData *welcomeInputMoreMenu;

@property(nonatomic, strong) NSMutableArray<TUIInputMoreCellData *> *customInputMoreMenus;
@property(nonatomic, strong) NSArray<TUIInputMoreCellData *> *builtInInputMoreMenus;

@property(nonatomic, strong) NSArray<TUICustomActionSheetItem *> *customInputMoreActionItemList;
@property(nonatomic, strong) NSArray<TUICustomActionSheetItem *> *builtInInputMoreActionItemList;
@end

@implementation TUIChatDataProvider

- (instancetype)init {
    if (self = [super init]) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
    }
    return self;
}

- (void)onChangeLanguage {
    self.customInputMoreActionItemList = nil;
    self.builtInInputMoreActionItemList = nil;
}

- (TUIInputMoreCellData *)welcomeInputMoreMenu {
    if (!_welcomeInputMoreMenu) {
        __weak typeof(self) weakSelf = self;
        _welcomeInputMoreMenu = [[TUIInputMoreCellData alloc] init];
        _welcomeInputMoreMenu.priority = 0;
        _welcomeInputMoreMenu.title = TIMCommonLocalizableString(TUIKitMoreLink);
        _welcomeInputMoreMenu.image = TUIChatBundleThemeImage(@"chat_more_link_img", @"chat_more_link_img");
        _welcomeInputMoreMenu.onClicked = ^(NSDictionary *actionParam) {
          NSString *text = TIMCommonLocalizableString(TUIKitWelcome);
          NSString *link = TUITencentCloudHomePageEN;
          NSString *language = [TUIGlobalization tk_localizableLanguageKey];
          if ([language containsString:@"zh-"]) {
              link = TUITencentCloudHomePageCN;
          }
          NSError *error = nil;
          NSDictionary *param = @{BussinessID : BussinessID_TextLink, @"text" : text, @"link" : link};
          NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
          if (error) {
              NSLog(@"[%@] Post Json Error", [weakSelf class]);
              return;
          }
          V2TIMMessage *message = [TUIMessageDataProvider getCustomMessageWithJsonData:data desc:text extension:text];
          if ([weakSelf.delegate respondsToSelector:@selector(dataProvider:sendMessage:)]) {
              [weakSelf.delegate dataProvider:weakSelf sendMessage:message];
          }
        };
    }
    return _welcomeInputMoreMenu;
}

- (NSMutableArray<TUIInputMoreCellData *> *)customInputMoreMenus {
    if (!_customInputMoreMenus) {
        _customInputMoreMenus = [NSMutableArray array];
    }
    return _customInputMoreMenus;
}

- (NSArray<TUIInputMoreCellData *> *)builtInInputMoreMenus {
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

        _builtInInputMoreMenus = @[ photoData, pictureData, videoData, fileData ];
    }
    return _builtInInputMoreMenus;
}

- (NSArray<TUICustomActionSheetItem *> *)customInputMoreActionItemList {
    if (_customInputMoreActionItemList == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        if (TUIChatConfig.defaultConfig.enableWelcomeCustomMessage) {
            __weak typeof(self) weakSelf = self;
            TUICustomActionSheetItem *link =
                [[TUICustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreLink)
                                                       leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_custom")]
                                              withActionHandler:^(UIAlertAction *_Nonnull action) {
                                                link.priority = 100;
                                                NSString *text = TIMCommonLocalizableString(TUIKitWelcome);
                                                NSString *link = TUITencentCloudHomePageEN;
                                                NSString *language = [TUIGlobalization tk_localizableLanguageKey];
                                                if ([language containsString:@"zh-"]) {
                                                    link = TUITencentCloudHomePageCN;
                                                }
                                                NSError *error = nil;
                                                NSDictionary *param = @{BussinessID : BussinessID_TextLink, @"text" : text, @"link" : link};
                                                NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
                                                if (error) {
                                                    NSLog(@"[%@] Post Json Error", [self class]);
                                                    return;
                                                }
                                                   V2TIMMessage *message = [TUIMessageDataProvider getCustomMessageWithJsonData:data desc:text extension:text];
                                                if ([weakSelf.delegate respondsToSelector:@selector(dataProvider:sendMessage:)]) {
                                                    [weakSelf.delegate dataProvider:weakSelf sendMessage:message];
                                                }
                                              }];
            [arrayM addObject:link];
        }
        _customInputMoreActionItemList = [NSArray arrayWithArray:arrayM];
    }
    return _customInputMoreActionItemList;
}

- (NSArray<TUICustomActionSheetItem *> *)builtInInputMoreActionItemList {
    if (_builtInInputMoreActionItemList == nil) {
        __weak typeof(self) weakSelf = self;
        TUICustomActionSheetItem *photo =
            [[TUICustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMorePhoto)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_photo")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSelectPhotoMoreCellData)]) {
                                                [weakSelf.delegate onSelectPhotoMoreCellData];
                                            }
                                          }];
        photo.priority = 1000;

        TUICustomActionSheetItem *camera =
            [[TUICustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreCamera)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_camera")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onTakePictureMoreCellData)]) {
                                                [weakSelf.delegate onTakePictureMoreCellData];
                                            }
                                          }];
        camera.priority = 900;

        TUICustomActionSheetItem *video =
            [[TUICustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreVideo)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_video")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onTakeVideoMoreCellData)]) {
                                                [weakSelf.delegate onTakeVideoMoreCellData];
                                            }
                                          }];
        video.priority = 800;

        TUICustomActionSheetItem *file =
            [[TUICustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreFile)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_document")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSelectFileMoreCellData)]) {
                                                [weakSelf.delegate onSelectFileMoreCellData];
                                            }
                                          }];
        file.priority = 700;
        _builtInInputMoreActionItemList = @[ photo, camera, video, file ];
    }
    return _builtInInputMoreActionItemList;
}


- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg {
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if (msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = [self.delegate dataProvider:self mergeForwardMsgAbstactForMessage:msg];

    if (display.length == 0) {
        display = [TUIMessageDataProvider getDisplayString:msg];
    }
    NSString * splitStr = @":";
    splitStr = @"\u202C:";
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@"%@", splitStr];
        desc = [desc stringByAppendingFormat:@"%@", display];
    }
    return desc;
}

#pragma mark - CellData

- (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                         conversationModel:(TUIChatConversationModel *)conversationModel
                                                 actionController:(id<TIMInputViewMoreActionProtocol>)actionController {
    
    BOOL isNeedVideoCall = [TUIChatConfig defaultConfig].enableVideoCall && conversationModel.enableVideoCall;
    BOOL isNeedAudioCall = [TUIChatConfig defaultConfig].enableAudioCall && conversationModel.enableAudioCall;
    BOOL isNeedWelcomeCustomMessage = [TUIChatConfig defaultConfig].enableWelcomeCustomMessage && conversationModel.enableWelcomeCustomMessage;
    BOOL isNeedRoom = conversationModel.enabelRoom;
    
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObjectsFromArray:self.builtInInputMoreMenus];
    
    if (isNeedWelcomeCustomMessage) {
        if (![self.customInputMoreMenus containsObject:self.welcomeInputMoreMenu]) {
            [self.customInputMoreMenus addObject:self.welcomeInputMoreMenu];
        }
    }
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
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterRoom]  = @(!isNeedRoom);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_ActionVC] = actionController;
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

- (NSArray<TUICustomActionSheetItem *> *)getInputMoreActionItemList:(NSString *)userID
                                                            groupID:(NSString *)groupID
                                                  conversationModel:(TUIChatConversationModel *)conversationModel
                                                             pushVC:(UINavigationController *)pushVC
                                                   actionController:(id<TIMInputViewMoreActionProtocol>)actionController {
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:self.builtInInputMoreActionItemList];
    [result addObjectsFromArray:self.customInputMoreActionItemList];

    // Extension items
    NSMutableArray<TUICustomActionSheetItem *> *items = [NSMutableArray array];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (userID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_UserID] = userID;
    } else if (groupID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] = groupID;
    }
    param[TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall] = @(!TUIChatConfig.defaultConfig.enableVideoCall);
    param[TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall] = @(!TUIChatConfig.defaultConfig.enableAudioCall);
    if (pushVC) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_PushVC] = pushVC;
    }
    param[TUICore_TUIChatExtension_InputViewMoreItem_ActionVC] = actionController;
    NSArray *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_InputViewMoreItem_MinimalistExtensionID param:param];
    for (TUIExtensionInfo *info in extensionList) {
        if (info.icon && info.text && info.onClicked) {
            TUICustomActionSheetItem *item = [[TUICustomActionSheetItem alloc] initWithTitle:info.text
                                                                                    leftMark:info.icon
                                                                           withActionHandler:^(UIAlertAction *_Nonnull action) {
                                                                             info.onClicked(param);
                                                                           }];
            item.priority = info.weight;
            [items addObject:item];
        }
    }
    if (items.count > 0) {
        [result addObjectsFromArray:items];
    }

    // Sort with priority
    NSArray *sorted = [result sortedArrayUsingComparator:^NSComparisonResult(TUICustomActionSheetItem *obj1, TUICustomActionSheetItem *obj2) {
      return obj1.priority > obj2.priority ? NSOrderedAscending : NSOrderedDescending;
    }];
    return sorted;
}

@end
