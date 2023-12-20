English | [简体中文](./README_ZH.md)

# TIM SDK 7.7.5282 (Android)

## Download IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK Type</th>
    <th width="440px" style="text-align:center">Introduction</th>
    <th width="320px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Java Edition</td>
     <td style="text-align:center">Support Java API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/imsdk-plus-7.7.5282.aar">imsdk-plus.aar</a></td>
  </tr>
</table>

## Download Plugin for IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK 插件类型</th>
    <th width="440px" style="text-align:center">简介</th>
    <th width="320px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic Plugin</td>
     <td style="text-align:center">Providing axp-quic multiplex transmission protocol to enhance network performance</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/timquic-plugin-7.7.5282.aar">timquic-plugin.aar</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">Advanced Encryption Plugin</td>
     <td style="text-align:center">Providing database encryption and SM4 encryption algorithm</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/timadvancedencryption-plugin-7.7.5282.aar">timadvancedencryption-plugin.aar</a></td>
  </tr>
</table>

## Maven Integration
Add the dependency to your module's build.gradle file.
```
dependencies {
    // Add the IM SDK and use the latest version number as recommended
    api 'com.tencent.imsdk:imsdk-plus:Version number'

    // If you need to add the Quic plugin, please uncomment the next line (Note: the plugin version number must match the IM SDK version number)
    // api "com.tencent.imsdk:timquic-plugin:Version number"

    // If you need to add the advanced encryption plugin, please uncomment the next line (Note: the plugin version number must match the IM SDK version number)
    // api "com.tencent.imsdk:timadvancedencryption-plugin:Version number"
}
```

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34306).

In addition, we also provide SDKs for the C and C++ API, which you can download from here，[Download C API Edition](https://im.sdk.qcloud.com/download/plus/7.7.5282/cross_platform/ImSDK_Android_C_7.7.5282.zip)、[Download  C++ API Edition](https://im.sdk.qcloud.com/download/plus/7.7.5282/cross_platform/ImSDK_Android_CPP_7.7.5282.zip)。