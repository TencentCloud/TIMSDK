import {
    TIMErrCode,
    TIMGenderType,
    TIMGroupGetInfoFlag,
    TIMInternalOperation,
    TIMLogLevel,
    TIMProfileAddPermission,
    TIMResult,
} from "../enum";
import { libMethods } from "./libMethodInterface";

interface CommonCallbackFun {
    (code: number, desc: string, json_param: string, user_data?: any): void;
}
interface GroupReadMembersCallback {
    (
        json_group_member_array: string,
        next_seq: number,
        is_finished: boolean,
        user_data?: any
    ): void;
}
interface CommonCallbackFuns {
    (code: number, desc: string, json_params: string, user_data?: any): void;
}
interface initConfig {
    sdkappid: number;
}

interface sdkconfig {
    sdkappid: number;
    consoleTag: string;
    Imsdklib: libMethods;
}
/**
 * @param {TIMResult | TIMErrCode} code code：返回状态码 每个返回值的定义请参考 [IM文档](https://cloud.tencent.com/document/product/269/1671)
 * @param {string} [desc]   describe
 * @param {string} [json_param]  json_param：根据具具体接口返回
 * @param {string | undefined} [json_params] json_params：兼容的字段，某些情况下会返回这个，根据具体接口返回
 * @param {string | undefined} [user_data] user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
//[TimResult](../../doc/enums/timresult.html)
interface commonResponse {
    code: TIMResult | TIMErrCode;
    desc?: string | undefined;
    json_param?: string | undefined;
    json_params?: string | undefined; // 兼容
    user_data?: string | undefined;
}
/**
 * @param {number} status 网络状态，请参考[TIMNetworkStatus](TIMCloudDef.h)
 * @param {code} code 值为ERR_SUCC表示成功，其他值表示失败。详情请参考 [错误码](https://cloud.tencent.com/document/product/269/1671)
 * @param {string} desc 错误描述字符串
 * @param {string} user_data ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMSetNetworkStatusListenerCallback {
    (status: number, code: number, desc: string, user_data?: any): void;
}
/**
 * @param {string} user_data ImSDK负责透传的用户自定义数据，未做任何处理
 * @return {void}
 *
 */
interface TIMSetKickedOfflineCallback {
    (user_data: string): void;
}
interface TIMSetUserSigExpiredCallback {
    (user_data: string): void;
}
/**
 * @param {TIMSetNetworkStatusListenerCallback} callback callback
 * @param {string} user_data user_data户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface TIMSetNetworkStatusListenerCallbackParam {
    callback: TIMSetNetworkStatusListenerCallback;
    userData: string;
}
/**
 * @brief 设置被踢下线通知回调
 * @param {TIMSetKickedOfflineCallback} callback callback 踢下线回调
 * @param {string} userData userData用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 *
 */
interface TIMSetKickedOfflineCallbackParam {
    callback: TIMSetKickedOfflineCallback;
    userData: string;
}
interface TIMSetUserSigExpiredCallbackParam {
    callback: TIMSetUserSigExpiredCallback;
    userData: string;
}
/**
 * @param {number} level 日志级别
 * @param {string} log 日志字符串
 * @param {string} user_data ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMLogCallbackFun {
    (level: number, log: string, user_data: string): void;
}
/**
 * @prop {string} user_data  user_data(可选参数)
 * @param {TIMLogCallbackFun} callback callback
 */
interface TIMSetLogCallbackParam {
    callback: TIMLogCallbackFun;
    user_data?: string;
}
interface GroupGetInfoConfig {
    group_get_info_option_info_flag?: TIMGroupGetInfoFlag;
    group_get_info_option_custom_array?: Array<string>;
}
/**
 * @prop {number} group_member_get_info_option_info_flag  group_member_get_info_option_info_flag:根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
 * @param {number} group_member_get_info_option_role_flag group_member_get_info_option_role_flag:根据成员角色过滤，默认值为kTIMGroupMemberRoleFlag_All，获取所有角色
 * @param {Array<string>} group_member_get_info_option_custom_array 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 */
interface GroupMemberInfoOption {
    group_member_get_info_option_info_flag?: number;
    group_member_get_info_option_role_flag?: number;
    group_member_get_info_option_custom_array?: Array<string>;
}
/**
 * @brief 用于配置信息
 * @param {boolean} user_config_is_read_receipt user_config_is_read_receipt：true表示要收已读回执事件
 * @param {boolean} user_config_is_sync_report user_config_is_sync_report：true表示服务端要删掉已读状态
 * @param {boolean} user_config_is_ingore_grouptips_unread user_config_is_ingore_grouptips_unread：true表示群tips不计入群消息已读计数
 * @param {boolean} user_config_is_is_disable_storage user_config_is_is_disable_storage：是否禁用本地数据库，true表示禁用，false表示不禁用。默认是false
 * @param {boolean} user_config_group_getinfo_option user_config_group_getinfo_option：获取群组信息默认选项
 * @param {boolean} user_config_group_member_getinfo_option user_config_group_member_getinfo_option：获取群组成员信息默认选项
 */
interface UserConfig {
    user_config_is_read_receipt?: boolean;
    user_config_is_sync_report?: boolean;
    user_config_is_ingore_grouptips_unread?: boolean;
    user_config_is_is_disable_storage?: boolean;
    user_config_group_getinfo_option?: GroupGetInfoConfig;
    user_config_group_member_getinfo_option?: GroupMemberInfoOption;
}
/**
 * @param {string} http_proxy_info_ip http_proxy_info_ip：代理的IP
 * @param {number} http_proxy_info_port http_proxy_info_port:代理的端口
 * @param {string} http_proxy_info_username http_proxy_info_username:认证的用户名
 * @param {string} http_proxy_info_password   http_proxy_info_password: 认证的密码
 */
interface HttpProxyInfo {
    http_proxy_info_ip?: string;
    http_proxy_info_port?: number;
    http_proxy_info_username?: string;
    http_proxy_info_password?: string;
}
/**
 * @param {string} socks5_proxy_info_ip socks5_proxy_info_ip：代理的IP
 * @param {number} socks5_proxy_info_port socks5_proxy_info_port:代理的端口
 * @param {string} socks5_proxy_info_username socks5_proxy_info_username:认证的用户名
 * @param {string} socks5_proxy_info_password socks5_proxy_info_password:认证的密码
 */
interface Socks5ProxyInfo {
    socks5_proxy_info_ip?: string;
    socks5_proxy_info_port?: number;
    socks5_proxy_info_username?: string;
    socks5_proxy_info_password?: string;
}
/**
 * @param {TIMLogLevel} set_config_log_level set_config_log_level：日志级别
 * @param {set_config_callback_log_level} set_config_callback_log_level set_config_callback_log_level:日志回调的日志级别
 * @param {boolean} set_config_is_log_output_console set_config_is_log_output_console:是否输出到控制台，默认为 true
 * @param {UserConfig} set_config_user_config   set_config_user_config: 用户配置
 * @param {string} set_config_user_define_data set_config_user_define_data: 自定义数据，如果需要，初始化前设置
 * @param {HttpProxyInfo} set_config_http_proxy_info set_config_http_proxy_info: 设置HTTP代理，如果需要，在发送图片、文件、语音、视频前设置
 * @param {Socks5ProxyInfo} set_config_socks5_proxy_info set_config_socks5_proxy_info:  设置SOCKS5代理，如果需要，初始化前设置
 * @param {boolean} set_config_is_only_local_dns_source set_config_is_only_local_dns_source: 如果为true，SDK内部会在选择最优IP时只使用LocalDNS
 */
interface JSONCongfig {
    set_config_log_level?: TIMLogLevel;
    set_config_callback_log_level?: TIMLogLevel;
    set_config_is_log_output_console?: boolean;
    set_config_user_config?: UserConfig;
    set_config_user_define_data?: string;
    set_config_http_proxy_info?: HttpProxyInfo;
    set_config_socks5_proxy_info?: Socks5ProxyInfo;
    set_config_is_only_local_dns_source?: boolean;
}
/**
 * @brief 服务器地址
 * @param {string} server_address_ip server_address_ip：服务器 IP
 * @param {number} server_address_port server_address_port：服务器端口
 */
interface ServerAddress {
    server_address_ip: string;
    server_address_port: number;
}
/**
 * @brief 自定义服务器信息
 * @param {Array<ServerAddress>} longconnection_address_array longconnection_address_array：array [ServerAddress](), 长连接服务器地址列表
 * @param {Array<ServerAddress>} shortconnection_address_array shortconnection_address_array：array [ServerAddress](), 只读, 短连接服务器地址列表
 * @param {string} server_public_key server_public_key：string, 只写(必填), 服务器公钥
 */
interface PrivatizationInfo {
    longconnection_address_array?: Array<ServerAddress>;
    shortconnection_address_array?: Array<ServerAddress>;
    server_public_key: string;
}
/**
 * @param {PrivatizationInfo} request_internal_operation request_internal_operation: 内部接口的操作类型
 *  @param {PrivatizationInfo} request_set_custom_server_info_param request_set_custom_server_info_param:自定义服务器信息, 当 kTIMRequestInternalOperation 为 kTIMInternalOperationSetCustomServerInfo 时需要设置
 */
interface callExperimentalAPIJsonParam {
    request_internal_operation: TIMInternalOperation;
    request_set_ui_platform_param?: string;
    request_set_custom_server_info_param?: PrivatizationInfo;
}
/**
 * @param {JSONCongfig}  json_config json_config:设置额外的用户配置
 * @param {CommonCallbackFun} callback callback:回调函数
 * @param {string} user_data user_data:用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface TIMSetConfigParam {
    json_config: JSONCongfig;
    callback: CommonCallbackFun;
    user_data: string;
}
/**
 * @param {callExperimentalAPIJsonParam} callExperimentalAPIJsonParam callExperimentalAPIJsonParam
 * @param {string} user_data user_data: 用户自定义数据
 */
interface callExperimentalAPIParam {
    json_param: callExperimentalAPIJsonParam;
    user_data?: string;
}
/**
 * @param {Array<string>} friendship_getprofilelist_param_identifier_array friendship_getprofilelist_param_identifier_array:想要获取目标用户资料的UserID列表
 * @param {boolean} friendship_getprofilelist_param_force_update friendship_getprofilelist_param_force_update: 是否强制更新。false表示优先从本地缓存获取，获取不到则去网络上拉取。true表示直接去网络上拉取资料。默认为false
 */
interface jsonGetUserProfileListParam {
    friendship_getprofilelist_param_identifier_array: Array<string>;
    friendship_getprofilelist_param_force_update: boolean;
}
/**
 * @param {jsonGetUserProfileListParam} json_get_user_profile_list_param json_get_user_profile_list_param:获取指定用户列表的用户资料接口参数的Json字符串
 * @param {string} user_data user_data: 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 *
 *> jsonGetUserProfileListParam的interface：
 *>```
 *>   jsonGetUserProfileListParam:
 *>  {
 *>   friendship_getprofilelist_param_identifier_array: Array<string>;  //获取指定用户列表的用户资料接口参数的Json字符串
 *>   friendship_getprofilelist_param_force_update: boolean;  //用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 *>  }
 *>```
 */
interface TIMProfileGetUserProfileListParam {
    json_get_user_profile_list_param: jsonGetUserProfileListParam;
    user_data: string;
}
/**
 * @brief 用户自定义资料字段，字符串
 *
 * @note
 * 字符串长度不得超过500字节
 * @param {string} user_profile_custom_string_info_key user_profile_custom_string_info_key:用户自定义资料字段的key值（包含前缀Tag_Profile_Custom_）
 * @param {string} user_profile_custom_string_info_value user_profile_custom_string_info_value:该字段对应的字符串值
 */
interface UserProfileCustemStringInfo {
    user_profile_custom_string_info_key: string;
    user_profile_custom_string_info_value: string;
}
/**
 * @brief 自身资料可修改的各个项
 * @param {string} user_profile_item_nick_name user_profile_item_nick_name:修改用户昵称
 * @param {string} user_profile_item_gender user_profile_item_gender:修改用户性别
 * @param {string} user_profile_item_face_url user_profile_item_face_url:修改用户头像
 * @param {string} user_profile_item_self_signature user_profile_item_self_signature:修改用户签名
 * @param {string} user_profile_item_add_permission user_profile_item_add_permission:修改用户加好友的选项
 * @param {string} user_profile_item_location user_profile_item_location:修改位置
 * @param {string} user_profile_item_language user_profile_item_language:修改语言
 * @param {string} user_profile_item_birthday user_profile_item_birthday:修改生日
 * @param {string} user_profile_item_level user_profile_item_level:修改等级
 * @param {string} user_profile_item_role user_profile_item_role:修改角色
 * @param {string} user_profile_item_custom_string_array user_profile_item_custom_string_array:修改[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)
 */
interface UserProfileItem {
    user_profile_item_nick_name?: string;
    user_profile_item_gender?: TIMGenderType;
    user_profile_item_face_url?: string;
    user_profile_item_self_signature?: string;
    user_profile_item_add_permission?: TIMProfileAddPermission;
    user_profile_item_location?: number;
    user_profile_item_language?: number;
    user_profile_item_birthday?: number;
    user_profile_item_level?: number;
    user_profile_item_role?: number;
    user_profile_item_custom_string_array?: Array<UserProfileCustemStringInfo>;
}
/**
 * 
 * @param {UserProfileItem} json_modify_self_user_profile_param  json_modify_self_user_profile_param:修改自己的资料接口参数的Json字符串
 * @param {string} user_data user_data:修改自己的资料接口参数的Json字符串
 * 
 *> UserProfileItem的interface：  
 *>```
interface UserProfileItem {
    user_profile_item_nick_name?: string; //修改用户昵称
    user_profile_item_gender?: TIMGenderType; //修改用户性别
    user_profile_item_face_url?: string; // 修改用户头像
    user_profile_item_self_signature?: string; // 修改用户签名
    user_profile_item_add_permission?: TIMProfileAddPermission; // 修改用户加好友的选项
    user_profile_item_location?: number; // 修改位置
    user_profile_item_language?: number; // 修改语言
    user_profile_item_birthday?: number; // 修改生日
    user_profile_item_level?: number; // 修改等级
    user_profile_item_role?: number; // 修改角色
    user_profile_item_custom_string_array?: Array<UserProfileCustemStringInfo>; // 修改[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)
}
 *>```
 */
interface TIMProfileModifySelfUserProfileParam {
    json_modify_self_user_profile_param: UserProfileItem;
    user_data: string;
}
interface cache {
    callback: any;
    cb: any;
    user_data?: string;
}
interface initParam {
    config_path?: string;
}
export {
    initParam,
    initConfig,
    sdkconfig,
    CommonCallbackFun,
    commonResponse,
    TIMSetNetworkStatusListenerCallback,
    TIMSetKickedOfflineCallback,
    TIMSetUserSigExpiredCallback,
    TIMSetNetworkStatusListenerCallbackParam,
    TIMSetKickedOfflineCallbackParam,
    TIMSetUserSigExpiredCallbackParam,
    TIMLogCallbackFun,
    TIMSetLogCallbackParam,
    TIMSetConfigParam,
    callExperimentalAPIParam,
    TIMProfileGetUserProfileListParam,
    TIMProfileModifySelfUserProfileParam,
    cache,
    CommonCallbackFuns,
    GroupReadMembersCallback,
};
