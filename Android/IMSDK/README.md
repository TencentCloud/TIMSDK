English | [简体中文](./README_ZH.md)

# TIM SDK 7.9.5680 (Android)

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
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/imsdk-plus-7.9.5680.aar">imsdk-plus.aar</a></td>
  </tr>
</table>

## Download Plugin for IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK Plugin Type</th>
    <th width="440px" style="text-align:center">Introduction</th>
    <th width="320px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic Plugin</td>
     <td style="text-align:center">Providing axp-quic multiplex transmission protocol to enhance network performance</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/timquic-plugin-7.9.5680.aar">timquic-plugin.aar</a></td>
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
}
```

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34306).

In addition, we also provide SDKs for the C and C++ API, which you can download from here，[Download C API Edition](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_Android_C_7.9.5680.zip)、[Download  C++ API Edition](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_Android_CPP_7.9.5680.zip)。
