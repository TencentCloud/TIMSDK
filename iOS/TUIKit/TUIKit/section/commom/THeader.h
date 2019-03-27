//
//  THeader.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#ifndef THeader_h
#define THeader_h



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


//cell
#define TMessageCell_Head_Size CGSizeMake(45, 45)
#define TMessageCell_Padding 8
#define TMessageCell_Margin 8
#define TMessageCell_Indicator_Size CGSizeMake(20, 20)

//text cell
#define TTextMessageCell_ReuseId @"TTextMessageCell"
#define TTextMessageCell_Height_Min (TMessageCell_Head_Size.height + 2 * TMessageCell_Padding)
#define TTextMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TTextMessageCell_Margin 12

//system cell
#define TSystemMessageCell_ReuseId @"TSystemMessageCell"
#define TSystemMessageCell_Background_Color RGBA(215, 215, 215, 1.0)
#define TSystemMessageCell_Text_Width_Max (Screen_Width * 0.5)
#define TSystemMessageCell_Margin 5

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
#define TVoiceMessageCell_Duration_Size CGSizeMake(30, 30)

//text view
#define TTextView_Height (49)
#define TTextView_Button_Size CGSizeMake(30, 30)
#define TTextView_Margin 6
#define TTextView_TextView_Height_Min (TTextView_Height - 2 * TTextView_Margin)
#define TTextView_TextView_Height_Max 80
#define TTextView_Line_Height 0.5
#define TTextView_Line_Color RGBA(188, 188, 188, 0.6)
#define TTextView_Background_Color  RGBA(244, 244, 246, 1.0)

//face view
#define TFaceView_Height 180
#define TFaceView_Margin 12
#define TFaceView_Page_Padding 20
#define TFaceView_Page_Height 30
#define TFaceView_Line_Height 0.5
#define TFaceView_Page_Color RGBA(188, 188, 188, 1.0)
#define TFaceView_Line_Color RGBA(188, 188, 188, 0.6)
#define TFaceView_Background_Color  RGBA(244, 244, 246, 1.0)

//menu view
#define TMenuView_Send_Color RGBA(44, 145, 247, 1.0)
#define TMenuView_Margin 6
#define TMenuView_Menu_Height 40
#define TMenuView_Line_Width 0.5
#define TMenuView_Line_Color RGBA(188, 188, 188, 0.6)

//more view
#define TMoreView_Column_Count 4
#define TMoreView_Section_Padding 30
#define TMoreView_Margin 10
#define TMoreView_Page_Height 30
#define TMoreView_Page_Color RGBA(188, 188, 188, 1.0)
#define TMoreView_Line_Height 0.5
#define TMoreView_Line_Color RGBA(188, 188, 188, 0.6)
#define TMoreView_Background_Color  RGBA(244, 244, 246, 1.0)

//menu item cell
#define TMenuCell_ReuseId @"TMenuCell"
#define TMenuCell_Margin 6
#define TMenuCell_Line_ReuseId @"TMenuLineCell"
#define TMenuCell_Selected_Background_Color  RGBA(244, 244, 246, 1.0)
#define TMenuCell_UnSelected_Background_Color  RGBA(255, 255, 255, 1.0)

//more item cell
#define TMoreCell_ReuseId @"TMoreCell"
#define TMoreCell_Margin 5
#define TMoreCell_Image_Size CGSizeMake(70, 70)
#define TMoreCell_Title_Height 20

//face item cell
#define TFaceCell_ReuseId @"TFaceCell"

//group member cell
#define TGroupMemberCell_ReuseId @"TGroupMemberCell"
#define TGroupMemberCell_Margin 5
#define TGroupMemberCell_Head_Size CGSizeMake(60, 60)
#define TGroupMemberCell_Name_Height 20

//conversation cell
#define TConversationCell_ReuseId @"TConversationCell"
#define TConversationCell_Height 70
#define TConversationCell_Margin 10
#define TConversationCell_Margin_Text 13

//pop view
#define TPopView_Arrow_Size CGSizeMake(15, 10)
#define TPopView_Background_Color RGBA(188, 188, 188, 0.5)
//pop cell
#define TPopCell_ReuseId @"TPopCell"
#define TPopCell_Height 45
#define TPopCell_Margin 18
#define TPopCell_Padding 12

//unRead
#define TUnReadView_Margin_TB 2
#define TUnReadView_Margin_LR 4


//conversation controller
#define TConversationController_Background_Color RGBA(244, 244, 246, 1.0)

//message controller
#define TMessageController_Background_Color RGBA(244, 244, 246, 1.0)
#define TMessageController_Header_Height 40

//input controller
#define TInputView_Background_Color RGBA(244, 244, 246, 1.0)

//members controller
#define TGroupMembersController_Background_Color RGBA(244, 244, 246, 1.0)
#define TGroupMembersController_Margin 20
#define TGroupMembersController_Row_Count 5

//info controller
#define TGroupInfoController_Background_Color RGBA(244, 244, 246, 1.0)

//setting controller
#define TSettingController_Background_Color RGBA(244, 244, 246, 1.0)

//add c2c controller
#define TAddC2CController_Background_Color RGBA(255, 255, 255, 1.0)
#define TAddC2CController_Margin 10
#define TAddC2CController_Line_Height 0.5
#define TAddC2CController_Line_Color RGBA(188, 188, 188, 0.6)


//add group controller
#define TAddGroupController_Background_Color RGBA(255, 255, 255, 1.0)
#define TAddGroupController_Margin 15
#define TAddGroupController_Line_Height 0.5
#define TAddGroupController_Line_Color RGBA(188, 188, 188, 0.6)

//add member controller
#define TAddMemberController_Background_Color RGBA(255, 255, 255, 1.0)
#define TAddMemberController_Margin 15
#define TAddMemberController_Line_Height 0.5
#define TAddMemberController_Line_Color RGBA(188, 188, 188, 0.6)

//delete member controller
#define TDeleteMemberController_Background_Color RGBA(255, 255, 255, 1.0)
#define TDeleteMemberController_Margin 15
#define TDeleteMemberController_Line_Height 0.5
#define TDeleteMemberController_Line_Color RGBA(188, 188, 188, 0.6)


//add collection cell
#define TAddCollectionCell_ReuseId @"TAddCollectionCell"
#define TAddCollectionCell_Margin 10
#define TAddCollectionCell_Size CGSizeMake(33, 33)

//add option cell
#define TAddGroupOptionView_Margin 15
#define TAddGroupOptionView_Height 55




//add cell
#define TAddCell_ReuseId @"TAddCell"
#define TAddCell_Height 55
#define TAddCell_Margin 10
#define TAddCell_Select_Size CGSizeMake(25, 25)
#define TAddCell_Head_Size CGSizeMake(38, 38)

//add header
#define TAddHeaderView_ReuseId @"TAddHeaderView"
#define TAddHeaderView_Height 22
#define TAddHeaderView_Margin 10

//pick view
#define TPickView_Background_Color RGBA(188, 188, 188, 0.5)
#define TPickView_Line_Height 0.5
#define TPickView_Line_Color RGBA(188, 188, 188, 0.6)
#define TPickView_Margin 15
#define TPickView_Button_Size CGSizeMake(40, 20)
#define TPickView_Confirm_Color RGBA(44, 145, 247, 1.0)

//select view
#define TSelectView_ReuseId @"TSelectView"
#define TSelectView_Background_Color RGBA(188, 188, 188, 0.5)
#define TSelectView_Row_Heihgt 50
#define TSelectView_Header_Background_Color RGBA(244, 244, 246, 1.0)

//modify view
#define TModifyView_Background_Color RGBA(188, 188, 188, 0.5)
#define TModifyView_Line_Height_Width 0.5
#define TModifyView_Line_Color RGBA(188, 188, 188, 0.6)
#define TModifyView_Confirm_Color RGBA(44, 145, 247, 1.0)

//alert view
#define TAlertView_Background_Color RGBA(188, 188, 188, 0.5)
#define TAlertView_Line_Height_Width 0.5
#define TAlertView_Line_Color RGBA(188, 188, 188, 0.6)
#define TAlertView_Confirm_Color RGBA(44, 145, 247, 1.0)

//index view
#define TAddIndexView_Width 30


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
#define TButtonCell_Height 60
#define TButtonCell_Margin 10

//switch cell
#define TSwitchCell_ReuseId @"TSwitchCell"
#define TSwitchCell_Height 50
#define TSwitchCell_Margin 10

//personal common cell
#define TPersonalCommonCell_ReuseId @"TPersonalCommonCell"
#define TPersonalCommonCell_Image_Size CGSizeMake(80, 80)
#define TPersonalCommonCell_Margin 10
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
#define TNaviBarIndicatorView_Margin 5

//resource
//#define TUIKitResource(name) [NSString stringWithFormat:@"TUIKitResource.bundle/%@", name]
//#define TUIKitFace(name) [NSString stringWithFormat:@"TUIKitFace.bundle/%@", name]
#define TUIKitFace(name) [[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"TUIKitFace" ofType:@"bundle"]] resourcePath] stringByAppendingPathComponent:name]
#define TUIKitResource(name) [[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"TUIKitResource" ofType:@"bundle"]] resourcePath] stringByAppendingPathComponent:name]
//#define TUIKitResource(name) name
//#define TUIKitFace(name) name


//notification
#define TUIKitNotification_TIMRefreshListener @"TUIKitNotification_TIMRefreshListener"
#define TUIKitNotification_TIMMessageListener @"TUIKitNotification_TIMMessageListener"
#define TUIKitNotification_TIMMessageRevokeListener @"TUIKitNotification_TIMMessageRevokeListener"
#define TUIKitNotification_TIMUploadProgressListener @"TUIKitNotification_TIMUploadProgressListener"
#define TUIKitNotification_TIMUserStatusListener @"TUIKitNotification_TIMUserStatusListener"
#define TUIKitNotification_TIMConnListener @"TUIKitNotification_TIMConnListener"

//path
#define TUIKit_DB_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/com_tencent_imsdk_data/"]
#define TUIKit_Image_Path [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/image/"]
#define TUIKit_Video_Path [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/video/"]
#define TUIKit_Voice_Path [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/voice/"]
#define TUIKit_File_Path [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/file/"]


// rich
#define kDefaultRichCellHeight 50
#define kDefaultRichCellMargin 8
#define kRichCellValueColor  [UIColor blackColor]
#define kRichCellTipsColor [UIColor grayColor]
#define kRichCellTextFont      [UIFont systemFontOfSize:14]

#endif /* THeader_h */
