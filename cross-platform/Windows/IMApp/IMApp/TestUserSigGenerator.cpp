/*
* Module:   TestUserSigGenerator
*
* Function: 用于获取 TIMLogin 接口所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 IM 功能不被盗用
*/

#include "TestUserSigGenerator.h"
#include "./usersig/include/tls_signature.h"

TestUserSigGenerator::TestUserSigGenerator()
{

}

TestUserSigGenerator::~TestUserSigGenerator()
{

}

TestUserSigGenerator& TestUserSigGenerator::instance()
{
    static TestUserSigGenerator uniqueInstance;
    return uniqueInstance;
}

std::string TestUserSigGenerator::genTestUserSig(const std::string& userId)
{
    std::string sig;
    gen_sig(_sdkAppId, userId, _PRIVATEKEY, sig);

    return sig;
}
