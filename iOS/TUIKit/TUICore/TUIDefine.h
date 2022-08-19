
#ifndef THeader_h
#define THeader_h

#import "TUIConfig.h"
#import "TUICommonModel.h"
#import "TUITool.h"
#import "TUIDarkModel.h"
#import "TUIGlobalization.h"
#import "UIView+TUILayout.h"
#import "UIView+TUIToast.h"
#import "NSDictionary+TUISafe.h"
#import "UIColor+TUIHexColor.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <SDWebImage/SDWebImage.h>
#import "TUIThemeManager.h"

@import ImSDK_Plus;

/////////////////////////////////////////////////////////////////////////////////
//
//                             自定义消息业务版本号
//                             Custom message protocol version number
//
/////////////////////////////////////////////////////////////////////////////////
#define BussinessID @"businessID"
#define BussinessID_GroupCreate @"group_create"
#define BussinessID_TextLink @"text_link"
#define BussinessID_Evaluation @"web_evaluation"
#define BussinessID_Order @"web_order"
#define BussinessID_Typing @"user_typing_status"


/**
 * 创建群自定义消息业务版本
 * The business version of "Group-creating custom message"
 */
#define GroupCreate_Version 4

/**
 * 自定义 cell 业务版本（点击跳转官网）
 * The business version of "custom cell" - click to jump to the official website
 */
#define TextLink_Version    4

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
#define APNs_Version             1

/**
 * 普通消息推送
 * General message push
 */
#define APNs_Business_NormalMsg  1

/**
 * 音视频通话推送
 * Pushing of audio and video call
 */
#define APNs_Business_Call       2

/////////////////////////////////////////////////////////////////////////////////
//
//                             设备系统相关
//                             Device & Platform
//
/////////////////////////////////////////////////////////////////////////////////
#define Screen_Width        [UIScreen mainScreen].bounds.size.width
#define Screen_Height       [UIScreen mainScreen].bounds.size.height
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_IPhoneX (Screen_Width >=375.0f && Screen_Height >=812.0f && Is_Iphone)
#define StatusBar_Height    (Is_IPhoneX ? (44.0):(20.0))
#define TabBar_Height       (Is_IPhoneX ? (49.0 + 34.0):(49.0))
#define NavBar_Height       (44)
#define SearchBar_Height    (55)
#define Bottom_SafeHeight   (Is_IPhoneX ? (34.0):(0))
#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.f]

/////////////////////////////////////////////////////////////////////////////////
//
//                             Bundle
//
/////////////////////////////////////////////////////////////////////////////////
#define TUIDemoBundle            @"TUIDemo"
#define TUICoreBundle            @"TUICore"
#define TUIChatBundle            @"TUIChat"
#define TUIChatFaceBundle        @"TUIChatFace"
#define TUIConversationBundle    @"TUIConversation"
#define TUIContactBundle         @"TUIContact"
#define TUIGroupBundle           @"TUIGroup"
#define TUISearchBundle          @"TUISearch"
#define TUIKitLocalizableBundle  @"TUIKitLocalizable"

#define TUIDemoBundle_Key_Class            @"TUIKit"
#define TUICoreBundle_Key_Class            @"TUICore"
#define TUIChatBundle_Key_Class            @"TUIChatService"
#define TUIChatFaceBundle_Key_Class        @"TUIChatService"
#define TUIConversationBundle_Key_Class    @"TUIConversationService"
#define TUIContactBundle_Key_Class         @"TUIContactService"
#define TUIGroupBundle_Key_Class           @"TUIGroupService"
#define TUISearchBundle_Key_Class          @"TUISearchService"
#define TUIKitLocalizableBundle_Key_Class  @"TUICore"

#define TUIBundlePath(bundleName, bundleKeyClass) [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"].length > 0 ? [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"] : [[NSBundle bundleForClass:NSClassFromString(bundleKeyClass)] pathForResource:bundleName ofType:@"bundle"]

#define TUICoreThemePath TUIBundlePath(@"TUICoreTheme",TUICoreBundle_Key_Class)
#define TUIChatThemePath TUIBundlePath(@"TUIChatTheme",TUIChatBundle_Key_Class)
#define TUIConversationThemePath TUIBundlePath(@"TUIConversationTheme",TUIConversationBundle_Key_Class)
#define TUIContactThemePath TUIBundlePath(@"TUIContactTheme",TUIContactBundle_Key_Class)
#define TUIGroupThemePath TUIBundlePath(@"TUIGroupTheme",TUIGroupBundle_Key_Class)
#define TUISearchThemePath TUIBundlePath(@"TUISearchTheme",TUISearchBundle_Key_Class)

#define TUIKitLocalizable(bundleName) [NSBundle bundleWithPath:TUIBundlePath(bundleName, TUIKitLocalizableBundle_Key_Class)]

#define TUIDemoImagePath(imageName) [TUIBundlePath(TUIDemoBundle,TUIDemoBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUICoreImagePath(imageName) [TUIBundlePath(TUICoreBundle,TUICoreBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatImagePath(imageName) [TUIBundlePath(TUIChatBundle,TUIChatBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIChatFaceImagePath(imageName) [TUIBundlePath(TUIChatFaceBundle,TUIChatFaceBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIConversationImagePath(imageName) [TUIBundlePath(TUIConversationBundle,TUIConversationBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIContactImagePath(imageName) [TUIBundlePath(TUIContactBundle,TUIContactBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUIGroupImagePath(imageName) [TUIBundlePath(TUIGroupBundle,TUIGroupBundle_Key_Class) stringByAppendingPathComponent:imageName]
#define TUISearchImagePath(imageName) [TUIBundlePath(TUISearchBundle,TUISearchBundle_Key_Class) stringByAppendingPathComponent:imageName]


/////////////////////////////////////////////////////////////////////////////////
//
//                             File Cache
//
/////////////////////////////////////////////////////////////////////////////////
#define TUIKit_DB_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/"]
#define TUIKit_Image_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/image/"]
#define TUIKit_Video_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/video/"]
#define TUIKit_Voice_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/voice/"]
#define TUIKit_File_Path  [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/file/"]


/////////////////////////////////////////////////////////////////////////////////
//
//                             Custom view
//
/////////////////////////////////////////////////////////////////////////////////
//input
#define TUIInputMoreCellKey_GroupLive @"TUIInputMoreCellKey_GroupLive"
#define TUIInputMoreCellKey_VideoCall @"TUIInputMoreCellKey_VideoCall"
#define TUIInputMoreCellKey_AudioCall @"TUIInputMoreCellKey_AudioCall"
#define TUIInputMoreCellKey_Link @"TUIInputMoreCellKey_Link"

//cell
#define TMessageCell_Name @"TMessageCell_Name"
#define TMessageCell_Data_Name @"TMessageCell_Data_Name"
#define TMessageCell_Head_Width 45
#define TMessageCell_Head_Height 45
#define TMessageCell_Head_Size CGSizeMake(45, 45)
#define TMessageCell_Padding 8
#define TMessageCell_Margin 8
#define TMessageCell_Indicator_Size CGSizeMake(20, 20)

//text cell
#define TTextMessageCell_ReuseId @"TTextMessageCell"
#define TTextMessageCell_Height_Min (TMessageCell_Head_Size.height + 2 * TMessageCell_Padding)
#define TTextMessageCell_Text_PADDING (160)
#define TTextMessageCell_Text_Width_Max (Screen_Width - TTextMessageCell_Text_PADDING)
#define TTextMessageCell_Margin 12

//system cell
#define TSystemMessageCell_ReuseId @"TSystemMessageCell"
#define TSystemMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TSystemMessageCell_Margin 5

//joinGroup cell
#define TJoinGroupMessageCell_ReuseId @"TJoinGroupMessageCell"
#define TJoinGroupMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TJoinGroupMessageCell_Margin 5

//image cell
#define TImageMessageCell_ReuseId @"TImageMessageCell"
#define TImageMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TImageMessageCell_Image_Height_Max TImageMessageCell_Image_Width_Max
#define TImageMessageCell_Margin_2 8
#define TImageMessageCell_Margin_1 16
#define TImageMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)

//face cell
#define TFaceMessageCell_ReuseId @"TFaceMessageCell"
#define TFaceMessageCell_Image_Width_Max (Screen_Width * 0.25)
#define TFaceMessageCell_Image_Height_Max TFaceMessageCell_Image_Width_Max
#define TFaceMessageCell_Margin 16

//file cell
#define TFileMessageCell_ReuseId @"TFileMessageCell"
#define TFileMessageCell_Container_Size CGSizeMake((Screen_Width * 0.5), (Screen_Width * 0.15))
#define TFileMessageCell_Margin 10
#define TFileMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)

//video cell
#define TVideoMessageCell_ReuseId @"TVideoMessageCell"
#define TVideoMessageCell_Image_Width_Max (Screen_Width * 0.4)
#define TVideoMessageCell_Image_Height_Max TVideoMessageCell_Image_Width_Max
#define TVideoMessageCell_Margin_3 4
#define TVideoMessageCell_Margin_2 8
#define TVideoMessageCell_Margin_1 16
#define TVideoMessageCell_Play_Size CGSizeMake(35, 35)
#define TVideoMessageCell_Progress_Color  RGBA(0, 0, 0, 0.5)

//voice cell
#define TVoiceMessageCell_ReuseId @"TVoiceMessaageCell"
#define TVoiceMessageCell_Max_Duration 60.0
#define TVoiceMessageCell_Height TMessageCell_Head_Size.height
#define TVoiceMessageCell_Margin 12
#define TVoiceMessageCell_Back_Width_Max (Screen_Width * 0.4)
#define TVoiceMessageCell_Back_Width_Min 60
#define TVoiceMessageCell_Duration_Size CGSizeMake(33, 33)

//group live cell
#define TGroupLiveMessageCell_ReuseId @"TGroupLiveMessageCell"

//repply message cell
#define TReplyMessageCell_ReuseId @"TUIReplyMessageCell"
#define TUIReferenceMessageCell_ReuseId @"TUIReferenceMessageCell"

//relay message cell
#define TRelayMessageCell_ReuserId @"TRelayMessageCell"
#define TRelayMessageCell_Text_PADDING (230)
#define TRelayMessageCell_Text_Height_Max (100)
#define TRelayMessageCell_Text_Width_Max (Screen_Width - TRelayMessageCell_Text_PADDING)

//text view
#define TTextView_Height (49)
#define TTextView_Button_Size CGSizeMake(30, 30)
#define TTextView_Margin 6
#define TTextView_TextView_Height_Min (TTextView_Height - 2 * TTextView_Margin)
#define TTextView_TextView_Height_Max 80

//face view
#define TFaceView_Height 180
#define TFaceView_Margin 12
#define TFaceView_Page_Padding 20
#define TFaceView_Page_Height 30

//menu view
#define TMenuView_Send_Color RGBA(87, 190, 105, 1.0)
#define TMenuView_Margin 6
#define TMenuView_Menu_Height 40

//more view
#define TMoreView_Column_Count 4
#define TMoreView_Section_Padding 24
#define TMoreView_Margin 20
#define TMoreView_Page_Height 30

//menu item cell
#define TMenuCell_ReuseId @"TMenuCell"
#define TMenuCell_Margin 6
#define TMenuCell_Line_ReuseId @"TMenuLineCell"
#define TMenuCell_Background_Color  RGBA(246, 246, 246, 1.0)
#define TMenuCell_Background_Color_Dark  RGBA(30, 30, 30, 1.0)
#define TMenuCell_Selected_Background_Color  RGBA(255, 255, 255, 1.0)
#define TMenuCell_Selected_Background_Color_Dark  RGBA(41, 41, 41, 1.0)

//more item cell
#define TMoreCell_ReuseId @"TMoreCell"
#define TMoreCell_Margin 5
#define TMoreCell_Image_Size CGSizeMake(65, 65)
#define TMoreCell_Title_Height 20

//face item cell
#define TFaceCell_ReuseId @"TFaceCell"

//group member cell
#define TGroupMemberCell_ReuseId @"TGroupMemberCell"
#define TGroupMemberCell_Margin 5
#define TGroupMemberCell_Head_Size CGSizeMake(50, 50)
#define TGroupMemberCell_Name_Height 20

//conversation cell
#define TConversationCell_Height 72
#define TConversationCell_Margin 12
#define TConversationCell_Margin_Text 14
#define TConversationCell_Margin_Disturb 16
#define TConversationCell_Margin_Disturb_Dot 10

//AudioCall cell
#define TUIAudioCallUserCell_ReuseId @"TUIAudioCallUserCell"

//VideoCall cell
#define TUIVideoCallUserCell_ReuseId @"TUIVideoCallUserCell"

//pop view
#define TPopView_Arrow_Size CGSizeMake(15, 10)
#define TPopView_Background_Color RGBA(188, 188, 188, 0.5)
#define TPopView_Background_Color_Dark RGBA(76, 76, 76, 0.5)

//pop cell
#define TPopCell_ReuseId @"TPopCell"
#define TPopCell_Height 45
#define TPopCell_Margin 18
#define TPopCell_Padding 12

//unRead
#define TUnReadView_Margin_TB 2
#define TUnReadView_Margin_LR 4

//message controller
#define TMessageController_Header_Height 40

//members controller
#define TGroupMembersController_Margin 20
#define TGroupMembersController_Row_Count 5

//add c2c controller
#define TAddC2CController_Margin 10

//add group controller
#define TAddGroupController_Margin 15

//add member controller
#define TAddMemberController_Margin 15

//delete member controller
#define TDeleteMemberController_Margin 15

//add cell
#define TAddCell_ReuseId @"TAddCell"
#define TAddCell_Height 55
#define TAddCell_Margin 10
#define TAddCell_Select_Size CGSizeMake(25, 25)
#define TAddCell_Head_Size CGSizeMake(38, 38)

//modify view
#define TModifyView_Background_Color RGBA(0, 0, 0, 0.5)
#define TModifyView_Background_Color_Dark RGBA(76, 76, 76, 0.5)
#define TModifyView_Confirm_Color RGBA(44, 145, 247, 1.0)

//record
#define Record_Background_Color RGBA(0, 0, 0, 0.6)
#define Record_Background_Size CGSizeMake(Screen_Width * 0.4, Screen_Width * 0.4)
#define Record_Title_Height 30
#define Record_Title_Background_Color RGBA(186, 60, 65, 1.0)
#define Record_Margin 8

//key value cell
#define TKeyValueCell_ReuseId @"TKeyValueCell"
#define TKeyValueCell_Indicator_Size CGSizeMake(15, 15)
#define TKeyValueCell_Margin 10
#define TKeyValueCell_Height 50

//button cell
#define TButtonCell_ReuseId @"TButtonCell"
#define TButtonCell_Height 56
#define TButtonCell_Margin 1

//switch cell
#define TSwitchCell_ReuseId @"TSwitchCell"
#define TSwitchCell_Height 50
#define TSwitchCell_Margin 10

//personal common cell
#define TPersonalCommonCell_Image_Size CGSizeMake(48, 48)
#define TPersonalCommonCell_Margin 20
#define TPersonalCommonCell_Indicator_Size CGSizeMake(15, 15)

//group common cell
#define TGroupCommonCell_ReuseId @"TGroupCommonCell"
#define TGroupCommonCell_Image_Size CGSizeMake(80, 80)
#define TGroupCommonCell_Margin 10
#define TGroupCommonCell_Indicator_Size CGSizeMake(15, 15)

//gropu member cell
#define TGroupMembersCell_ReuseId @"TGroupMembersCell"
#define TGroupMembersCell_Column_Count 5
#define TGroupMembersCell_Row_Count 2
#define TGroupMembersCell_Margin 10
#define TGroupMembersCell_Image_Size CGSizeMake(60, 60)

//navigationbar indicator view
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
#define TInput_Background_Color  RGBA(235, 240, 246, 1.0)
#define TInput_Background_Color_Dark  RGBA(30, 30, 30, 1.0)

// rich
#define kDefaultRichCellHeight 50
#define kDefaultRichCellMargin 8
#define kRichCellDescColor  [UIColor blackColor]
#define kRichCellValueColor [UIColor grayColor]
#define kRichCellTextFont      [UIFont systemFontOfSize:14]


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
 * 会话列表更新时收到的未读数更新通知
 * Unread update notifications received when the Conversation list is updated
 */
#define TUIKitNotification_onConversationMarkUnreadCountChanged @"TUIKitNotification_onConversationMarkUnreadCountChanged"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUICore
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - TUICore_TUIChatService
#define TUICore_TUIChatService @"TUICore_TUIChatService"

#define TUICore_TUIChatService_GetDisplayStringMethod @"TUICore_TUIChatService_GetDisplayStringMethod"
#define TUICore_TUIChatService_GetDisplayStringMethod_MsgKey @"msg"

#define TUICore_TUIChatService_GetChatViewControllerMethod @"TUICore_TUIChatService_GetChatViewControllerMethod"
#define TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey @"TUICore_TUIChatService_GetChatViewControllerMethod_TitleKey"
#define TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey @"TUICore_TUIChatService_GetChatViewControllerMethod_UserIDKey"
#define TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey @"TUICore_TUIChatService_GetChatViewControllerMethod_GroupIDKey"
#define TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey @"TUICore_TUIChatService_GetChatViewControllerMethod_ConversationIDKey"
#define TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey @"TUICore_TUIChatService_GetChatViewControllerMethod_HighlightKeywordKey"
#define TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey @"TUICore_TUIChatService_GetChatViewControllerMethod_LocateMessageKey"


#pragma mark - TUICore_TUIChatNotify
#define TUICore_TUIChatNotify @"TUICore_TUIChatNotify"


#pragma mark - TUICore_TUIChatExtension
#define TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall    @"TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall"
#define TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall    @"TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall"
#define TUICore_TUIChatExtension_GetMoreCellInfo_UserID       @"TUICore_TUIChatExtension_GetMoreCellInfo_UserID"
#define TUICore_TUIChatExtension_GetMoreCellInfo_GroupID       @"TUICore_TUIChatExtension_GetMoreCellInfo_GroupID"
#define TUICore_TUIChatExtension_GetMoreCellInfo_View       @"TUICore_TUIChatExtension_GetMoreCellInfo_View"

#pragma mark - TUICore_TUIConversationService
#define TUICore_TUIConversationService @"TUICore_TUIConversationService"
#define TUICore_TUIConversationService_GetConversationControllerMethod @"TUICore_TUIConversationService_GetConversationControllerMethod"
#define TUICore_TUIConversationService_GetConversationSelectControllerMethod @"TUICore_TUIConversationService_GetConversationSelectControllerMethod"


#pragma mark - TUICore_TUIConversationNotify
#define TUICore_TUIConversationNotify @"TUICore_TUIConversationNotify"
#define TUICore_TUIConversationNotify_SelectConversationSubKey @"TUICore_TUIConversationNotify_SelectConversationSubKey"
#define TUICore_TUIConversationNotify_SelectConversationSubKey_ConversationListKey @"TUICore_TUIConversationNotify_SelectConversationSubKey_ConversationListKey"
#define TUICore_TUIConversationNotify_SelectConversationSubKey_ItemConversationIDKey @"TUICore_TUIConversationNotify_SelectConversationSubKey_ItemConversationIDKey"
#define TUICore_TUIConversationNotify_SelectConversationSubKey_ItemGroupIDKey @"TUICore_TUIConversationNotify_SelectConversationSubKey_ItemGroupIDKey"
#define TUICore_TUIConversationNotify_SelectConversationSubKey_ItemUserIDKey @"TUICore_TUIConversationNotify_SelectConversationSubKey_ItemUserIDKey"
#define TUICore_TUIConversationNotify_SelectConversationSubKey_ItemTitleKey @"TUICore_TUIConversationNotify_SelectConversationSubKey_ItemTitleKey"

#define TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey @"TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey"

#pragma mark - TUICore_TUIConversationExtension
#define TUICore_TUIConversationExtension @"TUICore_TUIConversationExtension"
#define TUICore_TUIConversationExtension_GetSearchBar @"TUICore_TUIConversationExtension_GetSearchBar"
#define TUICore_TUIConversationExtension_ParentVC @"TUICore_TUIConversationExtension_ParentVC" //UIViewController
#define TUICore_TUIConversationExtension_SearchBar @"TUICore_TUIConversationExtension_SearchBar" // UIView

#pragma mark - TUICore_TUIContactService
#define TUICore_TUIContactService @"TUICore_TUIContactService"
#define TUICore_TUIContactService_GetContactControllerMethod @"TUICore_TUIContactService_GetContactControllerMethod"
#define TUICore_TUIContactService_GetContactSelectControllerMethod @"TUICore_TUIContactService_GetContactSelectControllerMethod"
#define TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey @"TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey"
#define TUICore_TUIContactService_GetContactSelectControllerMethod_SourceIdsKey @"TUICore_TUIContactService_GetContactSelectControllerMethod_SourceIdsKey"
#define TUICore_TUIContactService_GetContactSelectControllerMethod_DisableIdsKey @"TUICore_TUIContactService_GetContactSelectControllerMethod_DisableIdsKey"
#define TUICore_TUIContactService_GetFriendProfileControllerMethod @"TUICore_TUIContactService_GetFriendProfileControllerMethod"
#define TUICore_TUIContactService_GetFriendProfileControllerMethod_FriendProfileKey @"TUICore_TUIContactService_GetFriendProfileControllerMethod_FriendProfileKey"
#define TUICore_TUIContactService_GetUserProfileControllerMethod @"TUICore_TUIContactService_GetUserProfileControllerMethod"
#define TUICore_TUIContactService_GetUserProfileControllerMethod_UserProfileKey @"TUICore_TUIContactService_GetUserProfileControllerMethod_UserProfileKey"
#define TUICore_TUIContactService_GetUserProfileControllerMethod_PendencyDataKey @"TUICore_TUIContactService_GetUserProfileControllerMethod_PendencyDataKey"
#define TUICore_TUIContactService_GetUserProfileControllerMethod_ActionTypeKey @"TUICore_TUIContactService_GetUserProfileControllerMethod_ActionTypeKey"
#define TUICore_TUIContactService_GetUserOrFriendProfileVCMethod @"TUICore_TUIContactService_GetUserOrFriendProfileVCMethod"
#define TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_UserIDKey @"TUICore_TUIContactService_etUserOrFriendProfileVCMethod_UserIDKey"
#define TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_SuccKey @"TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_SuccKey"
#define TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_FailKey @"TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_FailKey"

#pragma mark - TUICore_TUIContactNotify
#define TUICore_TUIContactNotify @"TUICore_TUIContactNotify"
#define TUICore_TUIContactNotify_SelectedContactsSubKey @"TUICore_TUIContactNotify_SelectedContacts"
#define TUICore_TUIContactNotify_SelectedContactsSubKey_ListKey @"TUICore_TUIContactEvent_SelectedContactsSubKey_ListKey"

#pragma mark - TUICore_TUIGroupService
#define TUICore_TUIGroupService @"TUICore_TUIGroupService"
#define TUICore_TUIGroupService_GetGroupInfoControllerMethod @"TUICore_TUIGroupService_GetGroupInfoControllerMethod"
#define TUICore_TUIGroupService_GetGroupInfoControllerMethod_GroupIDKey @"TUICore_TUIGroupService_GetGroupInfoControllerMethod_GroupIDKey"
#define TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod"
#define TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod"
#define TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey"
#define TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey @"TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_optionalStyleKey"
#define TUICore_TUIGroupService_CreateGroupMethod @"TUICore_TUIGroupService_CreateGroupMethod"
#define TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey @"TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey"
#define TUICore_TUIGroupService_CreateGroupMethod_OptionKey @"TUICore_TUIGroupService_CreateGroupMethod_OptionKey"
#define TUICore_TUIGroupService_CreateGroupMethod_ContactsKey @"TUICore_TUIGroupService_CreateGroupMethod_ContactsKey"
#define TUICore_TUIGroupService_CreateGroupMethod_CompletionKey @"TUICore_TUIGroupService_CreateGroupMethod_CompletionKey"

#pragma mark - TUICore_TUIGroupNotify
#define TUICore_TUIGroupNotify @"TUICore_TUIContactNotify"
#define TUICore_TUIGroupNotify_SelectGroupMemberSubKey @"TUICore_TUIGroupNotify_SelectGroupMemberSubKey"
#define TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey @"TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey"
#define TUICore_TUIGroupNotify_CreateGroupSubKey @"TUICore_TUIGroupNotify_CreateGroupSubKey"
#define TUICore_TUIGroupNotify_CreateGroupSubKey_ConversationDataKey @"TUICore_TUIGroupNotify_CreateGroupSubKey_ConversationDataKey"

#pragma mark - TUICore_TUICallingService
#define TUICore_TUICallingService @"TUICore_TUICallingService"

#define TUICore_TUICallingService_ShowCallingViewMethod @"TUICore_TUICallingService_ShowCallingViewMethod"

#define TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey @"TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey"
#define TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey @"TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey"
#define TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey @"TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey"

#define TUICore_TUICallingService_ReceivePushCallingMethod @"TUICore_TUICallingService_ReceivePushCallingMethod"
#define TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo @"TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo"


#define TUICore_TUICallingService_EnableFloatWindowMethod @"TUICore_TUICallingService_EnableFloatWindowMethod"
#define TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow @"TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow"


#pragma mark - TUICore_TUIGiftExtension
#define TUICore_TUIGiftExtension_GetEnterBtn    @"TUICore_TUIGiftExtension_GetEnterBtn"
#define TUICore_TUIGiftExtension_GetLikeBtn    @"TUICore_TUIGiftExtension_GetLikeBtn"
#define TUICore_TUIGiftExtension_GetTUIGiftListPanel    @"TUICore_TUIGiftExtension_GetTUIGiftListPanel"
#define TUICore_TUIGiftExtension_GetTUIGiftPlayView    @"TUICore_TUIGiftExtension_GetTUIGiftPlayView"

#pragma mark - TUICore_TUIGiftService
#define TUICore_TUIGiftService @"TUICore_TUIGiftService"
#define TUICore_TUIGiftService_SendLikeMethod  @"TUICore_TUIGiftService_SendLikeMethod"

#pragma mark - TUICore_TUIBarrageExtension
#define TUICore_TUIBarrageExtension_GetEnterBtn    @"TUICore_TUIBarrageExtension_GetEnterBtn"
#define TUICore_TUIBarrageExtension_GetTUIBarrageSendView    @"TUICore_TUIBarrageExtension_GetTUIBarrageSendView"
#define TUICore_TUIBarrageExtension_TUIBarrageDisplayView   @"TUICore_TUIBarrageExtension_GetTUIBarrageDisplayView"

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


/////////////////////////////////////////////////////////////////////////////////
//
//            TUIOfflinePush
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 设置 APNs 的证书 ID
 * Set certificate IDs for APNs
 */
#define TUIOfflinePushCertificateIDForAPNS(value) - (int)push_certificateIDForAPNS {return value;}

/**
 * 设置 TPNS 的配置信息
 * Set TPNS configuration information
 */
#define TUIOfflinePushConfigForTPNS(access_id, access_key, tpn_domain) - (void)push_accessID:(int *)accessID accessKey:(NSString **)accessKey domain:(NSString **)domain\
                                                                        {\
                                                                            *accessID = access_id;\
                                                                            *accessKey = access_key;\
                                                                            *domain = tpn_domain;\
                                                                        }

#endif /* THeader_h */
