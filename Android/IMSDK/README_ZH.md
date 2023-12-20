[English](./README.md) | 简体中文

# TIM SDK 7.7.5282（Android）

## 下载 IM SDK

<table >
  <tr>
    <th width="180px" style="text-align:center">IM SDK 类型</th>
    <th width="600px" style="text-align:center">简介</th>
    <th width="220px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Java 版本</td>
     <td style="text-align:center">支持 Java API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/imsdk-plus-7.7.5282.aar">imsdk-plus.aar</a></td>
  </tr>
</table>

## 下载 IM SDK 的插件

<table >
  <tr>
    <th width="200px" style="text-align:center">IM SDK 插件类型</th>
    <th width="480px" style="text-align:center">简介</th>
    <th width="320px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic 插件</td>
     <td style="text-align:center">提供 axp-quic 多路传输协议，弱网抗性更优</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/timquic-plugin-7.7.5282.aar">timquic-plugin.aar</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">高级加密插件</td>
     <td style="text-align:center">提供数据库加密和 SM4 国密算法</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/timadvancedencryption-plugin-7.7.5282.aar">timadvancedencryption-plugin.aar</a></td>
  </tr>
</table>


## Maven 集成
在您的 module build.gradle 文件中添加依赖项。
```
dependencies {
    // 添加 IM SDK，推荐填写最新的版本号
    api 'com.tencent.imsdk:imsdk-plus:版本号'

    // 如果您需要添加 Quic 插件，请取消下一行的注释（注意：要求插件版本号和 IM SDK 版本号相同）
    // api "com.tencent.imsdk:timquic-plugin:版本号"

    // 如果您需要添加高级加密插件，请取消下一行的注释（注意：要求插件版本号和 IM SDK 版本号相同）
    // api "com.tencent.imsdk:timadvancedencryption-plugin:版本号"
}
```

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75283)。

此外，我们还提供了 C 接口和 C++ 接口的 SDK，您可以从这里下载：[下载 C API 版本](https://im.sdk.qcloud.com/download/plus/7.7.5282/cross_platform/ImSDK_Android_C_7.7.5282.zip)、[下载 C++ API 版本](https://im.sdk.qcloud.com/download/plus/7.7.5282/cross_platform/ImSDK_Android_CPP_7.7.5282.zip)。