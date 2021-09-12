### TUICalling接入说明

1. ##### 复制 TUICalling 到 components 文件

2. ##### 添加组件到对应page

```json
{
  "usingComponents": {
    "TRTCCalling": "../../components/TUICalling/TRTCCalling",
}
```

3. ##### 使用组件

js文件

```javascript
Page({
  /**
   * 页面的初始数据
   */
  data: {
    config: {
      sdkAppID: 0,
      userID: 0,
      userSig: '',
      type: 1
    },
    userId: 1
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    	// 将初始化后到TRTCCalling实例注册到this.TRTCCalling中，this.TRTCCalling 可使用TRTCCalling所以方法功能。
   		this.TRTCCalling = this.selectComponent('#TRTCCalling-component');
      // 绑定需要监听到事件
      this.bindTRTCCallingRoomEvent();
    	// 登录TRTCCalling
      this.TRTCCalling.login();
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {
    // 取消监听事件
    this.unbindTRTCCallingRoomEvent();
    // 退出登录
    this.TRTCCalling.logout();
  },
  
  invitedEvent() {
    console.log('收到邀请')
  },

  hangupEvent() {
    console.log('挂断')
  },

  rejectEvent() {
    console.log('对方拒绝')
  },

  userLeaveEvent() {
    console.log('用户离开房间')
  },

  onRespEvent() {
    console.log('对方无应答')
  },

  callingTimeoutEvent() {
    console.log('无应答超时')
  },

  lineBusyEvent() {
    console.log('对方忙线')
  },

  callingCancelEvent() {
    console.log('取消通话')
  },

  userEnterEvent() {
    console.log('用户进入房间')
  },

  callEndEvent() {
    console.log('通话结束')
  },

  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, this.invitedEvent)
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALL_END, this.callEndEvent)
  },
  unbindTRTCCallingRoomEvent() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.off(TRTCCallingEvent.INVITED, this.invitedEvent)
    this.TRTCCalling.off(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.off(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.off(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.off(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALL_END, this.callEndEvent)
  },
  
  call: function() {
    this.TRTCCalling.call({ userID: this.data.userId, type:2})
  },
})
```

wxml文件

```xml
		<TRTCCalling 
      id="TRTCCalling-component"
      config="{{config}}"
      backgroundMute="{{true}}"
    ></TRTCCalling>
```

TRTCCalling 属性

| 属性                 | 类型    | 默认值 | 必填 | 说明                                                         |
| -------------------- | ------- | ------ | ---- | ------------------------------------------------------------ |
| id                   | String  |        | 是   | 绑定TRTCCalling的dom ID，可通过this.selectComponent(ID)获取实例 |
| config               | Object  |        | 是   | TRTCCalling初始化配置                                        |
| backgroundMute       | Boolean | false  | 否   | 进入后台时是否保持音频通话，true保持、false挂断        |


config 参数

| 参数     | 类型   | 必填 | 说明                                                         |
| -------- | ------ | ---- | ------------------------------------------------------------ |
| sdkAppID | Number | 是   | 开通实时音视频服务创建应用后分配的 [SDKAppID](https://console.cloud.tencent.com/trtc/app)。 |
| userID   | String | 是   | 用户 ID，可以由您的帐号体系指定。                            |
| userSig  | String | 是   | 身份签名（即相当于登录密码），由 userID 计算得出，具体计算方法请参见 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。 |
| type     | Number | 是   | 指定通话类型。1：语音通话，2：视频通话。                     |

### 组件方法

#### selectComponent()

您可以通过小程序提供的 `this.selectComponent()` 方法获取组件实例。

```javascript
const TRTCCallingContext = this.selectComponent(ID)
```


#### login()

登入接口，会建议在页面 onLoad 阶段调用。

```javascript
TRTCCallingContext.login()
```


#### logout()

登出信令 SDK，执行后不再能收发信令。

```javascript
TRTCCallingContext.logout()
```


#### on(eventCode, handler, context)

用于监听组件派发的事件，详细事件请参见 [事件表](https://cloud.tencent.com/document/product/647/49380#EVENT)。

```javascript
TRTCCallingContext.on(EVENT.INVITED, () => {
 // todo
})
```


#### off(eventCode, handler)

用于取消事件监听。

```javascript
TRTCCallingContext.off(EVENT.INVITED)
```


#### call({userID, type})

进行某个 user 进行呼叫。

| 参数   | 含义                                              |
| :----- | :------------------------------------------------ |
| userID | 希望呼叫用户的 userID。                           |
| type   | 通话类型，type = 1：语音通话，type =2：视频通话。 |

```javascript
let userID = 'test'
let type = 2
TRTCCallingContext.call({userID, type})
```

