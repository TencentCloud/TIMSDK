/*
* Module:   GenerateTestUserSig
*
* Function: 用于获取 TIMLogin 接口所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 IM 功能不被盗用
*/

#include "GenerateTestUserSig.h"
#include "./usersig/include/tls_signature.h"

GenerateTestUserSig::GenerateTestUserSig()
{

}

GenerateTestUserSig::~GenerateTestUserSig()
{

}

GenerateTestUserSig& GenerateTestUserSig::instance()
{
    static GenerateTestUserSig uniqueInstance;
    return uniqueInstance;
}

uint32_t GenerateTestUserSig::getSdkAppId() const
{
    return _sdkAppId;
}

std::string GenerateTestUserSig::genTestUserSig(const std::string& userId)
{
    std::string sig;
    gen_sig(_sdkAppId, userId, _PRIVATEKEY, sig);

    return sig;
}
