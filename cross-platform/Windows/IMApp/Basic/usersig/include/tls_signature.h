#ifndef  CHECK_LICENCE_H
#define  CHECK_LICENCE_H

#if defined(WIN32) || defined(WIN64)
#pragma warning(disable: 4819)			// file codec warning, that's boring!
#define TLS_API __declspec(dllexport)
#else
#define TLS_API
#endif

#include <stdint.h>

#include <string>

/*
 * tls_gen_signature_ex 接收一系列参数，返回 sig
 *
 * @param dwExpire 过期时长，以秒为单位，建议不超过一个月，如果签名有效期为 10 天，那就填 10*24*3600
 * @param strAppid3Rd 第三方开放平台账号 appid，如果是自有的账号，那么直接填 sdkappid 的字符串形式
 * @param dwSdkAppid 创建应用时页面上分配的 sdkappid
 * @param strIdentifier 用户标示符，也就是我们常说的用户 id
 * @param dwAccountType 创建应用时页面上分配的 accounttype
 * @param strSig 返回的 sig
 * @param pPriKey 私钥内容，请注意不是私钥文件名
 * @param uPriKeyLen 私钥内容长度
 * @param strErrMsg 如果出错这里出错信息
 *
 * @return 0 表示成功，非 0 表示失败，失败信息会在 strErrMsg 中给出
 */
TLS_API int tls_gen_signature_ex(
    uint32_t dwExpire,
    const std::string& strAppid3Rd,
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    uint32_t dwAccountType,
    std::string& strSig,
    const char* pPriKey,
    uint32_t uPriKeyLen,
    std::string& strErrMsg
);

/*
 * @brief tls_gen_signature_ex2_with_expire 接收一系列参数，返回 sig
 *
 * @param dwSdkAppid 创建应用时页面上分配的 sdkappid
 * @param strIdentifier 用户标示符，也就是我们常说的用户 id
 * @param dwExpire 开发者自定义的有效期，单位是秒，推荐时长为 1 个月
 * @param strSig 返回的 sig
 * @param strPriKey 私钥内容，请注意不是私钥文件名
 * @param strErrMsg 如果出错这里出错信息
 *
 * @return 0 表示成功，非 0 表示失败，失败信息会在 strErrMsg 中给出
 */
TLS_API int tls_gen_signature_ex2_with_expire(
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    uint32_t dwExpire,
    std::string& strSig,
    std::string& strPriKey,
    std::string& strErrMsg);

/*
 * @brief tls_gen_signature_ex2 接收一系列参数，返回 sig，有效采用默认的180天
 *
 * @param dwSdkAppid 创建应用时页面上分配的 sdkappid
 * @param strIdentifier 用户标示符，也就是我们常说的用户 id
 * @param strSig 返回的 sig
 * @param strPriKey 私钥内容，请注意不是私钥文件名
 * @param strErrMsg 如果出错这里出错信息
 *
 * @return 0 表示成功，非 0 表示失败，失败信息会在 strErrMsg 中给出
 */
TLS_API int tls_gen_signature_ex2(
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    std::string& strSig,
    std::string& strPriKey,
    std::string& strErrMsg    
);

/**
 * @brief 描述 sig 内容的结构体，各个字段的含义可以参考 tls_gen_signature_ex()
 * @see tls_gen_signature_ex()
 */
typedef struct
{
	std::string strAccountType;
	std::string strAppid3Rd;
	std::string strAppid;            /**< 即 sdkappid  */
	std::string strIdentify;
} SigInfo;

/**
 * @brief 校验签名，兼容目前所有版本。
 * @param sig 签名内容
 * @param key 密钥，如果是早期非对称版本，那么这里是公钥
 * @param pubKeyLen 密钥内容长度
 * @param sigInfo 需要校验的签名明文信息
 * @param expireTime 传出参数，有效期，单位秒
 * @param initTime 传出参数，签名生成的 unix 时间戳
 * @param errMsg 传出参数，如果出错，这里有错误信息
 * @return 0 为成功，非 0 为失败
 */
TLS_API int tls_check_signature_ex(
    const std::string& sig,
    const char* key,
    uint32_t pubKeyLen,
    const SigInfo& sigInfo,
    uint32_t& expireTime,
    uint32_t& initTime,
    std::string& errMsg);

/**
 * @brief 验证 sig 是否合法
 *
 * @param strSig sig 的内容
 * @param strPubKey 公钥的内容
 * @param dwSdkAppid 应用的 sdkappid
 * @param strIdentifier 用户id，会与 sig 中的值进行对比
 * @param dwExpireTime 返回 sig 的有效期
 * @param dwInitTime 返回 sig 的生成时间
 * @param strErrMsg 如果出错，这里有错误信息
 *
 * @return 0 表示成功，非 0 表示失败，strErrMsg 中有失败信息
 */
TLS_API int tls_check_signature_ex2(
    const std::string& strSig,
    const std::string& strPubKey,
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    uint32_t& dwExpireTime,
    uint32_t& dwInitTime,
    std::string& strErrMsg
);

/**
 * @brief 生成 sig，此函数已“不推荐”使用
 * @see tls_check_signature_ex()
 *
 * @param strJson 输入参数的 json 串
 * strJson 示例
 * {
 *     "TLS.account_type": "107",
 *     "TLS.appid_at_3rd": "150000000",
 *     "TLS.identity": "xxx_openid",
 *     "TLS.sdk_appid": "150000000",
 *     "TLS.expire_after": "86400"
 * }
 * 值得说明的是 TLS.appid_at_3rd，如果不是第三方开放平台的账号，那么这个字段填写与 TLS.sdk_appid 一致就可以了。
 * @param strSig 返回 sig 的内容
 * @param pPriKey 私钥内容，注意不是私钥文件的路径
 * @param uPriKeyLen 私钥内容的长度
 * @param strErrMsg 如果出错，这里有出错信息
 * @param dwFlag 为时间格式，目前默认即可
 *
 * @return 返回 0 表示成功，非 0 失败，strErrMsg 有出错信息
 */
TLS_API int tls_gen_signature(
    const std::string& strJson,
    std::string& strSig,
    const char* pPriKey,
    uint32_t uPriKeyLen,
    std::string& strErrMsg,
    uint32_t dwFlag = 0
    );

enum {
	CHECK_ERR1  =  1,       // sig 为空
	CHECK_ERR2 ,            // sig base64 解码失败
	CHECK_ERR3 ,            // sig zip 解压缩失败
	CHECK_ERR4 ,            // sig 使用 json 解析时失败
	CHECK_ERR5 ,            // sig 使用 json 解析时失败
	CHECK_ERR6 ,            // sig 中 json 串 sig 字段 base64 解码失败
	CHECK_ERR7 ,            // sig 中字段缺失
	CHECK_ERR8 ,            // sig 校验签名失败，一般是秘钥不正确
	CHECK_ERR9 ,            // sig 过期
	CHECK_ERR10 ,           // sig 使用 json 解析时失败
	CHECK_ERR11 ,           // sig 中 appid_at_3rd 与明文不匹配
	CHECK_ERR12 ,           // sig 中 acctype 与明文不匹配
	CHECK_ERR13 ,           // sig 中 identifier 与明文不匹配
	CHECK_ERR14 ,           // sig 中 sdk_appid 与明文不匹配
    CHECK_ERR15 ,           // sig 中 userbuf 异常
    CHECK_ERR16 ,           // 内部错误
    CHECK_ERR17 ,           // 签名失败 可能是私钥有误

	CHECK_ERR_MAX,
};

#define API_VERSION "201803230000"

/*
 * @brief tls_gen_userbuf_ticket
 *
 * @param dwSdkAppid 创建应用时页面上分配的 sdkappid
 * @param strIdentifier 用户标示符，也就是我们常说的用户 id
 * @param dwExpire 开发者自定义的有效期，单位是秒
 * @param strSig 返回的 sig
 * @param strPriKey 私钥内容，请注意不是私钥文件名
 * @param strUserbuf 用户自定义内容
 * @param strErrMsg 如果出错这里出错信息
 *
 * @return 0 表示成功，非 0 表示失败，失败信息会在 strErrMsg 中给出
 */
TLS_API int tls_gen_userbuf_ticket(
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    uint32_t dwExpire,
    const std::string& strPriKey,
    const std::string& strUserbuf,
    std::string& strTicket,
    std::string& strErrMsg);

/**
 * @brief 验证 sig 是否合法
 *
 * @param strSig sig 的内容
 * @param strPubKey 公钥的内容
 * @param dwSdkAppid 应用的 sdkappid
 * @param strIdentifier 用户id，会与 sig 中的值进行对比
 * @param dwExpireTime 返回 sig 的有效期
 * @param dwInitTime 返回 sig 的生成时间
 * @param strUserbuf 返回生成时的userbuf
 * @param strErrMsg 如果出错，这里有错误信息
 *
 * @return 0 表示成功，非 0 表示失败，strErrMsg 中有失败信息
 */
TLS_API int tls_check_userbuf_ticket(
    const std::string& strTicket,
    const std::string& strPubKey,
    uint32_t dwSdkAppid,
    const std::string& strIdentifier,
    uint32_t& dwExpireTime,
    uint32_t& dwInitTime,
    std::string& strUserbuf,
    std::string& strErrMsg
);

TLS_API int gen_sig(uint32_t sdkappid, const std::string& identifier, const std::string& priKey, std::string& sig);

/**
 * @brief 生成签名函数 v2 版本
 * @param sdkappid 应用ID
 * @param identifier 用户账号，utf-8 编码
 * @param key 密钥
 * @param expire 有效期，单位秒
 * @param errMsg 错误信息
 * @return 0 为成功，非 0 为失败
 */
TLS_API int gen_sig_v2(uint32_t sdkappid, const std::string& identifier,
		const std::string& key, int expire, std::string& sig, std::string& errMsg);

int thread_setup();
void thread_cleanup();

namespace tls_signature_inner {
TLS_API int SigToJson(const std::string &sig, std::string &json, std::string  &errmsg);
}

#endif

