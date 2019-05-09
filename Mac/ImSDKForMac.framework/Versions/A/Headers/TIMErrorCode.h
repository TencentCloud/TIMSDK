//
//  TIMErrorCode.h
//  ImSDK
//
//  Created by jameskhdeng on 2018/11/23.
//  Copyright © 2018 tencent. All rights reserved.
//

#ifndef TIMErrorCode_h
#define TIMErrorCode_h

enum ERROR_CODE {
    ERR_SUCC = 0,
    ERR_PARSE_RESPONSE_FAILED            = 6001, //解析响应失败
    ERR_SERIALIZE_REQ_FAILED             = 6002, //序列化请求失败
    ERR_NO_SUCC_RESULT                   = 6003, //批量操作无成功结果
    ERR_INVALID_CONVERSATION             = 6004, //IM: 无效会话
    ERR_LOADMSG_FAILED                   = 6005, //IM: 加载本地消息存储失败
    ERR_FILE_TRANS_AUTH_FAILED           = 6006, //IM: 文件传输 - 鉴权失败
    ERR_FILE_TRANS_NO_SERVER             = 6007, //IM: 文件传输 - 获取svr失败
    ERR_FILE_TRANS_UPLOAD_FAILED         = 6008, //IM: 文件传输 - 上传失败
    ERR_FILE_TRANS_DOWNLOAD_FAILED       = 6009, //IM: 文件传输 - 下载失败
    ERR_HTTP_REQ_FAILED                  = 6010, //HTTP请求失败
    ERR_TO_USER_INVALID                  = 6011, //IM: 无效接收方
    ERR_REQUEST_TIMEOUT                  = 6012, //请求超时
    ERR_SDK_NOT_INITIALIZED              = 6013, //SDK未初始化
    ERR_SDK_NOT_LOGGED_IN                = 6014, //SDK未登录
    ERR_IN_PROGESS                       = 6015, //执行中
    ERR_INVALID_MSG_ELEM                 = 6016, //IM: 无效消息elem
    ERR_INVALID_PARAMETERS               = 6017, //API参数无效
    ERR_INIT_CORE_FAIL                   = 6018, //INIT CORE模块失败
    ERR_DATABASE_OPERATE_FAILED          = 6019, //本地数据库操作失败
    ERR_EXPIRED_SESSION_NODE             = 6020, //SessionNode为null
    ERR_INVALID_SDK_OBJECT               = 6021, //无效的imsdk对象，例如用户自己生成TIMImage,或内部赋值错误导致的sdk对象无效
    ERR_IO_OPERATION_FAILED              = 6022, //本地IO操作失败
    ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED = 6023, //在登录完成前进行了登出（在登录时返回）
    ERR_TLSSDK_NOT_INITIALIZED           = 6024, //tlssdk未初始化
    ERR_TLSSDK_USER_NOT_FOUND            = 6025, //TLSSDK没有找到相应的用户信息
    ERR_NO_PREVIOUS_LOGIN                = 6026, //自动登陆时并没有登陆过该用户
    
    ERR_BIND_FAIL_UNKNOWN                = 6100, //QALSDK未知原因BIND失败
    ERR_BIND_FAIL_NO_SSOTICKET           = 6101, //缺少SSO票据
    ERR_BIND_FAIL_REPEATD_BIND           = 6102, //重复BIND
    ERR_BIND_FAIL_TINYID_NULL            = 6103, //tiny为空
    ERR_BIND_FAIL_GUID_NULL              = 6104, //guid为空
    ERR_BIND_FAIL_UNPACK_REGPACK_FAILED  = 6105, //解注册包失败
    ERR_BIND_FAIL_REG_TIMEOUT            = 6106, //注册超时
    ERR_BIND_FAIL_ISBINDING              = 6107, //正在bind操作中
    
    ERR_PACKET_FAIL_UNKNOWN              = 6120, //发包未知错误
    ERR_PACKET_FAIL_REQ_NO_NET           = 6121, //发送请求包时没有网络,处理时转换成ERR_REQ_NO_NET_ON_REQ
    ERR_PACKET_FAIL_RESP_NO_NET          = 6122, //发送回复包时没有网络,处理时转换成ERR_REQ_NO_NET_ON_RSP
    ERR_PACKET_FAIL_REQ_NO_AUTH          = 6123, //发送请求包时没有权限
    ERR_PACKET_FAIL_SSO_ERR              = 6124, //SSO错误
    ERR_PACKET_FAIL_REQ_TIMEOUT          = 6125, //请求超时,处理时转化成ERR_REQUEST_TIMEOUT
    ERR_PACKET_FAIL_RESP_TIMEOUT         = 6126, //回复超时,处理时转化成ERR_REQUEST_TIMEOUT
    ERR_PACKET_FAIL_REQ_ON_RESEND        = 6127, //
    ERR_PACKET_FAIL_RESP_NO_RESEND       = 6128, //
    ERR_PACKET_FAIL_FLOW_SAVE_FILTERED   = 6129, //
    ERR_PACKET_FAIL_REQ_OVER_LOAD        = 6130, //
    ERR_PACKET_FAIL_LOGIC_ERR            = 6131,
    
    ERR_FRIENDSHIP_PROXY_NOT_SYNCED      = 6150, // proxy_manager没有完成svr数据同步
    ERR_FRIENDSHIP_PROXY_SYNCING         = 6151, // proxy_manager正在进行svr数据同步
    ERR_FRIENDSHIP_PROXY_SYNCED_FAIL     = 6152, // proxy_manager同步失败
    ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR = 6153, // proxy_manager请求参数，在本地检查不合法
    
    ERR_GROUP_INVALID_FIELD                  = 6160, // group assistant请求字段中包含非预设字段
    ERR_GROUP_STORAGE_DISABLED             = 6161, // group assistant群资料本地存储没有开启
    ERR_LOADGRPINFO_FAILED                 = 6162, // failed to load groupinfo from storage
    
    ERR_REQ_NO_NET_ON_REQ                = 6200, // 请求的时候没有网络
    ERR_REQ_NO_NET_ON_RSP                = 6201, // 响应的时候没有网络
    ERR_SERIVCE_NOT_READY                = 6205, // QALSDK服务未就绪
    ERR_USER_SIG_EXPIRED                 = 6206, // 票据过期
    ERR_LOGIN_AUTH_FAILED                = 6207, // 账号认证失败（tinyid转换失败）
    ERR_LOGIN_KICKED_OFF_BY_OTHER        = 6208, // 账号被踢
    ERR_NEVER_CONNECT_AFTER_LAUNCH       = 6209, // 在应用启动后没有尝试联网
    
    ERR_REQ_FAILED                       = 6210, // QAL执行失败
    ERR_REQ_INVALID_REQ                  = 6211, // 请求非法，toMsgService非法
    ERR_REQ_OVERLOADED                   = 6212, // 请求队列満
    ERR_REQ_KICK_OFF                     = 6213, // 已经被其他终端踢了
    ERR_REQ_SERVICE_SUSPEND              = 6214, // 服务被暂停
    ERR_REQ_INVALID_SIGN                 = 6215, // SSO签名错误
    ERR_REQ_INVALID_COOKIE               = 6216, // SSO cookie无效
    ERR_LOGIN_TLS_RSP_PARSE_FAILED       = 6217, // 登录时TLS回包校验，包体长度错误
    ERR_LOGIN_OPENMSG_TIMEOUT            = 6218, // 登录时OPENSTATSVC向OPENMSG上报状态超时
    ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED   = 6219, // 登录时OPENSTATSVC向OPENMSG上报状态时解析回包失败
    ERR_LOGIN_TLS_DECRYPT_FAILED         = 6220, // 登录时TLS解密失败
    ERR_WIFI_NEED_AUTH                   = 6221, // wifi需要认证
    
    ERR_USER_CANCELED                    = 6222, // 用户已取消
    
    ERR_REVOKE_TIME_LIMIT_EXCEED         = 6223, //消息撤回超过了时间限制（默认2分钟）
    ERR_LACK_UGC_EXT                     = 6224, // 缺少UGC扩展包
    ERR_AUTOLOGIN_NEED_USERSIG         = 6226, //自动登录，本地票据过期，需要userSig手动登录
    
    
    ERR_REQ_CONTENT_ATTACK               = 80001, // 消息内容安全打击
    
    ERR_LOGIN_SIG_EXPIRE                 = 70001,  // 登陆返回，票据过期
    
    ERR_SDK_HAD_INITIALIZED              = 90001,  // SDK 已经初始化无需重复初始化
    ERR_OPENBDH_BASE                     = 115000,  // openbdh 错误码基
};

#endif /* TIMErrorCode_h */
