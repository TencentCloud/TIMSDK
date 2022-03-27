// Copyright (c) 2021 Tencent. All rights reserved.

#ifndef SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_DEF_H_
#define SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_DEF_H_

#include "TIMCloudComm.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                      错误码
//
/////////////////////////////////////////////////////////////////////////////////
//详细 [错误码](https://cloud.tencent.com/document/product/269/1671)，请您移步官网查看
enum TIMErrCode {
    // ///////////////////////////////////////////////////////////////////////////////
    //
    // （一）IM SDK 的错误码
    //
    // ///////////////////////////////////////////////////////////////////////////////

    // 通用错误码

    ERR_SUCC                                    = 0,       // 无错误。
    ERR_IN_PROGESS                              = 6015,    // 执行中，请做好接口调用控制，例如，第一次初始化操作在回调前，后续的初始化操作会返回该错误码。
    ERR_INVALID_PARAMETERS                      = 6017,    // 参数无效，请检查参数是否符合要求，具体可查看错误信息进一步定义哪个字段。
    ERR_IO_OPERATION_FAILED                     = 6022,    // 操作本地 IO 错误，检查是否有读写权限，磁盘是否已满。
    ERR_INVALID_JSON                            = 6027,    // 错误的 JSON 格式，请检查参数是否符合接口的要求，具体可查看错误信息进一步定义哪个字段。
    ERR_OUT_OF_MEMORY                           = 6028,    // 内存不足，可能存在内存泄漏，iOS 平台使用 Instrument 工具，Android 平台使用 Profiler 工具，分析出什么地方的内存占用高。
    ERR_PARSE_RESPONSE_FAILED                   = 6001,    // PB 解析失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SERIALIZE_REQ_FAILED                    = 6002,    // PB 序列化失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NOT_INITIALIZED                     = 6013,    // IM SDK 未初始化，初始化成功回调之后重试。
    ERR_LOADMSG_FAILED                          = 6005,    // 加载本地数据库操作失败，可能存储文件有损坏，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 联系客服定位具体问题。
    ERR_DATABASE_OPERATE_FAILED                 = 6019,    // 本地数据库操作失败，可能是部分目录无权限或者数据库文件已损坏。
    ERR_SDK_COMM_CROSS_THREAD                   = 7001,    // 跨线程错误，不能在跨越不同线程中执行，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_COMM_TINYID_EMPTY                   = 7002,    // TinyId 为空，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_COMM_INVALID_IDENTIFIER             = 7003,    // Identifier 非法，必须不为空，要求可打印 ASCII 字符（0x20-0x7e），长度不超过32字节。
    ERR_SDK_COMM_FILE_NOT_FOUND                 = 7004,    // 文件不存在，请检查文件路径是否正确。
    ERR_SDK_COMM_FILE_TOO_LARGE                 = 7005,    // 文件大小超出了限制，语音、图片，最大限制是28MB，视频、文件，最大限制 100M
    ERR_SDK_COMM_FILE_SIZE_EMPTY                = 7006,    // 空文件，要求文件大小不是0字节，如果上传图片、语音、视频或文件，请检查文件是否正确生成。
    ERR_SDK_COMM_FILE_OPEN_FAILED               = 7007,    // 文件打开失败，请检查文件是否存在，或者已被独占打开，引起 SDK 打开失败。
    ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT       = 7008,    // API 调用超频
    ERR_SDK_COMM_INTERRUPT                      = 7009,    // 正在执行时被终止，例如正在登录时，调用 unInit 停止使用 SDK 。
    ERR_SDK_COMM_DATABASE_FAILURE               = 7010,    // database 操作失败
    ERR_SDK_COMM_DATABASE_NOTFOUND              = 7011,    // database 查询的数据不存在
    ERR_SDK_INTERNAL_ERROR                      = 7012,    // SDK 内部不应该出现的内部错误

    // 帐号错误码

    ERR_SDK_NOT_LOGGED_IN                       = 6014,    // IM SDK 未登录，请先登录，成功回调之后重试，或者已被踢下线，可使用 TIMManager getLoginUser 检查当前是否在线。
    ERR_NO_PREVIOUS_LOGIN                       = 6026,    // 自动登录时，并没有登录过该用户，这时候请调用 login 接口重新登录。
    ERR_USER_SIG_EXPIRED                        = 6206,    // UserSig 过期，请重新获取有效的 UserSig 后再重新登录。
    ERR_LOGIN_KICKED_OFF_BY_OTHER               = 6208,    // 其他终端登录同一个帐号，引起已登录的帐号被踢，需重新登录。
    ERR_SDK_ACCOUNT_LOGIN_IN_PROCESS            = 7501,    // 登录正在执行中，例如，第一次 login 或 autoLogin 操作在回调前，后续的 login 或 autoLogin 操作会返回该错误码。
    ERR_SDK_ACCOUNT_LOGOUT_IN_PROCESS           = 7502,    // 登出正在执行中，例如，第一次 logout 操作在回调前，后续的 logout 操作会返回该错误码。
    ERR_SDK_ACCOUNT_TLS_INIT_FAILED             = 7503,    // TLS SDK 初始化失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED         = 7504,    // TLS SDK 未初始化，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR          = 7505,    // TLS SDK TRANS 包格式错误，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED          = 7506,    // TLS SDK 解密失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED          = 7507,    // TLS SDK 请求失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT         = 7508,    // TLS SDK 请求超时，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。

    // 消息错误码

    ERR_INVALID_CONVERSATION                    = 6004,    // 会话无效，getConversation 时检查是否已经登录，如未登录获取会话，会有此错误码返回。
    ERR_FILE_TRANS_AUTH_FAILED                  = 6006,    // 文件传输鉴权失败，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_FILE_TRANS_NO_SERVER                    = 6007,    // 文件传输获取 Server 列表失败，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_FILE_TRANS_UPLOAD_FAILED                = 6008,    // 文件传输上传失败，请检查网络是否连接。
    ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE            = 6031,    // 文件传输上传失败，请检查上传的图片是否能够正常打开。
    ERR_FILE_TRANS_DOWNLOAD_FAILED              = 6009,    // 文件传输下载失败，请检查网络，或者文件、语音是否已经过期，目前资源文件存储7天。
    ERR_HTTP_REQ_FAILED                         = 6010,    // HTTP 请求失败，请检查 URL 地址是否合法，可在网页浏览器尝试访问该 URL 地址。
    ERR_INVALID_MSG_ELEM                        = 6016,    // IM SDK 无效消息 elem，具体可查看错误信息进一步定义哪个字段。
    ERR_INVALID_SDK_OBJECT                      = 6021,    // 无效的对象，例如用户自己生成 TIMImage 对象，或内部赋值错误导致对象无效。
    ERR_SDK_MSG_BODY_SIZE_LIMIT                 = 8001,    // 消息长度超出限制，消息长度不要超过8k，消息长度是各个 elem 长度的总和，elem 长度是所有 elem 字段的长度总和。
    ERR_SDK_MSG_KEY_REQ_DIFFER_RSP              = 8002,    // 消息 KEY 错误，内部错误，网络请求包的 KEY 和 回复包的不一致。
    ERR_SDK_IMAGE_CONVERT_ERROR                 = 8003,    // 万象优图 HTTP 请求失败。
    ERR_SDK_IMAGE_CI_BLOCK                      = 8004,    // 万象优图因为鉴黄等原因转缩略图失败。
    ERR_MERGER_MSG_LAYERS_OVER_LIMIT            = 8005,    // 合并消息嵌套层数超过上限（上限 100 层）。
    
    ERR_SDK_SIGNALING_INVALID_INVITE_ID         = 8010,    // 信令请求 ID 无效或已经被处理过。（上层接口使用，底层为了不重复也增加一份）
    ERR_SDK_SIGNALING_NO_PERMISSION             = 8011,    // 信令请求无权限，比如取消非自己发起的邀请。（上层接口使用，底层为了不重复也增加一份）
    ERR_SDK_INVALID_CANCEL_MESSAGE              = 8020,    // 取消消息时，取消的消息不存在，或者已经发送成功。取消失败
    ERR_SDK_SEND_MESSAGE_FAILED_WITH_CANCEL     = 8021,    // 消息发送失败，因为该消息已被取消
    // 群组错误码

    ERR_SDK_GROUP_INVALID_ID                    = 8501,    // 群组 ID 非法，自定义群组 ID 必须为可打印 ASCII 字符（0x20-0x7e），最长48个字节，且前缀不能为 @TGS#（避免与服务端默认分配的群组 ID 混淆）。
    ERR_SDK_GROUP_INVALID_NAME                  = 8502,    // 群名称非法，群名称最长30字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_GROUP_INVALID_INTRODUCTION          = 8503,    // 群简介非法，群简介最长240字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_GROUP_INVALID_NOTIFICATION          = 8504,    // 群公告非法，群公告最长300字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_GROUP_INVALID_FACE_URL              = 8505,    // 群头像 URL 非法，群头像 URL 最长100字节，可在网页浏览器尝试访问该 URL 地址。
    ERR_SDK_GROUP_INVALID_NAME_CARD             = 8506,    // 群名片非法，群名片最长50字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_GROUP_MEMBER_COUNT_LIMIT            = 8507,    // 超过群组成员数的限制，在创建群和邀请成员时，指定的成员数超出限制，最大群成员数量：私有群是200人，公开群是2000人，聊天室是10000人，音视频聊天室和在线成员广播大群无限制。
    ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY       = 8508,    // 不允许申请加入 Private 群组，任意群成员可邀请入群，且无需被邀请人同意。
    ERR_SDK_GROUP_INVITE_SUPER_DENY             = 8509,    // 不允许邀请角色为群主的成员，请检查角色字段是否填写正确。
    ERR_SDK_GROUP_INVITE_NO_MEMBER              = 8510,    // 不允许邀请0个成员，请检查成员字段是否填写正确。
    ERR_SDK_GROUP_ATTR_FREQUENCY_LIMIT          = 8511,    // 群属性接口操作限制：增删改接口后台限制1秒5次，查接口 SDK 限制5秒20次。
    ERR_SDK_GROUP_GET_ONLINE_MEMBER_COUNT_LIMIT = 8512,    // 获取群在线人数接口操作限制：查接口 SDK 限制60秒1次。
    ERR_SDK_GROUP_GET_GROUPS_INFO_LIMIT         = 8513,    // 获取群资料接口操作限制：查接口 SDK 限制1秒1次。
    ERR_SDK_GROUP_GET_JOINED_GROUP_LIMIT        = 8514,    // 获取加入群列表接口操作限制：查接口 SDK 限制1秒1次。

    // 关系链错误码

    ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY      = 9001,    // 资料字段非法，资料支持标配字段及自定义字段，其中自定义字段的关键字，必须是英文字母，且长度不得超过8字节，自定义字段的值最长不能超过500字节。
    ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK       = 9002,    // 备注字段非法，最大96字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING      = 9003,    // 请求添加好友的请求说明字段非法，最大120字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE       = 9004,    // 请求添加好友的添加来源字段非法，来源需要添加“AddSource_Type_”前缀。
    ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY       = 9005,    // 好友分组字段非法，必须不为空，每个分组的名称最长30字节，字符编码必须是 UTF-8 ，如果包含中文，可能用多个字节表示一个中文字符，请注意检查字符串的字节长度。
    ERR_SDK_FRIENDSHIP_EXCEED_THE_LIMIT         = 9006,    // 超过数量限制

    // 网络错误码

    ERR_SDK_NET_ENCODE_FAILED                   = 9501,    // SSO 加密失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NET_DECODE_FAILED                   = 9502,    // SSO 解密失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NET_AUTH_INVALID                    = 9503,    // SSO 未完成鉴权，可能登录未完成，请在登录完成后再操作。
    ERR_SDK_NET_COMPRESS_FAILED                 = 9504,    // 数据包压缩失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NET_UNCOMPRESS_FAILED               = 9505,    // 数据包解压失败，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NET_FREQ_LIMIT                      = 9506,    // 调用频率限制，最大每秒发起 5 次请求。
    ERR_SDK_NET_REQ_COUNT_LIMIT                 = 9507,    // 请求队列満，超过同时请求的数量限制，最大同时发起1000个请求。
    ERR_SDK_NET_DISCONNECT                      = 9508,    // 网络已断开，未建立连接，或者建立 socket 连接时，检测到无网络。
    ERR_SDK_NET_ALLREADY_CONN                   = 9509,    // 网络连接已建立，重复创建连接，内部错误。
    ERR_SDK_NET_CONN_TIMEOUT                    = 9510,    // 建立网络连接超时，请等网络恢复后重试。
    ERR_SDK_NET_CONN_REFUSE                     = 9511,    // 网络连接已被拒绝，请求过于频繁，服务端拒绝服务。
    ERR_SDK_NET_NET_UNREACH                     = 9512,    // 没有到达网络的可用路由，请等网络恢复后重试。
    ERR_SDK_NET_SOCKET_NO_BUFF                  = 9513,    // 系统中没有足够的缓冲区空间资源可用来完成调用，系统过于繁忙，内部错误。
    ERR_SDK_NET_RESET_BY_PEER                   = 9514,    // 对端重置了连接，可能服务端过载，SDK 内部会自动重连，请等网络连接成功 onConnSucc （ iOS ） 或 onConnected （ Android ） 回调后重试。
    ERR_SDK_NET_SOCKET_INVALID                  = 9515,    // socket 套接字无效，内部错误，可 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 提供使用接口、错误码、错误信息给客服解决。
    ERR_SDK_NET_HOST_GETADDRINFO_FAILED         = 9516,    // IP 地址解析失败，内部错误，可能是本地 imsdk_config 配置文件被损坏，读取到到 IP 地址非法。
    ERR_SDK_NET_CONNECT_RESET                   = 9517,    // 网络连接到中间节点或服务端重置，引起连接失效，内部错误，SDK 内部会自动重连，请等网络连接成功 onConnSucc （ iOS ） 或 onConnected （ Android ） 回调后重试。
    ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT            = 9518,    // 请求包等待进入待发送队列超时，发送时网络连接建立比较慢 或 频繁断网重连时，会出现该错误，请检查网络连接是否正常。
    ERR_SDK_NET_WAIT_SEND_TIMEOUT               = 9519,    // 请求包已进入待发送队列，等待进入系统的网络 buffer 超时，数据包较多 或 发送线程处理不过来，在回调错误时检测有联网，内部错误。
    ERR_SDK_NET_WAIT_ACK_TIMEOUT                = 9520,    // 请求包已进入系统的网络 buffer ，等待服务端回包超时，可能请求包没离开终端设备、中间路由丢弃、服务端意外丢包或回包被系统网络层丢弃，在回调错误时检测有联网，内部错误。
    ERR_SDK_NET_WAIT_SEND_REMAINING_TIMEOUT     = 9521,    // 请求包已进入待发送队列，部分数据已发送，等待发送剩余部分出现超时，可能上行带宽不足，请检查网络是否畅通，在回调错误时检测有联网，内部错误。
    ERR_SDK_NET_PKG_SIZE_LIMIT                  = 9522,    // 请求包长度大于限制，最大支持 1MB 。
    ERR_SDK_NET_WAIT_SEND_TIMEOUT_NO_NETWORK    = 9523,    // 请求包已进入待发送队列，等待进入系统的网络 buffer 超时，数据包较多 或 发送线程处理不过来，在回调错误时检测没有联网，内部错误。
    ERR_SDK_NET_WAIT_ACK_TIMEOUT_NO_NETWORK     = 9524,    // 请求包已进入系统的网络 buffer ，等待服务端回包超时，可能请求包没离开终端设备、中间路由丢弃、服务端意外丢包或回包被系统网络层丢弃，在回调错误时检测没有联网，内部错误。
    ERR_SDK_NET_SEND_REMAINING_TIMEOUT_NO_NETWORK = 9525,  // 请求包已进入待发送队列，部分数据已发送，等待发送剩余部分出现超时，可能上行带宽不足，请检查网络是否畅通，在回调错误时检测没有联网，内部错误。

    // ///////////////////////////////////////////////////////////////////////////////
    //
    // （二）服务端的错误码
    //
    // ///////////////////////////////////////////////////////////////////////////////

    // SSO 接入层的错误码

    ERR_SVR_SSO_CONNECT_LIMIT                   = -302  ,  // SSO 的连接数量超出限制，服务端拒绝服务。
    ERR_SVR_SSO_VCODE                           = -10000,  // 下发验证码标志错误。
    ERR_SVR_SSO_D2_EXPIRED                      = -10001,  // D2 过期。
    ERR_SVR_SSO_A2_UP_INVALID                   = -10003,  // A2 校验失败等场景使用。
    ERR_SVR_SSO_A2_DOWN_INVALID                 = -10004,  // 处理下行包时发现 A2 验证没通过或者被安全打击。
    ERR_SVR_SSO_EMPTY_KEY                       = -10005,  // 不允许空 D2Key 加密。
    ERR_SVR_SSO_UIN_INVALID                     = -10006,  // D2 中的 uin 和 SSO 包头的 uin 不匹配。
    ERR_SVR_SSO_VCODE_TIMEOUT                   = -10007,  // 验证码下发超时。
    ERR_SVR_SSO_NO_IMEI_AND_A2                  = -10008,  // 需要带上 IMEI 和 A2 。
    ERR_SVR_SSO_COOKIE_INVALID                  = -10009,  // Cookie 非法。
    ERR_SVR_SSO_DOWN_TIP                        = -10101,  // 下发提示语，D2 过期。
    ERR_SVR_SSO_DISCONNECT                      = -10102,  // 断链锁屏。
    ERR_SVR_SSO_IDENTIFIER_INVALID              = -10103,  // 失效身份。
    ERR_SVR_SSO_CLIENT_CLOSE                    = -10104,  // 终端自动退出。
    ERR_SVR_SSO_MSFSDK_QUIT                     = -10105,  // MSFSDK 自动退出。
    ERR_SVR_SSO_D2KEY_WRONG                     = -10106,  // SSO D2key 解密失败次数太多，通知终端需要重置，重新刷新 D2 。
    ERR_SVR_SSO_UNSURPPORT                      = -10107,  // 不支持聚合，给终端返回统一的错误码。终端在该 TCP 长连接上停止聚合。
    ERR_SVR_SSO_PREPAID_ARREARS                 = -10108,  // 预付费欠费。
    ERR_SVR_SSO_PACKET_WRONG                    = -10109,  // 请求包格式错误。
    ERR_SVR_SSO_APPID_BLACK_LIST                = -10110,  // SDKAppID 黑名单。
    ERR_SVR_SSO_CMD_BLACK_LIST                  = -10111,  // SDKAppID 设置 service cmd 黑名单。
    ERR_SVR_SSO_APPID_WITHOUT_USING             = -10112,  // SDKAppID 停用。
    ERR_SVR_SSO_FREQ_LIMIT                      = -10113,  // 频率限制(用户)，频率限制是设置针对某一个协议的每秒请求数的限制。
    ERR_SVR_SSO_OVERLOAD                        = -10114,  // 过载丢包(系统)，连接的服务端处理过多请求，处理不过来，拒绝服务。

    // 资源文件错误码

    ERR_SVR_RES_NOT_FOUND                       = 114000,  // 要发送的资源文件不存在。
    ERR_SVR_RES_ACCESS_DENY                     = 114001,  // 要发送的资源文件不允许访问。
    ERR_SVR_RES_SIZE_LIMIT                      = 114002,  // 文件大小超过限制。
    ERR_SVR_RES_SEND_CANCEL                     = 114003,  // 用户取消发送，如发送过程中登出等原因。
    ERR_SVR_RES_READ_FAILED                     = 114004,  // 读取文件内容失败。
    ERR_SVR_RES_TRANSFER_TIMEOUT                = 114005,  // 资源文件（如图片、文件、语音、视频）传输超时，一般是网络问题导致。
    ERR_SVR_RES_INVALID_PARAMETERS              = 114011,  // 参数非法。
    ERR_SVR_RES_INVALID_FILE_MD5                = 115066,  // 文件 MD5 校验失败。
    ERR_SVR_RES_INVALID_PART_MD5                = 115068,  // 分片 MD5 校验失败。

    // 后台公共错误码

    ERR_SVR_COMM_INVALID_HTTP_URL               = 60002,  // HTTP 解析错误 ，请检查 HTTP 请求 URL 格式。
    ERR_SVR_COMM_REQ_JSON_PARSE_FAILED          = 60003,  // HTTP 请求 JSON 解析错误，请检查 JSON 格式。
    ERR_SVR_COMM_INVALID_ACCOUNT                = 60004,  // 请求 URI 或 JSON 包体中 Identifier 或 UserSig 错误。
    ERR_SVR_COMM_INVALID_ACCOUNT_EX             = 60005,  // 请求 URI 或 JSON 包体中 Identifier 或 UserSig 错误。
    ERR_SVR_COMM_INVALID_SDKAPPID               = 60006,  // SDKAppID 失效，请核对 SDKAppID 有效性。
    ERR_SVR_COMM_REST_FREQ_LIMIT                = 60007,  // REST 接口调用频率超过限制，请降低请求频率。
    ERR_SVR_COMM_REQUEST_TIMEOUT                = 60008,  // 服务请求超时或 HTTP 请求格式错误，请检查并重试。
    ERR_SVR_COMM_INVALID_RES                    = 60009,  // 请求资源错误，请检查请求 URL。
    ERR_SVR_COMM_ID_NOT_ADMIN                   = 60010,  // REST API 请求的 Identifier 字段请填写 App 管理员帐号。
    ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT            = 60011,  // SDKAppID 请求频率超限，请降低请求频率。
    ERR_SVR_COMM_SDKAPPID_MISS                  = 60012,  // REST 接口需要带 SDKAppID，请检查请求 URL 中的 SDKAppID。
    ERR_SVR_COMM_RSP_JSON_PARSE_FAILED          = 60013,  // HTTP 响应包 JSON 解析错误。
    ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT        = 60014,  // 置换帐号超时。
    ERR_SVR_COMM_INVALID_ID_FORMAT              = 60015,  // 请求包体 Identifier 类型错误，请确认 Identifier 为字符串格式。
    ERR_SVR_COMM_SDKAPPID_FORBIDDEN             = 60016,  // SDKAppID 被禁用，请 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 联系客服确认。
    ERR_SVR_COMM_REQ_FORBIDDEN                  = 60017,  // 请求被禁用，请 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 联系客服确认。
    ERR_SVR_COMM_REQ_FREQ_LIMIT                 = 60018,  // 请求过于频繁，请稍后重试。
    ERR_SVR_COMM_REQ_FREQ_LIMIT_EX              = 60019,  // 请求过于频繁，请稍后重试。
    ERR_SVR_COMM_INVALID_SERVICE                = 60020,  // 未购买套餐包或购买的套餐包正在配置中暂未生效，请五分钟后再次尝试。
    ERR_SVR_COMM_SENSITIVE_TEXT                 = 80001,  // 文本安全打击，文本中可能包含敏感词汇。
    ERR_SVR_COMM_BODY_SIZE_LIMIT                = 80002,  // 发消息包体过长，目前支持最大8k消息包体长度，请减少包体大小重试。

    // 帐号错误码

    ERR_SVR_ACCOUNT_USERSIG_EXPIRED             = 70001,  // UserSig 已过期，请重新生成 UserSig，建议 UserSig 有效期不小于24小时。
    ERR_SVR_ACCOUNT_USERSIG_EMPTY               = 70002,  // UserSig 长度为0，请检查传入的 UserSig 是否正确。
    ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED        = 70003,  // UserSig 校验失败，请确认下 UserSig 内容是否被截断，如缓冲区长度不够导致的内容截断。
    ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX     = 70005,  // UserSig 校验失败，可用工具自行验证生成的 UserSig 是否正确。
    ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY  = 70009,  // 用公钥验证 UserSig 失败，请确认生成的 UserSig 使用的私钥和 SDKAppID 是否对应。
    ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID         = 70013,  // 请求的 Identifier 与生成 UserSig 的 Identifier 不匹配。
    ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID   = 70014,  // 请求的 SDKAppID 与生成 UserSig 的 SDKAppID 不匹配。
    ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND = 70016,  // 验证 UserSig 时公钥不存在。请先登录控制台下载私钥，下载私钥的具体方法可参考 [下载签名用的私钥](https://cloud.tencent.com/document/product/269/32688#.E4.B8.8B.E8.BD.BD.E7.AD.BE.E5.90.8D.E7.94.A8.E7.9A.84.E7.A7.81.E9.92.A5) 。
    ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND          = 70020,  // SDKAppID 未找到，请在云通信 IM 控制台确认应用信息。
    ERR_SVR_ACCOUNT_INVALID_USERSIG             = 70052,  // UserSig 已经失效，请重新生成，再次尝试。
    ERR_SVR_ACCOUNT_NOT_FOUND                   = 70107,  // 请求的用户帐号不存在。
    ERR_SVR_ACCOUNT_SEC_RSTR                    = 70114,  // 安全原因被限制。
    ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT            = 70169,  // 服务端内部超时，请重试。
    ERR_SVR_ACCOUNT_INVALID_COUNT               = 70206,  // 请求中批量数量不合法。
    ERR_SVR_ACCOUNT_INVALID_PARAMETERS          = 70402,  // 参数非法，请检查必填字段是否填充，或者字段的填充是否满足协议要求。
    ERR_SVR_ACCOUNT_ADMIN_REQUIRED              = 70403,  // 请求需要 App 管理员权限。
    ERR_SVR_ACCOUNT_FREQ_LIMIT                  = 70050,  // 因失败且重试次数过多导致被限制，请检查 UserSig 是否正确，一分钟之后再试。
    ERR_SVR_ACCOUNT_BLACKLIST                   = 70051,  // 帐号被拉入黑名单。
    ERR_SVR_ACCOUNT_COUNT_LIMIT                 = 70398,  // 创建帐号数量超过免费体验版数量限制，请升级为专业版。
    ERR_SVR_ACCOUNT_INTERNAL_ERROR              = 70500,  // 服务端内部错误，请重试。

    // 资料错误码

    ERR_SVR_PROFILE_INVALID_PARAMETERS          = 40001,  // 请求参数错误，请根据错误描述检查请求是否正确。
    ERR_SVR_PROFILE_ACCOUNT_MISS                = 40002,  // 请求参数错误，没有指定需要拉取资料的用户帐号。
    ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND           = 40003,  // 请求的用户帐号不存在。
    ERR_SVR_PROFILE_ADMIN_REQUIRED              = 40004,  // 请求需要 App 管理员权限。
    ERR_SVR_PROFILE_SENSITIVE_TEXT              = 40005,  // 资料字段中包含敏感词。
    ERR_SVR_PROFILE_INTERNAL_ERROR              = 40006,  // 服务端内部错误，请稍后重试。
    ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED    = 40007,  // 没有资料字段的读权限，详情可参见 [资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5) 。
    ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED   = 40008,  // 没有资料字段的写权限，详情可参见 [资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5) 。
    ERR_SVR_PROFILE_TAG_NOT_FOUND               = 40009,  // 资料字段的 Tag 不存在。
    ERR_SVR_PROFILE_SIZE_LIMIT                  = 40601,  // 资料字段的 Value 长度超过500字节。
    ERR_SVR_PROFILE_VALUE_ERROR                 = 40605,  // 标配资料字段的 Value 错误，详情可参见 [标配资料字段](https://cloud.tencent.com/doc/product/269/1500#.E6.A0.87.E9.85.8D.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5) 。
    ERR_SVR_PROFILE_INVALID_VALUE_FORMAT        = 40610,  // 资料字段的 Value 类型不匹配，详情可参见 [标配资料字段](https://cloud.tencent.com/doc/product/269/1500#.E6.A0.87.E9.85.8D.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5) 。

    // 关系链错误码

    ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS       = 30001,  // 请求参数错误，请根据错误描述检查请求是否正确。
    ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID         = 30002,  // SDKAppID 不匹配。
    ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND        = 30003,  // 请求的用户帐号不存在。
    ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED           = 30004,  // 请求需要 App 管理员权限。
    ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT           = 30005,  // 关系链字段中包含敏感词。
    ERR_SVR_FRIENDSHIP_INTERNAL_ERROR           = 30006,  // 服务端内部错误，请重试。
    ERR_SVR_FRIENDSHIP_NET_TIMEOUT              = 30007,  // 网络超时，请稍后重试。
    ERR_SVR_FRIENDSHIP_WRITE_CONFLICT           = 30008,  // 并发写导致写冲突，建议使用批量方式。
    ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY          = 30009,  // 后台禁止该用户发起加好友请求。
    ERR_SVR_FRIENDSHIP_COUNT_LIMIT              = 30010,  // 自己的好友数已达系统上限。
    ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT        = 30011,  // 分组已达系统上限。
    ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT           = 30012,  // 未决数已达系统上限。
    ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT          = 30013,  // 黑名单数已达系统上限。
    ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT        = 30014,  // 对方的好友数已达系统上限。
    ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST        = 30515,  // 请求添加好友时，对方在自己的黑名单中，不允许加好友。
    ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY      = 30516,  // 请求添加好友时，对方的加好友验证方式是不允许任何人添加自己为好友。
    ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST        = 30525,  // 请求添加好友时，自己在对方的黑名单中，不允许加好友。
    ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM  = 30539,  // A 请求加 B 为好友，B 的加好友验证方式被设置为“AllowType_Type_NeedConfirm”，这时 A 与 B 之间只能形成未决关系，该返回码用于标识加未决成功，以便与加好友成功的返回码区分开，调用方可以捕捉该错误给用户一个合理的提示。
    ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR      = 30540,  // 添加好友请求被安全策略打击，请勿频繁发起添加好友请求。
    ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND       = 30614,  // 请求的未决不存在。
    ERR_SVR_FRIENDSHIP_DEL_NONFRIEND            = 31704,  // 与请求删除的帐号之间不存在好友关系。
    ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR      = 31707,  // 删除好友请求被安全策略打击，请勿频繁发起删除好友请求。
    ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX     = 31804,  // 请求的用户帐号不存在。

    // 最近联系人错误码

    ERR_SVR_CONV_ACCOUNT_NOT_FOUND              = 50001,  // 请求的用户帐号不存在。
    ERR_SVR_CONV_INVALID_PARAMETERS             = 50002,  // 请求参数错误，请根据错误描述检查请求是否正确。
    ERR_SVR_CONV_ADMIN_REQUIRED                 = 50003,  // 请求需要 App 管理员权限。
    ERR_SVR_CONV_INTERNAL_ERROR                 = 50004,  // 服务端内部错误，请重试。
    ERR_SVR_CONV_NET_TIMEOUT                    = 50005,  // 网络超时，请稍后重试。

    // 消息错误码

    ERR_SVR_MSG_PKG_PARSE_FAILED                = 20001,  // 请求包非法，请检查发送方和接收方帐号是否存在。
    ERR_SVR_MSG_INTERNAL_AUTH_FAILED            = 20002,  // 内部鉴权失败。
    ERR_SVR_MSG_INVALID_ID                      = 20003,  // Identifier 无效或者 Identifier 未导入云通信 IM。
    ERR_SVR_MSG_NET_ERROR                       = 20004,  // 网络异常，请重试。
    ERR_SVR_MSG_INTERNAL_ERROR1                 = 20005,  // 服务端内部错误，请重试。
    ERR_SVR_MSG_PUSH_DENY                       = 20006,  // 触发发送单聊消息之前回调，App 后台返回禁止下发该消息。
    ERR_SVR_MSG_IN_PEER_BLACKLIST               = 20007,  // 发送单聊消息，被对方拉黑，禁止发送。
    ERR_SVR_MSG_BOTH_NOT_FRIEND                 = 20009,  // 消息发送双方互相不是好友，禁止发送（配置单聊消息校验好友关系才会出现）。
    ERR_SVR_MSG_NOT_PEER_FRIEND                 = 20010,  // 发送单聊消息，自己不是对方的好友（单向关系），禁止发送。
    ERR_SVR_MSG_NOT_SELF_FRIEND                 = 20011,  // 发送单聊消息，对方不是自己的好友（单向关系），禁止发送。
    ERR_SVR_MSG_SHUTUP_DENY                     = 20012,  // 因禁言，禁止发送消息。
    ERR_SVR_MSG_REVOKE_TIME_LIMIT               = 20016,  // 消息撤回超过了时间限制（默认2分钟）。
    ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR       = 20018,  // 删除漫游内部错误。
    ERR_SVR_MSG_JSON_PARSE_FAILED               = 90001,  // JSON 格式解析失败，请检查请求包是否符合 JSON 规范。
    ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT        = 90002,  // JSON 格式请求包中 MsgBody 不符合消息格式描述，或者 MsgBody 不是 Array 类型，请参考 [TIMMsgElement 对象](https://cloud.tencent.com/document/product/269/2720#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0timmsgelement) 的定义。
    ERR_SVR_MSG_INVALID_TO_ACCOUNT              = 90003,  // JSON 格式请求包体中缺少 To_Account 字段或者 To_Account 字段不是 Integer 类型
    ERR_SVR_MSG_INVALID_RAND                    = 90005,  // JSON 格式请求包体中缺少 MsgRandom 字段或者 MsgRandom 字段不是 Integer 类型
    ERR_SVR_MSG_INVALID_TIMESTAMP               = 90006,  // JSON 格式请求包体中缺少 MsgTimeStamp 字段或者 MsgTimeStamp 字段不是 Integer 类型
    ERR_SVR_MSG_BODY_NOT_ARRAY                  = 90007,  // JSON 格式请求包体中 MsgBody 类型不是 Array 类型，请将其修改为 Array 类型
    ERR_SVR_MSG_ADMIN_REQUIRED                  = 90009,  // 请求需要 App 管理员权限。
    ERR_SVR_MSG_INVALID_JSON_FORMAT             = 90010,  // JSON 格式请求包不符合消息格式描述，请参考 [TIMMsgElement 对象](https://cloud.tencent.com/document/product/269/2720#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0timmsgelement) 的定义。
    ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT          = 90011,  // 批量发消息目标帐号超过500，请减少 To_Account 中目标帐号数量。
    ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND            = 90012,  // To_Account 没有注册或不存在，请确认 To_Account 是否导入云通信 IM 或者是否拼写错误。
    ERR_SVR_MSG_TIME_LIMIT                      = 90026,  // 消息离线存储时间错误（最多不能超过7天）。
    ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE        = 90031,  // JSON 格式请求包体中 SyncOtherMachine 字段不是 Integer 类型
    ERR_SVR_MSG_INVALID_MSGLIFETIME             = 90044,  // JSON 格式请求包体中 MsgLifeTime 字段不是 Integer 类型
    ERR_SVR_MSG_ACCOUNT_NOT_FOUND               = 90048,  // 请求的用户帐号不存在。
    ERR_SVR_MSG_INTERNAL_ERROR2                 = 90994,  // 服务内部错误，请重试。
    ERR_SVR_MSG_INTERNAL_ERROR3                 = 90995,  // 服务内部错误，请重试。
    ERR_SVR_MSG_INTERNAL_ERROR4                 = 91000,  // 服务内部错误，请重试。
    ERR_SVR_MSG_INTERNAL_ERROR5                 = 90992,  // 服务内部错误，请重试；如果所有请求都返回该错误码，且 App 配置了第三方回调，请检查 App 服务端是否正常向云通信 IM 后台服务端返回回调结果。
    ERR_SVR_MSG_BODY_SIZE_LIMIT                 = 93000,  // JSON 数据包超长，消息包体请不要超过8k。
    ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT         = 91101,  // Web 端长轮询被踢（Web 端同时在线实例个数超出限制）。
    // 120001 - 130000,  // 单聊第三方回调返回的自定义错误码。

    // 群组错误码

    ERR_SVR_GROUP_INTERNAL_ERROR                = 10002,  // 服务端内部错误，请重试。
    ERR_SVR_GROUP_API_NAME_ERROR                = 10003,  // 请求中的接口名称错误，请核对接口名称并重试。
    ERR_SVR_GROUP_INVALID_PARAMETERS            = 10004,  // 参数非法，请根据错误描述检查请求是否正确。
    ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT            = 10005,  // 请求包体中携带的帐号数量过多。
    ERR_SVR_GROUP_FREQ_LIMIT                    = 10006,  // 操作频率限制，请尝试降低调用的频率。
    ERR_SVR_GROUP_PERMISSION_DENY               = 10007,  // 操作权限不足，比如 Public 群组中普通成员尝试执行踢人操作，但只有 App 管理员才有权限。
    ERR_SVR_GROUP_INVALID_REQ                   = 10008,  // 请求非法，可能是请求中携带的签名信息验证不正确，请再次尝试或 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 联系技术客服。
    ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT          = 10009,  // 该群不允许群主主动退出。
    ERR_SVR_GROUP_NOT_FOUND                     = 10010,  // 群组不存在，或者曾经存在过，但是目前已经被解散。
    ERR_SVR_GROUP_JSON_PARSE_FAILED             = 10011,  // 解析 JSON 包体失败，请检查包体的格式是否符合 JSON 格式。
    ERR_SVR_GROUP_INVALID_ID                    = 10012,  // 发起操作的 Identifier 非法，请检查发起操作的用户 Identifier 是否填写正确。
    ERR_SVR_GROUP_ALLREADY_MEMBER               = 10013,  // 被邀请加入的用户已经是群成员。
    ERR_SVR_GROUP_FULL_MEMBER_COUNT             = 10014,  // 群已满员，无法将请求中的用户加入群组，如果是批量加人，可以尝试减少加入用户的数量。
    ERR_SVR_GROUP_INVALID_GROUPID               = 10015,  // 群组 ID 非法，请检查群组 ID 是否填写正确。
    ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY        = 10016,  // App 后台通过第三方回调拒绝本次操作。
    ERR_SVR_GROUP_SHUTUP_DENY                   = 10017,  // 因被禁言而不能发送消息，请检查发送者是否被设置禁言。
    ERR_SVR_GROUP_RSP_SIZE_LIMIT                = 10018,  // 应答包长度超过最大包长（1MB），请求的内容过多，请尝试减少单次请求的数据量。
    ERR_SVR_GROUP_ACCOUNT_NOT_FOUND             = 10019,  // 请求的用户帐号不存在。
    ERR_SVR_GROUP_GROUPID_IN_USED               = 10021,  // 群组 ID 已被使用，请选择其他的群组 ID。
    ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT           = 10023,  // 发消息的频率超限，请延长两次发消息时间的间隔。
    ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED   = 10024,  // 此邀请或者申请请求已经被处理。
    ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER     = 10025,  // 群组 ID 已被使用，并且操作者为群主，可以直接使用。
    ERR_SVR_GROUP_SDKAPPID_DENY                 = 10026,  // 该 SDKAppID 请求的命令字已被禁用，请 [提交工单](https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=0&data_title=%E4%BA%91%E9%80%9A%E4%BF%A1%20%20IM&step=1) 联系客服。
    ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND          = 10030,  // 请求撤回的消息不存在。
    ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT         = 10031,  // 消息撤回超过了时间限制（默认2分钟）。
    ERR_SVR_GROUP_REVOKE_MSG_DENY               = 10032,  // 请求撤回的消息不支持撤回操作。
    ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG          = 10033,  // 群组类型不支持消息撤回操作。
    ERR_SVR_GROUP_REMOVE_MSG_DENY               = 10034,  // 该消息类型不支持删除操作。
    ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG          = 10035,  // 音视频聊天室和在线成员广播大群不支持删除消息。
    ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT        = 10036,  // 音视频聊天室创建数量超过了限制，请参考 [价格说明](https://cloud.tencent.com/document/product/269/11673) 购买预付费套餐“IM音视频聊天室”。
    ERR_SVR_GROUP_COUNT_LIMIT                   = 10037,  // 单个用户可创建和加入的群组数量超过了限制，请参考 [价格说明](https://cloud.tencent.com/document/product/269/11673) 购买或升级预付费套餐“单人可创建与加入群组数”。
    ERR_SVR_GROUP_MEMBER_COUNT_LIMIT            = 10038,  // 群成员数量超过限制，请参考 [价格说明](https://cloud.tencent.com/document/product/269/11673) 购买或升级预付费套餐“扩展群人数上限”。
    ERR_SVR_GROUP_ATTRIBUTE_WRITE_CONFILCT      = 10056,  // 群属性写冲突，请先拉取最新的群属性后再尝试写操作，IMSDK  5.6 及其以上版本支持。

    // ///////////////////////////////////////////////////////////////////////////////
    //
    // （三）IM SDK V3 版本的错误码
    //
    // ///////////////////////////////////////////////////////////////////////////////

    ERR_NO_SUCC_RESULT                          = 6003,   // 批量操作无成功结果。
    ERR_TO_USER_INVALID                         = 6011,   // 无效接收方。
    ERR_REQUEST_TIMEOUT                         = 6012,   // 请求超时。
    ERR_INIT_CORE_FAIL                          = 6018,   // INIT CORE 模块失败。
    ERR_EXPIRED_SESSION_NODE                    = 6020,   // SessionNode 为 null 。
    ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED        = 6023,   // 在登录完成前进行了登出（在登录时返回）。
    ERR_TLSSDK_NOT_INITIALIZED                  = 6024,   // TLS SDK 未初始化。
    ERR_TLSSDK_USER_NOT_FOUND                   = 6025,   // TLS SDK 没有找到相应的用户信息。
    ERR_BIND_FAIL_UNKNOWN                       = 6100,   // QALSDK 未知原因BIND失败。
    ERR_BIND_FAIL_NO_SSOTICKET                  = 6101,   // 缺少 SSO 票据。
    ERR_BIND_FAIL_REPEATD_BIND                  = 6102,   // 重复 BIND。
    ERR_BIND_FAIL_TINYID_NULL                   = 6103,   // TinyId 为空。
    ERR_BIND_FAIL_GUID_NULL                     = 6104,   // GUID 为空。
    ERR_BIND_FAIL_UNPACK_REGPACK_FAILED         = 6105,   // 解注册包失败。
    ERR_BIND_FAIL_REG_TIMEOUT                   = 6106,   // 注册超时。
    ERR_BIND_FAIL_ISBINDING                     = 6107,   // 正在 BIND 操作中。
    ERR_PACKET_FAIL_UNKNOWN                     = 6120,   // 发包未知错误。
    ERR_PACKET_FAIL_REQ_NO_NET                  = 6121,   // 发送请求包时没有网络。
    ERR_PACKET_FAIL_RESP_NO_NET                 = 6122,   // 发送回复包时没有网络。
    ERR_PACKET_FAIL_REQ_NO_AUTH                 = 6123,   // 发送请求包时没有权限。
    ERR_PACKET_FAIL_SSO_ERR                     = 6124,   // SSO 错误。
    ERR_PACKET_FAIL_REQ_TIMEOUT                 = 6125,   // 请求超时。
    ERR_PACKET_FAIL_RESP_TIMEOUT                = 6126,   // 回复超时。
    ERR_PACKET_FAIL_REQ_ON_RESEND               = 6127,   // 重发失败。
    ERR_PACKET_FAIL_RESP_NO_RESEND              = 6128,   // 重发时没有真正发送。
    ERR_PACKET_FAIL_FLOW_SAVE_FILTERED          = 6129,   // 保存被过滤。
    ERR_PACKET_FAIL_REQ_OVER_LOAD               = 6130,   // 发送过载。
    ERR_PACKET_FAIL_LOGIC_ERR                   = 6131,   // 数据逻辑错误。
    ERR_FRIENDSHIP_PROXY_NOT_SYNCED             = 6150,   // proxy_manager 没有完成服务端数据同步。
    ERR_FRIENDSHIP_PROXY_SYNCING                = 6151,   // proxy_manager 正在进行服务端数据同步。
    ERR_FRIENDSHIP_PROXY_SYNCED_FAIL            = 6152,   // proxy_manager 同步失败。
    ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR        = 6153,   // proxy_manager 请求参数，在本地检查不合法。
    ERR_GROUP_INVALID_FIELD                     = 6160,   // Group assistant 请求字段中包含非预设字段。
    ERR_GROUP_STORAGE_DISABLED                  = 6161,   // Group assistant 群资料本地存储没有开启。
    ERR_LOADGRPINFO_FAILED                      = 6162,   // 加载群资料失败。
    ERR_REQ_NO_NET_ON_REQ                       = 6200,   // 请求的时候没有网络。
    ERR_REQ_NO_NET_ON_RSP                       = 6201,   // 响应的时候没有网络。
    ERR_SERIVCE_NOT_READY                       = 6205,   // QALSDK 服务未就绪。
    ERR_LOGIN_AUTH_FAILED                       = 6207,   // 账号认证失败（ TinyId 转换失败）。
    ERR_NEVER_CONNECT_AFTER_LAUNCH              = 6209,   // 在应用启动后没有尝试联网。
    ERR_REQ_FAILED                              = 6210,   // QALSDK 执行失败。
    ERR_REQ_INVALID_REQ                         = 6211,   // 请求非法，toMsgService 非法。
    ERR_REQ_OVERLOADED                          = 6212,   // 请求队列满。
    ERR_REQ_KICK_OFF                            = 6213,   // 已经被其他终端踢了。
    ERR_REQ_SERVICE_SUSPEND                     = 6214,   // 服务被暂停。
    ERR_REQ_INVALID_SIGN                        = 6215,   // SSO 签名错误。
    ERR_REQ_INVALID_COOKIE                      = 6216,   // SSO cookie 无效。
    ERR_LOGIN_TLS_RSP_PARSE_FAILED              = 6217,   // 登录时 TLS SDK 回包校验，包体长度错误。
    ERR_LOGIN_OPENMSG_TIMEOUT                   = 6218,   // 登录时 OPENSTATSVC 向 OPENMSG 上报状态超时。
    ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED          = 6219,   // 登录时 OPENSTATSVC 向 OPENMSG 上报状态时解析回包失败。
    ERR_LOGIN_TLS_DECRYPT_FAILED                = 6220,   // 登录时 TLS SDK 解密失败。
    ERR_WIFI_NEED_AUTH                          = 6221,   // WIFI 需要认证。
    ERR_USER_CANCELED                           = 6222,   // 用户已取消。
    ERR_REVOKE_TIME_LIMIT_EXCEED                = 6223,   // 消息撤回超过了时间限制（默认2分钟）。
    ERR_LACK_UGC_EXT                            = 6224,   // 缺少 UGC 扩展包。
    ERR_AUTOLOGIN_NEED_USERSIG                  = 6226,   // 自动登录，本地票据过期，需要 UserSig 手动登录。
    ERR_QAL_NO_SHORT_CONN_AVAILABLE             = 6300,   // 没有可用的短连接 SSO 。
    ERR_REQ_CONTENT_ATTACK                      = 80101,  // 消息内容安全打击。
    ERR_LOGIN_SIG_EXPIRE                        = 70101,  // 登录返回，票据过期。
    ERR_SDK_HAD_INITIALIZED                     = 90101,  // IM SDK 已经初始化无需重复初始化。
    ERR_OPENBDH_BASE                            = 115000, // OpenBDH 错误码基。
    ERR_REQUEST_NO_NET_ONREQ                    = 6250,   // 请求时没有网络，请等网络恢复后重试。
    ERR_REQUEST_NO_NET_ONRSP                    = 6251,   // 响应时没有网络，请等网络恢复后重试。
    ERR_REQUEST_FAILED                          = 6252,   // QALSDK 执行失败。
    ERR_REQUEST_INVALID_REQ                     = 6253,   // 请求非法，toMsgService 非法。
    ERR_REQUEST_OVERLOADED                      = 6254,   // 请求队列満。
    ERR_REQUEST_KICK_OFF                        = 6255,   // 已经被其他终端踢了。
    ERR_REQUEST_SERVICE_SUSPEND                 = 6256,   // 服务被暂停。
    ERR_REQUEST_INVALID_SIGN                    = 6257,   // SSO 签名错误。
    ERR_REQUEST_INVALID_COOKIE                  = 6258,   // SSO cookie 无效。
};


/// @name 常用宏和基础配置选项
/// @{
/**
* @brief 调用接口的返回值
*
* @note
* 若接口参数中有回调，只有当接口返回TIM_SUCC时，回调才会被调用
*/
enum TIMResult {
    TIM_SUCC = 0,          // 接口调用成功
    TIM_ERR_SDKUNINIT = -1,// 接口调用失败，ImSDK未初始化
    TIM_ERR_NOTLOGIN = -2, // 接口调用失败，用户未登录
    TIM_ERR_JSON = -3,     // 接口调用失败，错误的Json格式或Json Key
    TIM_ERR_PARAM = -4,    // 接口调用失败，参数错误
    TIM_ERR_CONV = -5,     // 接口调用失败，无效的会话
    TIM_ERR_GROUP = -6,    // 接口调用失败，无效的群组
};

/**
* @brief 日志级别
*/
enum TIMLogLevel {
    kTIMLog_Off,     // 关闭日志输出
    kTIMLog_Test,    // 全量日志
    kTIMLog_Verbose, // 开发调试过程中一些详细信息日志
    kTIMLog_Debug,   // 调试日志
    kTIMLog_Info,    // 信息日志
    kTIMLog_Warn,    // 警告日志
    kTIMLog_Error,   // 错误日志
    kTIMLog_Assert,  // 断言日志
};

/**
* @brief 登陆状态
*/
enum TIMLoginStatus {
    kTIMLoginStatus_Logined = 1,     // 已登录
    kTIMLoginStatus_Logining = 2,    // 登录中
    kTIMLoginStatus_UnLogined = 3,   // 未登录
    kTIMLoginStatus_Logouting = 4,   // 登出中
};

/**
* @brief 连接事件类型
*/
enum TIMNetworkStatus {
    kTIMConnected,       // 已连接
    kTIMDisconnected,    // 失去连接
    kTIMConnecting,      // 正在连接
    kTIMConnectFailed,   // 连接失败
};

/**
* @brief 会话事件类型
*/
enum TIMConvEvent {
    kTIMConvEvent_Add,    // 会话新增,例如收到一条新消息,产生一个新的会话是事件触发
    kTIMConvEvent_Del,    // 会话删除,例如自己删除某会话时会触发
    kTIMConvEvent_Update, // 会话更新,会话内消息的未读计数变化和收到新消息时触发
    kTIMConvEvent_Start,  // 会话开始
    kTIMConvEvent_Finish, // 会话结束

};

/**
* @brief 会话类型
*/
enum TIMConvType {
    kTIMConv_Invalid, // 无效会话
    kTIMConv_C2C,     // 个人会话
    kTIMConv_Group,   // 群组会话
    kTIMConv_System,  // 系统会话
};

/**
* @brief 平台信息
*/
enum TIMPlatform {
    kTIMPlatform_Other = 0,      // 未知平台
    kTIMPlatform_Windows,        // Windows平台
    kTIMPlatform_Android,        // Android平台
    kTIMPlatform_IOS,            // iOS平台
    kTIMPlatform_Mac,            // MacOS平台
    kTIMPlatform_Simulator,      // iOS模拟器平台
};

/**
* @brief 初始化ImSDK的配置
*/
// Struct SdKConfig JsonKey
static const char* kTIMSdkConfigConfigFilePath     = "sdk_config_config_file_path";// string, 只写(选填), 配置文件路径,默认路径为"/"
static const char* kTIMSdkConfigLogFilePath        = "sdk_config_log_file_path";   // string, 只写(选填), 日志文件路径,默认路径为"/"
static const char* kTIMSdkConfigJavaVM             = "sdk_config_java_vm";         // uint64, 只写(选填), 配置Android平台的Java虚拟机指针
// EndStruct


/**
* @brief 群组成员信息标识
*/
enum TIMGroupMemberInfoFlag {
    kTIMGroupMemberInfoFlag_None         = 0x00,       // 无
    kTIMGroupMemberInfoFlag_JoinTime     = 0x01,       // 加入时间
    kTIMGroupMemberInfoFlag_MsgFlag      = 0x01 << 1,  // 群消息接收选项
    kTIMGroupMemberInfoFlag_MsgSeq       = 0x01 << 2,  // 成员已读消息seq
    kTIMGroupMemberInfoFlag_MemberRole   = 0x01 << 3,  // 成员角色
    kTIMGroupMemberInfoFlag_ShutupUntill = 0x01 << 4,  // 禁言时间。当该值为0时表示没有被禁言
    kTIMGroupMemberInfoFlag_NameCard     = 0x01 << 5,  // 群名片
};

/**
* @brief 群组成员角色标识
*/
enum TIMGroupMemberRoleFlag {
    kTIMGroupMemberRoleFlag_All    = 0x00,       // 获取全部角色类型
    kTIMGroupMemberRoleFlag_Owner  = 0x01,       // 获取所有者(群主)
    kTIMGroupMemberRoleFlag_Admin  = 0x01 << 1,  // 获取管理员，不包括群主
    kTIMGroupMemberRoleFlag_Member = 0x01 << 2,  // 获取普通群成员，不包括群主和管理员
};

/**
* @brief 获取群组成员信息的选项
*/
// Struct GroupMemberGetInfoOption JsonKey
static const char* kTIMGroupMemberGetInfoOptionInfoFlag    = "group_member_get_info_option_info_flag";     // uint64 [TIMGroupMemberInfoFlag](), 读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
static const char* kTIMGroupMemberGetInfoOptionRoleFlag    = "group_member_get_info_option_role_flag";     // uint64 [TIMGroupMemberRoleFlag](), 读写(选填), 根据成员角色过滤，默认值为kTIMGroupMemberRoleFlag_All，获取所有角色
static const char* kTIMGroupMemberGetInfoOptionCustomArray = "group_member_get_info_option_custom_array";  // array string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct


/**
* @brief 群组成员信息标识
*/
enum TIMGroupGetInfoFlag {
    kTIMGroupInfoFlag_None         = 0x00,
    kTIMGroupInfoFlag_Name         = 0x01,       // 群组名称
    kTIMGroupInfoFlag_CreateTime   = 0x01 << 1,  // 群组创建时间
    kTIMGroupInfoFlag_OwnerUin     = 0x01 << 2,  // 群组创建者帐号
    kTIMGroupInfoFlag_Seq          = 0x01 << 3,   
    kTIMGroupInfoFlag_LastTime     = 0x01 << 4,  // 群组信息最后修改时间
    kTIMGroupInfoFlag_NextMsgSeq   = 0x01 << 5,  
    kTIMGroupInfoFlag_LastMsgTime  = 0X01 << 6,  // 最新群组消息时间
    kTIMGroupInfoFlag_AppId        = 0x01 << 7,
    kTIMGroupInfoFlag_MemberNum    = 0x01 << 8,  // 群组成员数量
    kTIMGroupInfoFlag_MaxMemberNum = 0x01 << 9,  // 群组成员最大数量
    kTIMGroupInfoFlag_Notification = 0x01 << 10, // 群公告内容
    kTIMGroupInfoFlag_Introduction = 0x01 << 11, // 群简介内容
    kTIMGroupInfoFlag_FaceUrl      = 0x01 << 12, // 群头像URL
    kTIMGroupInfoFlag_AddOpton     = 0x01 << 13, // 加群选项
    kTIMGroupInfoFlag_GroupType    = 0x01 << 14, // 群类型
    kTIMGroupInfoFlag_LastMsg      = 0x01 << 15, // 群组内最新一条消息
    kTIMGroupInfoFlag_OnlineNum    = 0x01 << 16, // 群组在线成员数
    kTIMGroupInfoFlag_Visible      = 0x01 << 17, // 群组是否可见
    kTIMGroupInfoFlag_Searchable   = 0x01 << 18, // 群组是否可以搜索
    kTIMGroupInfoFlag_ShutupAll    = 0x01 << 19, // 群组是否全禁言
};

/**
* @brief 获取群组信息的选项
*/
// Struct GroupGetInfoOption JsonKey
static const char* kTIMGroupGetInfoOptionInfoFlag    = "group_get_info_option_info_flag";     // uint64 [TIMGroupGetInfoFlag](), 读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
static const char* kTIMGroupGetInfoOptionCustomArray = "group_get_info_option_custom_array";  // array string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 用于配置信息
*/
// Struct UserConfig JsonKey
static const char* kTIMUserConfigIsReadReceipt            = "user_config_is_read_receipt";             // bool, 只写(选填), true表示要收已读回执事件
static const char* kTIMUserConfigIsSyncReport             = "user_config_is_sync_report";              // bool, 只写(选填), true表示服务端要删掉已读状态
static const char* kTIMUserConfigIsIngoreGroupTipsUnRead  = "user_config_is_ingore_grouptips_unread";  // bool, 只写(选填), true表示群tips不计入群消息已读计数
static const char* kTIMUserConfigIsDisableStorage         = "user_config_is_is_disable_storage";       // bool, 只写(选填), 是否禁用本地数据库，true表示禁用，false表示不禁用。默认是false
static const char* kTIMUserConfigGroupGetInfoOption       = "user_config_group_getinfo_option";        // object [GroupGetInfoOption](),  只写(选填),获取群组信息默认选项
static const char* kTIMUserConfigGroupMemberGetInfoOption = "user_config_group_member_getinfo_option"; // object [GroupMemberGetInfoOption](),  只写(选填),获取群组成员信息默认选项
// EndStruct

/**
* @brief HTTP代理信息
*/
// Struct HttpProxyInfo JsonKey
static const char* kTIMHttpProxyInfoIp       = "http_proxy_info_ip";       // string, 只写(必填), 代理的IP
static const char* kTIMHttpProxyInfoPort     = "http_proxy_info_port";     // int,    只写(必填), 代理的端口
static const char* kTIMHttpProxyInfoUserName = "http_proxy_info_username"; // string, 只写(选填), 认证的用户名
static const char* kTIMHttpProxyInfoPassword = "http_proxy_info_password"; // string, 只写(选填), 认证的密码
// EndStruct

/**
* @brief SOCKS5代理信息
*/
// Struct Socks5ProxyInfo JsonKey
static const char* kTIMSocks5ProxyInfoIp       = "socks5_proxy_info_ip";       // string, 只写(必填), socks5代理的IP
static const char* kTIMSocks5ProxyInfoPort     = "socks5_proxy_info_port";     // int,    只写(必填), socks5代理的端口
static const char* kTIMSocks5ProxyInfoUserName = "socks5_proxy_info_username"; // string, 只写(选填), 认证的用户名
static const char* kTIMSocks5ProxyInfoPassword = "socks5_proxy_info_password"; // string, 只写(选填), 认证的密码
// EndStruct

/**
* @brief 更新配置
* > 自定义数据
* + 开发者可以自定义的数据(长度限制为64个字节)，ImSDK只负责透传给即时通信IM后台后，可以通过第三方回调[状态变更回调](https://cloud.tencent.com/document/product/269/2570)告知开发者业务后台。
* > HTTP代理
* + HTTP代理主要用在发送图片、语音、文件、微视频等消息时，将相关文件上传到COS，以及接收到图片、语音、文件、微视频等消息，将相关文件下载到本地时用到。
*   设置时，设置的IP不能为空，端口不能为0(0端口不可用).如果需要取消HTTP代理，只需将代理的IP设置为空字符串，端口设置为0
* > SOCKS5代理
* + SOCKS5代理需要在初始化之前设置。设置之后ImSDK发送的所有协议会通过SOCKS5代理服务器发送的即时通信IM后台。
*/
// Struct SetConfig JsonKey
static const char* kTIMSetConfigLogLevel             = "set_config_log_level";                // uint [TIMLogLevel](),  只写(选填), 输出到日志文件的日志级别
static const char* kTIMSetConfigCackBackLogLevel     = "set_config_callback_log_level";       // uint [TIMLogLevel](),  只写(选填), 日志回调的日志级别 
static const char* kTIMSetConfigIsLogOutputConsole   = "set_config_is_log_output_console";    // bool,                  只写(选填), 是否输出到控制台，默认为 true
static const char* kTIMSetConfigUserConfig           = "set_config_user_config";              // object [UserConfig](), 只写(选填), 用户配置
static const char* kTIMSetConfigUserDefineData       = "set_config_user_define_data";         // string,                只写(选填), 自定义数据，如果需要，初始化前设置
static const char* kTIMSetConfigHttpProxyInfo        = "set_config_http_proxy_info";          // object [HttpProxyInfo](),  只写(选填), 设置HTTP代理，如果需要，在发送图片、文件、语音、视频前设置
static const char* kTIMSetConfigSocks5ProxyInfo      = "set_config_socks5_proxy_info";        // object [Socks5ProxyInfo](), 只写(选填), 设置SOCKS5代理，如果需要，初始化前设置
static const char* kTIMSetConfigIsOnlyLocalDNSSource = "set_config_is_only_local_dns_source"; // bool,                  只写(选填), 如果为true，SDK内部会在选择最优IP时只使用LocalDNS
// EndStruct

/**
 * @brief 实验性接口的操作类型
 */
//  Struct TIMInternalOperation JsonValue
static const char* kTIMInternalOperationSSOData          = "internal_operation_sso_data";
static const char* kTIMInternalOperationUserId2TinyId    = "internal_operation_userid_tinyid";
static const char* kTIMInternalOperationTinyId2UserId    = "internal_operation_tinyid_userid";
static const char* kTIMInternalOperationSetEnv           = "internal_operation_set_env";
static const char* kTIMInternalOperationSetMaxRetryCount = "internal_operation_set_max_retry_count";
static const char* kTIMInternalOperationSetCustomServerInfo = "internal_operation_set_custom_server_info";
static const char* kTIMInternalOperationSetSM4GCMCallback = "internal_operation_set_sm4_gcm_callback";
static const char* kTIMInternalOperationInitLocalStorage = "internal_operation_init_local_storage";
static const char* kTIMInternalOperationSetCosSaveRegionForConversation = "internal_operation_set_cos_save_region_for_conversation";
static const char* kTIMInternalOperationSetUIPlatform = "internal_operation_set_ui_platform";
// EndStruct

/**
 * @brief 发送sso data 的参数
 */
// Struct SSODataParam JsonKey
static const char* kTIMSSODataParamCmd     = "sso_data_param_cmd";     // string, 只写(必填), sso请求的命令字
static const char* kTIMSSODataParamBody    = "sso_data_param_body";    // string, 只写(必填), sso请求的内容，内容是二进制，需要外部传入base64编码后的字符串，sdk内部回解码成原二进制
static const char* kTIMSSODataParamTimeout = "sso_data_param_timeout"; // uint64, 只写(选填), sso请求的超时时间，默认是15秒
// EndStruct

/**
 * @brief  发送sso data的返回信息
 */
// Struct SSODataRes JsonKey
static const char* kTIMSSODataResCmd    = "sso_data_res_cmd";     // string, 只读(必填), sso返回数据对应请求的命令字
static const char* kTIMSSODataResBody   = "sso_data_res_body";    // string, 只读(必填), sso返回的内容，内容是二进制，sdk内部使用base64编码了，外部使用前需要base64解码
// EndStruct

/**
 * @brief  用户的id信息
 */
// Struct UserInfo JsonKey
static const char* kTIMUserInfoUserId = "user_info_userid";
static const char* kTIMUserInfoTinyId = "user_info_tinyid";
// EndStruct

/**
* @brief 服务器地址
*/
// Struct ServerAddress JsonKey
static const char* kTIMServerAddressIp = "server_address_ip";                      // string, 只写(必填), 服务器 IP
static const char* kTIMServerAddressPort = "server_address_port";                  // int,    只写(必填), 服务器端口
static const char* kTIMServerAddressIsIPv6 = "server_address_is_ipv6";             // bool,   只写(选填), 是否 IPv6 地址，默认为 false
// EndStruct

/**
* @brief 自定义服务器信息
*/
// Struct CustomServerInfo JsonKey
static const char* kTIMCustomServerInfoLongConnectionAddressArray = "longconnection_address_array"; // array [ServerAddress](), 只写(必填), 长连接服务器地址列表
static const char* kTIMCustomServerInfoShortConnectionAddressArray = "shortconnection_address_array"; // array [ServerAddress](), 只写(选填), 短连接服务器地址列表
static const char* kTIMCustomServerInfoServerPublicKey = "server_public_key";       // string, 只写(必填), 服务器公钥
// EndStruct

/**
* @brief 国密 SM4 GCM 回调函数地址的参数
*/
// Struct SM4GCMCallbackParam JsonKey
static const char* kTIMSM4GCMCallbackParamEncrypt = "sm4_gcm_callback_param_encrypt"; // uint64 只写(必填), SM4 GCM 加密回调函数地址
static const char* kTIMSM4GCMCallbackParamDecrypt = "sm4_gcm_callback_param_decrypt"; // uint64, 只写(必填), SM4 GCM 解密回调函数地址
// EndStruct


/**
* @brief 设置 cos 存储区域
*/
// Struct CosSaveRegionForConversationParam JsonKey
static const char* kTIMCosSaveRegionForConversationParamConversationID = "cos_save_region_for_conversation_param_conversation_id"; // string, 只写(必填), 会话 ID
static const char* kTIMCosSaveRegionForConversationParamCosSaveRegion = "cos_save_region_for_conversation_param_cos_save_region"; // string, 只写(必填), 存储区域
// EndStruct

/**
 * @brief callExperimentalAPI接口请求的参数
 */
// Struct ReqeustParam JsonKey
static const char* kTIMRequestInternalOperation  = "request_internal_operation";  // string [TIMInternalOperation](), 只写(必填), 内部接口的操作类型
static const char* kTIMRequestSSODataParam       = "request_sso_data_param";      // object [SSODataParam](), 只写(选填), sso发包请求, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSSOData 时需要设置
static const char* kTIMRequestUserId2TinyIdParam = "request_userid_tinyid_param"; // array string, 只写(选填), 请求需要转换成tinyid的userid列表, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationUserId2TinyId 时需要设置
static const char* kTIMRequestTinyId2UserIdParam = "request_tinyid_userid_param"; // array uint64, 只写(选填), 请求需要转换成userid的tinyid列表, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationTinyId2UserId 时需要设置
static const char* kTIMRequestSetEnvParam        = "request_set_env_param";       // bool, 只写(选填), true 表示设置当前环境为测试环境，false表示设置当前环境是正式环境，默认是正式环境, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetEnv 时需要设置
static const char* kTIMRequestSetMaxRetryCountParam = "request_set_max_retry_count_param"; // uint32, 只写(选填), 设置登录、发消息的重试次数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetMaxRetryCount 时需要设置
static const char* kTIMRequestSetCustomServerInfoParam = "request_set_custom_server_info_param"; // object [CustomServerInfo](), 只写(选填), 自定义服务器信息, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetCustomServerInfo 时需要设置
static const char* kTIMRequestSetSM4GCMCallbackParam = "request_set_sm4_gcm_callback_param"; // object [SM4GCMCallbackParam](), 只写(选填), 国密 SM4 GCM 回调函数地址的参数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetSM4GCMCallback 时需要设置
static const char* kTIMRequestInitLocalStorageParam = "request_init_local_storage_user_id_param"; // string, 只写(选填), 初始化 Database 的用户 ID, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationInitLocalStorage 时需要设置
static const char* kTIMRequestSetCosSaveRegionForConversationParam = "request_set_cos_save_region_for_conversation_param"; // object [CosSaveRegionForConversationParam](), 只写(选填), 设置 cos 存储区域的参数, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetCosSaveRegionForConversation 时需要设置
static const char* kTIMRequestSetUIPlatformParam = "request_set_ui_platform_param"; // string, 只写(选填), 设置 UI 平台，当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetUIPlatform 时需要设置
// EndStruct


/**
 * @brief callExperimentalAPI接口回调返回的数据
 */
// Struct ReponseInfo JsonKey
static const char* kTIMResponseInternalOperation = "response_internal_operation"; // string [TIMInternalOperation](), 只读(必填), 响应的内部操作
static const char* kTIMResponseSSODataRes        = "response_sso_data_res";       // object [SSODataRes](), 只读(选填), sso发包请求的响应, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationSSOData 时有值
static const char* kTIMResponseUserId2TinyIdRes  = "response_userid_tinyid_res";  // array [UserInfo](), 只读(选填), 响应的tinyid列表, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationUserId2TinyId 时有值
static const char* kTIMResponseTinyId2UserIdRes  = "response_tinyid_userid_res";  // array [UserInfo](), 只读(选填), 响应的tinyid列表, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationTinyId2UserId 时有值
static const char* kTIMResponseSetEvnRes         = "response_set_env_res";        // bool, 只读(选填), true 表示当前环境为测试环境，false表示当前环境是正式环境, 当 kTIMResponseInternalOperation 为 kTIMInternalOperationSetEnv 时有值
// EndStruct

/// @}

/// @name 消息关键类型
/// @brief 消息相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 消息在iOS系统上的离线推送配置
*/
// Struct IOSOfflinePushConfig JsonKey
static const char* kTIMIOSOfflinePushConfigTitle       = "ios_offline_push_config_title";         //string, 读写, 通知标题
static const char* kTIMIOSOfflinePushConfigSound       = "ios_offline_push_config_sound";         //string, 读写, 当前消息在iOS设备上的离线推送提示声音URL。当设置为push.no_sound时表示无提示音无振动
static const char* kTIMIOSOfflinePushConfigIgnoreBadge = "ios_offline_push_config_ignore_badge";  //bool, 读写, 是否忽略badge计数。若为true，在iOS接收端，这条消息不会使App的应用图标未读计数增加
// EndStruct

/**
* @brief Android离线推送模式
*/
enum TIMAndroidOfflinePushNotifyMode {
    kTIMAndroidOfflinePushNotifyMode_Normal,   // 普通通知栏消息模式，离线消息下发后，点击通知栏消息直接启动应用，不会给应用进行回调
    kTIMAndroidOfflinePushNotifyMode_Custom,   // 自定义消息模式，离线消息下发后，点击通知栏消息会给应用进行回调
};

/**
* @brief 消息在Android系统上的离线推送配置
*
* @note ChannelID的说明
* Android8.0系统以上通知栏消息增加了channelid的设置，目前oppo要求必须填写，否则在8.0及以上的OPPO手机上会收不到离线推送消息。
* 后续可能会增加xiaomi_channel_id_，huawei_channel_id等。
*/
// Struct AndroidOfflinePushConfig JsonKey
static const char* kTIMAndroidOfflinePushConfigTitle         = "android_offline_push_config_title";            //string, 读写, 通知标题
static const char* kTIMAndroidOfflinePushConfigSound         = "android_offline_push_config_sound";            //string, 读写, 当前消息在Android设备上的离线推送提示声音URL
static const char* kTIMAndroidOfflinePushConfigNotifyMode    = "android_offline_push_config_notify_mode";      //uint [TIMAndroidOfflinePushNotifyMode](), 读写, 当前消息的通知模式
static const char* kTIMAndroidOfflinePushConfigOPPOChannelID = "android_offline_push_config_oppo_channel_id";  //string, 读写, OPPO的ChannelID
// EndStruct

/**
* @brief 推送规则
*/
enum TIMOfflinePushFlag {
    kTIMOfflinePushFlag_Default,   // 按照默认规则进行推送
    kTIMOfflinePushFlag_NoPush,    // 不进行推送
};

/**
* @brief 消息离线推送配置
*/
// Struct OfflinePushConfig JsonKey
static const char* kTIMOfflinePushConfigDesc          = "offline_push_config_desc";            //string, 读写, 当前消息在对方收到离线推送时候展示内容
static const char* kTIMOfflinePushConfigExt           = "offline_push_config_ext";             //string, 读写, 当前消息离线推送时的扩展字段
static const char* kTIMOfflinePushConfigFlag          = "offline_push_config_flag";            //uint [TIMOfflinePushFlag](), 读写, 当前消息是否允许推送，默认允许推送 kTIMOfflinePushFlag_Default
static const char* kTIMOfflinePushConfigIOSConfig     = "offline_push_config_ios_config";      //object [IOSOfflinePushConfig](), 读写, iOS离线推送配置
static const char* kTIMOfflinePushConfigAndroidConfig = "offline_push_config_android_config";  //object [AndroidOfflinePushConfig](), 读写, Android离线推送配置
// EndStruct

/**
* @brief 消息当前状态定义
*/
enum TIMMsgStatus {
    kTIMMsg_Sending = 1,        // 消息正在发送
    kTIMMsg_SendSucc = 2,       // 消息发送成功
    kTIMMsg_SendFail = 3,       // 消息发送失败
    kTIMMsg_Deleted = 4,        // 消息已删除
    kTIMMsg_LocalImported = 5,  // 消息导入状态
    kTIMMsg_Revoked = 6,        // 消息撤回状态
    kTIMMsg_Cancel = 7,         // 消息取消
};

/**
* @brief 标识消息的优先级，数字越大优先级越低
*/
enum TIMMsgPriority {
    kTIMMsgPriority_High,   // 优先级最高，一般为红包或者礼物消息
    kTIMMsgPriority_Normal, // 表示优先级次之，建议为普通消息
    kTIMMsgPriority_Low,    // 建议为点赞消息等
    kTIMMsgPriority_Lowest, // 优先级最低，一般为成员进退群通知(后台下发)
};

/// 在消息 kTIMMsgGroupAtUserArray 字段中填入 kMesssageAtALL 表示当前消息需要 @ 群里所有人
static const char* kImSDK_MesssageAtALL = "__kImSDK_MesssageAtALL__";

/**
* @brief 消息Json Keys
*
* @note 
* > 对应Elem的顺序
* + 目前文件和语音Elem不一定会按照添加顺序传输，其他Elem按照顺序，不过建议不要过于依赖Elem顺序进行处理，应该逐个按照Elem类型处理，防止异常情况下进程Crash。
* > 针对群组的红包和点赞消息
* + 对于直播场景，会有点赞和发红包功能，点赞相对优先级较低，红包消息优先级较高，具体消息内容可以使用自定义消息[CustomElem]()进行定义，发送消息时，可通过 kTIMMsgPriority 定义消息优先级。
* > 阅后即焚消息
* + 开发者通过设置 kTIMMsgIsOnlineMsg 字段为true时，表示发送阅后即焚消息,该消息有如下特性
* >>C2C会话,当此消息发送时，只有对方在线，对方才会收到。如果当时离线，后续再登录也收不到此消息。
* >>群会话,当此消息发送时，只有群里在线的成员才会收到。如果当时离线，后续再登录也收不到此消息。
* >>此消息服务器不会保存
* >>此消息不计入未读计数
* >>此消息在本地不会存储
* > 消息自定义字段
* + 开发者可以对消息增加自定义字段，如自定义整数(通过 kTIMMsgCustomInt 指定)、自定义二进制数据(通过 kTIMMsgCustomStr 指定，必须转换成String，Json不支持二进制传输)，可以根据这两个字段做出各种不同效果，例如语音消息是否已经播放等等。另外需要注意，此自定义字段仅存储于本地，不会同步到Server，更换终端获取不到。
*/
// Struct Message JsonKey
static const char* kTIMMsgElemArray   = "message_elem_array";    //array [Elem](), 读写(必填), 消息内元素列表
static const char* kTIMMsgConvId      = "message_conv_id";       //string,         读写(选填),       消息所属会话ID
static const char* kTIMMsgConvType    = "message_conv_type";     //uint [TIMConvType](), 读写(选填), 消息所属会话类型
static const char* kTIMMsgSender      = "message_sender";        //string,         读写(选填),       消息的发送者
static const char* kTIMMsgPriority    = "message_priority";      //uint [TIMMsgPriority](), 读写(选填), 消息优先级
static const char* kTIMMsgClientTime  = "message_client_time";   //uint64,         读写(选填),       客户端时间
static const char* kTIMMsgServerTime  = "message_server_time";   //uint64,         读写(选填),       服务端时间
static const char* kTIMMsgIsFormSelf  = "message_is_from_self";  //bool,           读写(选填),       消息是否来自自己
static const char* kTIMMsgPlatform    = "message_platform";      //uint, [TIMPlatform](), 读写(选填), 发送消息的平台
static const char* kTIMMsgIsRead      = "message_is_read";       //bool,           读写(选填),       消息是否已读
static const char* kTIMMsgIsOnlineMsg = "message_is_online_msg"; //bool,           读写(选填),       消息是否是在线消息，false表示普通消息,true表示阅后即焚消息，默认为false
static const char* kTIMMsgIsPeerRead  = "message_is_peer_read";  //bool,           只读,            消息是否被会话对方已读
static const char* kTIMMsgStatus      = "message_status";        //uint [TIMMsgStatus](), 读写(选填), 消息当前状态
static const char* kTIMMsgUniqueId    = "message_unique_id";     //uint64,         只读,       消息的唯一标识，推荐使用 kTIMMsgMsgId
static const char* kTIMMsgMsgId       = "message_msg_id";        //string,         只读,       消息的唯一标识
static const char* kTIMMsgRand        = "message_rand";          //uint64,         只读,       消息的随机码
static const char* kTIMMsgSeq         = "message_seq";           //uint64,         只读,       消息序列
static const char* kTIMMsgCustomInt   = "message_custom_int";    //uint32_t,       读写(选填), 自定义整数值字段（本地保存，不会发送到对端，程序卸载重装后失效）
static const char* kTIMMsgCustomStr   = "message_custom_str";    //string,         读写(选填), 自定义数据字段（本地保存，不会发送到对端，程序卸载重装后失效）
static const char* kTIMMsgCloudCustomStr = "message_cloud_custom_str"; //string, 读写(选填), 消息自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
static const char* kTIMMsgIsExcludedFromUnreadCount = "message_is_excluded_from_unread_count";  //bool, 读写(选填),  消息是否不计入未读计数：默认为 NO，表明需要计入未读计数，设置为 YES，表明不需要计入未读计数
static const char* kTIMMsgGroupAtUserArray = "message_group_at_user_array";            //array string, 读写(选填), 群消息中被 @ 的用户 UserID 列表（即该消息都 @ 了哪些人），如果需要 @ALL ，请传入 kImSDK_MesssageAtALL 字段
static const char* kTIMMsgIsForwardMessage = "message_is_forward_message";        //bool, 只写(选填), 如果需要转发一条消息，不能直接调用 sendMessage 接口发送原消息，原消息 kTIMMsgIsForwardMessage 设置为 true 再发送。
static const char* kTIMMsgSenderProfile         = "message_sender_profile";            //object [UserProfile](), 读写(选填), 消息的发送者的用户资料
static const char* kTIMMsgSenderGroupMemberInfo = "message_sender_group_member_info";  //object [GroupMemberInfo](), 读写(选填), 消息发送者在群里面的信息，只有在群会话有效。目前仅能获取字段 kTIMGroupMemberInfoIdentifier、kTIMGroupMemberInfoNameCard 其他的字段建议通过 TIMGroupGetMemberInfoList 接口获取
static const char* kTIMMsgOfflinePushConfig     = "message_offlie_push_config";        //object [OfflinePushConfig](), 读写(选填), 消息的离线推送设置
static const char* kTIMMsgExcludedFromLastMessage  = "message_excluded_from_last_message";        // bool 读写 是否作为会话的 lasgMessage，true - 不作为，false - 作为
// EndStruct

/**
* @brief 消息已读回执
*/
// Struct MessageReceipt JsonKey
static const char* kTIMMsgReceiptConvId    = "msg_receipt_conv_id";     //string, 只读, 会话ID
static const char* kTIMMsgReceiptConvType  = "msg_receipt_conv_type";   //uint [TIMConvType](), 只读, 会话类型
static const char* kTIMMsgReceiptTimeStamp = "msg_receipt_time_stamp";  //uint64, 只读, 时间戳
// EndStruct

/**
* @brief 元素的类型
*/
enum TIMElemType {
    kTIMElem_Text,           // 文本元素
    kTIMElem_Image,          // 图片元素
    kTIMElem_Sound,          // 声音元素
    kTIMElem_Custom,         // 自定义元素
    kTIMElem_File,           // 文件元素
    kTIMElem_GroupTips,      // 群组系统消息元素
    kTIMElem_Face,           // 表情元素
    kTIMElem_Location,       // 位置元素
    kTIMElem_GroupReport,    // 群组系统通知元素
    kTIMElem_Video,          // 视频元素
    kTIMElem_FriendChange,   // 关系链变更消息元素
    kTIMElem_ProfileChange,  // 资料变更消息元素
    kTIMElem_Merge,          // 合并消息元素
    kTIMElem_Invalid = -1,   // 未知元素类型
};

/**
* @brief 元素的类型
*/
// Struct Elem JsonKey
static const char* kTIMElemType         = "elem_type";    // uint [TIMElemType](), 读写(必填), 元素类型
// EndStruct

/**
* @brief 文本元素
*/
// Struct TextElem JsonKey
static const char* kTIMTextElemContent  = "text_elem_content"; // string, 读写(必填), 文本内容
// EndStruct

/**
* @brief 表情元素
*
* @note 
* ImSDK并不提供表情包，如果开发者有表情包，可使用 kTIMFaceElemIndex 存储表情在表情包中的索引，由用户自定义。
* 或者直接使用 kTIMFaceElemBuf 存储表情二进制信息(必须转换成String，Json不支持二进制传输)，由用户自定义，ImSDK内部只做透传。
*/
// Struct FaceElem JsonKey
static const char* kTIMFaceElemIndex          = "face_elem_index";  // int,    读写(必填), 表情索引
static const char* kTIMFaceElemBuf            = "face_elem_buf";    // string, 读写(选填), 其他额外数据,可由用户自定义填写。若要传输二进制，麻烦先转码成字符串。JSON只支持字符串
// EndStruct

/**
* @brief 位置元素
*/
// Struct LocationElem JsonKey
static const char* kTIMLocationElemDesc       = "location_elem_desc";          // string, 读写(选填), 位置描述
static const char* kTIMLocationElemLongitude  = "location_elem_longitude";     // double, 读写(必填), 经度
static const char* kTIMLocationElemlatitude   = "location_elem_latitude";      // double, 读写(必填), 纬度
// EndStruct


/**
* @brief 图片质量级别
*/
enum TIMImageLevel {
    kTIMImageLevel_Orig,        // 原图发送
    kTIMImageLevel_Compression, // 高压缩率图发送(图片较小,默认值)
    kTIMImageLevel_HD,          // 高清图发送(图片较大)
};

/**
* @brief 图片元素
*
* @note
* >  图片规格说明：每幅图片有三种规格，分别是Original（原图）、Large（大图）、Thumb（缩略图）。
* >> 原图：指用户发送的原始图片，尺寸和大小都保持不变。
* >> 大图：是将原图等比压缩，压缩后宽、高中较小的一个等于720像素。
* >> 缩略图：是将原图等比压缩，压缩后宽、高中较小的一个等于198像素
* >  如果原图尺寸就小于198像素，则三种规格都保持原始尺寸，不需压缩。
* >  如果原图尺寸在198-720之间，则大图和原图一样，不需压缩。
* >  在手机上展示图片时，建议优先展示缩略图，用户单击缩略图时再下载大图，单击大图时再下载原图。当然开发者也可以选择跳过大图，单击缩略图时直接下载原图。
* >  在Pad或PC上展示图片时，由于分辨率较大，且基本都是Wi-Fi或有线网络，建议直接显示大图，用户单击大图时再下载原图。
*/
// Struct ImageElem JsonKey
static const char* kTIMImageElemOrigPath        = "image_elem_orig_path";        // string, 读写(必填), 发送图片的路径
static const char* kTIMImageElemLevel           = "image_elem_level";            // uint[TIMImageLevel](), 读写(必填), 发送图片的质量级别
static const char* kTIMImageElemFormat          = "image_elem_format";           // int,    读写,       发送图片格式:，0xff:未知格式, 1：JPG, 2:GIF, 3:PNG, 4:BMP
static const char* kTIMImageElemOrigId          = "image_elem_orig_id";          // string, 只读,       原图 ID
static const char* kTIMImageElemOrigPicHeight   = "image_elem_orig_pic_height";  // int,    只读,       原图的图片高度
static const char* kTIMImageElemOrigPicWidth    = "image_elem_orig_pic_width";   // int,    只读,       原图的图片宽度
static const char* kTIMImageElemOrigPicSize     = "image_elem_orig_pic_size";    // int,    只读,       原图的图片大小
static const char* kTIMImageElemThumbId         = "image_elem_thumb_id";         // string, 只读,       缩略图 ID
static const char* kTIMImageElemThumbPicHeight  = "image_elem_thumb_pic_height"; // int,    只读,       缩略图的图片高度
static const char* kTIMImageElemThumbPicWidth   = "image_elem_thumb_pic_width";  // int,    只读,       缩略图的图片宽度
static const char* kTIMImageElemThumbPicSize    = "image_elem_thumb_pic_size";   // int,    只读,       缩略图的图片大小
static const char* kTIMImageElemLargeId         = "image_elem_large_id";         // string, 只读,       大图片uuid
static const char* kTIMImageElemLargePicHeight  = "image_elem_large_pic_height"; // int,    只读,       大图片的图片高度
static const char* kTIMImageElemLargePicWidth   = "image_elem_large_pic_width";  // int,    只读,       大图片的图片宽度
static const char* kTIMImageElemLargePicSize    = "image_elem_large_pic_size";   // int,    只读,       大图片的图片大小
static const char* kTIMImageElemOrigUrl         = "image_elem_orig_url";         // string, 只读,       原图URL
static const char* kTIMImageElemThumbUrl        = "image_elem_thumb_url";        // string, 只读,       缩略图URL
static const char* kTIMImageElemLargeUrl        = "image_elem_large_url";        // string, 只读,       大图片URL
static const char* kTIMImageElemTaskId          = "image_elem_task_id";          // int,    只读,       任务ID，废弃
// EndStruct

/**
* @brief 声音元素
*
* @note
* > 语音是否已经播放，可使用 消息自定义字段 实现，如定义一个字段值0表示未播放，1表示播放，当用户单击播放后可设置改字段的值为1
* > 一条消息只能添加一个声音元素，添加多个声音元素时，发送消息可能失败。
*/
// Struct SoundElem JsonKey
static const char* kTIMSoundElemFilePath        = "sound_elem_file_path";        // string, 读写(必填), 语音文件路径,需要开发者自己先保存语言然后指定路径
static const char* kTIMSoundElemFileSize        = "sound_elem_file_size";        // int,    读写(必填), 语言数据文件大小，以秒为单位
static const char* kTIMSoundElemFileTime        = "sound_elem_file_time";        // int,    读写(必填), 语音时长
static const char* kTIMSoundElemFileId          = "sound_elem_file_id";          // string, 只读,       语音 ID
static const char* kTIMSoundElemBusinessId      = "sound_elem_business_id";      // int,    只读,       下载时用到的businessID
static const char* kTIMSoundElemDownloadFlag    = "sound_elem_download_flag";    // int,    只读,       是否需要申请下载地址(0:需要申请，1:到cos申请，2:不需要申请,直接拿url下载)
static const char* kTIMSoundElemUrl             = "sound_elem_url";              // string, 只读,       下载的URL
static const char* kTIMSoundElemTaskId          = "sound_elem_task_id";          // int,    只读,       任务ID，废弃
// EndStruct

/**
* @brief 自定义元素
*
* @note
* 自定义消息是指当内置的消息类型无法满足特殊需求，开发者可以自定义消息格式，内容全部由开发者定义，ImSDK只负责透传。
*/
// Struct CustomElem JsonKey
static const char* kTIMCustomElemData   = "custom_elem_data";   // string,  读写, 数据,支持二进制数据
static const char* kTIMCustomElemDesc   = "custom_elem_desc";   // string,  读写, 自定义描述
static const char* kTIMCustomElemExt    = "custom_elem_ext";    // string,  读写, 后台推送对应的ext字段
static const char* kTIMCustomElemSound  = "custom_elem_sound";  // string,  读写, 自定义声音
// EndStruct

/**
* @brief 文件元素
*
* @note
* 一条消息只能添加一个文件元素，添加多个文件时，发送消息可能失败。
*/
// Struct FileElem JsonKey
static const char* kTIMFileElemFilePath      = "file_elem_file_path";      // string,   读写(必填), 文件所在路径（包含文件名）
static const char* kTIMFileElemFileName      = "file_elem_file_name";      // string,   读写(必填), 文件名，显示的名称。不设置该参数时，kTIMFileElemFileName默认为kTIMFileElemFilePath指定的文件路径中的文件名
static const char* kTIMFileElemFileSize      = "file_elem_file_size";      // int,      读写(必填), 文件大小
static const char* kTIMFileElemFileId        = "file_elem_file_id";        // string,   只读, 文件 ID
static const char* kTIMFileElemBusinessId    = "file_elem_business_id";    // int,      只读, 下载时用到的businessID
static const char* kTIMFileElemDownloadFlag  = "file_elem_download_flag";  // int,      只读, 文件下载flag
static const char* kTIMFileElemUrl           = "file_elem_url";            // string,   只读, 文件下载的URL
static const char* kTIMFileElemTaskId        = "file_elem_task_id";        // int,      只读, 任务ID，废弃
// EndStruct

/**
* @brief 视频元素
*/
// Struct VideoElem JsonKey
static const char* kTIMVideoElemVideoType          = "video_elem_video_type";           // string, 读写(必填), 视频文件类型，发送消息时进行设置
static const char* kTIMVideoElemVideoSize          = "video_elem_video_size";           // uint,   读写(必填), 视频文件大小
static const char* kTIMVideoElemVideoDuration      = "video_elem_video_duration";       // uint,   读写(必填), 视频时长，发送消息时进行设置
static const char* kTIMVideoElemVideoPath          = "video_elem_video_path";           // string, 读写(必填), 适配文件路径 
static const char* kTIMVideoElemVideoId            = "video_elem_video_id";             // string, 只读, 视频 ID
static const char* kTIMVideoElemBusinessId         = "video_elem_business_id";          // int,    只读, 下载时用到的businessID
static const char* kTIMVideoElemVideoDownloadFlag  = "video_elem_video_download_flag";  // int,    只读, 视频文件下载flag 
static const char* kTIMVideoElemVideoUrl           = "video_elem_video_url";            // string, 只读, 视频文件下载的URL 
static const char* kTIMVideoElemImageType          = "video_elem_image_type";           // string, 读写(必填), 截图文件类型，发送消息时进行设置
static const char* kTIMVideoElemImageSize          = "video_elem_image_size";           // uint,   读写(必填), 截图文件大小
static const char* kTIMVideoElemImageWidth         = "video_elem_image_width";          // uint,   读写(必填), 截图高度，发送消息时进行设置
static const char* kTIMVideoElemImageHeight        = "video_elem_image_height";         // uint,   读写(必填), 截图宽度，发送消息时进行设置
static const char* kTIMVideoElemImagePath          = "video_elem_image_path";           // string, 读写(必填), 保存截图的路径
static const char* kTIMVideoElemImageId            = "video_elem_image_id";             // string, 只读, 截图 ID
static const char* kTIMVideoElemImageDownloadFlag  = "video_elem_image_download_flag";  // int,    只读, 截图文件下载flag 
static const char* kTIMVideoElemImageUrl           = "video_elem_image_url";            // string, 只读, 截图文件下载的URL 
static const char* kTIMVideoElemTaskId             = "video_elem_task_id";              // uint,   只读, 任务ID，废弃
// EndStruct

/**
* @brief  合并消息元素
*/
// Struct MergerElem JsonKey
static const char* kTIMMergerElemTitle              = "merge_elem_title";                // string, 读写(必填), 合并消息 title
static const char* kTIMMergerElemAbstractArray      = "merge_elem_abstract_array";       // array string, 读写(必填), 合并消息摘要列表
static const char* kTIMMergerElemCompatibleText     = "merge_elem_compatible_text";      // string, 读写(必填), 合并消息兼容文本，低版本 SDK 如果不支持合并消息，默认会收到一条文本消息，文本消息的内容为 compatibleText，该参数不能为空。
static const char* kTIMMergerElemMsgArray           = "merge_elem_message_array";        // array [Message](), 读写(必填), 消息列表（最大支持 300 条，消息对象必须是 kTIMMsg_SendSucc 状态，消息类型不能为 GroupTipsElem 或 GroupReportElem）
static const char* kTIMMergerElemLayersOverLimit    = "merge_elem_layer_over_limit";     // bool, 只读, 合并消息里面又包含合并消息我们称之为合并嵌套，合并嵌套层数不能超过 100 层，如果超过限制，layersOverLimit 会返回 YES，kTIMMergerElemTitle 和 kTIMMergerElemAbstractArray 为空，DownloadMergerMessage 会返回 ERR_MERGER_MSG_LAYERS_OVER_LIMIT 错误码。
static const char* kTIMMergerElemRelayPbKey         = "merge_elem_relay_pb_key";         // string, 只读, native 端消息列表下载 key
static const char* kTIMMergerElemRelayJsonKey       = "merge_elem_relay_json_key";       // string, 只读, web 端消息列表下载 key
static const char* kTIMMergerElemRelayBuffer        = "merge_elem_relay_buffer";         // string, 只读, 转发消息的 buffer
// EndStruct

/**
* @brief 群组信息修改的类型
*/
enum TIMGroupTipGroupChangeFlag {
    kTIMGroupTipChangeFlag_Unknown,      // 未知的修改
    kTIMGroupTipChangeFlag_Name,         // 修改群组名称
    kTIMGroupTipChangeFlag_Introduction, // 修改群简介
    kTIMGroupTipChangeFlag_Notification, // 修改群公告
    kTIMGroupTipChangeFlag_FaceUrl,      // 修改群头像URL
    kTIMGroupTipChangeFlag_Owner,        // 修改群所有者
    kTIMGroupTipChangeFlag_Custom,       // 修改群自定义信息
    kTIMGroupTipChangeFlag_Attribute,    // 群属性变更 (新增)
};

/**
* @brief 群组系统消息-群组信息修改
*/
// Struct GroupTipGroupChangeInfo JsonKey
static const char* kTIMGroupTipGroupChangeInfoFlag        = "group_tips_group_change_info_flag";         // uint [TIMGroupTipGroupChangeFlag](), 只读, 群消息修改群信息标志
static const char* kTIMGroupTipGroupChangeInfoValue       = "group_tips_group_change_info_value";        // string, 只读, 修改的后值,不同的 info_flag 字段,具有不同的含义
static const char* kTIMGroupTipGroupChangeInfoKey         = "group_tips_group_change_info_key";          // string, 只读, 自定义信息对应的 key 值，只有 info_flag 为 kTIMGroupTipChangeFlag_Custom 时有效
// EndStruct

/**
* @brief 群组系统消息-群组成员禁言
*/
// Struct GroupTipMemberChangeInfo JsonKey
static const char* kTIMGroupTipMemberChangeInfoIdentifier  = "group_tips_member_change_info_identifier";     // string, 只读, 群组成员ID
static const char* kTIMGroupTipMemberChangeInfoShutupTime  = "group_tips_member_change_info_shutupTime";     // uint,   只读, 禁言时间
// EndStruct


/**
* @brief 群组系统消息类型
*/
enum TIMGroupTipType {
    kTIMGroupTip_None,              // 无效的群提示
    kTIMGroupTip_Invite,            // 邀请加入提示
    kTIMGroupTip_Quit,              // 退群提示
    kTIMGroupTip_Kick,              // 踢人提示
    kTIMGroupTip_SetAdmin,          // 设置管理员提示
    kTIMGroupTip_CancelAdmin,       // 取消管理员提示
    kTIMGroupTip_GroupInfoChange,   // 群信息修改提示
    kTIMGroupTip_MemberInfoChange,  // 群成员信息修改提示
};

/**
* @brief 群组系统消息元素(针对所有群成员)
*/
// Struct GroupTipsElem JsonKey
static const char* kTIMGroupTipsElemTipType                     = "group_tips_elem_tip_type";                       // uint [TIMGroupTipType](), 只读, 群消息类型
static const char* kTIMGroupTipsElemOpUser                      = "group_tips_elem_op_user";                        // string,   只读, 操作者ID
static const char* kTIMGroupTipsElemGroupName                   = "group_tips_elem_group_name";                     // string,   只读, 群组名称
static const char* kTIMGroupTipsElemGroupId                     = "group_tips_elem_group_id";                       // string,   只读, 群组ID
static const char* kTIMGroupTipsElemTime                        = "group_tips_elem_time";                           // uint,     只读, 群消息时间，废弃
static const char* kTIMGroupTipsElemUserArray                   = "group_tips_elem_user_array";                     // array string, 只读, 被操作的帐号列表
static const char* kTIMGroupTipsElemGroupChangeInfoArray        = "group_tips_elem_group_change_info_array";        // array [GroupTipGroupChangeInfo](),  只读, 群资料变更信息列表,仅当 tips_type 值为 kTIMGroupTip_GroupInfoChange 时有效
static const char* kTIMGroupTipsElemMemberChangeInfoArray       = "group_tips_elem_member_change_info_array";       // array [GroupTipMemberChangeInfo](), 只读, 群成员变更信息列表,仅当 tips_type 值为 kTIMGroupTip_MemberInfoChange 时有效
static const char* kTIMGroupTipsElemOpUserInfo                  = "group_tips_elem_op_user_info";                   // object [UserProfile](),              只读, 操作者个人资料
static const char* kTIMGroupTipsElemOpGroupMemberInfo           = "group_tips_elem_op_group_memberinfo";            // object [GroupMemberInfo](),          只读, 群成员信息
static const char* kTIMGroupTipsElemChangedUserInfoArray        = "group_tips_elem_changed_user_info_array";        // array [UserProfile](),               只读, 被操作者列表资料
static const char* kTIMGroupTipsElemChangedGroupMemberInfoArray = "group_tips_elem_changed_group_memberinfo_array"; // array [GroupMemberInfo](),       只读, 群成员信息列表
static const char* kTIMGroupTipsElemMemberNum                   = "group_tips_elem_member_num";                     // uint,   只读, 当前群成员数,只有当事件消息类型为 kTIMGroupTip_Invite 、 kTIMGroupTip_Quit 、 kTIMGroupTip_Kick 时有效
static const char* kTIMGroupTipsElemPlatform                    = "group_tips_elem_platform";                       // string, 只读, 操作方平台信息
// EndStruct

/**
* @brief 群组系统通知类型
*/
enum TIMGroupReportType {
    kTIMGroupReport_None,         // 未知类型
    kTIMGroupReport_AddRequest,   // 申请加群(只有管理员会接收到)
    kTIMGroupReport_AddAccept,    // 申请加群被同意(只有申请人自己接收到)
    kTIMGroupReport_AddRefuse,    // 申请加群被拒绝(只有申请人自己接收到)
    kTIMGroupReport_BeKicked,     // 被管理员踢出群(只有被踢者接收到)
    kTIMGroupReport_Delete,       // 群被解散(全员接收)
    kTIMGroupReport_Create,       // 创建群(创建者接收, 不展示)
    kTIMGroupReport_Invite,       // 无需被邀请者同意，拉入群中（例如工作群）
    kTIMGroupReport_Quit,         // 主动退群(主动退出者接收, 不展示)
    kTIMGroupReport_GrantAdmin,   // 设置管理员(被设置者接收)
    kTIMGroupReport_CancelAdmin,  // 取消管理员(被取消者接收)
    kTIMGroupReport_GroupRecycle, // 群已被回收(全员接收, 不展示)
    kTIMGroupReport_InviteReq,    // 被邀请者收到邀请，由被邀请者同意是否接受
    kTIMGroupReport_InviteAccept, // 邀请加群被同意(只有发出邀请者会接收到)
    kTIMGroupReport_InviteRefuse, // 邀请加群被拒绝(只有发出邀请者会接收到)
    kTIMGroupReport_ReadReport,   // 已读上报多终端同步通知(只有上报人自己收到)
    kTIMGroupReport_UserDefine,   // 用户自定义通知(默认全员接收)
};

/**
* @brief 群组系统通知元素(针对个人)
*/
// Struct GroupReportElem JsonKey
static const char* kTIMGroupReportElemReportType        = "group_report_elem_report_type";          // uint [TIMGroupReportType](), 只读, 类型
static const char* kTIMGroupReportElemGroupId           = "group_report_elem_group_id";             // string, 只读, 群组ID
static const char* kTIMGroupReportElemGroupName         = "group_report_elem_group_name";           // string, 只读, 群组名称
static const char* kTIMGroupReportElemOpUser            = "group_report_elem_op_user";              // string, 只读, 操作者ID
static const char* kTIMGroupReportElemMsg               = "group_report_elem_msg";                  // string, 只读, 操作理由
static const char* kTIMGroupReportElemUserData          = "group_report_elem_user_data";            // string, 只读, 操作者填的自定义数据
static const char* kTIMGroupReportElemOpUserInfo        = "group_report_elem_op_user_info";         // object [UserProfile](), 只读, 操作者个人资料
static const char* kTIMGroupReportElemOpGroupMemberInfo = "group_report_elem_op_group_memberinfo";  // object [GroupMemberInfo](), 只读,操作者群内资料
static const char* kTIMGroupReportElemPlatform          = "group_report_elem_platform";             // string, 只读, 操作方平台信息
// EndStruct

/**
 * @brief 资料变更类型
 */
enum TIMProfileChangeType {
    kTIMProfileChange_None,       // 未知类型
    kTIMProfileChange_Profile,    // 资料修改
};

/**
 * @brief 资料变更通知
 */
// Struct ProfileChangeElem JsonKey
static const char* kTIMProfileChangeElemChangeType      = "profile_change_elem_change_type";        // uint [TIMProfileChangeType](), 只读, 资料变更类型
static const char* kTIMProfileChangeElemFromIndentifier = "profile_change_elem_from_identifer";     // string,                        只读, 资料变更用户的UserID
static const char* kTIMProfileChangeElemUserProfileItem = "profile_change_elem_user_profile_item";  // object [UserProfileItem](),    只读, 具体的变更信息，只有当 change_type 为 kTIMProfileChange_Profile 时有效
// EndStruct

/**
 * @brief 好友变更类型
 */
enum TIMFriendChangeType {
    kTIMFriendChange_None,                   // 未知类型
    kTIMFriendChange_FriendAdd,              // 新增好友
    kTIMFriendChange_FriendDel,              // 删除好友
    kTIMFriendChange_PendencyAdd,            // 新增好友申请的未决
    kTIMFriendChange_PendencyDel,            // 删除好友申请的未决
    kTIMFriendChange_BlackListAdd,           // 加入黑名单
    kTIMFriendChange_BlackListDel,           // 从黑名单移除
    kTIMFriendChange_PendencyReadedReport,   // 未决已读上报
    kTIMFriendChange_FriendProfileUpdate,    // 好友数据更新
    kTIMFriendChange_FriendGroupAdd,         // 分组增加
    kTIMFriendChange_FriendGroupDel,         // 分组删除
    kTIMFriendChange_FriendGroupModify,      // 分组修改
};

/**
 * @brief 好友资料更新信息
 */
// Struct FriendProfileUpdate JsonKey
static const char* kTIMFriendProfileUpdateIdentifier = "friend_profile_update_identifier";  // string, 只写, 资料更新的好友的UserID
static const char* kTIMFriendProfileUpdateItem       = "friend_profile_update_item";        // object [FriendProfileItem](), 只写, 资料更新的Item
// EndStruct

/**
 * @brief 好友变更通知
 */
// Struct FriendChangeElem JsonKey
static const char* kTIMFriendChangeElemChangeType                       = "friend_change_elem_change_type";                        // uint [TIMFriendChangeType](),  只读, 资料变更类型
static const char* kTIMFriendChangeElemFriendAddIdentifierArray         = "friend_change_elem_friend_add_identifier_array";        // array string,                  只读, 新增的好友UserID列表，只有当 change_type 为 kTIMFriendChange_FriendAdd 时有效
static const char* kTIMFriendChangeElemFriendDelIdentifierArray         = "friend_change_elem_friend_del_identifier_array";        // array string,                  只读, 删除的好友UserID列表，只有当 change_type 为 kTIMFriendChange_FriendDel 时有效
static const char* kTIMFriendChangeElemFriendAddPendencyItemArray       = "friend_change_elem_friend_add_pendency_array";          // array [FriendAddPendency](),   只读, 好友申请的未决列表，     只有当 change_type 为 kTIMFriendChange_PendencyAdd 时有效
static const char* kTIMFriendChangeElemPendencyDelIdentifierArray       = "friend_change_elem_pendency_del_identifier_array";      // array string,                  只读, 被删除的好友申请的未决列表，     只有当 change_type 为 kTIMFriendChange_PendencyDel 时有效
static const char* kTIMFriendChangeElemPendencyReadedReportTimestamp    = "friend_change_elem_pendency_readed_report_timestamp";   // uint64,                        只读, 未决已读上报时间戳，       只有当 change_type 为 kTIMFriendChange_PendencyReadedReport 时有效
static const char* kTIMFriendChangeElemBlackListAddIdentifierArray      = "friend_change_elem_blacklist_add_identifier_array";     // array string,                  只读, 新增的黑名单UserID列表，只有当 change_type 为 kTIMFriendChange_BlackListAdd 时有效
static const char* kTIMFriendChangeElemBlackListDelIdentifierArray      = "friend_change_elem_blacklist_del_identifier_array";     // array string,                  只读, 删除的黑名单UserID列表，只有当 change_type 为 kTIMFriendChange_BlackListDel 时有效
static const char* kTIMFriendChangeElemFreindProfileUpdateItemArray     = "friend_change_elem_friend_profile_update_item_array";   // array [FriendProfileUpdate](), 只读, 好友资料更新列表，          只有当 change_type 为 kTIMFriendChange_FriendProfileUpdate 时有效
static const char* kTIMFriendChangeElemFriendGroupAddIdentifierArray    = "friend_change_elem_friend_group_add_array";             // array string,                  只读, 新增的好友分组名称列表，     只有当 change_type 为 kTIMFriendChange_FriendGroupAdd 时有效
static const char* kTIMFriendChangeElemFriendGroupDelIdentifierArray    = "friend_change_elem_friend_group_del_array";             // array string,                  只读, 删除的好友分组名称列表，     只有当 change_type 为 kTIMFriendChange_FriendGroupDel 时有效
static const char* kTIMFriendChangeElemFriendGroupModifyIdentifierArray = "friend_change_elem_friend_group_update_array";          // array string,                  只读, 修改的好友分组名称列表，     只有当 change_type 为 kTIMFriendChange_FriendGroupModify 时有效
// EndStruct

/**
* @brief 消息群发接口的参数
*/
// Struct MsgBatchSendParam JsonKey
static const char* kTIMMsgBatchSendParamIdentifierArray = "msg_batch_send_param_identifier_array"; // array string,       只写(必填), 接收群发消息的用户 ID 列表
static const char* kTIMMsgBatchSendParamMsg             = "msg_batch_send_param_msg";              // object [Message](), 只写(必填), 群发的消息
// EndStruct

/**
* @brief 消息群发接口的返回
*/
// Struct MsgBatchSendResult JsonKey
static const char* kTIMMsgBatchSendResultIdentifier = "msg_batch_send_result_identifier";  // string, 只读, 接收群发消息的用户 ID
static const char* kTIMMsgBatchSendResultCode       = "msg_batch_send_result_code";        // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 消息发送结果
static const char* kTIMMsgBatchSendResultDesc       = "msg_batch_send_result_desc";        // string, 只读, 消息发送的描述
static const char* kTIMMsgBatchSendResultMsg        = "msg_batch_send_result_msg";         // object [Message](), 只读, 发送的消息
// EndStruct

/**
* @brief 消息定位符
*/
// Struct MsgLocator JsonKey
static const char* kTIMMsgLocatorConvId    = "message_locator_conv_id";    // bool,   读写,      要查找的消息所属的会话ID
static const char* kTIMMsgLocatorConvType  = "message_locator_conv_type";  // bool,   读写,      要查找的消息所属的会话类型
static const char* kTIMMsgLocatorIsRevoked = "message_locator_is_revoked"; // bool,   读写(必填), 要查找的消息是否是被撤回。true表示被撤回的，false表示未撤回的。默认为false
static const char* kTIMMsgLocatorTime      = "message_locator_time";       // uint64, 读写(必填), 要查找的消息的时间戳
static const char* kTIMMsgLocatorSeq       = "message_locator_seq";        // uint64, 读写(必填), 要查找的消息的序列号
static const char* kTIMMsgLocatorIsSelf    = "message_locator_is_self";    // bool,   读写(必填), 要查找的消息的发送者是否是自己。true表示发送者是自己，false表示发送者不是自己。默认为false
static const char* kTIMMsgLocatorRand      = "message_locator_rand";       // uint64, 读写(必填), 要查找的消息随机码
static const char* kTIMMsgLocatorUniqueId  = "message_locator_unique_id";  // uint64, 读写(必填), 要查找的消息的唯一标识
// EndStruct


/**
* @brief 消息获取接口的参数
*/
// Struct MsgGetMsgListParam JsonKey
static const char* kTIMMsgGetMsgListParamLastMsg    = "msg_getmsglist_param_last_msg";      // object [Message](), 只写(选填), 指定的消息，不允许为null
static const char* kTIMMsgGetMsgListParamCount      = "msg_getmsglist_param_count";         // uint,               只写(选填), 从指定消息往后的消息数
static const char* kTIMMsgGetMsgListParamIsRamble   = "msg_getmsglist_param_is_remble";     // bool,               只写(选填), 是否漫游消息
static const char* kTIMMsgGetMsgListParamIsForward  = "msg_getmsglist_param_is_forward";    // bool,               只写(选填), 是否向前排序
static const char* kTIMMsgGetMsgListParamLastMsgSeq = "msg_getmsglist_param_last_msg_seq";  // unit64,               只写(选填), 指定的消息的 seq
static const char* kTIMMsgGetMsgListParamTimeBegin  = "msg_getmsglist_param_time_begin";    // unit64,               只写(选填), 开始时间；UTC 时间戳， 单位：秒
static const char* kTIMMsgGetMsgListParamTimePeriod = "msg_getmsglist_param_time_period";   // unit64,               只写(选填), 持续时间；单位：秒
// EndStruct



/**
* @brief 消息删除接口的参数
*/
// Struct MsgDeleteParam JsonKey
static const char* kTIMMsgDeleteParamMsg       = "msg_delete_param_msg";        // object [Message](), 只写(选填), 要删除的消息
static const char* kTIMMsgDeleteParamIsRamble  = "msg_delete_param_is_remble";  // bool, 只写(选填), 是否删除本地/漫游所有消息。true删除漫游消息，false删除本地消息，默认值false
// EndStruct


/// 消息接收选项
enum TIMReceiveMessageOpt {
    kTIMRecvMsgOpt_Receive = 0,  // 在线正常接收消息，离线时会进行 APNs 推送
    kTIMRecvMsgOpt_Not_Receive,  // 不会接收到消息，离线不会有推送通知
    kTIMRecvMsgOpt_Not_Notify,   // 在线正常接收消息，离线不会有推送通知
};

/**
* @brief 查询 C2C 消息接收选项的返回
*/
// Struct GetC2CRecvMsgOptResult JsonKey
static const char* kTIMMsgGetC2CRecvMsgOptResultIdentifier  = "msg_recv_msg_opt_result_identifier";   // string, 只读，用户ID
static const char* kTIMMsgGetC2CRecvMsgOptResultOpt         = "msg_recv_msg_opt_result_opt";          // uint [TIMReceiveMessageOpt](), 只读，消息接收选项
// EndStruct


/**
* @brief UUID类型
*/
enum TIMDownloadType {
    kTIMDownload_VideoThumb = 0, // 视频缩略图
    kTIMDownload_File,           // 文件
    kTIMDownload_Video,          // 视频
    kTIMDownload_Sound,          // 声音
};

/**
* @brief 下载元素接口的参数
*/
// Struct DownloadElemParam JsonKey
static const char* kTIMMsgDownloadElemParamFlag       = "msg_download_elem_param_flag";         // uint,   只写, 从消息元素里面取出来,元素的下载类型
static const char* kTIMMsgDownloadElemParamType       = "msg_download_elem_param_type";         // uint [TIMDownloadType](), 只写, 从消息元素里面取出来,元素的类型
static const char* kTIMMsgDownloadElemParamId         = "msg_download_elem_param_id";           // string, 只写, 从消息元素里面取出来,元素的ID
static const char* kTIMMsgDownloadElemParamBusinessId = "msg_download_elem_param_business_id";  // uint,   只写, 从消息元素里面取出来,元素的BusinessID
static const char* kTIMMsgDownloadElemParamUrl        = "msg_download_elem_param_url";          // string, 只写, 从消息元素里面取出来,元素URL
// EndStruct

/**
* @brief 下载元素接口的返回
*/
// Struct MsgDownloadElemResult JsonKey
static const char* kTIMMsgDownloadElemResultCurrentSize = "msg_download_elem_result_current_size";       // uint, 只读, 当前已下载的大小
static const char* kTIMMsgDownloadElemResultTotalSize   = "msg_download_elem_result_total_size";         // uint, 只读, 需要下载的文件总大小
// EndStruct

/**
* @brief 消息搜索关键字的组合类型
*/
// Struct KeywordListMatchType JsonKey
enum TIMKeywordListMatchType {
    TIMKeywordListMatchType_Or,
    TIMKeywordListMatchType_And
};
// EndStruct

/**
* @brief 消息搜索参数
*/
// Struct MessageSearchParam JsonKey
static const char* kTIMMsgSearchParamKeywordArray       = "msg_search_param_keyword_array";               // array string, 只写(必填)，搜索关键字列表，最多支持5个。
static const char* kTIMMsgSearchParamMessageTypeArray   = "msg_search_param_message_type_array";          // array [TIMElemType](), 只写(选填), 指定搜索的消息类型集合，传入空数组，表示搜索支持的全部类型消息（FaceElem 和 GroupTipsElem 暂不支持）取值详见 TIMElemType。
static const char* kTIMMsgSearchParamConvId             = "msg_search_param_conv_id";                     // string, 只写(选填)，会话 ID
static const char* kTIMMsgSearchParamConvType           = "msg_search_param_conv_type";                   // uint [TIMConvType](), 只写(选填), 会话类型，如果设置 kTIMConv_Invalid，代表搜索全部会话。否则，代表搜索指定会话。
static const char* kTIMMsgSearchParamSearchTimePosition = "msg_search_param_search_time_position";        // uint64, 只写(选填), 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
static const char* kTIMMsgSearchParamSearchTimePeriod   = "msg_search_param_search_time_period";          // uint64, 只写(选填), 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天。
static const char* kTIMMsgSearchParamPageIndex          = "msg_search_param_page_index";                  // uint, 只写(选填), 分页的页号：用于分页展示查找结果，从零开始起步。首次调用：通过参数 pageSize = 10, pageIndex = 0 调用 searchLocalMessage，从结果回调中的 totalCount 可以获知总共有多少条结果。计算页数：可以获知总页数：totalPage = (totalCount % loadCount == 0) ? (totalCount / pageIndex) : (totalCount / pageIndex + 1) 。再次调用：可以通过指定参数 pageIndex （pageIndex < totalPage）返回后续页号的结果。
static const char* kTIMMsgSearchParamPageSize           = "msg_search_param_page_size";                 // uint, 只写(选填), 每页结果数量：用于分页展示查找结果，如不希望分页可将其设置成 0，但如果结果太多，可能会带来性能问题。
static const char* kTIMMsgSearchParamKeywordListMatchType   = "msg_search_param_keyword_list_match_type";                  // uint [TIMKeywordListMatchType], 关键字进行 Or 或者 And 进行搜索
static const char* kTIMMsgSearchParamSenderIdentifierArray   = "msg_search_param_send_indentifier_array";  // array string, 按照发送者的 userid 进行搜索

// EndStruct


/**
* @brief 消息搜索结果项
*/
// Struct MessageSearchResultItem JsonKey
static const char* kTIMMsgSearchResultItemConvId            = "msg_search_result_item_conv_id";             // string, 只读，会话 ID
static const char* kTIMMsgSearchResultItemConvType          = "msg_search_result_item_conv_type";           // uint [TIMConvType](), 只读, 会话类型
static const char* kTIMMsgSearchResultItemTotalMessageCount = "msg_search_result_item_total_message_count"; // uint, 只读, 当前会话一共搜索到了多少条符合要求的消息
static const char* kTIMMsgSearchResultItemMessageArray      = "msg_search_result_item_message_array";       // array [Message](), 只读, 满足搜索条件的消息列表
// EndStruct

/**
* @brief 消息搜索结果返回
*/
// Struct MessageSearchResult JsonKey
static const char* kTIMMsgSearchResultTotalCount        = "msg_search_result_total_count";        // uint, 只读, 如果您本次搜索【指定会话】，那么返回满足搜索条件的消息总数量；如果您本次搜索【全部会话】，那么返回满足搜索条件的消息所在的所有会话总数量。
static const char* kTIMMsgSearchResultItemArray         = "msg_search_result_item_array";         // array [TIMMessageSearchResultItem](), 只读, 如果您本次搜索【指定会话】，那么返回结果列表只包含该会话结果；如果您本次搜索【全部会话】，那么对满足搜索条件的消息根据会话 ID 分组，分页返回分组结果；
// EndStruct

/// @}


/// @name 会话关键类型
/// @brief 会话相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 草稿信息
*/
// Struct Draft JsonKey
static const char* kTIMDraftMsg              = "draft_msg";         // object [Message](), 只读, 草稿内的消息
static const char* kTIMDraftUserDefine       = "draft_user_define"; // string, 只读, 用户自定义数据
static const char* kTIMDraftEditTime         = "draft_edit_time";   // uint, 只读, 草稿最新编辑时间
// EndStruct


/// @ 类型
enum TIMGroupAtType {
    kTIMGroup_At_Me = 1,                    // @ 我
    kTIMGroup_At_All,                       // @ 群里所有人
    kTIMGroup_At_All_At_ME,                 // @ 群里所有人并且单独 @ 我
};

/**
* @brief 群 @ 信息
*/
// Struct GroupAtInfo JsonKey
static const char* kTIMGroupAtInfoSeq          = "conv_group_at_info_seq";     // uint64, 只读, @ 消息序列号，即带有 “@我” 或者 “@所有人” 标记的消息的序列号
static const char* kTIMGroupAtInfoAtType       = "conv_group_at_info_at_type"; // uint [TIMGroupAtType](), 只读, @ 提醒类型，分成 “@我” 、“@所有人” 以及 “@我并@所有人” 三类
// EndStruct

/**
* @brief 会话信息
*/
// Struct ConvInfo JsonKey
static const char* kTIMConvId               = "conv_id";                    // string, 只读, 会话ID
static const char* kTIMConvType             = "conv_type";                  // uint [TIMConvType](), 只读, 会话类型
static const char* kTIMConvOwner            = "conv_owner";                 // string, 只读, 会话所有者，废弃
static const char* kTIMConvUnReadNum        = "conv_unread_num";            // uint64, 只读, 会话未读计数
static const char* kTIMConvActiveTime       = "conv_active_time";           // uint64, 只读, 会话的激活时间
static const char* kTIMConvIsHasLastMsg     = "conv_is_has_lastmsg";        // bool, 只读, 会话是否有最后一条消息
static const char* kTIMConvLastMsg          = "conv_last_msg";              // object [Message](), 只读, 会话最后一条消息
static const char* kTIMConvIsHasDraft       = "conv_is_has_draft";          // bool, 只读, 会话是否有草稿
static const char* kTIMConvDraft            = "conv_draft";                 // object [Draft](), 只读(选填), 会话草稿
static const char* kTIMConvRecvOpt          = "conv_recv_opt";              // uint [TIMReceiveMessageOpt](), 只读(选填), 消息接收选项
static const char* kTIMConvGroupAtInfoArray = "conv_group_at_info_array";   // array [GroupAtInfo](), 只读(选填),  群会话 @ 信息列表，用于展示 “有人@我” 或 “@所有人” 这两种提醒状态
static const char* kTIMConvIsPinned         = "conv_is_pinned";              // bool, 只读,是否置顶
static const char* kTIMConvShowName         = "conv_show_name";              //string , 只读, 获取会话展示名称，其展示优先级如下：1、群组，群名称 C2C; 2、对方好友备注->对方昵称->对方的 userID

// EndStruct
/// @}

/**
* @brief 获取指定的会话列表
*/
// Struct GetConversationListParam JsonKey
static const char* kTIMGetConversationListParamConvId           = "get_conversation_list_param_conv_id";             // string, 只写, 会话ID
static const char* kTIMGetConversationListParamConvType         = "get_conversation_list_param_conv_type";           // uint [TIMConvType](), 只写, 会话类型
// EndStruct
/// @}

/**
* @brief 获取会话未读消息个数
*/
// Struct GetTotalUnreadNumberResult JsonKey
static const char* kTIMConvGetTotalUnreadMessageCountResultUnreadCount           = "conv_get_total_unread_message_count_result_unread_count";             // int, 只读，会话未读数
// EndStruct
/// @}



/// @name 群组关键类型
/// @brief 群组相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 群组加群选项
*/
enum TIMGroupAddOption {
    kTIMGroupAddOpt_Forbid = 0,  // 禁止加群
    kTIMGroupAddOpt_Auth = 1,    // 需要管理员审批
    kTIMGroupAddOpt_Any = 2,     // 任何人都可以加群
};

/**
* @brief 群组类型
*/
enum TIMGroupType {
    kTIMGroup_Public,     // 公开群（Public），成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
    kTIMGroup_Private,    // 工作群（Work），成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
    kTIMGroup_ChatRoom,   // 会议群（Meeting），成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
    kTIMGroup_BChatRoom,  // 在线成员广播大群，推荐使用 直播群（AVChatRoom）
    kTIMGroup_AVChatRoom, // 直播群（AVChatRoom），人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
    kTIMGroup_Community,  // 社群（Community），成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。
};

/**
* @brief 群组成员角色类型
*/
enum TIMGroupMemberRole {
    kTIMMemberRole_None         = 0,    // 未定义
    kTIMMemberRole_Normal       = 200,  // 群成员
    kTIMMemberRole_Admin        = 300,  // 管理员
    kTIMMemberRole_Owner        = 400,  // 超级管理员(群主）
};

/**
 * @brief 群组成员信息自定义字段
 */
// Struct GroupMemberInfoCustemString JsonKey
static const char* kTIMGroupMemberInfoCustemStringInfoKey   = "group_member_info_custom_string_info_key";   // string, 只写, 自定义字段的key
static const char* kTIMGroupMemberInfoCustemStringInfoValue = "group_member_info_custom_string_info_value"; // string, 只写, 自定义字段的value
// EndStruct

/**
* @brief 群组成员信息
*/
// Struct GroupMemberInfo JsonKey
static const char* kTIMGroupMemberInfoIdentifier = "group_member_info_identifier";   // string, 读写(必填), 群组成员ID
static const char* kTIMGroupMemberInfoGroupId = "group_member_info_group_id";   // string, 只读, 群组 ID
static const char* kTIMGroupMemberInfoJoinTime   = "group_member_info_join_time";    // uint,  只读, 群组成员加入时间
static const char* kTIMGroupMemberInfoMemberRole = "group_member_info_member_role";  // uint [TIMGroupMemberRole](), 读写(选填), 群组成员角色
static const char* kTIMGroupMemberInfoMsgFlag    = "group_member_info_msg_flag";     // uint, [TIMReceiveMessageOpt] 只读, 成员接收消息的选项
static const char* kTIMGroupMemberInfoMsgSeq     = "group_member_info_msg_seq";      // uint, 只读, 消息序列号
static const char* kTIMGroupMemberInfoShutupTime = "group_member_info_shutup_time";  // uint,  只读, 成员禁言时间
static const char* kTIMGroupMemberInfoNameCard   = "group_member_info_name_card";    // string, 只读, 成员群名片
static const char* kTIMGroupMemberInfoNickName   = "group_member_info_nick_name";    // string, 只读, 好友昵称
static const char* kTIMGroupMemberInfoRemark   = "group_member_info_remark";    // string, 只读, 好友备注
static const char* kTIMGroupMemberInfoFaceUrl   = "group_member_info_face_url";    // string, 只读, 好友头像
static const char* kTIMGroupMemberInfoCustomInfo = "group_member_info_custom_info";  // array [GroupMemberInfoCustemString](), 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
 * @brief 群组成员信息自定义字段
 */
// Struct GroupInfoCustemString JsonKey
static const char* kTIMGroupInfoCustemStringInfoKey   = "group_info_custom_string_info_key";   // string, 只写, 自定义字段的key
static const char* kTIMGroupInfoCustemStringInfoValue = "group_info_custom_string_info_value"; // string, 只写, 自定义字段的value
// EndStruct

/**
* @brief 创建群组接口的参数
*/
// Struct CreateGroupParam JsonKey
static const char* kTIMCreateGroupParamGroupName        = "create_group_param_group_name";          // string, 只写(必填), 群组名称
static const char* kTIMCreateGroupParamGroupId          = "create_group_param_group_id";            // string, 只写(选填), 群组ID,不填时创建成功回调会返回一个后台分配的群ID，如果创建社群（Community）需要自定义群组 ID ，那必须以 "@TGS#_" 作为前缀。
static const char* kTIMCreateGroupParamGroupType        = "create_group_param_group_type";          // uint [TIMGroupType](), 只写(选填), 群组类型,默认为Public
static const char* kTIMCreateGroupParamGroupMemberArray = "create_group_param_group_member_array";  // array [GroupMemberInfo](), 只写(选填), 群组初始成员数组
static const char* kTIMCreateGroupParamNotification     = "create_group_param_notification";        // string, 只写(选填), 群组公告
static const char* kTIMCreateGroupParamIntroduction     = "create_group_param_introduction";        // string, 只写(选填), 群组简介
static const char* kTIMCreateGroupParamFaceUrl          = "create_group_param_face_url";            // string, 只写(选填), 群组头像URL
static const char* kTIMCreateGroupParamAddOption        = "create_group_param_add_option";          // uint [TIMGroupAddOption](),   只写(选填), 加群选项，默认为Any
static const char* kTIMCreateGroupParamMaxMemberCount   = "create_group_param_max_member_num";      // uint,   只写(选填), 群组最大成员数
static const char* kTIMCreateGroupParamCustomInfo       = "create_group_param_custom_info";         // array [GroupInfoCustemString](), 只读(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 创建群组接口的返回
*/
// Struct CreateGroupResult JsonKey
static const char* kTIMCreateGroupResultGroupId         = "create_group_result_groupid"; // string, 只读, 创建的群ID
// EndStruct

/**
* @brief 邀请成员接口的参数
*/
// Struct GroupInviteMemberParam JsonKey
static const char* kTIMGroupInviteMemberParamGroupId         = "group_invite_member_param_group_id";         // string, 只写(必填), 群组ID
static const char* kTIMGroupInviteMemberParamIdentifierArray = "group_invite_member_param_identifier_array"; // array string, 只写(必填), 被邀请加入群组用户ID数组
static const char* kTIMGroupInviteMemberParamUserData        = "group_invite_member_param_user_data";        // string, 只写(选填), 用于自定义数据
// EndStruct


/**
* @brief 群组基础信息
*/
enum HandleGroupMemberResult {
    kTIMGroupMember_HandledErr, // 失败
    kTIMGroupMember_HandledSuc, // 成功
    kTIMGroupMember_Included,   // 已是群成员
    kTIMGroupMember_Invited,    // 已发送邀请
};


/**
* @brief 邀请成员接口的返回
*/
// Struct GroupInviteMemberResult JsonKey
static const char* kTIMGroupInviteMemberResultIdentifier = "group_invite_member_result_identifier"; // string, 只读, 被邀请加入群组的用户ID
static const char* kTIMGroupInviteMemberResultResult     = "group_invite_member_result_result";     // uint [HandleGroupMemberResult](), 只读, 邀请结果
// EndStruct

/**
* @brief 删除成员接口的参数
*/
// Struct GroupDeleteMemberParam JsonKey
static const char* kTIMGroupDeleteMemberParamGroupId         = "group_delete_member_param_group_id";          // string, 只写(必填), 群组ID
static const char* kTIMGroupDeleteMemberParamIdentifierArray = "group_delete_member_param_identifier_array";  // array string, 只写(必填), 被删除群组成员数组
static const char* kTIMGroupDeleteMemberParamUserData        = "group_delete_member_param_user_data";         // string, 只写(选填), 用于自定义数据
// EndStruct

/**
* @brief 删除成员接口的返回
*/
// Struct GroupDeleteMemberResult JsonKey
static const char* kTIMGroupDeleteMemberResultIdentifier  = "group_delete_member_result_identifier"; // string, 只读, 删除的成员ID
static const char* kTIMGroupDeleteMemberResultResult      = "group_delete_member_result_result";     // uint [HandleGroupMemberResult](), 只读, 删除结果
// EndStruct

/**
* @brief 群组内本人的信息
*/
// Struct GroupSelfInfo JsonKey
static const char* kTIMGroupSelfInfoJoinTime   = "group_self_info_join_time";   // uint, 只读, 加入群组时间
static const char* kTIMGroupSelfInfoRole       = "group_self_info_role";        // uint, 只读, 用户在群组中的角色
static const char* kTIMGroupSelfInfoUnReadNum  = "group_self_info_unread_num";  // uint, 只读, 消息未读计数
static const char* kTIMGroupSelfInfoMsgFlag    = "group_self_info_msg_flag";    // uint [TIMReceiveMessageOpt](), 只读, 消息接收选项
// EndStruct

/**
* @brief 获取已加入群组列表接口的返回(群组基础信息)
*/
// Struct GroupBaseInfo JsonKey
static const char* kTIMGroupBaseInfoGroupId      = "group_base_info_group_id";       // string, 只读, 群组ID
static const char* kTIMGroupBaseInfoGroupName    = "group_base_info_group_name";     // string, 只读, 群组名称
static const char* kTIMGroupBaseInfoGroupType    = "group_base_info_group_type";     // uint [TIMGroupType](), 只读, 群组类型
static const char* kTIMGroupBaseInfoFaceUrl      = "group_base_info_face_url";       // string, 只读, 群组头像URL
static const char* kTIMGroupBaseInfoInfoSeq      = "group_base_info_info_seq";       // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
static const char* kTIMGroupBaseInfoLastestSeq   = "group_base_info_lastest_seq";    // uint,   只读, 群最新消息的Seq。群组内每一条消息都有一条唯一的消息Seq，且该Seq是按照发消息顺序而连续的。从1开始，群内每增加一条消息，LastestSeq就会增加1
static const char* kTIMGroupBaseInfoReadedSeq    = "group_base_info_readed_seq";     // uint,   只读, 用户所在群已读的消息Seq
static const char* kTIMGroupBaseInfoMsgFlag      = "group_base_info_msg_flag";       // uint,   只读, 消息接收选项
static const char* kTIMGroupBaseInfoIsShutupAll  = "group_base_info_is_shutup_all";  // bool,   只读, 当前群组是否设置了全员禁言
static const char* kTIMGroupBaseInfoSelfInfo     = "group_base_info_self_info";      // object [GroupSelfInfo](), 只读, 用户所在群的个人信息
// EndStruct

/**
* @brief 群组详细信息
*/
// Struct GroupDetailInfo JsonKey
static const char* kTIMGroupDetialInfoGroupId          = "group_detial_info_group_id";           // string, 只读, 群组ID
static const char* kTIMGroupDetialInfoGroupType        = "group_detial_info_group_type";         // uint [TIMGroupType](), 只读, 群组类型
static const char* kTIMGroupDetialInfoGroupName        = "group_detial_info_group_name";         // string, 只读, 群组名称
static const char* kTIMGroupDetialInfoNotification     = "group_detial_info_notification";       // string, 只读, 群组公告
static const char* kTIMGroupDetialInfoIntroduction     = "group_detial_info_introduction";       // string, 只读, 群组简介
static const char* kTIMGroupDetialInfoFaceUrl          = "group_detial_info_face_url";           // string, 只读, 群组头像URL
static const char* kTIMGroupDetialInfoCreateTime       = "group_detial_info_create_time";        // uint,   只读, 群组创建时间
static const char* kTIMGroupDetialInfoInfoSeq          = "group_detial_info_info_seq";           // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
static const char* kTIMGroupDetialInfoLastInfoTime     = "group_detial_info_last_info_time";     // uint,   只读, 群组信息最后修改时间
static const char* kTIMGroupDetialInfoNextMsgSeq       = "group_detial_info_next_msg_seq";       // uint,   只读, 群最新消息的Seq
static const char* kTIMGroupDetialInfoLastMsgTime      = "group_detial_info_last_msg_time";      // uint,   只读, 最新群组消息时间
static const char* kTIMGroupDetialInfoMemberNum        = "group_detial_info_member_num";         // uint,   只读, 群组当前成员数量
static const char* kTIMGroupDetialInfoMaxMemberNum     = "group_detial_info_max_member_num";     // uint,   只读, 群组最大成员数量
static const char* kTIMGroupDetialInfoAddOption        = "group_detial_info_add_option";         // uint [TIMGroupAddOption](), 只读, 群组加群选项
static const char* kTIMGroupDetialInfoOnlineMemberNum  = "group_detial_info_online_member_num";  // uint,   只读, 群组在线成员数量
static const char* kTIMGroupDetialInfoVisible          = "group_detial_info_visible";            // uint,   只读, 群组成员是否对外可见
static const char* kTIMGroupDetialInfoSearchable       = "group_detial_info_searchable";         // uint,   只读, 群组是否能被搜索
static const char* kTIMGroupDetialInfoIsShutupAll      = "group_detial_info_is_shutup_all";      // bool,   只读, 群组是否被设置了全员禁言
static const char* kTIMGroupDetialInfoOwnerIdentifier  = "group_detial_info_owener_identifier";  // string, 只读, 群组所有者ID
static const char* kTIMGroupDetialInfoCustomInfo       = "group_detial_info_custom_info";        // array [GroupInfoCustemString](), 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群组信息列表接口的返回
*/
// Struct GetGroupInfoResult JsonKey
static const char* kTIMGetGroupInfoResultCode  = "get_groups_info_result_code";    // int [错误码](https://cloud.tencent.com/document/product/269/1671),   只读, 获取群组详细信息的结果
static const char* kTIMGetGroupInfoResultDesc  = "get_groups_info_result_desc";    // string, 只读, 获取群组详细失败的描述信息
static const char* kTIMGetGroupInfoResultInfo  = "get_groups_info_result_info";    // object [GroupDetailInfo](), 只读, 群组详细信息
// EndStruct

/**
* @brief 设置(修改)群组信息的类型
*/
enum TIMGroupModifyInfoFlag {
    kTIMGroupModifyInfoFlag_None         = 0x00,
    kTIMGroupModifyInfoFlag_Name         = 0x01,       // 修改群组名称
    kTIMGroupModifyInfoFlag_Notification = 0x01 << 1,  // 修改群公告
    kTIMGroupModifyInfoFlag_Introduction = 0x01 << 2,  // 修改群简介
    kTIMGroupModifyInfoFlag_FaceUrl      = 0x01 << 3,  // 修改群头像URL
    kTIMGroupModifyInfoFlag_AddOption    = 0x01 << 4,  // 修改群组添加选项
    kTIMGroupModifyInfoFlag_MaxMmeberNum = 0x01 << 5,  // 修改群最大成员数
    kTIMGroupModifyInfoFlag_Visible      = 0x01 << 6,  // 修改群是否可见
    kTIMGroupModifyInfoFlag_Searchable   = 0x01 << 7,  // 修改群是否允许被搜索
    kTIMGroupModifyInfoFlag_ShutupAll    = 0x01 << 8,  // 修改群是否全体禁言
    kTIMGroupModifyInfoFlag_Custom       = 0x01 << 9,  // 修改群自定义信息
    kTIMGroupModifyInfoFlag_Owner        = 0x01 << 31, // 修改群主

};

/**
* @brief 设置群信息接口的参数
*/
// Struct GroupModifyInfoParam JsonKey
static const char* kTIMGroupModifyInfoParamGroupId           = "group_modify_info_param_group_id";        // string, 只写(必填), 群组ID
static const char* kTIMGroupModifyInfoParamModifyFlag        = "group_modify_info_param_modify_flag";     // uint [TIMGroupModifyInfoFlag](),  只写(必填), 修改标识,可设置多个值按位或
static const char* kTIMGroupModifyInfoParamGroupName         = "group_modify_info_param_group_name";      // string, 只写(选填), 修改群组名称,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_Name 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamNotification      = "group_modify_info_param_notification";    // string, 只写(选填), 修改群公告,        当 modify_flag 包含 kTIMGroupModifyInfoFlag_Notification 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamIntroduction      = "group_modify_info_param_introduction";    // string, 只写(选填), 修改群简介,        当 modify_flag 包含 kTIMGroupModifyInfoFlag_Introduction 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamFaceUrl           = "group_modify_info_param_face_url";        // string, 只写(选填), 修改群头像URL,     当 modify_flag 包含 kTIMGroupModifyInfoFlag_FaceUrl 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamAddOption         = "group_modify_info_param_add_option";      // uint,  只写(选填), 修改加群方式,       当 modify_flag 包含 kTIMGroupModifyInfoFlag_AddOption 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamMaxMemberNum      = "group_modify_info_param_max_member_num";  // uint,  只写(选填), 修改群最大成员数,    当 modify_flag 包含 kTIMGroupModifyInfoFlag_MaxMmeberNum 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamVisible           = "group_modify_info_param_visible";         // uint,  只写(选填), 修改群是否可见,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_Visible 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamSearchAble        = "group_modify_info_param_searchable";      // uint,  只写(选填), 修改群是否允许被搜索, 当 modify_flag 包含 kTIMGroupModifyInfoFlag_Searchable 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamIsShutupAll       = "group_modify_info_param_is_shutup_all";   // bool,   只写(选填), 修改群是否全体禁言,  当 modify_flag 包含 kTIMGroupModifyInfoFlag_ShutupAll 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamOwner             = "group_modify_info_param_owner";           // string, 只写(选填), 修改群主所有者,     当 modify_flag 包含 kTIMGroupModifyInfoFlag_Owner 时必填,其他情况不用填。此时 modify_flag 不能包含其他值，当修改群主时，同时修改其他信息已无意义
static const char* kTIMGroupModifyInfoParamCustomInfo        = "group_modify_info_param_custom_info";     // array [GroupInfoCustemString](), 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群成员列表接口的参数
*/
// Struct GroupGetMemberInfoListParam JsonKey
static const char* kTIMGroupGetMemberInfoListParamGroupId         = "group_get_members_info_list_param_group_id";          // string,       只写(必填), 群组ID
static const char* kTIMGroupGetMemberInfoListParamIdentifierArray = "group_get_members_info_list_param_identifier_array";  // array string, 只写(选填), 群成员ID列表
static const char* kTIMGroupGetMemberInfoListParamOption          = "group_get_members_info_list_param_option";            // object [GroupMemberGetInfoOption](), 只写(选填), 获取群成员信息的选项
static const char* kTIMGroupGetMemberInfoListParamNextSeq         = "group_get_members_info_list_param_next_seq";          // uint64, 只写(选填), 分页拉取标志,第一次拉取填0,回调成功如果不为零,需要分页,调用接口传入再次拉取,直至为0
// EndStruct

/**
* @brief 获取群成员列表接口的返回
*/
// Struct GroupGetMemberInfoListResult JsonKey
static const char* kTIMGroupGetMemberInfoListResultNexSeq     = "group_get_memeber_info_list_result_next_seq";   // uint64, 只读, 下一次拉取的标志,server返回0表示没有更多的数据,否则在下次获取数据时填入这个标志
static const char* kTIMGroupGetMemberInfoListResultInfoArray  = "group_get_memeber_info_list_result_info_array"; // array [GroupMemberInfo](), 只读, 成员信息列表
// EndStruct


/**
* @brief 设置(修改)群成员信息的类型
*/
enum TIMGroupMemberModifyInfoFlag {
    kTIMGroupMemberModifyFlag_None       = 0x00,      // 
    kTIMGroupMemberModifyFlag_MsgFlag    = 0x01,      // 修改消息接收选项
    kTIMGroupMemberModifyFlag_MemberRole = 0x01 << 1, // 修改成员角色
    kTIMGroupMemberModifyFlag_ShutupTime = 0x01 << 2, // 修改禁言时间
    kTIMGroupMemberModifyFlag_NameCard   = 0x01 << 3, // 修改群名片
    kTIMGroupMemberModifyFlag_Custom     = 0x01 << 4, // 修改群成员自定义信息
};
/**
* @brief 设置群成员信息接口的参数
*/
// Struct GroupModifyMemberInfoParam JsonKey
static const char* kTIMGroupModifyMemberInfoParamGroupId     = "group_modify_member_info_group_id";       // string, 只写(必填), 群组ID
static const char* kTIMGroupModifyMemberInfoParamIdentifier  = "group_modify_member_info_identifier";     // string, 只写(必填), 被设置信息的成员ID
static const char* kTIMGroupModifyMemberInfoParamModifyFlag  = "group_modify_member_info_modify_flag";    // uint [TIMGroupMemberModifyInfoFlag](), 只写(必填), 修改类型,可设置多个值按位或
static const char* kTIMGroupModifyMemberInfoParamMsgFlag     = "group_modify_member_info_msg_flag";       // uint,[TIMReceiveMessageOpt]   只写(选填), 修改消息接收选项,                  当 modify_flag 包含 kTIMGroupMemberModifyFlag_MsgFlag 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamMemberRole  = "group_modify_member_info_member_role";    // uint [TIMGroupMemberRole](), 只写(选填), 修改成员角色, 当 modify_flag 包含 kTIMGroupMemberModifyFlag_MemberRole 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamShutupTime  = "group_modify_member_info_shutup_time";    // uint,   只写(选填), 修改禁言时间,                      当 modify_flag 包含 kTIMGroupMemberModifyFlag_ShutupTime 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamNameCard    = "group_modify_member_info_name_card";      // string, 只写(选填), 修改群名片,                        当 modify_flag 包含 kTIMGroupMemberModifyFlag_NameCard 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamCustomInfo  = "group_modify_member_info_custom_info";    // array [GroupMemberInfoCustemString](), 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群未决信息列表的参数
*/
// Struct GroupPendencyOption JsonKey
static const char* kTIMGroupPendencyOptionStartTime     = "group_pendency_option_start_time";       // uint64, 只写(必填), 设置拉取时间戳,第一次请求填0,后边根据server返回的[GroupPendencyResult]()键kTIMGroupPendencyResultNextStartTime指定的时间戳进行填写
static const char* kTIMGroupPendencyOptionMaxLimited    = "group_pendency_option_max_limited";      // uint,   只写(选填), 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志
// EndStruct


/**
* @brief 未决请求类型
*/
enum TIMGroupPendencyType {
    kTIMGroupPendency_RequestJoin = 0,  // 请求加群
    kTIMGroupPendency_InviteJoin = 1,   // 邀请加群
    kTIMGroupPendency_ReqAndInvite = 2, // 邀请和请求的
};

/**
* @brief 群未决处理状态
*/
enum TIMGroupPendencyHandle {
    kTIMGroupPendency_NotHandle = 0,      // 未处理
    kTIMGroupPendency_OtherHandle = 1,    // 他人处理
    kTIMGroupPendency_OperatorHandle = 2, // 操作方处理
};

/**
* @brief 群未决处理操作类型
*/
enum TIMGroupPendencyHandleResult {
    kTIMGroupPendency_Refuse = 0,  // 拒绝
    kTIMGroupPendency_Accept = 1,  // 同意
};

/**
* @brief 群未决信息定义
*/
// Struct GroupPendency JsonKey
static const char* kTIMGroupPendencyGroupId             = "group_pendency_group_id";                //string,  读写, 群组ID
static const char* kTIMGroupPendencyFromIdentifier      = "group_pendency_form_identifier";         //string,  读写, 请求者的ID,例如：请求加群:请求者,邀请加群:邀请人
static const char* kTIMGroupPendencyToIdentifier        = "group_pendency_to_identifier";           //string,  读写, 判决者的 ID，处理此条“加群的未决请求”的管理员ID
static const char* kTIMGroupPendencyAddTime             = "group_pendency_add_time";                //uint64,  只读, 未决信息添加时间
static const char* kTIMGroupPendencyPendencyType        = "group_pendency_pendency_type";           //uint [TIMGroupPendencyType](),  只读, 未决请求类型
static const char* kTIMGroupPendencyHandled             = "group_pendency_handled";                 //uint [TIMGroupPendencyHandle](),只读, 群未决处理状态
static const char* kTIMGroupPendencyHandleResult        = "group_pendency_handle_result";           //uint [TIMGroupPendencyHandleResult](), 只读, 群未决处理操作类型
static const char* kTIMGroupPendencyApplyInviteMsg      = "group_pendency_apply_invite_msg";        //string, 只读, 申请或邀请附加信息
static const char* kTIMGroupPendencyFromUserDefinedData = "group_pendency_form_user_defined_data";  //string, 只读, 申请或邀请者自定义字段
static const char* kTIMGroupPendencyApprovalMsg         = "group_pendency_approval_msg";            //string, 只读, 审批信息：同意或拒绝信息
static const char* kTIMGroupPendencyToUserDefinedData   = "group_pendency_to_user_defined_data";    //string, 只读, 审批者自定义字段
static const char* kTIMGroupPendencyKey                 = "group_pendency_key";                     //string, 只读, 签名信息，客户不用关心
static const char* kTIMGroupPendencyAuthentication      = "group_pendency_authentication";          //string, 只读, 签名信息，客户不用关心
static const char* kTIMGroupPendencySelfIdentifier      = "group_pendency_self_identifier";         //string, 只读, 自己的ID
// EndStruct

/**
* @brief 获取群未决信息列表的返回
*/
// Struct GroupPendencyResult JsonKey
static const char* kTIMGroupPendencyResultNextStartTime = "group_pendency_result_next_start_time";  // uint64, 只读, 下一次拉取的起始时戳,server返回0表示没有更多的数据,否则在下次获取数据时以这个时间戳作为开始时间戳
static const char* kTIMGroupPendencyResultReadTimeSeq   = "group_pendency_result_read_time_seq";    // uint64, 只读, 已读上报的时间戳
static const char* kTIMGroupPendencyResultUnReadNum     = "group_pendency_result_unread_num";       // uint,   只读, 未决请求的未读数
static const char* kTIMGroupPendencyResultPendencyArray = "group_pendency_result_pendency_array";   // array [GroupPendency](), 只读, 群未决信息列表
// EndStruct

/**
* @brief 处理群未决消息接口的参数
*/
// Struct GroupHandlePendencyParam JsonKey
static const char* kTIMGroupHandlePendencyParamIsAccept   = "group_handle_pendency_param_is_accept";  // bool,   只写(选填), true表示接受，false表示拒绝。默认为false
static const char* kTIMGroupHandlePendencyParamHandleMsg  = "group_handle_pendency_param_handle_msg"; // string, 只写(选填), 同意或拒绝信息,默认为空字符串
static const char* kTIMGroupHandlePendencyParamPendency   = "group_handle_pendency_param_pendency";   // object [GroupPendency](), 只写(必填), 未决信息详情
// EndStruct

/// @}

/**
* @brief 获取指定群在线人数结果
*/
// Struct GroupGetOnlineMemberCountResult JsonKey
static const char* TIMGroupGetOnlineMemberCountResulCount  = "group_get_online_member_count_result";  // int, 只读, 指定群的在线人数
// EndStruct

/// @}

/**
 * @brief 群搜索 Field 的枚举
 */
enum TIMGroupSearchFieldKey {
    kTIMGroupSearchFieldKey_GroupId = 0x01,  //  群 ID
    kTIMGroupSearchFieldKey_GroupName = 0x01 << 1, // 群名称
};

/**
 * @brief 群成员搜索 Field 的枚举
 */
enum TIMGroupMemberSearchFieldKey {
    kTIMGroupMemberSearchFieldKey_Identifier = 0x01, // 用户 ID
    kTIMGroupMemberSearchFieldKey_NikeName = 0x01 << 1, // 昵称
    kTIMGroupMemberSearchFieldKey_Remark = 0x01 << 2, // 备注
    kTIMGroupMemberSearchFieldKey_NameCard = 0x01 << 3,  // 名片
};

/**
* @brief  群搜索参数
*/
// Struct GroupSearchParam JsonKey
static const char* TIMGroupSearchParamKeywordList  = "group_search_params_keyword_list";  // array string 搜索关键字列表，最多支持5个 
static const char* TIMGroupSearchParamFieldList  = "group_search_params_field_list";  // array [TIMGroupSearchFieldKey] 搜索域列表表
// EndStruct

/**
* @brief 群成员搜索参数
*/
// Struct GroupMemberSearchParam JsonKey
static const char* TIMGroupMemberSearchParamGroupidList  = "group_search_member_params_groupid_list";  // array string 指定群 ID 列表，若为不填则搜索全部群中的群成员
static const char* TIMGroupMemberSearchParamKeywordList  = "group_search_member_params_keyword_list";  // array string 搜索关键字列表，最多支持5个
static const char* TIMGroupMemberSearchParamFieldList  = "group_search_member_params_field_list";  // array [TIMGroupMemberSearchFieldKey] 搜索域列表
// EndStruct

/**
* @brief 群成员结果
*/
// Struct GroupSearchGroupMembersdResult JsonKey
static const char* TIMGroupSearchGroupMembersdResultGroupID = "group_search_member_result_groupid";  // array string 群 id 列表
static const char* TIMGroupSearchGroupMembersdResultMemberInfoList = "group_search_member_result_menber_info_list";  // array [GroupMemberInfo] 群成员的列表
// EndStruct

/**
* @brief 设置群属性的 map 对象
*/
// Struct GroupAttributes JsonKey
static const char* TIMGroupAttributeKey = "group_atrribute_key";  // string  群属性 map 的 key
static const char* TIMGroupAttributeValue = "group_atrribute_value";  // string 群属性 map 的 value
// EndStruct

/**
* @brief 处理群未决消息接口的参数
*/
// Struct FriendShipGetProfileListParam JsonKey
static const char* kTIMFriendShipGetProfileListParamIdentifierArray = "friendship_getprofilelist_param_identifier_array";  // array string, 只写, 想要获取目标用户资料的UserID列表
static const char* kTIMFriendShipGetProfileListParamForceUpdate     = "friendship_getprofilelist_param_force_update";      // bool,         只写, 是否强制更新。false表示优先从本地缓存获取，获取不到则去网络上拉取。true表示直接去网络上拉取资料。默认为false
// EndStruct

/**
* @brief 用户性别类型
*/
enum TIMGenderType {
    kTIMGenderType_Unkown, // 未知性别
    kTIMGenderType_Male,   // 性别男
    kTIMGenderType_Female, // 性别女
};

/**
* @brief 用户加好友的选项
*/
enum TIMProfileAddPermission {
    kTIMProfileAddPermission_Unknown,       // 未知
    kTIMProfileAddPermission_AllowAny,      // 允许任何人添加好友
    kTIMProfileAddPermission_NeedConfirm,   // 添加好友需要验证
    kTIMProfileAddPermission_DenyAny,       // 拒绝任何人添加好友
};

/**
* @brief 用户自定义资料字段，字符串
*
* @note
* 字符串长度不得超过500字节
*/
// Struct UserProfileCustemStringInfo JsonKey
static const char* kTIMUserProfileCustemStringInfoKey   = "user_profile_custom_string_info_key";   // string, 只写, 用户自定义资料字段的key值（包含前缀Tag_Profile_Custom_）
static const char* kTIMUserProfileCustemStringInfoValue = "user_profile_custom_string_info_value"; // string, 只写, 该字段对应的字符串值
// EndStruct

/**
 * @brief 用户个人资料
 */
// Struct UserProfile JsonKey
static const char* kTIMUserProfileIdentifier         = "user_profile_identifier";            // string,                           只读, 用户ID
static const char* kTIMUserProfileNickName           = "user_profile_nick_name";             // string,                           只读, 用户的昵称
static const char* kTIMUserProfileGender             = "user_profile_gender";                // uint [TIMGenderType](),           只读, 性别
static const char* kTIMUserProfileFaceUrl            = "user_profile_face_url";              // string,                           只读, 用户头像URL
static const char* kTIMUserProfileSelfSignature      = "user_profile_self_signature";        // string,                           只读, 用户个人签名
static const char* kTIMUserProfileAddPermission      = "user_profile_add_permission";        // uint [TIMProfileAddPermission](), 只读, 用户加好友的选项
static const char* kTIMUserProfileLocation           = "user_profile_location";              // string,                           只读, 用户位置信息
static const char* kTIMUserProfileLanguage           = "user_profile_language";              // uint,                             只读, 语言
static const char* kTIMUserProfileBirthDay           = "user_profile_birthday";              // uint,                             只读, 生日
static const char* kTIMUserProfileLevel              = "user_profile_level";                 // uint,                             只读, 等级
static const char* kTIMUserProfileRole               = "user_profile_role";                  // uint,                             只读, 角色
static const char* kTIMUserProfileCustomStringArray  = "user_profile_custom_string_array";   // array [UserProfileCustemStringInfo](), 只读, 请参考[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)
// EndStruct

/**
 * @brief 自身资料可修改的各个项
 */
// Struct UserProfileItem JsonKey
static const char* kTIMUserProfileItemNickName          = "user_profile_item_nick_name";           // string,                           只写, 修改用户昵称
static const char* kTIMUserProfileItemGender            = "user_profile_item_gender";              // uint [TIMGenderType](),           只写, 修改用户性别
static const char* kTIMUserProfileItemFaceUrl           = "user_profile_item_face_url";            // string,                           只写, 修改用户头像
static const char* kTIMUserProfileItemSelfSignature     = "user_profile_item_self_signature";      // string,                           只写, 修改用户签名
static const char* kTIMUserProfileItemAddPermission     = "user_profile_item_add_permission";      // uint [TIMProfileAddPermission](), 只写, 修改用户加好友的选项
static const char* kTIMUserProfileItemLoaction          = "user_profile_item_location";            // uint,                             只写, 修改位置
static const char* kTIMUserProfileItemLanguage          = "user_profile_item_language";            // uint,                             只写, 修改语言
static const char* kTIMUserProfileItemBirthDay          = "user_profile_item_birthday";            // uint,                             只写, 修改生日
static const char* kTIMUserProfileItemLevel             = "user_profile_item_level";               // uint,                             只写, 修改等级
static const char* kTIMUserProfileItemRole              = "user_profile_item_role";                // uint,                             只写, 修改角色
static const char* kTIMUserProfileItemCustomStringArray = "user_profile_item_custom_string_array"; // array [UserProfileCustemStringInfo](), 只写, 修改[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)
// EndStruct

/**
 * @brief 好友自定义资料字段
 */
// Struct FriendProfileCustemStringInfo JsonKey
static const char* kTIMFriendProfileCustemStringInfoKey   = "friend_profile_custom_string_info_key";   // string, 只写, 好友自定义资料字段key
static const char* kTIMFriendProfileCustemStringInfoValue = "friend_profile_custom_string_info_value"; // string, 只写, 好友自定义资料字段value
// EndStruct

/**
* @brief 好友资料
*/
// Struct FriendProfile JsonKey
static const char* kTIMFriendProfileIdentifier          = "friend_profile_identifier";          // string,       只读, 好友UserID
static const char* kTIMFriendProfileGroupNameArray      = "friend_profile_group_name_array";    // array string, 只读, 好友分组名称列表
static const char* kTIMFriendProfileRemark              = "friend_profile_remark";              // string,       只读, 好友备注，最大96字节，获取自己资料时，该字段为空
static const char* kTIMFriendProfileAddWording          = "friend_profile_add_wording";         // string,       只读, 好友申请时的添加理由
static const char* kTIMFriendProfileAddSource           = "friend_profile_add_source";          // string,       只读, 好友申请时的添加来源
static const char* kTIMFriendProfileAddTime             = "friend_profile_add_time";            // uint64,       只读, 好友添加时间
static const char* kTIMFriendProfileUserProfile         = "friend_profile_user_profile";        // object [UserProfile](), 只读, 好友的个人资料
static const char* kTIMFriendProfileCustomStringArray   = "friend_profile_custom_string_array"; // array [FriendProfileCustemStringInfo](), 只读, [自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)
// EndStruct

/**
 * @brief 好友资料可修改的各个项
 */
// Struct FriendProfileItem JsonKey
static const char* kTIMFriendProfileItemRemark            = "friend_profile_item_remark";               // string,       只写, 修改好友备注
static const char* kTIMFriendProfileItemGroupNameArray    = "friend_profile_item_group_name_array";     // array string, 只写, 修改好友分组名称列表
static const char* kTIMFriendProfileItemCustomStringArray = "friend_profile_item_custom_string_array";  // array [FriendProfileCustemStringInfo](), 只写, 修改[自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)
// EndStruct

/**
 * @brief 好友类型
 */
enum TIMFriendType {
    FriendTypeSignle,  // 单向好友：用户A的好友表中有用户B，但B的好友表中却没有A
    FriendTypeBoth,    // 双向好友：用户A的好友表中有用户B，B的好友表中也有A
};

/**
* @brief 添加好友接口的参数
*/
// Struct FriendshipAddFriendParam JsonKey
static const char* kTIMFriendshipAddFriendParamIdentifier = "friendship_add_friend_param_identifier";  // string, 只写, 请求加好友对应的UserID
static const char* kTIMFriendshipAddFriendParamFriendType = "friendship_add_friend_param_friend_type"; // uint [TIMFriendType](), 只写, 请求添加好友的好友类型
static const char* kTIMFriendshipAddFriendParamRemark     = "friendship_add_friend_param_remark";      // string, 只写, 预备注
static const char* kTIMFriendshipAddFriendParamGroupName  = "friendship_add_friend_param_group_name";  // string, 只写, 预分组名
static const char* kTIMFriendshipAddFriendParamAddSource  = "friendship_add_friend_param_add_source";  // string, 只写, 加好友来源描述
static const char* kTIMFriendshipAddFriendParamAddWording = "friendship_add_friend_param_add_wording"; // string, 只写, 加好友附言
// EndStruct


/**
 * @brief 关系链操作接口的返回
 */
 // Struct FriendResult JsonKey
static const char* kTIMFriendResultIdentifier = "friend_result_identifier"; // string, 只读, 关系链操作的用户ID
static const char* kTIMFriendResultCode = "friend_result_code";       // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 关系链操作的结果
static const char* kTIMFriendResultDesc = "friend_result_desc";       // string, 只读, 关系链操作失败的详细描述
// EndStruct

/**
 * @brief 修改好友资料接口的参数
 */
// Struct FriendshipModifyFriendProfileParam JsonKey
static const char* kTIMFriendshipModifyFriendProfileParamIdentifier = "friendship_modify_friend_profile_param_identifier";  // string, 只写, 被修改的好友的UserID
static const char* kTIMFriendshipModifyFriendProfileParamItem       = "friendship_modify_friend_profile_param_item";        // object [FriendProfileItem](), 只写, 修改的好友资料各个选项
// EndStruct


/**
 * @brief 好友添加请求未决信息
 */
// Struct FriendAddPendency JsonKey
static const char* kTIMFriendAddPendencyIdentifier = "friend_add_pendency_identifier";  // string, 只读, 添加好友请求方的UserID
static const char* kTIMFriendAddPendencyNickName   = "friend_add_pendency_nick_name";   // string, 只读, 添加好友请求方的昵称
static const char* kTIMFriendAddPendencyAddSource  = "friend_add_pendency_add_source";  // string, 只读, 添加好友请求方的来源
static const char* kTIMFriendAddPendencyAddWording = "friend_add_pendency_add_wording"; // string, 只读, 添加好友请求方的附言
// EndStruct

/**
 * @brief 好友添加请求未决类型
 */
enum TIMFriendPendencyType {
    FriendPendencyTypeComeIn,  // 别人发给我的
    FriendPendencyTypeSendOut, // 我发给别人的
    FriendPendencyTypeBoth,    // 双向的
};

/**
 * @brief 翻页获取好友添加请求未决信息列表的参数
 */
 // Struct FriendshipGetPendencyListParam JsonKey
 static const char* kTIMFriendshipGetPendencyListParamType        = "friendship_get_pendency_list_param_type";         // uint [TIMFriendPendencyType](), 只写, 添加好友的未决请求类型
 static const char* kTIMFriendshipGetPendencyListParamStartSeq    = "friendship_get_pendency_list_param_start_seq";    // uint64, 只写, 分页获取未决请求的起始 seq，返回的结果包含最大 seq，作为获取下一页的起始 seq
 static const char* kTIMFriendshipGetPendencyListParamStartTime   = "friendship_get_pendency_list_param_start_time";   // uint64, 只写, 获取未决信息的开始时间戳
 static const char* kTIMFriendshipGetPendencyListParamLimitedSize = "friendship_get_pendency_list_param_limited_size"; // int,    只写, 获取未决信息列表，每页的数量
 // EndStruct


/**
 * @brief 好友添加请求未决信息
 */
// Struct PendencyPage JsonKey
static const char* kTIMPendencyPageStartTime          = "pendency_page_start_time";           // uint64, 只读, 未决请求信息页的起始时间
static const char* kTIMPendencyPageUnReadNum          = "pendency_page_unread_num";           // uint64, 只读, 未决请求信息页的未读数量
static const char* kTIMPendencyPageCurrentSeq         = "pendency_page_current_seq";          // uint64, 只读, 未决请求信息页的当前Seq
static const char* kTIMPendencyPagePendencyInfoArray  = "pendency_page_pendency_info_array";  // array [FriendAddPendencyInfo](), 只读, 未决请求信息页的未决信息列表
// EndStruct


/**
 * @brief 好友添加请求未决信息
 */
// Struct FriendAddPendencyInfo JsonKey
static const char* kTIMFriendAddPendencyInfoType       = "friend_add_pendency_info_type";          // uint [TIMFriendPendencyType](), 只读, 好友添加请求未决类型
static const char* kTIMFriendAddPendencyInfoIdentifier = "friend_add_pendency_info_idenitifer";    // string, 只读, 好友添加请求未决的UserID
static const char* kTIMFriendAddPendencyInfoNickName   = "friend_add_pendency_info_nick_name";     // string, 只读, 好友添加请求未决的昵称
static const char* kTIMFriendAddPendencyInfoAddTime    = "friend_add_pendency_info_add_time";      // uint64, 只读, 发起好友申请的时间
static const char* kTIMFriendAddPendencyInfoAddSource  = "friend_add_pendency_info_add_source";    // string, 只读, 好友添加请求未决的添加来源
static const char* kTIMFriendAddPendencyInfoAddWording = "friend_add_pendency_info_add_wording";   // string, 只读, 好友添加请求未决的添加附言
// EndStruct

/**
 * @brief 删除好友添加请求未决信息接口的参数
 */
// Struct FriendshipDeletePendencyParam JsonKey
static const char* kTIMFriendshipDeletePendencyParamType            = "friendship_delete_pendency_param_type";              // uint [TIMFriendPendencyType](), 只读, 添加好友的未决请求类型
static const char* kTIMFriendshipDeletePendencyParamIdentifierArray = "friendship_delete_pendency_param_identifier_array";  // array string, 只读, 删除好友未决请求的UserID列表
// EndStruct

/**
 * @brief 好友添加请求响应的动作类型
 */
enum TIMFriendResponseAction {
    ResponseActionAgree,       // 同意
    ResponseActionAgreeAndAdd, // 同意并添加
    ResponseActionReject,      // 拒绝
};

/**
 * @brief 好友添加的响应
 */
// Struct FriendRespone JsonKey
static const char* kTIMFriendResponeIdentifier = "friend_respone_identifier"; // string, 只写(必填), 响应好友添加的UserID
static const char* kTIMFriendResponeAction     = "friend_respone_action";     // uint [TIMFriendResponseAction](), 只写(必填), 响应好友添加的动作
static const char* kTIMFriendResponeRemark     = "friend_respone_remark";     // string, 只写(选填), 好友备注
static const char* kTIMFriendResponeGroupName  = "friend_respone_group_name"; // string, 只写(选填), 好友分组列表
// EndStruct


/**
 * @brief 删除好友接口的参数
 */
// Struct FriendshipDeleteFriendParam JsonKey
static const char* kTIMFriendshipDeleteFriendParamFriendType      = "friendship_delete_friend_param_friend_type";       // uint [TIMFriendType](), 只写, 删除好友，指定删除的好友类型
static const char* kTIMFriendshipDeleteFriendParamIdentifierArray = "friendship_delete_friend_param_identifier_array";  // array string, 只写(选填), 删除好友UserID列表
// EndStruct

/**
 * @brief 好友分组信息
 */
// Struct FriendGroupInfo JsonKey
static const char* kTIMFriendshipCreateFriendGroupParamNameArray       = "friendship_create_friend_group_param_name_array";        // array string, 只写, 创建分组的名称列表
static const char* kTIMFriendshipCreateFriendGroupParamIdentifierArray = "friendship_create_friend_group_param_identifier_array";  // array string, 只写, 要放到创建的分组的好友UserID列表
// EndStruct

/**
 * @brief 好友分组信息
 */
// Struct FriendGroupInfo JsonKey
static const char* kTIMFriendGroupInfoName            = "friend_group_info_name";              // string,       只读, 分组名称
static const char* kTIMFriendGroupInfoCount           = "friend_group_info_count";             // uint64,       只读, 当前分组的好友个数
static const char* kTIMFriendGroupInfoIdentifierArray = "friend_group_info_identifier_array";  // array string, 只读, 当前分组内好友UserID列表
// EndStruct

/**
 * @brief 修改好友分组信息的接口参数
 */
// Struct FriendshipModifyFriendGroupParam JsonKey
static const char* kTIMFriendshipModifyFriendGroupParamName                  = "friendship_modify_friend_group_param_name";                     // string, 只写, 要修改的分组名称
static const char* kTIMFriendshipModifyFriendGroupParamNewName               = "friendship_modify_friend_group_param_new_name";                 // string, 只写(选填), 修改后的分组名称
static const char* kTIMFriendshipModifyFriendGroupParamDeleteIdentifierArray = "friendship_modify_friend_group_param_delete_identifier_array";  // array string, 只写(选填), 要从当前分组删除的好友UserID列表
static const char* kTIMFriendshipModifyFriendGroupParamAddIdentifierArray    = "friendship_modify_friend_group_param_add_identifier_array";     // array string, 只写(选填), 当前分组要新增的好友UserID列表
// EndStruct


/**
 * @brief 检测好友的类型接口的参数
 */
// Struct FriendshipCheckFriendTypeParam JsonKey
static const char* kTIMFriendshipCheckFriendTypeParamCheckType       = "friendship_check_friendtype_param_check_type";        // uint [TIMFriendType](), 只写, 要检测的好友类型
static const char* kTIMFriendshipCheckFriendTypeParamIdentifierArray = "friendship_check_friendtype_param_identifier_array";  // array string, 只写, 要检测的好友UserID列表
// EndStruct

/**
 * @brief 二者之间的关系
 */
enum TIMFriendCheckRelation {
    FriendCheckNoRelation,  // 无关系
    FriendCheckAWithB,      // 仅A中有B
    FriendCheckBWithA,      // 仅B中有A
    FriendCheckBothWay,     // 双向
};

/**
 * @brief 检测好友的类型接口返回
 */
// Struct FriendshipCheckFriendTypeResult JsonKey
static const char* kTIMFriendshipCheckFriendTypeResultIdentifier = "friendship_check_friendtype_result_identifier"; // string, 只读, 被检测的好友UserID
static const char* kTIMFriendshipCheckFriendTypeResultRelation   = "friendship_check_friendtype_result_relation";   // uint [TIMFriendCheckRelation](), 只读, 检测成功时返回的二者之间的关系
static const char* kTIMFriendshipCheckFriendTypeResultCode       = "friendship_check_friendtype_result_code";       // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 检测的结果
static const char* kTIMFriendshipCheckFriendTypeResultDesc       = "friendship_check_friendtype_result_desc";       // string, 只读, 检测好友失败的描述信息
// EndStruct


/**
 * @brief 好友搜索的枚举
 */
enum TIMFriendshipSearchFieldKey {
    kTIMFriendshipSearchFieldKey_Identifier = 0x01,  // 用户 ID
    kTIMFriendshipSearchFieldKey_NikeName = 0x01 << 1, // 昵称
    kTIMFriendshipSearchFieldKey_Remark = 0x01 << 2, // 备注
};

/**
 * @brief 搜索好友的参数
 */
// Struct FriendSearchParam JsonKey
static const char* kTIMFriendshipSearchParamKeywordList = "friendship_search_param_keyword_list"; // array string, 只写, 搜索的关键字列表，关键字列表最多支持 5 个
static const char* kTIMFriendshipSearchParamSearchFieldList  = "friendship_search_param_search_field_list";   // array int, 只写 [TIMFriendshipSearchFieldKey]() 好友搜索类型
// EndStruct


/**
 * @brief 二者之间的关系
 */
enum TIMFriendshipRelationType {
    kTIMFriendshipRelationType_None,  // 未知关系
    kTIMFriendshipRelationType_InMyFriendList,    // 单向好友：对方是我的好友，我不是对方的好友
    kTIMFriendshipRelationType_InOtherFriendList,      // 单向好友：对方不是我的好友，我是对方的好友
    kTIMFriendshipRelationType_BothFriend,      // 双向好友
};

/**
 * @brief 搜索好友结果
 */
// Struct FriendInfoGetResult JsonKey
static const char* kTIMFriendshipFriendInfoGetResultIdentifier = "friendship_friend_info_get_result_identifier"; // string, 只读, 好友 user_id
static const char* kTIMFriendshipFriendInfoGetResultRelationType  = "friendship_friend_info_get_result_relation_type";   // uint [TIMFriendshipRelationType], 只读， 好友关系
static const char* kTIMFriendshipFriendInfoGetResultErrorCode  = "friendship_friend_info_get_result_error_code";   // uint， 只读，错误码
static const char* kTIMFriendshipFriendInfoGetResultErrorMessage  = "friendship_friend_info_get_result_error_message";   // string, 只读， 错误描述
static const char* kTIMFriendshipFriendInfoGetResultFriendInfo  = "friendship_friend_info_get_result_field_info";   // array [FriendProfile], 只读, 好友资料

// EndStruct

#endif //SRC_PLATFORM_CROSS_PLATFORM_INCLUDE_TIM_CLOUD_DEF_H_
