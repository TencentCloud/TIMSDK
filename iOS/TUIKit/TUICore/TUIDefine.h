
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#ifndef THeader_h
#define THeader_h

#import <SDWebImage/SDWebImage.h>
#import "NSDictionary+TUISafe.h"
#import "TUICommonModel.h"
#import "TUIConfig.h"
#import "TUIDarkModel.h"
#import "TUIGlobalization.h"
#import "TUIThemeManager.h"
#import "TUITool.h"
#import "UIColor+TUIHexColor.h"
#import "UIView+TUILayout.h"
#import "UIView+TUIToast.h"

@import ImSDK_Plus;

#define tui_weakify(object) \
    autoreleasepool {}         \
    __weak typeof(object) weak##object = object;
#define tui_strongify(object) \
    autoreleasepool {}           \
    __strong typeof(weak##object) object = weak##object;

/////////////////////////////////////////////////////////////////////////////////
//
//                             自定义消息业务版本号
//                             Custom message protocol version number
//
/////////////////////////////////////////////////////////////////////////////////
#define BussinessID @"businessID"
#define BussinessID_GroupCreate @"group_create"
#define BussinessID_TextLink @"text_link"
// Supported in 6.5 and later, created by web
#define BussinessID_Evaluation @"evaluation"
// Supported in 6.5 and later, created by web
#define BussinessID_Order @"order"
// Supported in 6.5 and later
#define BussinessID_Typing @"user_typing_status"
// Supported in 7.1 and later
#define BussinessID_GroupPoll @"group_poll"
#define BussinessID_GroupNote @"group_note"
#define BussinessID_GroupNoteTips @"group_note_tips"
#define BussinessID_GroupRoomMessage @"group_room_message"
// Supported in 7.6 and later
#define BussinessID_CustomerService @"customerServicePlugin"
#define BussinessID_Src_CustomerService @"src"
#define BussinessID_Src_CustomerService_Request @"7"
#define BussinessID_Src_CustomerService_Evaluation @"9"
#define BussinessID_Src_CustomerService_EvaluationSelected @"10"
#define BussinessID_Src_CustomerService_Typing @"12"
#define BussinessID_Src_CustomerService_Branch @"15"
#define BussinessID_Src_CustomerService_End @"19"
#define BussinessID_Src_CustomerService_Timeout @"20"
#define BussinessID_Src_CustomerService_Collection @"21"
#define BussinessID_Src_CustomerService_Card @"22"
#define BussinessID_Src_CustomerService_EvaluationRule @"23"
#define BussinessID_Src_CustomerService_EvaluationTrigger @"24"
#define GetCustomerServiceBussinessID(src) [NSString stringWithFormat:@"%@%@",BussinessID_CustomerService, src]
// Supported in 7.7 and later
#define BussinessID_ChatBot @"chatbotPlugin"
#define BussinessID_Src_ChatBot @"src"
#define BussinessID_Src_ChatBot_Stream_Text @(2)
#define BussinessID_Src_ChatBot_Request @(7)
#define BussinessID_Src_ChatBot_Welcome_Clarify_Selected @(15)
#define GetChatBotBussinessID(src) [NSString stringWithFormat:@"%@%@",BussinessID_ChatBot, src]

/**
 * 创建群自定义消息业务版本
 * The business version of "Group-creating custom message"
 */
#define GroupCreate_Version 4

/**
 * 自定义 cell 业务版本（点击跳转官网）
 * The business version of "custom cell" - click to jump to the official website
 */
#define TextLink_Version 4

/**
 * 消息回复的协议版本
 *「消息自定义字段」中的「消息回复协议」版本号
 *
 * The version of the protocol for the message reply
 * "Message Reply Protocol" version number in "Message Custom Field"
 */
#define kMessageReplyVersion 1

/**
 * 消息回复的协议版本
 *「草稿字段」中的「消息回复协议」版本号
 *
 * The version of the protocol for the message reply
 * "Message Reply Protocol" version number in "Draft Field"
 */
#define kDraftMessageReplyVersion 1

/////////////////////////////////////////////////////////////////////////////////
//
//                             推送业务版本号
//                             The version number of the push service
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 推送版本
 * The version number of the push service
 */
#define APNs_Version 1

/**
 * 普通消息推送
 * General message push
 */
#define APNs_Business_NormalMsg 1

/**
 * 音视频通话推送
 * Pushing of audio and video call
 */
#define APNs_Business_Call 2

/////////////////////////////////////////////////////////////////////////////////
//
//                             设备系统相关
//                             Device & Platform
//
/////////////////////////////////////////////////////////////////////////////////
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_IPhoneX (Screen_Width >= 375.0f && Screen_Height >= 812.0f && Is_Iphone)
#define StatusBar_Height (Is_IPhoneX ? (44.0) : (20.0))
#define TabBar_Height (Is_IPhoneX ? (49.0 + 34.0) : (49.0))
#define NavBar_Height (44)
#define SearchBar_Height (55)
#define Bottom_SafeHeight (Is_IPhoneX ? (34.0) : (0))
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:a]
#define RGB(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1.f]
#define kScale390(x) (x * (UIScreen.mainScreen.bounds.size.width / 390.0))
#define kScale375(x) (x * (UIScreen.mainScreen.bounds.size.width / 375.0))
/////////////////////////////////////////////////////////////////////////////////
//
//                             Bundle
//
/////////////////////////////////////////////////////////////////////////////////
#define TUIDemoBundle @"TUIDemo"
#define TUICoreBundle @"TUICore"
#define TUIChatBundle @"TUIChat"
#define TUIChatFaceBundle @"TUIChatFace"
#define TUIConversationBundle @"TUIConversation"
#define TUIConversationGroupBundle @"TUIConversationGroup"
#define TUIConversationMarkBundle @"TUIConversationMark"
#define TUIContactBundle @"TUIContact"
#define TUIGroupBundle @"TUIGroup"
#define TUISearchBundle @"TUISearch"
#define TUIPollBundle @"TUIPoll"
#define TUIGroupNoteBundle @"TUIGroupNote"
#define TIMCommonBundle @"TIMCommon"
#define TUITranslationBundle @"TUITranslation"
#define TUIVoiceToTextBundle @"TUIVoiceToText"
#define TUICustomerServicePluginBundle @"TUICustomerServicePlugin"
#define TUIChatBotPluginBundle @"TUIChatBotPlugin"

#define TUIKitLocalizableBundle @"TUIKitLocalizable"
#define TUICoreLocalizableBundle TUIKitLocalizableBundle
#define TUIChatLocalizableBundle @"TUIChatLocalizable"
#define TUIConversationLocalizableBundle @"TUIConversationLocalizable"
#define TUIContactLocalizableBundle @"TUIContactLocalizable"
#define TUIGroupLocalizableBundle @"TUIGroupLocalizable"
#define TUISearchLocalizableBundle @"TUISearchLocalizable"
#define TIMCommonLocalizableBundle @"TIMCommonLocalizable"

#define TUIDemoBundle_Key_Class @"TUIKit"
#define TUICoreBundle_Key_Class @"TUICore"
#define TUIChatBundle_Key_Class @"TUIChatService"
#define TUICallKitBundle_Key_Class @"TUICallingService"
#define TUIChatFaceBundle_Key_Class @"TUIChatService"
#define TUIConversationBundle_Key_Class @"TUIConversationService"
#define TUIConversationGroupBundle_Key_Class @"TUIConversationGroupService"
#define TUIConversationMarkBundle_Key_Class @"TUIConversationMarkService"
#define TUIContactBundle_Key_Class @"TUIContactService"
#define TUIGroupBundle_Key_Class @"TUIGroupService"
#define TUISearchBundle_Key_Class @"TUISearchService"
#define TUIPollBundle_Key_Class @"TUIPollService"
#define TUIGroupNoteBundle_Key_Class @"TUIGroupNoteService"
#define TIMCommonBundle_Key_Class @"TIMConfig"
#define TUITranslationBundle_Key_Class @"TUITranslationService"
#define TUIVoiceToTextBundle_Key_Class @"TUIVoiceToTextService"
#define TUIKitLocalizableBundle_Key_Class @"TUICore"
#define TUIChatLocalizableBundle_Key_Class @"TUIChatService"
#define TIMCommonLocalizableBundle_Key_Class @"TIMConfig"
#define TUICustomerServicePluginBundle_Key_Class @"TUICustomerServicePluginService"
#define TUIChatBotPluginBundle_Key_Class @"TUIChatBotPluginService"

static inline NSString *getTUIFrameWorkName(NSString *bundleKeyClass) {
    if ([bundleKeyClass isEqualToString:TUICoreBundle_Key_Class] || [bundleKeyClass isEqualToString:TUIKitLocalizableBundle_Key_Class]) {
        return @"TUICore";
    }
    if ([bundleKeyClass isEqualToString:TUIChatBundle_Key_Class] || [bundleKeyClass isEqualToString:TUIChatFaceBundle_Key_Class] ||
        [bundleKeyClass isEqualToString:TUIChatLocalizableBundle_Key_Class]) {
        return @"TUIChat";
    }
    if ([bundleKeyClass isEqualToString:TUIConversationBundle_Key_Class]) {
        return @"TUIConversation";
    }
    if ([bundleKeyClass isEqualToString:TUIConversationGroupBundle_Key_Class]) {
        return @"TUIConversationGroupPlugin";
    }
    if ([bundleKeyClass isEqualToString:TUIConversationMarkBundle_Key_Class]) {
        return @"TUIConversationMarkPlugin";
    }
    if ([bundleKeyClass isEqualToString:TUIContactBundle_Key_Class]) {
        return @"TUIContact";
    }
    if ([bundleKeyClass isEqualToString:TUIGroupBundle_Key_Class]) {
        return @"TUIGroup";
    }
    if ([bundleKeyClass isEqualToString:TUISearchBundle_Key_Class]) {
        return @"TUISearch";
    }
    if ([bundleKeyClass isEqualToString:TUIPollBundle_Key_Class]) {
        return @"TUIPullPlugin";
    }
    if ([bundleKeyClass isEqualToString:TUIGroupNoteBundle_Key_Class]) {
        return @"TUIGroupNotePlugin";
    }
    if ([bundleKeyClass isEqualToString:TIMCommonBundle_Key_Class]) {
        return @"TIMCommon";
    }
    if ([bundleKeyClass isEqualToString:TUITranslationBundle_Key_Class]) {
        return @"TUITranslationPlugin";
    }
    if ([bundleKeyClass isEqualToString:TUIVoiceToTextBundle_Key_Class]) {
        return @"TUIVoiceToTextPlugin";
    }
    if ([bundleKeyClass isEqualToString:TUICustomerServicePluginBundle_Key_Class]) {
        return @"TUICustomerServicePlugin";
    }
    if ([bundleKeyClass isEqualToString:TUIChatBotPluginBundle_Key_Class]) {
        return @"TUIChatBotPlugin";
    }
    return @"";
}

static inline NSString *getTUIGetBundlePath(NSString *bundleName, NSString *bundleKeyClass) {
    static NSMutableDictionary *bundlePathCache = nil;
    if (bundlePathCache == nil) {
        bundlePathCache = [NSMutableDictionary dictionary];
    }
    NSString *bundlePathKey = [NSString stringWithFormat:@"%@_%@", bundleName, bundleKeyClass];
    NSString *bundlePath = [bundlePathCache objectForKey:bundlePathKey];
    if (bundlePath == nil) {
        bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    }
    if (bundlePath.length == 0) {
        bundlePath = [[NSBundle bundleForClass:NSClassFromString(bundleKeyClass)] pathForResource:bundleName ofType:@"bundle"];
    }
    if (bundlePath.length == 0) {
        bundlePath = [NSBundle mainBundle].bundlePath;
        bundlePath = [bundlePath stringByAppendingPathComponent:@"Frameworks"];
        bundlePath = [bundlePath stringByAppendingPathComponent:getTUIFrameWorkName(bundleKeyClass)];
        bundlePath = [bundlePath stringByAppendingPathExtension:@"framework"];
        bundlePath = [bundlePath stringByAppendingPathComponent:bundleName];
        bundlePath = [bundlePath stringByAppendingPathExtension:@"bundle"];
    }
    if (bundlePath && bundlePathKey) {
        [bundlePathCache setObject:bundlePath forKey:bundlePathKey];
    }
    return bundlePath;
}

#define TUIBundlePath(bundleName, bundleKeyClass) getTUIGetBundlePath(bundleName, bundleKeyClass)

#define TUIDemoThemePath TUIBundlePath(@"TUIDemoTheme", TUIDemoBundle_Key_Class)
#define TUICoreThemePath TUIBundlePath(@"TUICoreTheme", TUICoreBundle_Key_Class)
#define TUIChatThemePath TUIBundlePath(@"TUIChatTheme", TUIChatBundle_Key_Class)
#define TUIConversationThemePath TUIBundlePath(@"TUIConversationTheme", TUIConversationBundle_Key_Class)
#define TUIConversationGroupTheme TUIBundlePath(@"TUIConversationGroupTheme", TUIConversationGroupBundle_Key_Class)
#define TUIContactThemePath TUIBundlePath(@"TUIContactTheme", TUIContactBundle_Key_Class)
#define TUIGroupThemePath TUIBundlePath(@"TUIGroupTheme", TUIGroupBundle_Key_Class)
#define TUISearchThemePath TUIBundlePath(@"TUISearchTheme", TUISearchBundle_Key_Class)
#define TUIPollThemePath TUIBundlePath(@"TUIPollTheme", TUIPollBundle_Key_Class)
#define TUIGroupNoteThemePath TUIBundlePath(@"TUIGroupNoteTheme", TUIGroupNoteBundle_Key_Class)
#define TIMCommonThemePath TUIBundlePath(@"TIMCommonTheme", TIMCommonBundle_Key_Class)
#define TUITranslationThemePath TUIBundlePath(@"TUITranslationTheme", TUITranslationBundle_Key_Class)
#define TUIVoiceToTextThemePath TUIBundlePath(@"TUIVoiceToTextTheme", TUIVoiceToTextBundle_Key_Class)
#define TUICallKitThemePath TUIBundlePath(@"TUICallKitTheme", TUICallKitBundle_Key_Class)
#define TUICustomerServicePluginThemePath TUIBundlePath(@"TUICustomerServicePluginTheme",TUICustomerServicePluginBundle_Key_Class)
#define TUIChatBotPluginThemePath TUIBundlePath(@"TUIChatBotPluginTheme",TUIChatBotPluginBundle_Key_Class)

static inline NSBundle *getTUIGetLocalizable(NSString *bundleName) {
    if ([bundleName isEqualToString:TUIChatLocalizableBundle] || [bundleName isEqualToString:TUIChatFaceBundle]) {
        return [NSBundle bundleWithPath:TUIBundlePath(bundleName, TUIChatLocalizableBundle_Key_Class)];
    } else if ([bundleName isEqualToString:TIMCommonLocalizableBundle]) {
        return [NSBundle bundleWithPath:TUIBundlePath(bundleName, TIMCommonLocalizableBundle_Key_Class)];
    } else {
        return [NSBundle bundleWithPath:TUIBundlePath(bundleName, TUIKitLocalizableBundle_Key_Class)];
    }
}
#define TUIKitLocalizable(bundleName) getTUIGetLocalizable(bundleName)

#define TUIDemoImagePath(imageName) [TUIBundlePath(TUIDemoBundle, TUIDemoBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUICoreImagePath(imageName) [TUIBundlePath(TUICoreBundle, TUICoreBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatImagePath(imageName) [TUIBundlePath(TUIChatBundle, TUIChatBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatFaceImagePath(imageName) [TUIBundlePath(TUIChatFaceBundle, TUIChatFaceBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIConversationImagePath(imageName) [TUIBundlePath(TUIConversationBundle, TUIConversationBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIConversationGroupImagePath(imageName) \
    [TUIBundlePath(TUIConversationGroupBundle, TUIConversationGroupBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIConversationMarkImagePath(imageName) \
    [TUIBundlePath(TUIConversationMarkBundle, TUIConversationMarkBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIContactImagePath(imageName) [TUIBundlePath(TUIContactBundle, TUIContactBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIGroupImagePath(imageName) [TUIBundlePath(TUIGroupBundle, TUIGroupBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUISearchImagePath(imageName) [TUIBundlePath(TUISearchBundle, TUISearchBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIPollImagePath(imageName) [TUIBundlePath(TUIPollBundle, TUIPollBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIGroupNoteImagePath(imageName) [TUIBundlePath(TUIGroupNoteBundle, TUIGroupNoteBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TIMCommonImagePath(imageName) [TUIBundlePath(TIMCommonBundle, TIMCommonBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUITranslationImagePath(imageName) [TUIBundlePath(TUITranslationBundle, TUITranslationBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIVoiceToTextImagePath(imageName) [TUIBundlePath(TUIVoiceToTextBundle, TUIVoiceToTextBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUICustomerServicePluginImagePath(imageName) \
    [TUIBundlePath(TUICustomerServicePluginBundle,TUICustomerServicePluginBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatBotPluginImagePath(imageName) \
    [TUIBundlePath(TUIChatBotPluginBundle,TUIChatBotPluginBundle_Key_Class) stringByAppendingPathComponent:imageName]

//-----Minimalist-------
#define TUIDemoBundle_Minimalist @"TUIDemo_Minimalist"
#define TUICoreBundle_Minimalist @"TUICore_Minimalist"
#define TUIChatBundle_Minimalist @"TUIChat_Minimalist"
#define TUIChatFaceBundle_Minimalist @"TUIChatFace_Minimalist"
#define TUIConversationBundle_Minimalist @"TUIConversation_Minimalist"
#define TUIContactBundle_Minimalist @"TUIContact_Minimalist"
#define TUIGroupBundle_Minimalist @"TUIGroup_Minimalist"
#define TUISearchBundle_Minimalist @"TUISearch_Minimalist"
#define TUIPollBundle_Minimalist @"TUIPoll_Minimalist"
#define TUIGroupNoteBundle_Minimalist @"TUIGroupNote_Minimalist"
#define TUITranslationBundle_Minimalist @"TUITranslation_Minimalist"
#define TUIVoiceToTextBundle_Minimalist @"TUIVoiceToText_Minimalist"
// #define TUIKitLocalizableBundle  @"TUIKitLocalizable"

// #define TUIKitLocalizable(bundleName) [NSBundle bundleWithPath:TUIBundlePath(bundleName, TUIKitLocalizableBundle_Key_Class)]

#define TUIDemoImagePath_Minimalist(imageName) [TUIBundlePath(TUIDemoBundle_Minimalist, TUIDemoBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUICoreImagePath_Minimalist(imageName) [TUIBundlePath(TUICoreBundle_Minimalist, TUICoreBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatImagePath_Minimalist(imageName) [TUIBundlePath(TUIChatBundle_Minimalist, TUIChatBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatFaceImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUIChatFaceBundle_Minimalist, TUIChatFaceBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIConversationImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUIConversationBundle_Minimalist, TUIConversationBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIContactImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUIContactBundle_Minimalist, TUIContactBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIGroupImagePath_Minimalist(imageName) [TUIBundlePath(TUIGroupBundle_Minimalist, TUIGroupBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUISearchImagePath_Minimalist(imageName) [TUIBundlePath(TUISearchBundle_Minimalist, TUISearchBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIPollImagePath_Minimalist(imageName) [TUIBundlePath(TUIPollBundle_Minimalist, TUIPollBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIGroupNoteImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUIGroupNoteBundle_Minimalist, TUIGroupNoteBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUITranslationImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUITranslationBundle_Minimalist, TUITranslationBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIVoiceToTextImagePath_Minimalist(imageName) \
    [TUIBundlePath(TUIVoiceToTextBundle_Minimalist, TUIVoiceToTextBundle_Key_Class) stringByAppendingPathComponent:imageName]
//-----

/////////////////////////////////////////////////////////////////////////////////
//
//                             File Cache
//
/////////////////////////////////////////////////////////////////////////////////
#define TUIKit_DB_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/"]
#define TUIKit_Image_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/image/"]
#define TUIKit_Video_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/video/"]
#define TUIKit_Voice_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/voice/"]
#define TUIKit_File_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/file/"]

/////////////////////////////////////////////////////////////////////////////////
//
//                             Custom view
//
/////////////////////////////////////////////////////////////////////////////////
// input
#define TUIInputMoreCellKey_VideoCall @"TUIInputMoreCellKey_VideoCall"
#define TUIInputMoreCellKey_AudioCall @"TUIInputMoreCellKey_AudioCall"
#define TUIInputMoreCellKey_Link @"TUIInputMoreCellKey_Link"
#define TUIInputMoreCellKey_Poll @"TUIInputMoreCellKey_Poll"
#define TUIInputMoreCellKey_GroupNote @"TUIInputMoreCellKey_GroupNote"

// cell
#define TMessageCell_Name @"TMessageCell_Name"
#define TMessageCell_Data_Name @"TMessageCell_Data_Name"
#define TMessageCell_Head_Width 45
#define TMessageCell_Head_Height 45
#define TMessageCell_Head_Size CGSizeMake(45, 45)
#define TMessageCell_Padding 8
#define TMessageCell_Margin 8
#define TMessageCell_Indicator_Size CGSizeMake(20, 20)

// text cell
#define TTextMessageCell_ReuseId @"TTextMessageCell"
#define TTextMessageCell_Height_Min (TMessageCell_Head_Size.height + 2 * TMessageCell_Padding)
#define TTextMessageCell_Text_PADDING (160)
#define TTextMessageCell_Text_Width_Max (Screen_Width - TTextMessageCell_Text_PADDING)
#define TTextMessageCell_Margin 12

// system cell
#define TSystemMessageCell_ReuseId @"TSystemMessageCell"
#define TSystemMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TSystemMessageCell_Margin 5

// joinGroup cell
#define TJoinGroupMessageCell_ReuseId @"TJoinGroupMessageCell"
#define TJoinGroupMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TJoinGroupMessageCell_Margin 5

// image cell
#define TImageMessageCell_ReuseId @"TImageMessageCell"
#define TImageMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TImageMessageCell_Image_Height_Max TImageMessageCell_Image_Width_Max
#define TImageMessageCell_Margin_2 8
#define TImageMessageCell_Margin_1 16
#define TImageMessageCell_Progress_Color RGBA(0, 0, 0, 0.5)

// face cell
#define TFaceMessageCell_ReuseId @"TFaceMessageCell"
#define TFaceMessageCell_Image_Width_Max (Screen_Width * 0.25)
#define TFaceMessageCell_Image_Height_Max TFaceMessageCell_Image_Width_Max
#define TFaceMessageCell_Margin 16

// file cell
#define TFileMessageCell_ReuseId @"TFileMessageCell"
#define TFileMessageCell_Container_Size CGSizeMake((474 * 0.5), (124 * 0.5))
#define TFileMessageCell_Margin 10
#define TFileMessageCell_Progress_Color RGBA(0, 0, 0, 0.5)

// video cell
#define TVideoMessageCell_ReuseId @"TVideoMessageCell"
#define TVideoMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TVideoMessageCell_Image_Height_Max TVideoMessageCell_Image_Width_Max
#define TVideoMessageCell_Margin_3 4
#define TVideoMessageCell_Margin_2 8
#define TVideoMessageCell_Margin_1 16
#define TVideoMessageCell_Play_Size CGSizeMake(35, 35)
#define TVideoMessageCell_Progress_Color RGBA(0, 0, 0, 0.5)

// voice cell
#define TVoiceMessageCell_ReuseId @"TVoiceMessaageCell"
#define TVoiceMessageCell_Max_Duration 60.0
#define TVoiceMessageCell_Height TMessageCell_Head_Size.height
#define TVoiceMessageCell_Margin 12
#define TVoiceMessageCell_Back_Width_Max (Screen_Width * 0.4)
#define TVoiceMessageCell_Back_Width_Min 60
#define TVoiceMessageCell_Duration_Size CGSizeMake(33, 33)

// group live cell
#define TGroupLiveMessageCell_ReuseId @"TGroupLiveMessageCell"

// repply message cell
#define TReplyMessageCell_ReuseId @"TUIReplyMessageCell"
#define TUIReferenceMessageCell_ReuseId @"TUIReferenceMessageCell"

// relay message cell
#define TRelayMessageCell_ReuserId @"TRelayMessageCell"
#define TRelayMessageCell_Text_PADDING (230)
#define TRelayMessageCell_Text_Height_Max (100)
#define TRelayMessageCell_Text_Width_Max (Screen_Width - TRelayMessageCell_Text_PADDING)

// text view
#define TTextView_Height (49)
#define TTextView_Button_Size CGSizeMake(30, 30)
#define TTextView_Margin 6
#define TTextView_TextView_Height_Min (TTextView_Height - 2 * TTextView_Margin)
#define TTextView_TextView_Height_Max 80

// face view
#define TFaceView_Height 180
#define TFaceView_Margin 12
#define TFaceView_Page_Padding 20
#define TFaceView_Page_Height 30

// menu view
#define TMenuView_Send_Color RGBA(87, 190, 105, 1.0)
#define TMenuView_Margin 6
#define TMenuView_Menu_Height 40

// more view
#define TMoreView_Column_Count 4
#define TMoreView_Section_Padding 24
#define TMoreView_Margin 20
#define TMoreView_Page_Height 30

// menu item cell
#define TMenuCell_ReuseId @"TMenuCell"
#define TMenuCell_Margin 6
#define TMenuCell_Line_ReuseId @"TMenuLineCell"
#define TMenuCell_Background_Color RGBA(246, 246, 246, 1.0)
#define TMenuCell_Background_Color_Dark RGBA(30, 30, 30, 1.0)
#define TMenuCell_Selected_Background_Color RGBA(255, 255, 255, 1.0)
#define TMenuCell_Selected_Background_Color_Dark RGBA(41, 41, 41, 1.0)

// more item cell
#define TMoreCell_ReuseId @"TMoreCell"
#define TMoreCell_Margin 5
#define TMoreCell_Image_Size CGSizeMake(65, 65)
#define TMoreCell_Title_Height 20

// face item cell
#define TFaceCell_ReuseId @"TFaceCell"

// group member cell
#define TGroupMemberCell_ReuseId @"TGroupMemberCell"
#define TGroupMemberCell_Margin 5
#define TGroupMemberCell_Head_Size CGSizeMake(50, 50)
#define TGroupMemberCell_Name_Height 20

// conversation cell
#define TConversationCell_Height 72
#define TConversationCell_Margin 12
#define TConversationCell_Margin_Text 14
#define TConversationCell_Margin_Disturb 16
#define TConversationCell_Margin_Disturb_Dot 10

#define TConversationCell_Height_LiteMode 62

// AudioCall cell
#define TUIAudioCallUserCell_ReuseId @"TUIAudioCallUserCell"

// VideoCall cell
#define TUIVideoCallUserCell_ReuseId @"TUIVideoCallUserCell"

// pop view
#define TUIPopView_Arrow_Size CGSizeMake(15, 10)
#define TUIPopView_Background_Color RGBA(188, 188, 188, 0.5)
#define TUIPopView_Background_Color_Dark RGBA(76, 76, 76, 0.5)

// pop cell
#define TUIPopCell_ReuseId @"TUIPopCell"
#define TUIPopCell_Height 45
#define TUIPopCell_Margin 18
#define TUIPopCell_Padding 12

// unRead
#define TUnReadView_Margin_TB 2
#define TUnReadView_Margin_LR 4

// message controller
#define TMessageController_Header_Height 40

// members controller
#define TGroupMembersController_Margin 20
#define TGroupMembersController_Row_Count 5

// add c2c controller
#define TAddC2CController_Margin 10

// add group controller
#define TAddGroupController_Margin 15

// add member controller
#define TAddMemberController_Margin 15

// delete member controller
#define TDeleteMemberController_Margin 15

// add cell
#define TAddCell_ReuseId @"TAddCell"
#define TAddCell_Height 55
#define TAddCell_Margin 10
#define TAddCell_Select_Size CGSizeMake(25, 25)
#define TAddCell_Head_Size CGSizeMake(38, 38)

// modify view
#define TModifyView_Background_Color RGBA(0, 0, 0, 0.5)
#define TModifyView_Background_Color_Dark RGBA(76, 76, 76, 0.5)
#define TModifyView_Confirm_Color RGBA(44, 145, 247, 1.0)

// record
#define Record_Background_Color RGBA(0, 0, 0, 0.6)
#define Record_Background_Size CGSizeMake(Screen_Width * 0.4, Screen_Width * 0.4)
#define Record_Title_Height 30
#define Record_Title_Background_Color RGBA(186, 60, 65, 1.0)
#define Record_Margin 8

// key value cell
#define TKeyValueCell_ReuseId @"TKeyValueCell"
#define TKeyValueCell_Indicator_Size CGSizeMake(15, 15)
#define TKeyValueCell_Margin 10
#define TKeyValueCell_Height 50

// button cell
#define TButtonCell_ReuseId @"TButtonCell"
#define TButtonCell_Height 56
#define TButtonCell_Margin 1

// switch cell
#define TSwitchCell_ReuseId @"TSwitchCell"
#define TSwitchCell_Height 50
#define TSwitchCell_Margin 10

// personal common cell
#define TPersonalCommonCell_Image_Size CGSizeMake(48, 48)
#define TPersonalCommonCell_Margin 20
#define TPersonalCommonCell_Indicator_Size CGSizeMake(15, 15)

// group common cell
#define TGroupCommonCell_ReuseId @"TGroupCommonCell"
#define TGroupCommonCell_Image_Size CGSizeMake(80, 80)
#define TGroupCommonCell_Margin 10
#define TGroupCommonCell_Indicator_Size CGSizeMake(15, 15)

// gropu member cell
#define TGroupMembersCell_ReuseId @"TGroupMembersCell"
#define TGroupMembersCell_Column_Count 5
#define TGroupMembersCell_Row_Count 2
#define TGroupMembersCell_Margin 10
#define TGroupMembersCell_Image_Size CGSizeMake(60, 60)

// navigationbar indicator view
#define TUINaviBarIndicatorView_Margin 5

// controller commom color
#define TController_Background_Color RGBA(255, 255, 255, 1.0)
#define TController_Background_Color_Dark RGBA(25, 25, 25, 1.0)

// title commom color
#define TText_Color [UIColor blackColor]
#define TText_Color_Dark RGB(217, 217, 217)
#define TText_OutMessage_Color_Dark RGB(0, 15, 0)

// cell commom color
#define TCell_Nomal [UIColor whiteColor]
#define TCell_Nomal_Dark RGB(35, 35, 35)
#define TCell_Touched RGB(219, 219, 219)
#define TCell_Touched_Dark RGB(47, 47, 47)
#define TCell_OnTop RGB(247, 247, 247)
#define TCell_OnTop_Dark RGB(47, 47, 47)

// line commom color
#define TLine_Color RGBA(188, 188, 188, 0.6)
#define TLine_Color_Dark RGBA(35, 35, 35, 0.6)
#define TLine_Heigh 0.5

// page commom color
#define TPage_Color RGBA(222, 222, 222, 1.0)
#define TPage_Color_Dark RGBA(55, 55, 55, 1.0)
#define TPage_Current_Color RGBA(125, 125, 125, 1.0)
#define TPage_Current_Color_Dark RGBA(140, 140, 140, 1.0)

// input view commom color
#define TInput_Background_Color RGBA(235, 240, 246, 1.0)
#define TInput_Background_Color_Dark RGBA(30, 30, 30, 1.0)

// rich
#define kDefaultRichCellHeight 50
#define kDefaultRichCellMargin 8
#define kRichCellDescColor [UIColor blackColor]
#define kRichCellValueColor [UIColor grayColor]
#define kRichCellTextFont [UIFont systemFontOfSize:14]

/////////////////////////////////////////////////////////////////////////////////
//
//                             Notification
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 消息状态变更通知
 * Notification of a change in message state
 */
#define TUIKitNotification_onMessageStatusChanged @"TUIKitNotification_onMessageStatusChanged"

/**
 * 收到套餐包不支持接口的错误通知
 * Received error notification that the package is not supported
 */
#define TUIKitNotification_onReceivedUnsupportInterfaceError @"TUIKitNotification_onReceivedUnsupportInterfaceError"

/**
 * 收到增值包不支持接口的错误通知，需要联系技术人员开启内测
 * Received error notification that the package is not supported, need contact to experience
 */
#define TUIKitNotification_onReceivedValueAddedUnsupportContactNeededError @"TUIKitNotification_onReceivedValueAddedUnsupportContactNeededError"

/**
 * 收到增值包不支持接口的错误通知，需要购买
 * Received error notification that the package is not supported, need to purchase
 */
#define TUIKitNotification_onReceivedValueAddedUnsupportPurchaseNeededError @"TUIKitNotification_onReceivedValueAddedUnsupportPurchaseNeededError"

/**
 * 会话列表更新时收到的未读数更新通知
 * Unread update notifications received when the Conversation list is updated
 */
#define TUIKitNotification_onConversationMarkUnreadCountChanged @"TUIKitNotification_onConversationMarkUnreadCountChanged"
#define TUIKitNotification_onConversationMarkUnreadCountChanged_DataProvider @"dataProvider"
#define TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadCount @"markUnreadCount"
#define TUIKitNotification_onConversationMarkUnreadCountChanged_MarkHideUnreadCount @"markHideUnreadCount"
#define TUIKitNotification_onConversationMarkUnreadCountChanged_MarkUnreadMap @"markUnreadMap"

#define TUIKitNotification_onMessageVCBottomMarginChanged @"TUIKitNotification_onMessageVCBottomMarginChanged"
#define TUIKitNotification_onMessageVCBottomMarginChanged_Margin @"bottonMargin"
/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICore
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - TUICore_TUIChat_Service
#define TUICore_TUIChatService @"TUICore_TUIChatService"
#define TUICore_TUIChatService_Minimalist @"TUICore_TUIChatService_Minimalist"

#define TUICore_TUIChatService_GetDisplayStringMethod @"TUICore_TUIChatService_GetDisplayStringMethod"
#define TUICore_TUIChatService_GetDisplayStringMethod_MsgKey @"msg"

#define TUICore_TUIChatService_SendMessageMethod @"TUICore_TUIChatService_SendMessageMethod"
#define TUICore_TUIChatService_SendMessageMethod_MsgKey @"TUICore_TUIChatService_SendMessageMethod_MsgKey"

#define TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI @"TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI"
#define TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey @"TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey"

#define TUICore_TUIChatService_SetChatExtensionMethod @"TUICore_TUIChatService_SetChatExtensionMethod"
#define TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey @"TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey"
#define TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey @"TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey"
#define TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey @"TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey"

#define TUICore_TUIChatService_AppendCustomMessageMethod @"TUICore_TUIChatService_AppendCustomMessageMethod"
#define TUICore_TUIChatService_SetMaxTextSize @"TUICore_TUIChatService_SetMaxTextSize"


#pragma mark - TUICore_TUIChat_Notify
#define TUICore_TUIChatNotify @"TUICore_TUIChatNotify"
#define TUICore_TUIChatNotify_SendMessageSubKey @"TUICore_TUIChatNotify_SendMessageSubKey"
#define TUICore_TUIChatNotify_SendMessageSubKey_Code @"TUICore_TUIChatNotify_SendMessageSubKey_Code"
#define TUICore_TUIChatNotify_SendMessageSubKey_Desc @"TUICore_TUIChatNotify_SendMessageSubKey_Desc"
#define TUICore_TUIChatNotify_SendMessageSubKey_Message @"TUICore_TUIChatNotify_SendMessageSubKey_Message"
#define TUICore_TUIChatNotify_KeyboardWillHideSubKey @"TUICore_TUIChatNotify_KeyboardWillHideSubKey"
#define TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey @"TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey"
#define TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey_UserID @"TUICore_TUIChatNotify_ChatVC_ViewDidLoadSubKey_UserID"
// 消息 cellData 被展示的通知
// The notification of displaying the message cell data
#define TUICore_TUIChatNotify_MessageDisplayedSubKey @"TUICore_TUIChatNotify_MessageDisplayedSubKey"

#pragma mark - TUICore_TUIChat_Extension
#define TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall @"TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall"
#define TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall @"TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall"
#define TUICore_TUIChatExtension_GetMoreCellInfo_UserID @"TUICore_TUIChatExtension_GetMoreCellInfo_UserID"
#define TUICore_TUIChatExtension_GetMoreCellInfo_GroupID @"TUICore_TUIChatExtension_GetMoreCellInfo_GroupID"
#define TUICore_TUIChatExtension_GetMoreCellInfo_View @"TUICore_TUIChatExtension_GetMoreCellInfo_View"

// 聊天界面 config 配置扩展
#define TUICore_TUIChatExtension_GetChatConversationModelParams @"TUICore_TUIChatExtension_GetChatConversationModelParams"
#define TUICore_TUIChatExtension_GetChatConversationModelParams_UserID @"TUICore_TUIChatExtension_GetChatConversationModelParams_UserID"
#define TUICore_TUIChatExtension_GetChatConversationModelParams_MsgNeedReadReceipt @"TUICore_TUIChatExtension_GetChatConversationModelParams_MsgNeedReadReceipt" //bool
#define TUICore_TUIChatExtension_GetChatConversationModelParams_EnableVideoCall @"TUICore_TUIChatExtension_GetChatConversationModelParams_EnableVideoCall" //bool
#define TUICore_TUIChatExtension_GetChatConversationModelParams_EnableAudioCall @"TUICore_TUIChatExtension_GetChatConversationModelParams_EnableAudioCall" //bool
#define TUICore_TUIChatExtension_GetChatConversationModelParams_EnableWelcomeCustomMessage @"TUICore_TUIChatExtension_GetChatConversationModelParams_EnableWelcomeCustomMessage" //bool

// 聊天界面消息列表点击头像的 UI 扩展
// UI extension when clicking the avatar in message list
#define TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID @"TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID"
#define TUICore_TUIChatExtension_ClickAvatar_MinimalistExtensionID @"TUICore_TUIChatExtension_ClickAvatar_MinimalistExtensionID"
#define TUICore_TUIChatExtension_ClickAvatar_UserID @"TUICore_TUIChatExtension_ClickAvatar_UserID"
#define TUICore_TUIChatExtension_ClickAvatar_GroupID @"TUICore_TUIChatExtension_ClickAvatar_GroupID"
#define TUICore_TUIChatExtension_ClickAvatar_PushVC @"TUICore_TUIChatExtension_ClickAvatar_PushVC"

// 聊天页面导航栏右侧的 "更多" UI 扩展
// UI extension on the right side of navigation bar in chat page
#define TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID @"TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID"
#define TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID @"TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID"
#define TUICore_TUIChatExtension_NavigationMoreItem_UserID @"TUICore_TUIChatExtension_NavigationMoreItem_UserID"
#define TUICore_TUIChatExtension_NavigationMoreItem_GroupID @"TUICore_TUIChatExtension_NavigationMoreItem_GroupID"
#define TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall @"TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall"
#define TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall @"TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall"
#define TUICore_TUIChatExtension_NavigationMoreItem_ItemSize @"TUICore_TUIChatExtension_NavigationMoreItem_ItemSize"
#define TUICore_TUIChatExtension_NavigationMoreItem_ItemImage @"TUICore_TUIChatExtension_NavigationMoreItem_ItemImage"
#define TUICore_TUIChatExtension_NavigationMoreItem_PushVC @"TUICore_TUIChatExtension_NavigationMoreItem_PushVC"

// 聊天页面底部输入区域 “更多” UI 扩展
// UI extension for the input area at the bottom of the chat page
#define TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID @"TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID"
#define TUICore_TUIChatExtension_InputViewMoreItem_MinimalistExtensionID @"TUICore_TUIChatExtension_InputViewMoreItem_MinimalistExtensionID"
#define TUICore_TUIChatExtension_InputViewMoreItem_UserID @"TUICore_TUIChatExtension_InputViewMoreItem_UserID"
#define TUICore_TUIChatExtension_InputViewMoreItem_GroupID @"TUICore_TUIChatExtension_InputViewMoreItem_GroupID"
#define TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall @"TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall"
#define TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall @"TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall"
#define TUICore_TUIChatExtension_InputViewMoreItem_FilterRoom @"TUICore_TUIChatExtension_InputViewMoreItem_FilterRoom"
#define TUICore_TUIChatExtension_InputViewMoreItem_ItemSize @"TUICore_TUIChatExtension_InputViewMoreItem_ItemSize"
#define TUICore_TUIChatExtension_InputViewMoreItem_ItemImage @"TUICore_TUIChatExtension_InputViewMoreItem_ItemImage"
#define TUICore_TUIChatExtension_InputViewMoreItem_ItemTitle @"TUICore_TUIChatExtension_InputViewMoreItem_ItemTitle"
#define TUICore_TUIChatExtension_InputViewMoreItem_PushVC @"TUICore_TUIChatExtension_InputViewMoreItem_PushVC"
#define TUICore_TUIChatExtension_InputViewMoreItem_VC @"TUICore_TUIChatExtension_InputViewMoreItem_VC"
#define TUICore_TUIChatExtension_InputViewMoreItem_ActionVC @"TUICore_TUIChatExtension_InputViewMoreItem_ActionVC"

// 聊天页面消息长按弹框UI 扩展
// Chat page message long press pop-up UI extension.
#define TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID @"TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID"
#define TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID @"TUICore_TUIChatExtension_PopMenuActionItem_MinimalistExtensionID"
#define TUICore_TUIChatExtension_PopMenuActionItem_TargetVC @"TUICore_TUIChatExtension_PopMenuActionItem_TargetVC"
#define TUICore_TUIChatExtension_PopMenuActionItem_ClickCell @"TUICore_TUIChatExtension_PopMenuActionItem_ClickCell"
// Chat message cell bottom container UI extension.
#define TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID @"TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID"
#define TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID @"TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID"
#define TUICore_TUIChatExtension_BottomContainer_CellData @"TUICore_TUIChatExtension_BottomContainer_CellData"
#define TUICore_TUIChatExtension_BottomContainer_VC @"TUICore_TUIChatExtension_BottomContainer_VC"
// Chat page UI extension below chatVC
#define TUICore_TUIChatExtension_ChatVCBottomContainer_ClassicExtensionID @"TUICore_TUIChatExtension_ChatVCBottomContainer_ClassicExtensionID"
#define TUICore_TUIChatExtension_ChatVCBottomContainer_VC @"TUICore_TUIChatExtension_ChatVCBottomContainer_VC"
#define TUICore_TUIChatExtension_ChatVCBottomContainer_UserID @"TUICore_TUIChatExtension_ChatVCBottomContainer_UserID"

#pragma mark - TUICore_TUIChat_ObjectFactory
#define TUICore_TUIChatObjectFactory @"TUICore_TUIChatObjectFactory"
#define TUICore_TUIChatObjectFactory_Minimalist @"TUICore_TUIChatObjectFactory_Minimalist"

#pragma mark - TUICore_TUIChat_ObjectFactory_Route
#define TUICore_TUIChatObjectFactory_ChatViewController_Classic @"TUICore_TUIChatObjectFactory_ChatViewController_Classic"
#define TUICore_TUIChatObjectFactory_ChatViewController_Minimalist @"TUICore_TUIChatObjectFactory_ChatViewController_Minimalist"
#define TUICore_TUIChatObjectFactory_ChatViewController_Title @"TUICore_TUIChatObjectFactory_ChatViewController_Title"
#define TUICore_TUIChatObjectFactory_ChatViewController_UserID @"TUICore_TUIChatObjectFactory_ChatViewController_UserID"
#define TUICore_TUIChatObjectFactory_ChatViewController_GroupID @"TUICore_TUIChatObjectFactory_ChatViewController_GroupID"
#define TUICore_TUIChatObjectFactory_ChatViewController_ConversationID @"TUICore_TUIChatObjectFactory_ChatViewController_ConversationID"
#define TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage @"TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage"
#define TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl @"TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl"
#define TUICore_TUIChatObjectFactory_ChatViewController_HighlightKeyword @"TUICore_TUIChatObjectFactory_ChatViewController_HighlightKeyword"
#define TUICore_TUIChatObjectFactory_ChatViewController_LocateMessage @"TUICore_TUIChatObjectFactory_ChatViewController_LocateMessage"
#define TUICore_TUIChatObjectFactory_ChatViewController_AtTipsStr @"TUICore_TUIChatObjectFactory_ChatViewController_AtTipsStr"
#define TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs @"TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs"
#define TUICore_TUIChatObjectFactory_ChatViewController_Draft @"TUICore_TUIChatObjectFactory_ChatViewController_Draft"
#define TUICore_TUIChatObjectFactory_ChatViewController_Enable_Video_Call @"TUICore_TUIChatObjectFactory_ChatViewController_Enable_Video_Call"
#define TUICore_TUIChatObjectFactory_ChatViewController_Enable_Audio_Call @"TUICore_TUIChatObjectFactory_ChatViewController_Enable_Audio_Call"
#define TUICore_TUIChatObjectFactory_ChatViewController_Enable_Room @"TUICore_TUIChatObjectFactory_ChatViewController_Enable_Room"
#define TUICore_TUIChatObjectFactory_ChatViewController_Limit_Portrait_Orientation @"TUICore_TUIChatObjectFactory_ChatViewController_Limit_Portrait_Orientation"

#pragma mark - TUICore_TUIConversation_Service
#define TUICore_TUIConversationService @"TUICore_TUIConversationService"
#define TUICore_TUIConversationService_Minimalist @"TUICore_TUIConversationService_Minimalist"

#pragma mark - TUICore_TUIConversation_Notify
#define TUICore_TUIConversationNotify @"TUICore_TUIConversationNotify"
#define TUICore_TUIConversationNotify_RemoveConversationSubKey @"TUICore_TUIConversationNotify_RemoveConversationSubKey"
#define TUICore_TUIConversationNotify_RemoveConversationSubKey_ConversationID @"TUICore_TUIConversationNotify_RemoveConversationSubKey_ConversationID"
#define TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey @"TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey"

#pragma mark - TUICore_TUIConversation_Extension
// 会话列表页面的 banner 扩展
// UI extension for the banner in the conversation list page
#define TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID @"TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationListBanner_MinimalistExtensionID \
    @"TUICore_TUIConversationExtension_ConversationListBanner_MinimalistExtensionID"
#define TUICore_TUIConversationExtension_ConversationListBanner_BannerSize @"TUICore_TUIConversationExtension_ConversationListBanner_BannerSize"
#define TUICore_TUIConversationExtension_ConversationListBanner_ModalVC @"TUICore_TUIConversationExtension_ConversationListBanner_ModalVC"

#pragma mark - TUICore_TUIConversation_ObjectFactory
#define TUICore_TUIConversationObjectFactory @"TUICore_TUIConversationObjectFactory"
#define TUICore_TUIConversationObjectFactory_Minimalist @"TUICore_TUIConversationObjectFactory_Minimalist"

#define TUICore_TUIConversationObjectFactory_GetConversationControllerMethod @"TUICore_TUIConversationObjectFactory_GetConversationControllerMethod"

#pragma mark - TUICore_TUIConversation_ObjectFactory_Route
// Route to conversation select page
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_Classic @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_Classic"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_Minimalist @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_Minimalist"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_ConversationID \
    @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_ConversationID"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_Title @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_Title"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_UserID \
    @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_UserID"
#define TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_GroupID \
    @"TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_GroupID"

// 会话分组列表 banner 扩展
// UI extension for the banner in the conversation group list
#define TUICore_TUIConversationExtension_ConversationGroupListBanner_ClassicExtensionID \
    @"TUICore_TUIConversationExtension_ConversationGroupListBanner_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationGroupListBanner_GroupItemKey @"TUICore_TUIConversationExtension_ConversationGroupListBanner_GroupItemKey"
// 会话分组管理按钮扩展
// UI extension for the conversation group manager
#define TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ClassicExtensionID \
    @"TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ParentVCKey \
    @"TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ParentVCKey"
// 会话列表界面扩展
// UI extension for the conversation list
#define TUICore_TUIConversationExtension_ConversationListContainer_ClassicExtensionID \
    @"TUICore_TUIConversationExtension_ConversationListContainer_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationListContainer_GroupNameKey @"TUICore_TUIConversationExtension_ConversationListContainer_GroupNameKey"
// 会话 cell 右上角区域扩展
// UI extension for the conversation cell upper right corner
#define TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_ClassicExtensionID \
    @"TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_GroupListKey \
    @"TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_GroupListKey"
#define TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_MarkListKey \
    @"TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_MarkListKey"

// 会话 cell 左滑点击"更多"后的 action 扩展
// UI extension for click more
#define TUICore_TUIConversationExtension_ConversationCellMoreAction_ClassicExtensionID \
    @"TUICore_TUIConversationExtension_ConversationCellMoreAction_ClassicExtensionID"
#define TUICore_TUIConversationExtension_ConversationCellAction_ConversationIDKey @"TUICore_TUIConversationExtension_ConversationCellAction_ConversationIDKey"
#define TUICore_TUIConversationExtension_ConversationCellAction_MarkListKey @"TUICore_TUIConversationExtension_ConversationCellAction_MarkListKey"
#define TUICore_TUIConversationExtension_ConversationCellAction_GroupListKey @"TUICore_TUIConversationExtension_ConversationCellAction_GroupListKey"

#pragma mark - TUICore_TUIConversationGroupNotify
#define TUICore_TUIConversationGroupNotify @"TUICore_TUIConversationGroupNotify"
#define TUICore_TUIConversationGroupNotify_GroupListReloadKey @"TUICore_TUIConversationGroupNotify_GroupListReloadKey"
#define TUICore_TUIConversationGroupNotify_GroupAddKey @"TUICore_TUIConversationGroupNotify_GroupAddKey"
#define TUICore_TUIConversationGroupNotify_GroupUpdateKey @"TUICore_TUIConversationGroupNotify_GroupUpdateKey"
#define TUICore_TUIConversationGroupNotify_GroupRenameKey @"TUICore_TUIConversationGroupNotify_GroupRenameKey"
#define TUICore_TUIConversationGroupNotify_GroupDeleteKey @"TUICore_TUIConversationGroupNotify_GroupDeleteKey"

#pragma mark - UICore_TUIConversationGroupExtension
#define TUICore_TUIConversationGroupExtension_ConversationGroupListSort_ClassicExtensionID \
    @"TUICore_TUIConversationGroupExtension_ConversationGroupListSort_ClassicExtensionID"
#define TUICore_TUIConversationGroupExtension_ConversationGroupListSort_GroupItemKey \
    @"TUICore_TUIConversationGroupExtension_ConversationGroupListSort_GroupItemKey"

#pragma mark - TUICore_TUIConversationMarkNotify
#define TUICore_TUIConversationMarkNotify @"TUICore_TUIConversationMarkNotify"
#define TUICore_TUIConversationGroupNotify_MarkAddKey @"TUICore_TUIConversationGroupNotify_MarkAddKey"
#define TUICore_TUIConversationGroupNotify_MarkUpdateKey @"TUICore_TUIConversationGroupNotify_MarkUpdateKey"

#pragma mark - TUICore_TUIContact_Service
#define TUICore_TUIContactService @"TUICore_TUIContactService"
#define TUICore_TUIContactService_Minimalist @"TUICore_TUIContactService_Minimalist"

#pragma mark - TUICore_TUIContact_Notify
#define TUICore_TUIContactNotify @"TUICore_TUIContactNotify"

#define TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey @"TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey"
#define TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID \
    @"TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID"

#pragma mark - TUICore_TUIContact_Extension
// 好友资料页面的响应菜单扩展
// UI extension for the action menus in the friend profile page
#define TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID @"TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID @"TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_UserID @"TUICore_TUIContactExtension_FriendProfileActionMenu_UserID"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_UserIcon @"TUICore_TUIContactExtension_FriendProfileActionMenu_UserIcon"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_UserName @"TUICore_TUIContactExtension_FriendProfileActionMenu_UserName"

#define TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall @"TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall @"TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall"
#define TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC @"TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC"

// "我" 个人设置页的设置项扩展
// UI extension for the settings in the "Me" profile page
#define TUICore_TUIContactExtension_MeSettingMenu_ClassicExtensionID @"TUICore_TUIContactExtension_MeSettingMenu_ClassicExtensionID"
#define TUICore_TUIContactExtension_MeSettingMenu_MinimalistExtensionID @"TUICore_TUIContactExtension_MeSettingMenu_MinimalistExtensionID"
#define TUICore_TUIContactExtension_MeSettingMenu_Nav @"TUICore_TUIContactExtension_MeSettingMenu_Nav"
#define TUICore_TUIContactExtension_MeSettingMenu_Data @"TUICore_TUIContactExtension_MeSettingMenu_Data"
#define TUICore_TUIContactExtension_MeSettingMenu_View @"TUICore_TUIContactExtension_MeSettingMenu_View"
#define TUICore_TUIContactExtension_MeSettingMenu_Weight @"TUICore_TUIContactExtension_MeSettingMenu_Weight"

// "通讯录" 界面的联系人群组类型扩展
// UI extension for group type in the "Contact" page
#define TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID @"TUICore_TUIContactExtension_ContactMenu_ClassicExtensionID"
#define TUICore_TUIContactExtension_ContactMenu_MinimalistExtensionID @"TUICore_TUIContactExtension_ContactMenu_MinimalistExtensionID"
#define TUICore_TUIContactExtension_ContactMenu_Nav @"TUICore_TUIContactExtension_ContactMenu_Nav"

#pragma mark - TUICore_TUIContact_ObjectFactory
#define TUICore_TUIContactObjectFactory @"TUICore_TUIContactObjectFactory"
#define TUICore_TUIContactObjectFactory_Minimalist @"TUICore_TUIContactObjectFactory_Minimalist"

#define TUICore_TUIContactObjectFactory_GetContactControllerMethod @"TUICore_TUIContactObjectFactory_GetContactControllerMethod"

#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount \
    @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_SourceIdsKey \
    @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_SourceIdsKey"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey \
    @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey \
    @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey"
#define TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey \
    @"TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey"

#define TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod @"TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod"
#define TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod_FriendProfileKey \
    @"TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod_FriendProfileKey"

#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod"
#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_TitleKey @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_TitleKey"
#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupNameKey \
    @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupNameKey"
#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupTypeKey \
    @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupTypeKey"
#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey \
    @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey"
#define TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_CompletionKey \
    @"TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_CompletionKey"

#define TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod @"TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod"
#define TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey @"TUICore_TUIContactService_etUserOrFriendProfileVCMethod_UserIDKey"
#define TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey @"TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey"
#define TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey @"TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey"

#pragma mark - TUICore_TUIContact_ObjectFactory_Route
// 路由到用户个人资料页面
// Route to user profile page
#define TUICore_TUIContactObjectFactory_UserProfileController_Classic @"TUICore_TUIContactObjectFactory_UserProfileController_Classic"
#define TUICore_TUIContactObjectFactory_UserProfileController_Minimalist @"TUICore_TUIContactObjectFactory_UserProfileController_Minimalist"
#define TUICore_TUIContactObjectFactory_UserProfileController_UserProfile @"TUICore_TUIContactObjectFactory_UserProfileController_UserProfile"
#define TUICore_TUIContactObjectFactory_UserProfileController_PendencyData @"TUICore_TUIContactObjectFactory_UserProfileController_PendencyData"
#define TUICore_TUIContactObjectFactory_UserProfileController_ActionType @"TUICore_TUIContactObjectFactory_UserProfileController_ActionType"

#pragma mark - TUICore_TUIGroup_Service
#define TUICore_TUIGroupService @"TUICore_TUIGroupService"
#define TUICore_TUIGroupService_Minimalist @"TUICore_TUIGroupService_Minimalist"

#define TUICore_TUIGroupService_CreateGroupMethod @"TUICore_TUIGroupService_CreateGroupMethod"
#define TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey @"TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey"
#define TUICore_TUIGroupService_CreateGroupMethod_OptionKey @"TUICore_TUIGroupService_CreateGroupMethod_OptionKey"
#define TUICore_TUIGroupService_CreateGroupMethod_ContactsKey @"TUICore_TUIGroupService_CreateGroupMethod_ContactsKey"
#define TUICore_TUIGroupService_CreateGroupMethod_CompletionKey @"TUICore_TUIGroupService_CreateGroupMethod_CompletionKey"

#pragma mark - TUICore_TUIGroup_Notify
#define TUICore_TUIGroupNotify @"TUICore_TUIContactNotify"

#define TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey @"TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey"
#define TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID \
    @"TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID"

#pragma mark - TUICore_TUIGroup_Extension
// 群资料页面的响应菜单扩展
// UI extension for the action menus in the group infomation page
#define TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID @"TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID"
#define TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID @"TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID"
#define TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterVideoCall @"TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterVideoCall"
#define TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterAudioCall @"TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterAudioCall"
#define TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC @"TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC"

#pragma mark - TUICore_TUIGroup_ObjectFactory
#define TUICore_TUIGroupObjectFactory @"TUICore_TUIGroupObjectFactory"
#define TUICore_TUIGroupObjectFactory_Minimalist @"TUICore_TUIGroupObjectFactory_Minimalist"

#define TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod @"TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod"
#define TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod_GroupInfoKey \
    @"TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod_GroupInfoKey"

#pragma mark - TUICore_TUIGroup_ObjectFactory_Route
// 路由到群成员选择页面，提供 TUIRoute 的跳转方式
// Route to the page for selecting group member
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic @"TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Minimalist @"TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Minimalist"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_OptionalStyle @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_optionalStyleKey"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_SelectedUserIDList \
    @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_SelectedUserIDListKey"
#define TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList @"TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList"

// 路由到群信息页面，提供 TUIRoute 的跳转方式
// Route to group info page
#define TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Classic @"TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Classic"
#define TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist @"TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist"
#define TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID @"TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID"

#pragma mark - TUICore_TUICallKit_TUICallingService
#define TUICore_TUICallingService @"TUICore_TUICallingService"

#define TUICore_TUICallingService_ShowCallingViewMethod @"TUICore_TUICallingService_ShowCallingViewMethod"

#define TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey @"TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey"
#define TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey @"TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey"
#define TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey @"TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey"

#define TUICore_TUICallingService_ReceivePushCallingMethod @"TUICore_TUICallingService_ReceivePushCallingMethod"
#define TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo @"TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo"

#define TUICore_TUICallingService_EnableMultiDeviceAbilityMethod @"TUICore_TUICallingService_EnableMultiDeviceAbilityMethod"
#define TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility \
    @"TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility"

#define TUICore_TUICallingService_EnableFloatWindowMethod @"TUICore_TUICallingService_EnableFloatWindowMethod"
#define TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow @"TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow"

#define TUICore_TUICallingService_SetAudioPlaybackDeviceMethod @"TUICore_TUICallingService_SetAudioPlaybackDeviceMethod"
#define TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice @"TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice"
#define TUICore_TUICallingService_SetIsMicMuteMethod @"TUICore_TUICallingService_SetIsMicMuteMethod"
#define TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute @"TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute"

#pragma mark - TUICore_TUICallKit_TUIAudioMessageRecordService
#define TUICore_TUIAudioMessageRecordService @"TUIAudioMessageRecordService"
#define TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod @"TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod"
#define TUICore_TUIAudioMessageRecordService_StopRecordAudioMessageMethod @"TUICore_TUIAudioMessageRecordService_StopRecordAudioMessageMethod"

#define TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey @"sdkappid"
#define TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SignatureKey @"signature"
#define TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey @"path"

#pragma mark - TUICore_TUICallKit_TUICallingNotify
#define TUICore_RecordAudioMessageNotify @"TUICore_RecordAudioMessageNotify"
#define TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey @"TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey"
#define TUICore_RecordAudioMessageNotify_StopRecordAudioMessageSubKey @"TUICore_RecordAudioMessageNotify_StopRecordAudioMessageSubKey"

#define TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey @"TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey"
#define TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey_VolumeKey @"volume"

#pragma mark - TUICore_TUICallKit_TUICallingObjectFactory
#define TUICore_TUICallingObjectFactory @"TUICore_TUICallingObjectFactory"

// Get the view controler for displaying call history
#define TUICore_TUICallingObjectFactory_RecordCallsVC @"TUICore_TUICallingObjectFactory_RecordCallsVC"
#define TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle @"TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle"
#define TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic @"TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic"
#define TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Minimalist @"TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Minimalist"

#pragma mark - TUICore_TUIPlugin_Notify
#define TUICore_TUIPluginNotify @"TUICore_TUIPluginNotify"
#define TUICore_TUIPluginNotify_PluginCustomCellClick @"TUICore_TUIPluginNotify_PluginCustomCellClick"
#define TUICore_TUIPluginNotify_PluginCustomCellClick_PushVC @"TUICore_TUIPluginNotify_PluginCustomCellClick_PushVC"
#define TUICore_TUIPluginNotify_PluginCustomCellClick_Cell @"TUICore_TUIPluginNotify_PluginCustomCellClick_Cell"

#define TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey @"TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey"
#define TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message @"TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message"

#define TUICore_TUIPluginNotify_PluginViewDidAddToSuperview @"TUICore_TUIPluginNotify_PluginViewDidAddToSuperview"
#define TUICore_TUIPluginNotify_PluginViewDidAddToSuperviewSubKey_PluginViewHeight @"TUICore_TUIPluginNotify_PluginViewDidAddToSuperviewSubKey_PluginViewHeight"

#define TUICore_TUIPluginNotify_DidChangePluginViewSubKey @"TUICore_TUIPluginNotify_DidChangePluginViewSubKey"
#define TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data @"TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data"
#define TUICore_TUIPluginNotify_DidChangePluginViewSubKey_VC @"TUICore_TUIPluginNotify_DidChangePluginViewSubKey_VC"

#define TUICore_TUIPluginNotify_WillForwardTextSubKey @"TUICore_TUIPluginNotify_WillForwardTextSubKey"
#define TUICore_TUIPluginNotify_WillForwardTextSubKey_Text @"TUICore_TUIPluginNotify_WillForwardTextSubKey_Text"

// 初始化录制成功,录制成功
#define TUICore_RecordAudioMessageNotifyError_None 0
// 参数为空
#define TUICore_RecordAudioMessageNotifyError_InvalidParam -1001
// 录音被拒绝,当前在通话中
#define TUICore_RecordAudioMessageNotifyError_StatusInCall -1002
// 录音被拒绝,当前录音未结束
#define TUICore_RecordAudioMessageNotifyError_StatusIsAudioRecording -1003
// 录音被拒绝,获取麦克风权限失败
#define TUICore_RecordAudioMessageNotifyError_MicPermissionRefused -1004
// 录音被拒绝,获取音频焦点失败
#define TUICore_RecordAudioMessageNotifyError_RequestAudioFocusFailed -1005

// -1, 初始化录制失败(onLocalRecordBegin)
#define TUICore_RecordAudioMessageNotifyError_RecordInitFailed -2001
// -2, 文件后缀名有误(onLocalRecordBegin)
#define TUICore_RecordAudioMessageNotifyError_PathFormatNotSupport -2002
// -1, 录制失败
#define TUICore_RecordAudioMessageNotifyError_RecordFailed -2003
// -3, 音频数据或者视频数据一直没有到达导致没有开始正式录制
#define TUICore_RecordAudioMessageNotifyError_NoMessageToRecord -2004

// -4, 签名错误(onLocalRecordBegin)
#define TUICore_RecordAudioMessageNotifyError_SignatureError -3001
// -5, 签名过期(onLocalRecordBegin)
#define TUICore_RecordAudioMessageNotifyError_SignatureExpired -3002

// 打开麦克风失败，例如在 Windows 或 Mac 设备，麦克风的配置程序（驱动程序）异常，禁用后重新启用设备，或者重启机器，或者更新配置程序
#define TUICore_RecordAudioMessageNotifyError_MicStartFail -1302
// 麦克风设备未授权，通常在移动设备出现，可能是权限被用户拒绝了
#define TUICore_RecordAudioMessageNotifyError_MicNotAuthorized -1317
// 麦克风设置参数失败
#define TUICore_RecordAudioMessageNotifyError_MicSetParamFail -1318
// 麦克风正在被占用中，例如移动设备正在通话时，打开麦克风会失败
#define TUICore_RecordAudioMessageNotifyError_MicOccupy -1319

#pragma mark - TUICore_TUIGiftExtension
#define TUICore_TUIGiftExtension_GetEnterBtn @"TUICore_TUIGiftExtension_GetEnterBtn"
#define TUICore_TUIGiftExtension_GetLikeBtn @"TUICore_TUIGiftExtension_GetLikeBtn"
#define TUICore_TUIGiftExtension_GetTUIGiftListPanel @"TUICore_TUIGiftExtension_GetTUIGiftListPanel"
#define TUICore_TUIGiftExtension_GetTUIGiftPlayView @"TUICore_TUIGiftExtension_GetTUIGiftPlayView"

#pragma mark - TUICore_TUIGiftService
#define TUICore_TUIGiftService @"TUICore_TUIGiftService"
#define TUICore_TUIGiftService_SendLikeMethod @"TUICore_TUIGiftService_SendLikeMethod"

#pragma mark - TUICore_TUIBarrageExtension
#define TUICore_TUIBarrageExtension_GetEnterBtn @"TUICore_TUIBarrageExtension_GetEnterBtn"
#define TUICore_TUIBarrageExtension_GetTUIBarrageSendView @"TUICore_TUIBarrageExtension_GetTUIBarrageSendView"
#define TUICore_TUIBarrageExtension_TUIBarrageDisplayView @"TUICore_TUIBarrageExtension_GetTUIBarrageDisplayView"

#pragma mark - TUICore_TUIBeautyExtension
#define TUICore_TUIBeautyExtension_BeautyView @"TUICore_TUIBeautyExtension_BeautyView"
#define TUICore_TUIBeautyExtension_Extension @"TUICore_TUIBeautyExtension_Extension"

#define TUICore_TUIBeautyExtension_BeautyView_View @"TUICore_TUIBeautyExtension_BeautyView_View"
#define TUICore_TUIBeautyExtension_Extension_View @"TUICore_TUIBeautyExtension_Extension_View"

#define TUICore_TUIBeautyExtension_BeautyView_BeautyManager @"TUICore_TUIBeautyExtension_BeautyView_BeautyManager"
#define TUICore_TUIBeautyExtension_BeautyView_LicenseUrl @"TUICore_TUIBeautyExtension_BeautyView_LicenseUrl"
#define TUICore_TUIBeautyExtension_BeautyView_LicenseKey @"TUICore_TUIBeautyExtension_BeautyView_LicenseKey"
#define TUICore_TUIBeautyExtension_BeautyView_DataProcessDelegate @"TUICore_TUIBeautyExtension_BeautyView_DataProcessDelegate"

#pragma mark - TUICore_TUIBeautyService
#define TUICore_TUIBeautyService @"TUICore_TUIBeautyService"
#define TUICore_TUIBeautyService_SetLicense @"TUICore_TUIBeautyService_SetLicense"
#define TUICore_TUIBeautyService_ProcessVideoFrame @"TUICore_TUIBeautyService_ProcessVideoFrame"
#define TUICore_TUIBeautyService_ProcessVideoFrame_SRCTextureIdKey @"TUICore_TUIBeautyService_ProcessVideoFrame_SRCTextureIdKey"
#define TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameWidthKey @"TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameWidthKey"
#define TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameHeightKey @"TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameHeightKey"

#pragma mark - TUICore_TUIAudioEffectViewExtension
#define TUICore_TUIAudioEffectViewExtension_AudioEffectView @"TUICore_TUIAudioEffectViewExtension_AudioEffectView"
#define TUICore_TUIAudioEffectViewExtension_Extension @"TUICore_TUIAudioEffectViewExtension_Extension"

#define TUICore_TUIAudioEffectViewExtension_AudioEffectView_View @"TUICore_TUIAudioEffectViewExtension_AudioEffectView_View"
#define TUICore_TUIAudioEffectViewExtension_Extension_View @"TUICore_TUIAudioEffectViewExtension_Extension_View"

#define TUICore_TUIAudioEffectViewExtension_AudioEffectView_AudioEffectManager @"TUICore_TUIAudioEffectViewExtension_AudioEffectView_AudioEffectManager"

#pragma mark - TUICore_NetworkConnection_EVENT
#define TUICore_NetworkConnection_EVENT_CONNECTION_STATE_CHANGED @"eventConnectionStateChanged"
#define TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECTING @"eventSubKeyConnecting"
#define TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECT_SUCCESS @"eventSubKeyConnectSuccess"
#define TUICore_NetworkConnection_EVENT_SUB_KEY_CONNECT_FAILED @"eventSubKeyConnectFailed"

#pragma mark - TUICore_TUIRoomImAccessService
#define TUICore_TUIRoomImAccessService @"TUICore_TUIRoomImAccessService"
#define TUICore_TUIRoomImAccessService_EnableFloatWindowMethod @"TUICore_TUIRoomImAccessService_EnableFloatWindowMethod"
#define TUICore_TUIRoomImAccessService_EnableFloatWindowMethod_EnableFloatWindow @"TUICore_TUIRoomImAccessService_EnableFloatWindowMethod_EnableFloatWindow"

#pragma mark - TUICore_TUIRoomImAccessFactory
#define TUICore_TUIRoomImAccessFactory @"TUICore_TUIRoomImAccessFactory"
#define TUICore_TUIRoomImAccessFactory_GetRoomMessageViewMethod @"TUICore_TUIRoomImAccessFactory_GetRoomMessageViewMethod"
#define TUICore_TUIRoomImAccessFactory_GetRoomMessageViewMethod_Message @"TUICore_TUIRoomImAccessFactory_GetRoomMessageViewMethod_Message"

#pragma mark - TUICore_PrivacyService_ScreenShareAntifraudReminderService
#define TUICore_PrivacyService @"TUICore_PrivacyService"
#define TUICore_PrivacyService_ScreenShareAntifraudReminderMethod @"TUICore_PrivacyService_ScreenShareAntifraudReminderMethod"
#define TUICore_PrivacyService_EnableScreenShareAntifraudReminderMethod_Cancel -1
#define TUICore_PrivacyService_EnableScreenShareAntifraudReminderMethod_Continue 0

#define TUICore_PrivacyService_CallKitAntifraudReminderMethod @"TUICore_PrivacyService_CallKitAntifraudReminderMethod"

#pragma mark - TUICore_TUICallKitVoIPExtension_Notify
#define TUICore_TUICallKitVoIPExtensionNotify @"TUICore_TUICallKitVoIPExtension_Notify"
#define TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey @"TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey"
#define TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey @"TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey"

/////////////////////////////////////////////////////////////////////////////////
//
//            TUIOfflinePush
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 设置 VoIP 的证书 ID
 * Set certificate IDs for VoIP
 */
#define TUIOfflinePushCertificateIDForVoIP(value) \
    -(int)push_certificateIDForVoIP {             \
        return value;                             \
    }

/**
 * 设置 APNs 的证书 ID
 * Set certificate IDs for APNs
 */
#define TUIOfflinePushCertificateIDForAPNS(value) \
    -(int)push_certificateIDForAPNS {             \
        return value;                             \
    }

/**
 * 设置 TPNS 的配置信息
 * Set TPNS configuration information
 */
#define TUIOfflinePushConfigForTPNS(access_id, access_key, tpn_domain)                                       \
    -(void)push_accessID : (int *)accessID accessKey : (NSString **)accessKey domain : (NSString **)domain { \
        *accessID = access_id;                                                                               \
        *accessKey = access_key;                                                                             \
        *domain = tpn_domain;                                                                                \
    }

#endif /* THeader_h */

