/**
 * Module: TUILiveMsgModel
 *
 * Function: 消息相关的定义
 */

#import <Foundation/Foundation.h>
//#import "TCRoomListModel.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define MSG_TABLEVIEW_WIDTH        200
#define MSG_TABLEVIEW_HEIGHT       160
#define MSG_TABLEVIEW_BOTTOM_SPACE 40
#define MSG_TABLEVIEW_LABEL_FONT   14
#define MSG_BULLETVIEW_HEIGHT      34
#define MSG_UI_SPACE               10

// 发送框
#define MSG_TEXT_SEND_VIEW_HEIGHT          45
#define MSG_TEXT_SEND_FEILD_HEIGHT         25
#define MSG_TEXT_SEND_BTN_WIDTH            35
#define MSG_TEXT_SEND_BULLET_BTN_WIDTH     55

// 小图标
#define BOTTOM_BTN_ICON_WIDTH  35

@interface TUILiveIMUserAble : NSObject

@property (nonatomic, assign) NSInteger cmdType;

// 两个用户是否相同，可通过比较imUserId来判断
// 用户IMSDK的identigier
@property (nonatomic, copy) NSString *imUserId;

// 用户昵称
@property (nonatomic, copy) NSString *imUserName;

// 用户头像地址
@property (nonatomic, copy) NSString *imUserIconUrl;

@end

typedef NS_ENUM(NSInteger, TUILiveMsgModelType) {
    TUILiveMsgModelType_NormalMsg           = 1,   //普通消息
    TUILiveMsgModelType_MemberEnterRoom     = 2,   //进入房间消息
    TUILiveMsgModelType_MemberQuitRoom      = 3,   //退出房间消息
    TUILiveMsgModelType_Praise              = 4,   //点赞消息
    TUILiveMsgModelType_DanmaMsg            = 5,   //弹幕消息
    TUILiveMsgModelType_Gift                = 6    //礼物消息
};

/**
 *  消息model，这个model会在弹幕，消息列表，观众列表用到
 */
@interface TUILiveMsgModel : NSObject
@property (nonatomic, assign) TUILiveMsgModelType msgType;      //消息类型
@property (nonatomic, copy) NSString *userId;            //用户Id
@property (nonatomic, copy) NSString *userName;          //用户名字
@property (nonatomic, copy) NSString *userMsg;           //用户发的消息
@property (nonatomic, copy) NSString *userHeadImageUrl;  //用户头像url
@property (nonatomic, assign) NSInteger msgHeight;         //消息高度
@property (nonatomic, copy) NSAttributedString* msgAttribText;
@end


