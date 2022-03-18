//
//  GenerateTestUserSig.swift
//  TRTCVoiceRoomApp
//
//  Created by abyyxwang on 2021/5/7.
//

import Foundation
import CommonCrypto
import zlib

/**
 * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */
let SDKAPPID: Int = 1400590001;

/**
 *  签名过期时间，建议不要设置的过短
 *
 *  时间单位：秒
 *  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */
let EXPIRETIME: Int = 604800;

/**
 * 计算签名用的加密密钥，获取步骤如下：
 *
 * step1. 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) ，如果还没有应用就创建一个，
 * step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
 *
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */
let SECRETKEY = "33c0dcda7a6177975500383473d7b7ac63ae6b3167afb3644e8aa1b267aeb377";

class GenerateTestUserSig {
    
    class func genTestUserSig(identifier: String) -> String {
        let current = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
        let TLSTime: CLong = CLong(floor(current))
        var obj: [String: Any] = [
            "TLS.ver": "2.0",
            "TLS.identifier": identifier,
            "TLS.sdkappid": SDKAPPID,
            "TLS.expire": EXPIRETIME,
            "TLS.time": TLSTime
        ]
        let keyOrder = [
            "TLS.identifier",
            "TLS.sdkappid",
            "TLS.time",
            "TLS.expire"
        ]
        var stringToSign = ""
        keyOrder.forEach { (key) in
            if let value = obj[key] {
                stringToSign += "\(key):\(value)\n"
            }
        }
        print("string to sign: \(stringToSign)")
        let sig = hmac(stringToSign)
        obj["TLS.sig"] = sig!
        print("sig: \(String(describing: sig))")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .sortedKeys) else { return "" }
        
        let bytes = jsonData.withUnsafeBytes { (result) -> UnsafePointer<Bytef> in
            return result.bindMemory(to: Bytef.self).baseAddress!
        }
        let srcLen: uLongf = uLongf(jsonData.count)
        let upperBound: uLong = compressBound(srcLen)
        let capacity: Int = Int(upperBound)
        let dest: UnsafeMutablePointer<Bytef> = UnsafeMutablePointer<Bytef>.allocate(capacity: capacity)
        var destLen = upperBound
        let ret = compress2(dest, &destLen, bytes, srcLen, Z_BEST_SPEED)
        if ret != Z_OK {
            print("[Error] Compress Error \(ret), upper bound: \(upperBound)")
            dest.deallocate()
            return ""
        }
        let count = Int(destLen)
        let result = self.base64URL(data: Data.init(bytesNoCopy: dest, count: count, deallocator: .free))
        return result
    }
    
    class func hmac(_ plainText: String) -> String? {
        let cKey = SECRETKEY.cString(using: String.Encoding.ascii)
        let cData = plainText.cString(using: String.Encoding.ascii)
        
        let cKeyLen = SECRETKEY.lengthOfBytes(using: .ascii)
        let cDataLen = plainText.lengthOfBytes(using: .ascii)
        
        var cHMAC = [CUnsignedChar].init(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let pointer = cHMAC.withUnsafeMutableBufferPointer { (unsafeBufferPointer) in
            return unsafeBufferPointer
        }
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey!, cKeyLen, cData, cDataLen, pointer.baseAddress)
        let data = Data.init(bytes: pointer.baseAddress!, count: cHMAC.count)
        return data.base64EncodedString(options: [])
    }
    
    class func base64URL(data: Data) -> String {
        let result = data.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        var final = ""
        result.forEach { (char) in
            switch char {
            case "+":
                final += "*"
            case "/":
                final += "-"
            case "=":
                final += "_"
            default:
                final += "\(char)"
            }
        }
        return final
    }
}
