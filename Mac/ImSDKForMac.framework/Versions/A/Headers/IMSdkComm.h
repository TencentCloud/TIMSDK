//
//  IMSdkComm.h
//  ImSDK
//
//  Created by bodeng on 10/12/14.
//  Copyright (c) 2014 tencent. All rights reserved.
//

#ifndef ImSDK_IMSdkComm_h
#define ImSDK_IMSdkComm_h

@interface OMErrResp : NSObject
{
    NSString*   cmd;                // 返回的命令字
    int         seq;                // 请求包的seq
    NSString*   uin;                // uin
    int         errCode;          // 错误码
    NSString*   errTips;            // error tips
}

@property(nonatomic,strong) NSString* cmd;
@property(nonatomic,strong) NSString* uin;
@property(nonatomic,assign) int seq;
@property(nonatomic,assign) int errCode;
@property(nonatomic,strong) NSString* errTips;

@end


/// 业务相关回调

/**
 *  userid和tinyid 转换回包
 *  userList 存储IMUserId结构
 */
@interface OMUserIdResp : NSObject{
    NSArray*   userList;         // 用户的登录的open id
}


@property(nonatomic,strong) NSArray* userList;

@end

/**
 *  userid转换tinyid回调
 *
 *  @param resp 回包结构
 *
 *  @return 0 处理成功
 */
typedef int (^OMUserIdSucc)(OMUserIdResp *resp);

//请求回调
typedef int (^OMErr)(OMErrResp *resp);


/**
 *  音视频回调
 */
@interface OMCommandResp : NSObject{
    NSData*   rspbody;
}


@property(nonatomic,strong) NSData* rspbody;

@end

// relay 回调
typedef int (^OMCommandSucc)(OMCommandResp *resp);

// request 回调
typedef void (^OMRequestSucc)(NSData * data);
typedef void (^OMRequsetFail)(int code, NSString* msg);

/**
 *  UserId 结构，表示一个用户的账号信息
 */
@interface IMUserId : NSObject{
    NSString*       uidtype;            // uid 类型
    unsigned int    userappid;
    NSString*       userid;             // 用户id
    unsigned long long   tinyid;
    unsigned long long   uin;
}

@property(nonatomic,strong) NSString* uidtype;
@property(nonatomic,assign) unsigned int userappid;
@property(nonatomic,strong) NSString* userid;
@property(nonatomic,assign) unsigned long long tinyid;
@property(nonatomic,assign) unsigned long long uin;

@end

/**
 *  一般多人音视频操作成功回调
 */
typedef void (^OMMultiSucc)();

/**
 *  一般多人音视频操作失败回调
 *
 *  @param code     错误码
 *  @param err      错误描述
 */
typedef void (^OMMultiFail)(int code, NSString * err);

#endif
