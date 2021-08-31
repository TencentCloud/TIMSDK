//
//  TCConstants.h
//  TCLVBIMDemo
//
//  Created by realingzhou on 16/8/22.
//  Copyright © 2016年 tencent. All rights reserved.
//

#ifndef TCConstants_h
#define TCConstants_h

//Http配置
#define kHttpServerAddr                     @"https://im-demo.qcloud.com"


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

#endif /* TCConstants_h */
