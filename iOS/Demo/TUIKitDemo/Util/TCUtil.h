//
//  TCUtil.h
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//
/** 腾讯云IM Demo数据处理单元
 *
 *  本类为Demo客户端提供数据处理服务，以便客户端更好的工作
 *
 */
#import <Foundation/Foundation.h>

//report action
#define Action_Install            @"install"                    //安装
#define Action_Startup            @"startup"                    //启动
#define Action_Staytime           @"staytime"                   //使用时长
#define Action_Register           @"register"                   //注册
#define Action_Login              @"login"                      //登录
#define Action_Logout             @"logout"                     //登出
#define Action_Clickhelper        @"clickhelper"                //点击IM助手
#define Action_Sendmsg2helper     @"sendmsg2helper"             //向IM助手发消息
#define Action_Clickdefaultgrp    @"clickdefaultgrp"            //点击默认交流群
#define Action_Sendmsg2defaultgrp @"sendmsg2defaultgrp"         //向默认群发送消息
#define Action_Createc2c          @"createc2c"                  //发起C2C会话
#define Action_Createprivategrp   @"createprivategrp"           //创建讨论组
#define Action_Createpublicgrp    @"createpublicgrp"            //创建群聊
#define Action_Createchatroomgrp  @"createchatroomgrp"          //创建聊天室
#define Action_Addfriend          @"addfriend"                  //添加好友
#define Action_Addgroup           @"addgroup"                   //添加群组
#define Action_Addblacklist       @"addblacklist"               //添加黑名单
#define Action_Deleteblacklist    @"deleteblacklist"            //删除黑名单
#define Action_Modifyselfprofile  @"modifyselfprofile"          //修改个人信息
#define Action_Setapns            @"setapns"                    //设置消息提醒
#define Action_Clickaboutsdk      @"clickaboutsdk"              //点击关于云通信
#define Action_Clickdebug         @"clickdebug"                 //点击开发调试
#define Action_Clickmemoryreport  @"clickmemoryreport"          //点击内存泄露上报
#define Action_SendMsg            @"sendmsg"                    //发消息

//when Action_SendMsg
#define Action_Sub_Sendtext        @"sendtext"         //发送文本消息
#define Action_Sub_Sendaudio       @"sendaudio"        //发送语音消息
#define Action_Sub_Sendface        @"sendface"         //发送表情消息
#define Action_Sub_Sendpicture     @"sendpicture"      //发送图片消息
#define Action_Sub_Sendvideo       @"sendvideo"        //发送视频消息
#define Action_Sub_Sendfile        @"sendfile"         //发送文件消息
#define Action_Sub_Sendgrouplive   @"sendgrouplive"    //发送群直播消息
#define Action_Sub_Sendcustom      @"sendcustom"       //发送自定义消息

//when Action_Modifyselfprofile
#define Action_Sub_Modifyfaceurl   @"modifyfaceurl"    //修改头像
#define Action_Sub_Modifybirthday  @"modifybirthday"   //修改生日
#define Action_Sub_Modifynick      @"modifynick"       //修改昵称
#define Action_Sub_Modifysignature @"modifysignature"  //修改签名
#define Action_Sub_Modifylocation  @"modifylocation"   //修改所在地
#define Action_Sub_Modifygender    @"modifygender"     //修改性别
#define Action_Sub_Modifyallowtype @"modifyallowtype"  //修改好友申请

@interface TCUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString*)string;

+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int resultCode, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;

// 废弃
+ (void)report:(NSString *)action actionSub:(NSString *)actionSub code:(NSNumber *)code  msg:(NSString *)msg;

@end

