## 获取当前会话未读消息数

会话的未读记数存储在 `sessMap` 对象中，其结构描述 如下：
```javascript
{
  // 私聊会话，会话 ID skey 为'C2C[toAccount]'，其中'[toAccount]'表示对方的帐号
  // 例如您正在和 identifier 为 'zhangsan' 的帐号聊天，而 [toAccout]取值为'zhangsan'。
  // 而'C2C[toAccount]'取值为'C2Czhangsan'
  'C2C[toAccount]': {
     	// ...省略
      id: '[toAccount]',
      name: '[toAccount]',
      unread: Function,
      //... 省略
  },
  
  // 群聊会话，会话 ID skey 为'GROUP[groupId]'，其中'[groupId]'表示群组 ID
  // 例如您在群组 ID 为 'developergroup' 的群中聊天，此时[groupId]取值为'developergroup'。
  // 而'GROUP[groupId]'取值为'GROPdevelopergroup'
  'GROUP[groupId]': {
    	// ...省略
      id: '[groupId]',
      name: '[groupId]',
      unread: Function,
      //... 省略
  }
}
```

因此，获取某个会话的未读消息记数需要以下步骤：
1. 取得会话 ID : skey，skey 的组装规则：私聊 "C2C[toAccount]" ； 群组 "GROUP[groupId]"。
2. 取得`sessMap`对象，可以通过`webim.MsgStore.sessMap()`方法来取得`sessMap`对象。
3. 用调用`sessMap[skey].unread()`便可取得这个会话的未数消息计数。

### 私聊场景示例

以与 identifier 为'zhangsan'的帐号私聊为例，示例如下:

```javascript
var skey= 'C2Czhangsan';	// 拼装 skey
var sessMap = webim.MsgStore.sessMap();	// 获取 sessMap
sessMap[skey].unread();	// 获取未读消息记数
```

### 群聊场景示例

以群组 ID 为"developergroup"为例，示例如下：

```javascript
var skey= 'GROUPdevelopergroup';	// 拼装 skey
var sessMap= webim.MsgStore.sessMap();	// 获取 sessMap
sessMap[skey].unread();	// 获取未读消息记数
```

## 设置会话自动已读标记 

当用户阅读某个会话的数据后，需要进行会话消息的已读上报，IM SDK 根据会话中最后一条阅读的消息，设置会话中之前所有消息为已读。 函数原型如下：

```javascript
/**
 * 设置会设置会话自动已读标记话自动已读上报标志
 * @param {Object} selSess - 会话对象，必须为 webim.Session 的实例。
 * @param {boolean} isOn - 是否上报当前会话已读消息，同时将 selSess 的自动已读消息标志改为 isOn
 * @param {boolean} isResetAll - 是否重置所有会话的自动已读标志
 */
setAutoRead: function(selSess, isOn, isResetAll) {}
```

`setAutoRead()`方法需要会话（Webim.Session）的实例为参数，所以应先获取会话实例，再把会话传递给`setAutoRead()`，步骤如下：
1. 获取会话实例。
2. 调用`setAutoRead()`。

### 私聊场景示例：

以与 identifier为'zhangsan'的帐号私聊为例，示例如下: 

```javascript
var skey= 'C2Czhangsan';	// 拼装 skey
var sessMap = webim.MsgStore.sessMap();	// 获取 sessMap
var selSess= sessMap[skey];	// 获取 Session 的实例
webim.setAutoRead(selSess, true, true);
```



### 群组场景示例:

以群组 ID 为"developergroup"为例，示例如下：

```javascript
var skey= 'GRPUPdevelopergroup';	// 拼装 skey
var sessMap = webim.MsgStore.sessMap();	// 获取 sessMap
var selSess= sessMap[skey];	// 获取 Session 的实例
webim.setAutoRead(selSess, true, true);
```
