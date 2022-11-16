English | [简体中文](./README_ZH.md)

Notice: If you open a pull request in TUIKit Android or iOS and the corresponding changes are successfully merged, your name will be included in README.md with a hyperlink to your homepage on GitHub.

## Image Download

Tencent Cloud branch download address: [Download](https://im.sdk.qcloud.com/download/github/TIMSDK.zip)

## SDK Download

<table>
<tr>
<th width="94px" style="text-align:center" >Native SDK</td>
 <th width="0px" style="text-align:center" >Download Address</td>
<th width="0px"  style="text-align:center">Integration Guide</td>
<th width="175px" style="text-align:center">Update Log</td>
</tr>
<tr>
<td style="text-align:center">Android  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Android/IMSDK">GitHub (Recommended)</a></td>
<td style="text-align:left" ><a href="https://intl.cloud.tencent.com/document/product/1047/34286">[Quick Integration] SDK Integration (Android)</a><br><a href="https://intl.cloud.tencent.com/document/product/1047/34306">[General Integration] SDK Integration (Android)</a></td>
<td style="text-align:center" rowspan='4'><a href="https://intl.cloud.tencent.com/document/product/1047/34282">Update Log (Native)</a> </td>
</tr>
<tr>
<td style="text-align:center">iOS  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/iOS/IMSDK">GitHub (Recommended)</a></td>
<td style="text-align:left" ><a href="https://intl.cloud.tencent.com/document/product/1047/34287">[Quick Integration] SDK Integration (iOS)</a><br><a href="https://intl.cloud.tencent.com/document/product/1047/34307">[General Integration] SDK Integration (iOS)</a></td>
</tr>
<tr>
<td style="text-align:center">Mac  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Mac/IMSDK">GitHub (Recommended)</a></td>
<td style="text-align:left" ><a href="https://intl.cloud.tencent.com/document/product/1047/34308">[General Integration] SDK Integration (Mac)</a></td>
</tr>
<tr>
<td style="text-align:center">Windows  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Windows/IMSDK">GitHub (Recommended)</a></td>
<td style="text-align:left" ><a href="https://intl.cloud.tencent.com/document/product/1047/34310">[General Integration] SDK Integration (Windows)</a></td>
</tr>
</table>

## TUIKit Integration

<table >
  <tr>
    <th width="180px" style="text-align:center">Module</th>
    <th width="180px" style="text-align:center">Platform</th>
    <th width="500px" style="text-align:center">Document Link</th>
  </tr>

  <tr >
​    <td rowspan='2' style="text-align:center">Quick Integration</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34287">TUIKit-iOS Quick Integration</a></td>
  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34286">TUIKit-Android Quick Integration</a></td>
  </tr>

  <tr>
​    <td rowspan='2' style="text-align:center">Setting UI Styles</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34290">Setting UI Styles (TUIKit-iOS)</a></td>

  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34289">Setting UI Styles (TUIKit-Android)</a></td>
  </tr>

  <tr>
​    <td rowspan='2' style="text-align:center">Adding Custom Messages</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34293">Adding Custom Messages (TUIKit-iOS)</a></td>
  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://intl.cloud.tencent.com/document/product/1047/34292">Adding Custom Messages (TUIKit-Android)</a></td>
  </tr>

</table>

## Differences Between the Basic Edition and the Enhanced Edition
- SDK added the Enhanced Edition from SDK 5.4. The original edition is called the Basic Edition.
- Both the Basic Edition and Enhanced Edition support [V2 APIs](https://intl.cloud.tencent.com/document/product/1047/36169). However, the Enhanced Edition no longer supports legacy APIs while the Basic Edition still supports legacy APIs.
- If you have not integrated legacy APIs, we recommend that you directly use [V2 APIs](https://intl.cloud.tencent.com/document/product/1047/36169) and choose the Enhanced Edition SDK.
- If you have integrated legacy APIs, we recommend that you upgrade to [V2 APIs](https://intl.cloud.tencent.com/document/product/1047/36169) and gradually transition to the Enhanced Edition SDK.
- Compared with the Basic Edition, the Enhanced Edition has greatly reduced the SDK size and installation package increment.
- Compared with the Basic Edition, the Enhanced Edition provides more new features.
- Subsequent development of new features will only be supported on the Enhanced Edition. The Basic Edition supports only routine maintenance and fixing of existing problems.
- Enhanced Edition Pro has been released from SDK 6.8 version which supports dual line acceleration on network layer and provides better performance for bad network environment.

### Comparison of the SDK sizes
<table>
  <tr>
    <th width="200px" style="text-align:center">Platform</th>
    <th width="260px" style="text-align:center">Item</th>
    <th width="200px" style="text-align:center">Basic Edition</th>
    <th width="200px" style="text-align:center">Enhanced Edition</th>
  </tr>
  <tr>
    <td style="text-align:center">Android</td>
    <td style="text-align:center">aar size</td>
    <td style="text-align:center">7.8 MB</td>
    <td style="text-align:center">3.1 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center">framework size</td>
    <td style="text-align:center">57.7 MB</td>
    <td style="text-align:center">11.2 MB</td>
  </tr>
</table>

### Comparison of the app size increments
<table>
  <tr>
    <th width="200px" style="text-align:center">Platform</th>
    <th width="260px" style="text-align:center">Architecture</th>
    <th width="200px" style="text-align:center">Basic Edition</th>
    <th width="200px" style="text-align:center">Enhanced Edition</th>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">apk increment</td>
    <td style="text-align:center">armeabi-v7a</td>
    <td style="text-align:center">3.2 MB</td>
    <td style="text-align:center">1.1 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">arm64-v8a</td>
    <td style="text-align:center">5.2 MB</td>
    <td style="text-align:center">1.7 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">ipa increment</td>
    <td style="text-align:center">arm64</td>
    <td style="text-align:center">2.1 MB</td>
    <td style="text-align:center">1.1 MB</td>
  </tr>
</table>

## Guidelines for Upgrading IMSDK to V2 APIs

[API Upgrade Guidelines](https://docs.qq.com/sheet/DS3lMdHpoRmpWSEFW)


## Latest Enhanced Edition 6.7.3184 @2022.09.29

## Latest Enhanced Edition 6.8.3374 @2022.11.14

### SDK

- Supported local text moderation on clients.
- Released the Swift SDK.
- Supported the group attribute feature for non-audio-video groups.
- Optimized the logic for updating the number of members in a non-audio-video groups when someone entered the group.
- Optimized the COS upload process.
- Optimized the issue of unread message count after operations such as message recall in a community group.
- Fixed the failure to deliver a notification when a custom friend field is set independently.
- Fixed the double callbacks for group listening.
- Fixed the issue where the topic profile under a community group would not be updated timely when a user left the group and then joined the group again.
- Fixed the issue that sender’s profile photo is empty in the callback for inserting a local message successfully.
- Fixed the occasional error when setting message extension after repeated login.
- Fixed the failure to update the message read receipt status in the conversation update callback after all messages in the conversation are marked as read.
- Fixed the occasional emptiness of `send_user_id` in a message when a user sends a message immediately after login callback.
- C++ API: Added an API to check whether a message is read.
- C++ API: Fixed the failure to update the cursor in the result of the paged pulling of the conversation list.

### TUIKit and demo

- Fixed the issue where a search webpage window popped out when a user long pressed a text message on iOS 16.
- TUIChat-iOS: Supported sending GIF images.
- TUIChat-iOS: Fixed image sending status exceptions.
- TUIChat-iOS: Supported the deletion of time when deleting a message.
- Fixed system exceptions caused by iOS TUIOfflinePush.
- Fixed the issue where Android TUIOfflinePush push parameter settings did not take effect.



## Latest Basic Version 5.1.66 @2021.09.22

### Android

- Removed the feature of getting Wi-Fi information.

## Feedback
- If you encounter any issue when using TIMSDK, please provide feedback on the problem to us so that we can quickly and effectively locate and solve the issue for you.
- [TIMSDK Issue Feedback Guidelines](https://github.com/tencentyun/TIMSDK/wiki/TIMSDK-issue%E6%9C%89%E6%95%88%E5%8F%8D%E9%A6%88%E6%A8%A1%E6%9D%BF)
