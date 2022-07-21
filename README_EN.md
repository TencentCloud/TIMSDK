English | [简体中文](./README.md)

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


## Latest Enhanced Version 6.5.2803 @2022.07.15

### SDK

- Added the support for marking conversations.
- Added the support for grouping conversations.
- Added the support for customizing chat fields.
- Added the advanced API for pulling conversation list.
- Supported receiving broadcast messages of audio-video groups.
- Supported sending notifications of changes to group joining options.
- Added the support for syncing the changes to group message receiving options across terminals.
- Optimized the routing logic for persistent connections and added the support for rotation policy.
- Scheduled to support for Tencent Cloud Japan.
- Upgraded the authorization ID for HTTPDNS routing requests.
- Added the support for HTTPDNS routing at Tencent Cloud International.
- Optimized the start sequence of long polling requests in audio-video groups.
- Fixed the issue where `lastMessage` is missing in topic profile under certain conditions.
- Optimized the logic of pinning a chat to the top.
- Optimized the statistics collection logic of end-to-end message time.
- Fixed the issue where duplicate messages occasionally appeared in historical messages due to the resending of failed messages.
- Fixed the issue where garbled characters were displayed when emojis were sent on earlier mobile phones.
- Fixed the issue where the `faceURL` was empty in the message returned by `onRecvMessageModified`.
- Fixed the issue where the group invitation signaling sent when the invitee was offline couldn't be received after login.


### TUIKit and demo

- Supported displaying the "Typing..." status in one-to-one chat.
- Supported displaying the online status of friends in chats and contacts.
- No longer displayed the "Recall" option 2 minutes after a message was sent.
- Made custom messages intercompatible across terminals.
- Fixed the issue where chats were not rearranged in certain scenarios on Android.
- Removed the TPNS channel from the offline push component.


## Latest Basic Version 5.1.66 @2021.09.22

### Android

- Removed the feature of getting Wi-Fi information.

## Feedback
- If you encounter any issue when using TIMSDK, please provide feedback on the problem to us so that we can quickly and effectively locate and solve the issue for you.
- [TIMSDK Issue Feedback Guidelines](https://github.com/tencentyun/TIMSDK/wiki/TIMSDK-issue%E6%9C%89%E6%95%88%E5%8F%8D%E9%A6%88%E6%A8%A1%E6%9D%BF)
