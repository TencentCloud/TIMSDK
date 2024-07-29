//
//  TUIVoiceToTextExtensionObserver.m
//  TUIVoiceToText
//
//  Created by xia on 2023/8/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceToTextExtensionObserver.h"

#import <TIMCommon/TIMPopActionProtocol.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TUIChat/TUIVoiceMessageCell.h>
#import <TUIChat/TUIVoiceMessageCell_Minimalist.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import "TUIVoiceToTextConfig.h"
#import "TUIVoiceToTextDataProvider.h"
#import "TUIVoiceToTextView.h"

@interface TUIVoiceToTextExtensionObserver () <TUIExtensionProtocol>

@property(nonatomic, weak) UINavigationController *navVC;
@property(nonatomic, weak) TUICommonTextCellData *cellData;

@end

@implementation TUIVoiceToTextExtensionObserver

static id gShareInstance = nil;

+ (void)load {
    TUIRegisterThemeResourcePath(TUIVoiceToTextThemePath, TUIThemeModuleVoiceToText);

    // UI extensions in pop menu when message is long pressed.
    [TUICore registerExtension:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID object:TUIVoiceToTextExtensionObserver.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID object:TUIVoiceToTextExtensionObserver.shareInstance];
    
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [TUICore registerExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID object:self];
        [TUICore registerExtension:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID object:self];
    }
    return self;
}

#pragma mark - TUIExtensionProtocol
- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID] ||
        [extensionID isEqualToString:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID]) {
        NSObject *data = [param objectForKey:TUICore_TUIChatExtension_BottomContainer_CellData];
        if (![parentView isKindOfClass:UIView.class] || ![data isKindOfClass:TUIMessageCellData.class]) {
            return NO;
        }

        TUIMessageCellData *cellData = (TUIMessageCellData *)data;
        if (cellData.innerMessage.elemType != V2TIM_ELEM_TYPE_SOUND ||
            cellData.innerMessage.status != V2TIM_MSG_STATUS_SEND_SUCC) {
            return NO;
        }

        NSMutableDictionary *cacheMap = parentView.tui_extValueObj;
        TUIVoiceToTextView *cacheView = nil;
        if (!cacheMap){
            cacheMap = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        else if ([cacheMap isKindOfClass:NSDictionary.class]) {
            cacheView = [cacheMap objectForKey:@"TUIVoiceToTextView"];
        }
        else {
            //cacheMap is not a dic ;
        }
        if (cacheView) {
            [cacheView removeFromSuperview];
            cacheView = nil;
        }
        TUIVoiceToTextView *view = [[TUIVoiceToTextView alloc] initWithData:cellData];
        [parentView addSubview:view];

        [cacheMap setObject:view forKey:@"TUIVoiceToTextView"];
        parentView.tui_extValueObj  = cacheMap;
        return YES;
    }
    return NO;
}

- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }

    if ([extensionID isEqualToString:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID]) {
        // Extension entrance in pop menu when message is long pressed.
        if (![param isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        TUIMessageCell *cell = param[TUICore_TUIChatExtension_PopMenuActionItem_ClickCell];
        if (([extensionID isEqualToString:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID] &&
            ![cell isKindOfClass:TUIVoiceMessageCell.class])) {
            return nil;
        }
        if (cell.messageData.innerMessage.elemType != V2TIM_ELEM_TYPE_SOUND ||
            cell.messageData.innerMessage.status != V2TIM_MSG_STATUS_SEND_SUCC) {
            return nil;
        }
        if ([TUIVoiceToTextDataProvider shouldShowConvertedText:cell.messageData.innerMessage]) {
            return nil;
        }

        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.weight = 2000;
        info.text = TIMCommonLocalizableString(TUIKitConvertToText);
        if ([extensionID isEqualToString:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID]) {
            info.icon = TUIChatBundleThemeImage(@"chat_icon_convert_voice_to_text_img", @"icon_convert_voice_to_text");
        }
        info.onClicked = ^(NSDictionary *_Nonnull action) {
            TUIMessageCellData *cellData = cell.messageData;
            V2TIMMessage *message = cellData.innerMessage;
            if (message.elemType != V2TIM_ELEM_TYPE_SOUND) {
                return;
            }
            [TUIVoiceToTextDataProvider convertMessage:cellData
                                            completion:^(NSInteger code, NSString * _Nonnull desc,
                                                         TUIMessageCellData * _Nonnull data, NSInteger status,
                                                         NSString * _Nonnull text) {
                if (code != 0 || (text.length == 0 && status == TUIVoiceToTextViewStatusHidden)) {
                    [TUITool makeToast:TIMCommonLocalizableString(TUIKitConvertToTextFailed)];
                }
                NSDictionary *param = @{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : cellData};
                [TUICore notifyEvent:TUICore_TUIPluginNotify
                              subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                              object:nil
                               param:param];
            }];
        };
        return @[ info ];
    }
    
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID]) {
        // Extension entrance in pop menu when message is long pressed.
        if (![param isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        TUIMessageCell *cell = param[TUICore_TUIChatExtension_PopMenuActionItem_ClickCell];
        if (([extensionID isEqualToString:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID] &&
            ![cell isKindOfClass:TUIVoiceMessageCell.class])) {
            return nil;
        }
        if (cell.messageData.innerMessage.elemType != V2TIM_ELEM_TYPE_SOUND ||
            cell.messageData.innerMessage.status != V2TIM_MSG_STATUS_SEND_SUCC) {
            return nil;
        }
        if ([TUIVoiceToTextDataProvider shouldShowConvertedText:cell.messageData.innerMessage]) {
            return nil;
        }

        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.weight = 2000;
        info.text = TIMCommonLocalizableString(TUIKitConvertToText);
        info.icon = TUIChatBundleThemeImage(@"chat_icon_convert_voice_to_text_img", @"icon_convert_voice_to_text");

        info.onClicked = ^(NSDictionary *_Nonnull action) {
            TUIMessageCellData *cellData = cell.messageData;
            V2TIMMessage *message = cellData.innerMessage;
            if (message.elemType != V2TIM_ELEM_TYPE_SOUND) {
                return;
            }
            [TUIVoiceToTextDataProvider convertMessage:cellData
                                            completion:^(NSInteger code, NSString * _Nonnull desc,
                                                         TUIMessageCellData * _Nonnull data, NSInteger status,
                                                         NSString * _Nonnull text) {
                if (code != 0 || (text.length == 0 && status == TUIVoiceToTextViewStatusHidden)) {
                    [TUITool makeToast:TIMCommonLocalizableString(TUIKitConvertToTextFailed)];
                }
                NSDictionary *param = @{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : cellData};
                [TUICore notifyEvent:TUICore_TUIPluginNotify
                              subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                              object:nil
                               param:param];
            }];
        };
        return @[ info ];
    }
    return nil;
}

@end
