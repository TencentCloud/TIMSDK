[English](./README.md) | 简体中文

# TIM SDK 7.9.5680（Android）

## 下载 IM SDK

<table >
  <tr>
    <th width="220px" style="text-align:center">IM SDK 类型</th>
    <th width="440px" style="text-align:center">简介</th>
    <th width="340px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Java 版本</td>
     <td style="text-align:center">支持 Java API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/imsdk-plus-7.9.5680.aar">imsdk-plus.aar</a></td>
  </tr>
</table>

## 下载 IM SDK 的插件

<table >
  <tr>
    <th width="220px" style="text-align:center">IM SDK 插件类型</th>
    <th width="440px" style="text-align:center">简介</th>
    <th width="340px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic 插件</td>
     <td style="text-align:center">提供 axp-quic 多路传输协议，弱网抗性更优</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/timquic-plugin-7.9.5680.aar">timquic-plugin.aar</a></td>
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
}
```

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75283)。

此外，我们还提供了 C 接口和 C++ 接口的 SDK，您可以从这里下载：[下载 C API 版本](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_Android_C_7.9.5680.zip)、[下载 C++ API 版本](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_Android_CPP_7.9.5680.zip)。
