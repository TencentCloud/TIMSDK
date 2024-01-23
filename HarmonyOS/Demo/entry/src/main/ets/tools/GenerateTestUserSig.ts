// Copyright (c) 2023 Tencent. All rights reserved.

import buffer from "@ohos.buffer";
import CryptoJS from "@ohos/crypto-js";
import pako from "pako";

/**
 * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 * <p>
 * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc ) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */
export const SDKAPPID = TODO;

/**
 * 签名过期时间，建议不要设置的过短
 * <p>
 * 时间单位：秒
 * 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */
const EXPIRETIME = 604800;

/**
 * 计算签名用的加密密钥，获取步骤如下：
 * <p>
 * step1. 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc ) ，如果还没有应用就创建一个，
 * step2. 单击“应用配置”进入基础配置页面，并进一步找到“账号体系集成”部分。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
 * <p>
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */
const SECRETKEY = TODO;

/**
 * 计算 UserSig 签名
 * <p>
 * 函数内部使用 HMAC-SHA256 非对称加密算法，对 SDKAPPID、userId 和 EXPIRETIME 进行加密。
 *
 * @note: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 * <p>
 * 本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 * 这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 * 一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 * <p>
 * 正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 * 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 * <p>
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */
export function genTestUserSig(userId: string): string {
  return genTlsSignature(userId, SDKAPPID, EXPIRETIME, SECRETKEY);
}

function genTlsSignature(userId: string, sdkAppId: number, expireTime: number, key: string): string {
  const currentTime = (new Date().getTime() / 1000).toFixed();

  const data = `TLS.identifier:${userId}\nTLS.sdkappid:${sdkAppId}\nTLS.time:${currentTime}\nTLS.expire:${expireTime}\n`;
  const hashedData = hMacSha256(key, data);

  const content = new Object();
  content["TLS.ver"] = "2.0";
  content["TLS.identifier"] = userId;
  content["TLS.sdkappid"] = sdkAppId;
  content["TLS.expire"] = expireTime;
  content["TLS.time"] = currentTime;
  content["TLS.sig"] = hashedData;

  const deflatedContent = deflate(JSON.stringify(content));
  const result = base64Url(deflatedContent);
  return result;
}

function hMacSha256(key: string, message: string): string {
  const hmac = CryptoJS.HmacSHA256(message, key);
  const result = hmac.toString(CryptoJS.enc.Base64);
  return result;
}

function deflate(data: string): Uint8Array {
  const input = new Uint8Array(buffer.from(data).buffer);
  const result = pako.deflate(input);
  return result;
}

function base64Url(data: Uint8Array): string {
  const base64 = buffer.from(data).toString("base64");
  let result = "";
  for (let c of base64) {
    switch (c) {
      case "+":
        result += "*";
        break;
      case "/":
        result += "-";
        break;
      case "=":
        result += "_";
        break;
      default:
        result += c;
        break;
    }
  }
  return result;
}
