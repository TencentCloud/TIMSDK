本文主要介绍腾讯云 TRTC SDK 的几个最基本功能的使用方法，阅读此文档有助于您对 TRTC 的基本使用流程有一个简单的认识。

## 准备工作
在使用基本功能前，请确保您已完成以下骤，详见 [跑通Demo(Web)](https://cloud.tencent.com/document/product/647/32398)，[快速集成(Web)](https://cloud.tencent.com/document/product/647/16863)。
- 创建了腾讯云实时音视频应用，购买了相应的套餐，并获取到SDKAppid。
- 获取私钥文件。
- 在 WEB 项目里集成了 WebRTCAPI.min.js

## 部署签名服务
在初始化组件时需要签名服务进行签发 userSig，详情可以参考 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。

## 检测环境
检测当前浏览器环境是否支持 WebRTC 相关特性，在支持 WebRTC 的情况下才可以进行初始化等操作。
```javascript
WebRTCAPI.fn.detectRTC({
        screenshare : true // 是否进行屏幕分享检测，默认true
    }, function(info){
    if( !info.support ) {
        alert('不支持WebRTC')
    }
});
```
回调返回的 info 字段包含的参数有：

| 字段  | 含义    |  备注|
| :------: | ----- | ------ |
| isTBS      | 是否是TBS (Android的微信/手机QQ Webview) |   [什么是 TBS](https://x5.tencent.com/tbs/index.html)              |
| TBSversion      | TBS版本号 |                 |
| isTBSValid      | TBS版本号是否支持 WebRTC |                 |
| support      | 是否支持WebRTC |  |
| h264Support      | 是否支持H.264 |必须支持 H.264 |
| screenshare      | 是否支持屏幕分享 |必须安装插件 |

## 组装参数
使用基本功能必须的参数有:

- **sdkAppId**
进入腾讯云实时音视频 [控制台](https://console.cloud.tencent.com/rav)，如果您还没有应用，请创建一个，即可看到 sdkAppId。
![](https://main.qcloudimg.com/raw/79bfa75cea7faec26d91226a5fb23f10.png)

- **userId**
您可以随意指定，由于是字符串类型，可以直接跟您现有的账号体系保持一致，但请注意，**同一个音视频房间里不应该有两个同名的 userId**。

- **userSig**
基于 sdkAppId 和 userID 可以计算出 userSig，计算方法请参考 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。

- **roomid**
房间号是数字类型，是进入房间时的必要参数，您可以随意指定，但请注意，**同一个应用里的两个音视频房间不能分配同一个 roomid**。

- **role**
画面设定的配置集名称，在【控制台】-【实时音视频】-【画面设定】进行配置。
![](https://main.qcloudimg.com/raw/1b828be9923df6a67d335b23d12309bb.png)

## 初始化 SDK
在需要实现实时音视频的页面添加初始化代码：
```javascript
var RTC = new WebRTCAPI({
    sdkAppId: sdkappid, // [必选]开通实时音视频服务创建应用后分配的 sdkappid
    userId: userId, // [必选]用户 ID，可以由您的服务指定
    userSig: userSig, // [必选]身份签名，需要从自行搭建的签名服务获取
}, function () {
    // 初始化成功的回调，可以开始创建或进入房间
}, function (error) {
    console.warn("init error", error)
});
```

## 进入(或创建)房间
在得到初始化的 WebRTCAPI 对象实例 RTC 后，调用对象实例的 `enterRoom()` 方法，即可进入房间（如果 roomid 不存在则为创建房间）。
```javascript
RTC.enterRoom({
    roomid: roomid, // [必选]房间号，可以由您的服务指定   
    role : role  // 画面设定的配置集名称 （见控制台 - 画面设定 )
}, function(){
    // 成功
}, function(){
    // 失败
}
);
```

## 采集本地音视频流
进入房间后，如果要进行本地推流，需要先采集本地音视频流:
```javascript
RTC.getLocalStream({
    video:true, // 是否采集视频，默认true
    audio:true, // 是否采集音频，默认true
    attributes:{ // 推流相关配置的属性
        width:640, // 分辨率宽度
        height:480, // 分辨率高度
        frameRate:20 // 帧率
    }
},function(info){
    var stream = info.stream;
},function (error){
    console.error(error)
});
```

## 开始推流
进入房间成功并开始采集本地音视频流后，才可以开始音视频推流。
```javascript
RTC.startRTC({
    role : role,  // 画面设定的配置集名称 （见控制台 - 画面设定 )
    stream: stream // 通过采集本地音视频流获取到的本地流对象
}, function(){
    // 成功
},function(){
    // 失败
});
```

## 收听远端视频流
远端视频流新增/更新通知。
```javascript
RTC.on( 'onRemoteStreamUpdate' , function(data){
    if(data && data.stream){
        var stream = data.stream
        console.debug( data.userId + 'enter this room with unique videoId '+ data.videoId);
        document.querySelector("#remoteVideo").srcObject = stream; // 通过 <video> 显示远端视频画面
    }else{
        console.debug( 'somebody enter this room without stream' );
    }
});
```
事件回调返回的 data 包含的参数有：

| 参数                   | 类型       | 描述            |
| -------------------- | --------  | ---- |
| userId     | String  | 视频流所属用户的userId    |
| stream     | Stream  | 视频流 Stream，可能为 null( 每一个用户进来 不管是否推流，都会触发这个回调)  |
| videoId    | String  | 视频流Stream的唯一id ,由 tinyid + "_" + 由随机字符串 组成      |
| videoType: | Integer | 0 : NONE , 1:AUDIO 音频,   2：主路 MAIN   7：辅路 AID |


远端视频流断开通知。
```javascript
RTC.on( 'onRemoteStreamRemove' , function(data){
    console.debug( data.userId + ' leave this room with unique videoId '+ data.videoId  )
})
```
事件回调返回的 data 包含的参数有：

| 参数                   | 类型       | 描述            |
| -------------------- | --------  | ---- |
| userId         | String | 远端视频流所属用户的 userId    |
| videoId         | String | 远端视频流 Stream 的唯一 ID    |

## 开启（或关闭）本地声音采集
采集音频标识（取消静音）。
```javascript
    RTC.openAudio();
```

不采集音频（静音）。
```javascript
    RTC.closeAudio();
```


## 开启（或关闭）本地视频采集
打开视频采集需要在已经进行音视频推流的时候，关闭了视频的情况下再打开采集。
```javascript
    RTC.openVideo();
```
不采集视频。
```javascript
    RTC.closeVideo();
```

## 切换摄像头
先获取摄像头设备，然后再选择摄像头设备进行切换。
```javascript
    RTC.getVideoDevices( function(devices){
        //devices 是枚举当前设备的视频输入设备的数组(DeviceObject)
        // 例如 ：[device0,device1,device2]
        // 这些device将在选择摄像头的时候使用
        RTC.chooseVideoDevice( devices[0] );
    })
```

## 停止推流
调用实例方法 stopRTC() 停止推流。
```javascript
    RTC.stopRTC({}, function(){
        console.debug('stop succ')
    }, function(){
        console.debug('stop end')
    });
```
## 退出房间
调用实例方法 quit() 退出房间。
```javascript
    //注意：这里必须在 WebRTCAPI 的初始化成功的回调中调用
    RTC.quit(  function(){
        //退出成功
    } , function(){
        //退出失败
    } );
```