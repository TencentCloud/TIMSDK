
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

@import ImSDK_Plus;
#import <objc/runtime.h>

#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatConfig.h"
#import "TUIChatDataProvider_Minimalist.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "UIAlertController+TUICustomStyle.h"

@interface TUIChatDataProvider_Minimalist ()

@property(nonatomic, strong) NSArray<TUICustomActionSheetItem *> *customInputMoreActionItemList;
@property(nonatomic, strong) NSArray<TUICustomActionSheetItem *> *builtInInputMoreActionItemList;

@end

@implementation TUIChatDataProvider_Minimalist

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
                                                V2TIMMessage *message = [TUIMessageDataProvider_Minimalist getCustomMessageWithJsonData:data];
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
        display = [TUIMessageDataProvider_Minimalist getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

- (NSArray<TUICustomActionSheetItem *> *)getInputMoreActionItemList:(NSString *)userID
                                                            groupID:(NSString *)groupID
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
