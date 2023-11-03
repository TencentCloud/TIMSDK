//
//  TCConstants.h
//  TCLVBIMDemo
//
//  Created by realingzhou on 16/8/22.
//  Copyright © 2016年 tencent. All rights reserved.
//

#ifndef TCConstants_h
#define TCConstants_h

// 全局调度服务器地址，国内
#define kGlobalDispatchServiceHost @""
#define kApaasAppID @""
// 全局调度服务器地址，国际
#define kGlobalDispatchServiceHost_international @""
#define kApaasAppID_international @""
// 全局调度服务
#define kGlobalDispatchServicePath @""

// 开发测试环境
#define kEnvDev @"/dev"
// 生产环境
#define kEnvProd @"/prod"

// 获取短信验证码（含图片验证）
#define kGetSmsVerfifyCodePath @""
// 手机号登录
#define kLoginByPhonePath @""
// token 登录
#define kLoginByTokenPath @""
// 登出
#define kLogoutPath @""
// 注销账号
#define kDeleteUserPath @""


// Http配置
#define kHttpServerAddr @""

//Elk 数据上报地址
#define DEFAULT_ELK_HOST @""

//Licence url
#define LicenceURL @""

//Licence key
#define LicenceKey @""

//APNS
#define kAPNSBusiId 0
#define kTIMPushAppGorupKey @"" 

//tpns
#define kTPNSAccessID  0
#define kTPNSAccessKey @""
//tpns domain
#define kTPNSDomain  @""
//**********************************************************************

#define kHttpTimeout                         30

//错误码
#define kError_InvalidParam                            -10001
#define kError_ConvertJsonFailed                       -10002
#define kError_HttpError                               -10003

//IMSDK群组相关错误码
#define kError_GroupNotExist                            10010  //该群已解散
#define kError_HasBeenGroupMember                       10013  //已经是群成员

//错误信息
#define  kErrorMsgNetDisconnected  @"网络异常，请检查网络"

//版本
#define kVersion  4
#endif /* TCConstants_h */
