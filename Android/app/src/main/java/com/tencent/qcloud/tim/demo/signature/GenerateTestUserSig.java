package com.tencent.qcloud.tim.demo.signature;

import com.tencent.qcloud.tim.demo.utils.Constants;

import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.bouncycastle.util.Arrays;
import org.bouncycastle.util.encoders.Base64;
import org.json.JSONObject;

import java.io.CharArrayReader;
import java.io.IOException;
import java.io.Reader;
import java.nio.charset.Charset;
import java.security.PrivateKey;
import java.security.Security;
import java.security.Signature;
import java.util.zip.Deflater;

/*
 * Module:   GenerateTestUserSig
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
public class GenerateTestUserSig {

    /**
     * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
     *
     * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) 创建应用，即可看到 SDKAppId，
     * 它是腾讯云用于区分客户的唯一标识。
     */
    private static final int SDKAPPID = Constants.SDKAPPID;


    /**
     *  签名过期时间，建议不要设置的过短
     *
     *  时间单位：秒
     *  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
     */
    private static final int EXPIRETIME = 604800;


    /**
     * 计算签名用的非对称私钥，需要替换为您自己账号下的私钥。
     *
     * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) 创建一个应用，
     * 单击应用名称进入应用详情页面，即可以获得签名用的私钥下载链接。
     *
     * 单击【点击下载公私钥】，会得到 keys.zip 的压缩文件，解压后会生成 private_key 和
     * public_key 两个文件，其中 private_key 就是我们需要的私钥文件。
     */
    private static final String PRIVATEKEY = "-----BEGIN PRIVATE KEY-----\n" +
        "MIGHAgEAMBM  “无效”的私钥样例，仅仅代码编写参考   GBB6RtS7EMWX\n" +
        "nnXrYKui2gM  “无效”的私钥样例，仅仅代码编写参考   IlzTwqs0DD03\n" +
        "ELuZK8EIQWA  “无效”的私钥样例，仅仅代码编写参考   pBKP\n" +
        "-----END PRIVATE KEY-----\n";


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
    public static String genTestUserSig(String userId) {
        return GenTLSSignature(EXPIRETIME, "0", SDKAPPID, userId, 0, PRIVATEKEY);
    }

    /**
     * 生成 tls 票据
     *
     * @param expire        有效期，单位是秒
     * @param appid3rd      填写与 sdkAppid 一致字符串形式的值
     * @param sdkappid      应用的 appid
     * @param identifier    用户 id
     * @param accountType   创建应用后在配置页面上展示的 acctype
     * @param priKeyContent 生成 tls 票据使用的私钥内容
     * @return 如果出错，GenTLSSignatureResult 中的 urlSig为空，errMsg 为出错信息，成功返回有效的票据
     */
    private static String GenTLSSignature(long expire, String appid3rd, long sdkappid, String identifier,
                                          long accountType, String priKeyContent) {

        GenTLSSignatureResult result = new GenTLSSignatureResult();

        Security.addProvider(new BouncyCastleProvider());
        Reader reader = new CharArrayReader(priKeyContent.toCharArray());
        JcaPEMKeyConverter converter = new JcaPEMKeyConverter();
        PEMParser parser = new PEMParser(reader);
        PrivateKey privKeyStruct;
        try {
            Object obj = parser.readObject();
            parser.close();
            privKeyStruct = converter.getPrivateKey((PrivateKeyInfo) obj);
        } catch (Exception e) {
            result.errMessage = "read pem error:" + e.getMessage();
            return null;
        }

        //Create Json string and serialization String
        String jsonString = "{"
                + "\"TLS.account_type\":\"" + accountType + "\","
                + "\"TLS.identifier\":\"" + identifier + "\","
                + "\"TLS.appid_at_3rd\":\"" + appid3rd + "\","
                + "\"TLS.sdk_appid\":\"" + sdkappid + "\","
                + "\"TLS.expire_after\":\"" + expire + "\""
                + "}";
        //System.out.println("#jsonString : \n" + jsonString);

        String time = String.valueOf(System.currentTimeMillis() / 1000);
        String SerialString =
                "TLS.appid_at_3rd:" + appid3rd + "\n" +
                        "TLS.account_type:" + accountType + "\n" +
                        "TLS.identifier:" + identifier + "\n" +
                        "TLS.sdk_appid:" + sdkappid + "\n" +
                        "TLS.time:" + time + "\n" +
                        "TLS.expire_after:" + expire + "\n";

        try {
            //Create Signature by SerialString
            Signature signature = null;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                signature = Signature.getInstance("SHA256withECDSA"); //适配Android P及以后版本，否则报错NoSuchAlgorithmException
            } else {
                signature = Signature.getInstance("SHA256withECDSA", "BC");
            }
            signature.initSign(privKeyStruct);
            signature.update(SerialString.getBytes(Charset.forName("UTF-8")));
            byte[] signatureBytes = signature.sign();

            String sigTLS = Base64.toBase64String(signatureBytes);

            //Add TlsSig to jsonString
            JSONObject jsonObject = new JSONObject(jsonString);
            jsonObject.put("TLS.sig", sigTLS);
            jsonObject.put("TLS.time", time);
            jsonString = jsonObject.toString();

            //compression
            Deflater compresser = new Deflater();
            compresser.setInput(jsonString.getBytes(Charset.forName("UTF-8")));

            compresser.finish();
            byte[] compressBytes = new byte[512];
            int compressBytesLength = compresser.deflate(compressBytes);
            compresser.end();

            result.urlSig = new String(Base64Url.base64EncodeUrl(Arrays.copyOfRange(compressBytes, 0, compressBytesLength)));
        } catch (Exception e) {
            e.printStackTrace();
            result.errMessage = e.getMessage();
            return null;
        }

        return result.urlSig;
    }

    private static class GenTLSSignatureResult {
        public String errMessage;
        public String urlSig;

        public GenTLSSignatureResult() {
            errMessage = "";
            urlSig = "";
        }
    }

}
