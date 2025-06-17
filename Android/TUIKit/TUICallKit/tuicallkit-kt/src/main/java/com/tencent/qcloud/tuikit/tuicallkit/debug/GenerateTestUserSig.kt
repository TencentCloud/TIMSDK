package com.tencent.qcloud.tuikit.tuicallkit.debug

import android.util.Base64
import org.json.JSONException
import org.json.JSONObject
import java.nio.charset.Charset
import java.util.Arrays
import java.util.zip.Deflater
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/*
* Description: Generates UserSig for testing. UserSig is a security signature designed
*           by Tencent Cloud for its cloud services.
*           It is calculated based on `SDKAppID`, `UserID`,
*           and `EXPIRETIME` using the HMAC-SHA256 encryption algorithm.
*
* Attention: For the following reasons, do not use the code below in your commercial application.
*
*            The code may be able to calculate UserSig correctly, b
*            ut it is only for quick testing of the SDK’s basic features,
*            not for commercial applications.
*            `SECRETKEY` in client code can be easily decompiled and reversed, especially on web.
*            Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
*
*            The correct method is to deploy the `UserSig` calculation code and encryption key on your server
*            so that your application can request a `UserSig` from your server,
*            which will calculate it whenever one is needed.
*            Given that it is more difficult to hack a server than a client application,
*            server-end calculation can better protect your key.
*
* Reference: https://www.tencentcloud.com/document/product/1047/34385
*/
object GenerateTestUserSig {
    /**
     * Signature validity period, which should not be set too short
     *
     *
     * Unit: Second
     * Default value: 7 x 24 x 60 x 60 = 604800 (seven days)
     */
    private const val EXPIRETIME = 604800

    /**
     * Calculating UserSig
     *
     *
     * The asymmetric encryption algorithm HMAC-SHA256 is used in the
     * function to calculate UserSig based on `SDKAppID`, `UserID`, and `EXPIRETIME`.
     *
     * @note: For the following reasons, do not use the code below in your commercial application.
     *
     *
     * The code may be able to calculate UserSig correctly,
     * but it is only for quick testing of the SDK’s basic features,
     * not for commercial applications.
     * SECRETKEY in client code can be easily decompiled and reversed, especially on web.
     * Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
     *
     *
     * The correct method is to deploy the `UserSig` calculation code and encryption key on your server
     * so that your application can request a `UserSig` from your server,
     * which will calculate it whenever one is needed.
     * Given that it is more difficult to hack a server than a client application,
     * server-end calculation can better protect your key.
     *
     *
     * Documentation: https://www.tencentcloud.com/document/product/1047/34385
     */
    @JvmStatic
    fun genTestUserSig(userId: String, sdkAppId: Int, secretKey: String): String {
        return genTLSSignature(sdkAppId.toLong(), userId, EXPIRETIME.toLong(), null, secretKey)
    }

    /**
     * Generating a TLS Ticket
     *
     * @param sdkappId      `appid` of your application
     * @param userId        User ID
     * @param expire        Validity period in seconds
     * @param userbuf       `null` by default
     * @param priKeyContent Private key required for generating a TLS ticket
     * @return If an error occurs, an empty string will be returned or exceptions printed.
     * If the operation succeeds, a valid ticket will be returned.
     */
    private fun genTLSSignature(
        sdkappId: Long, userId: String, expire: Long, userbuf: ByteArray?, priKeyContent: String
    ): String {
        if (priKeyContent.isNullOrEmpty()) {
            return ""
        }
        val currTime = System.currentTimeMillis() / 1000
        val sigDoc = JSONObject()
        try {
            sigDoc.put("TLS.ver", "2.0")
            sigDoc.put("TLS.identifier", userId)
            sigDoc.put("TLS.sdkappid", sdkappId)
            sigDoc.put("TLS.expire", expire)
            sigDoc.put("TLS.time", currTime)
        } catch (e: JSONException) {
            e.printStackTrace()
        }

        var base64UserBuf: String? = null
        if (null != userbuf) {
            base64UserBuf = Base64.encodeToString(userbuf, Base64.NO_WRAP)
            try {
                sigDoc.put("TLS.userbuf", base64UserBuf)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
        val sig = hmacsha256(sdkappId, userId, currTime, expire, priKeyContent, base64UserBuf)
        if (sig.length == 0) {
            return ""
        }
        try {
            sigDoc.put("TLS.sig", sig)
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        val compressor = Deflater()
        compressor.setInput(sigDoc.toString().toByteArray(Charset.forName("UTF-8")))
        compressor.finish()
        val compressedBytes = ByteArray(2048)
        val compressedBytesLength = compressor.deflate(compressedBytes)
        compressor.end()
        return String(base64EncodeUrl(Arrays.copyOfRange(compressedBytes, 0, compressedBytesLength)))
    }


    private fun hmacsha256(
        sdkappid: Long, userId: String, currTime: Long, expire: Long, priKeyContent: String,
        base64Userbuf: String?
    ): String {
        var contentToBeSigned = """
            TLS.identifier:$userId
            TLS.sdkappid:$sdkappid
            TLS.time:$currTime
            TLS.expire:$expire
            
            """.trimIndent()
        if (null != base64Userbuf) {
            contentToBeSigned += "TLS.userbuf:$base64Userbuf\n"
        }
        try {
            val byteKey = priKeyContent.toByteArray(charset("UTF-8"))
            val hmac = Mac.getInstance("HmacSHA256")
            val keySpec = SecretKeySpec(byteKey, "HmacSHA256")
            hmac.init(keySpec)
            val byteSig = hmac.doFinal(contentToBeSigned.toByteArray(charset("UTF-8")))
            return String(Base64.encode(byteSig, Base64.NO_WRAP))
        } catch (e: Exception) {
            e.printStackTrace()
            return ""
        }
    }

    private fun base64EncodeUrl(input: ByteArray): ByteArray {
        val base64 = String(Base64.encode(input, Base64.NO_WRAP)).toByteArray()
        for (i in base64.indices) {
            when (base64[i]) {
                '+'.code.toByte() -> base64[i] = '*'.code.toByte()
                '/'.code.toByte() -> base64[i] = '-'.code.toByte()
                '='.code.toByte() -> base64[i] = '_'.code.toByte()
                else -> {}
            }
        }
        return base64
    }
}