#pragma once

/*
* Module:   TestUserSigGenerator
*
* Function: 用于生成测试用的 UserSig，UserSig 是腾讯云会用到的一种“签名”，
*           签名的计算方法是对 SDKAppID、UserID 和过期时间进行非对称签名，签名算法为 ECDSA-SHA256。
*
* Attention: 本文件所使用的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能。
*            因为客户端代码中的 _PRIVATEKEY 很容易被反编译逆向破解，一旦您的私钥泄露，攻击者就可以
*            盗用您的腾讯云流量，所以更推荐的做法是将 UserSig 的计算代码放在您的业务服务器上，
*            然后由您的 App 在需要的时候向您的业务服务器获取临时生成的 UserSig。
*
* Reference：https://cloud.tencent.com/document/product/269/32688
*/

#include <string>

class TestUserSigGenerator
{
	
private:
    TestUserSigGenerator();
    ~TestUserSigGenerator();
	
   /**
    * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
	*
	* 进入云通信[控制台]( https://console.cloud.tencent.com/avc ) 创建应用，即可看到 SDKAppId，
	* 它是腾讯云用于区分客户的唯一标识。
	*/
	const int _sdkAppId = 0;
	
	/**
	*  签名过期时间，建议不要设置的过短
	*
	*  时间单位：秒
	*  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
	*/
	const int _expireTime = 604800;

   /**
    * 计算签名用的非对称私钥，需要替换为您自己账号下的私钥。
	* 
	* 进入云通信[控制台]( https://console.cloud.tencent.com/avc )创建一个应用，
	* 单击应用配置进入应用详情页面，即可以获得签名用的私钥下载链接。
	*
	* 单击【点击下载公私钥】，会得到 keys.zip 的压缩文件，解压后会生成 public_key.txt 和
    * public_key.txt 两个文件，其中 public_key.txt 就是我们需要的私钥文件。
	*/
    const char* _PRIVATEKEY = "-----BEGIN PRIVATE KEY-----\n"
        "MIGHAgEAMBM  “无效”的私钥样例，仅仅代码编写参考   GBB4h682EMWX\n"
        "nnXrYKui2gM  “无效”的私钥样例，仅仅代码编写参考   Ilzaqs04A03\n"
        "ELuZK8EIQWA  “无效”的私钥样例，仅仅代码编写参考   pBKP\n"
        "-----END PRIVATE KEY-----\n";
		
public:
    static TestUserSigGenerator& instance();
	
	/**
	* 计算 UserSig 签名
	*
	* 函数内部使用 ECDSA-SHA256 非对称加密算法，对 _sdkAppId、userId 和 expireTime 进行加密。
	*
	* 本文件所使用的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能。
    * 因为客户端代码中的 _PRIVATEKEY 很容易被反编译逆向破解，一旦您的私钥泄露，攻击者就可以
    * 盗用您的腾讯云流量，所以更推荐的做法是将 UserSig 的计算代码放在您的业务服务器上，
    * 然后由您的 App 在需要的时候向您的业务服务器获取临时生成的 UserSig。
	*/
	std::string genTestUserSig(const std::string& userId);
};
