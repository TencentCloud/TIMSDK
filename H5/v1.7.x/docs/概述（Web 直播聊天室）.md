## IM SDK 集成 

- 单击体验 [直播聊天室 Demo](http://avc.cloud.tencent.com/demo/webim/biggroup/mobile/index.html)，或者扫描下方二维码：

	![](//mccdn.qcloud.com/static/img/a188f7fd653c8237b362a7adea1f63b1/image.png)

-  单击体验 [通用 Demo](http://avc.cloud.tencent.com/demo/webim/index.html)。

-  单击了解 [通用 Demo 运行指引](https://cloud.tencent.com/doc/product/269/4196)。

### 下载 IM SDK

从官网下载 [IM SDK 包](https://cloud.tencent.com/product/im/developer)，包含以下库文件，其中 `json2.js` 提供了 JSON 的序列化和反序列化方法，可以将一个 JSON 对象转换成 JSON 字符串，也可以将一个 JSON 字符串转换成一个 JSON 对象。`webim.js` 就是 webim SDK 库，提供了登录，加群，收发消息，退群，登出功能。

```
sdk/webim.js
sdk/json2.js
```

### 集成 IM SDK

**首先引入 IM SDK 文件：**

```
<!--引入 webim sdk-->
<script type="text/javascript" src="sdk/webim.js"></script>
<script type="text/javascript" src="sdk/json2.js"></script>
```


### 函数调用顺序
IM SDK 函数使用顺序，如下：

| 步骤 | 对应函数 | 说明 |
|---------|---------|---------|
| 登录 | webim.login(loginInfo, listeners,opts,cbOk,cbErr);| 登录 IM SDK，需要传入当前用户信息，新消息通知回调函数等 |
| 进群 | webim.applyJoinBigGroup(options,cbOk, cbErr);| 进群 |
|监听新消息 |Demo 中使用的监听函数是:<br/>onBigGroupMsgNotify(监听群普通消，点赞，提示和红包消息);<br/>groupSystemNotifys（监听群系统消息）;<br/>onMsgNotify（监听新消息(私聊(包括普通消息和全员推送消息)，普通群(非直播聊天室)消息)）|业务自定义监听函数，包括群普通消息，群提示消息和群系统消息，登录时传给 IM SDK |
|发消息(带登录态) |webim.sendMsg(options,cbOk, cbErr); |发消息（普通，点赞，红包） |
|退群 |webim.quitBigGroup(options,cbOk, cbErr);|退群 |
|登出|webim.logout(options,cbOk, cbErr); |退出，用于切换帐号登录 |

### 支持浏览器版本

IM SDK 支持 IE 7+，Chrome 7+，FireFox 3.6+，Opera 12+和 Safari 6+（PC 端）和主流移动端浏览器。

## IM SDK 基本概念

**会话：**IM SDK 中会话（webim.Session）分为两种，一种是 C2C 会话，表示单聊情况，自己与对方建立的对话；另一种是群会话，表示群聊情况下，群内成员组成的会话。

**消息：**IM SDK 中消息（webim.Msg）表示要发送给对方的内容，消息包括若干属性，如自己是否为发送者，发送人帐号，消息产生时间等；一条消息由若干 `Elem` 组合而成，每种 `Elem` 可以是文本、表情，图片等，消息支持多种 `Elem` 组合发送。


### IM SDK 对象简介

 IM SDK 对象主要分为常量对象和类对象，具体的含义参见下表：

|对象 | 介绍 | 功能 |
|---------|---------|---------|
|webim.SESSION_TYPE  |会话类型，取值范围：<br/>1) webim.SESSION_TYPE.C2C-私聊（目前未使用到）<br/>2) webim.SESSION_TYPE.GROUP-群聊| 区分消息属于哪种聊天类型 |
|webim.C2C_MSG_SUB_TYPE  | C2C 消息子类型，取值范围：<br/>1) webim.C2C_MSG_SUB_TYPE.COMMON-普通消息 | 区分 C2C 消息类型|
|webim.GROUP_MSG_SUB_TYPE |群消息子类型，取值范围：<br/>1)	webim.GROUP_MSG_SUB_TYPE.COMMON-普通消息<br/>2)	webim.GROUP_MSG_SUB_TYPE.LOVEMSG –点赞消息<br/>3)	webim.GROUP_MSG_SUB_TYPE.TIP –提示消息<br/>4)webim.GROUP_MSG_SUB_TYPE.REDPACKET –红包消息(优先级最高)|  区分群消息类型，业务可针对不同的消息作出不同的操作。|
|webim.GROUP_TIP_TYPE |群提示消息类型，取值范围：<br/>1)	webim. GROUP_TIP_TYPE.JOIN-进群<br/>2)	webim. GROUP_TIP_TYPE.QUIT-退群<br/>3)	webim. GROUP_TIP_TYPE.KICK-被踢出群<br/>4)webim. GROUP_TIP_TYPE.SET_ADMIN-被设置成管理员<br/>5)	webim. GROUP_TIP_TYPE.CANCEL_ADMIN-被取消管理员角色<br/>6)	webim. GROUP_TIP_TYPE.CANCEL_ADMIN-被取消管理员角色<br/>7)	webim. GROUP_TIP_TYPE.MODIFY_GROUP_INFO-修改群资料 <br/>8)	webim. GROUP_TIP_TYPE.MODIFY_MEMBER_INFO-修改群成员信息 |  区分群提示消息类型
|webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE  | 群资料变更类型，取值范围：<br/>1)	webim. GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL-群头像发生变更<br/>2)	webim. GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME -群名称发生变更<br/>3)	webim. GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER-群主发生变更<br/>4)	webim. GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION -群公告发生变更<br/>5)	webim. GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION-群简介发生变更| 区分群资料变更类型 |
|webim.GROUP_SYSTEM_TYPE | 群系统消息类型，取值范围：<br/>1)	webim.GROUP_SYSTEM_TYPE.JOIN_GROUP_REQUEST-申请加群请求（只有管理员会收到）<br/>2)	webim.GROUP_SYSTEM_TYPE.JOIN_GROUP_ACCEPT -申请加群被同意（只有申请人能够收到）<br/>3)	webim.GROUP_SYSTEM_TYPE.JOIN_GROUP_REFUSE -申请加群被拒绝（只有申请人能够收到）<br/>4)	webim.GROUP_SYSTEM_TYPE.KICK-被管理员踢出群（只有被踢者接收到<br/>5)	webim.GROUP_SYSTEM_TYPE.DESTORY -群被解散（全员接收）<br/>6)	webim.GROUP_SYSTEM_TYPE.CREATE -创建群（创建者接收，不展示）<br/>7)	webim.GROUP_SYSTEM_TYPE.INVITED_JOIN_GROUP_REQUEST -邀请加群（被邀请者接收）<br/>8)	webim.GROUP_SYSTEM_TYPE.QUIT-主动退群（主动退出者接收, 不展示）<br/>9)	webim.GROUP_SYSTEM_TYPE.SET_ADMIN -设置管理员（被设置者接收）<br/>10)	webim.GROUP_SYSTEM_TYPE.CANCEL_ADMIN -取消管理员（被取消者接收）<br/>11)	webim.GROUP_SYSTEM_TYPE.REVOKE -群已被回收（全员接收，不展示）<br/>12)	webim.GROUP_SYSTEM_TYPE.CUSTOM -用户自定义通知（默认全员接收）| 区分群系统消息类型 |
|webim.MSG_ELEMENT_TYPE  | 消息元素类型，取值范围：<br/>1)	webim.MSG_ELEMENT_TYPE.TEXT-文本消息<br/>2)	webim.MSG_ELEMENT_TYPE.FACE表情消息<br/>3)	webim.MSG_ELEMENT_TYPE.IMAGE-图片消息<br/>4)webim.MSG_ELEMENT_TYPE.SOUND-语音消息<br/>5)	webim.MSG_ELEMENT_TYPE.FILE-文件消息<br/>6)	webim.MSG_ELEMENT_TYPE.LOCATION-位置消息<br/>7)	webim.MSG_ELEMENT_TYPE.CUSTOM-自定义消息<br/>8)webim.MSG_ELEMENT_TYPE.GROUP_TIP-群提示消息（只有群聊天才会出现）|区分消息元素类型  |
|webim.IMAGE_TYPE  | webim.IMAGE_TYPE	图片大小类型，取值范围：<br/>1)	webim.IMAGE_TYPE.SMALL-小图<br/>2)	webim.IMAGE_TYPE.LARGE-大图<br/>3)	webim.IMAGE_TYPE.ORIGIN-原图| 区分图片大小类型 |
|webim.Emotions |表情对象  | 键值对形式，key 是表情 index，value 包括了表情标识字符串和表情图片的 BASE64 编码 |
|webim.EmotionDataIndexs | 表情标识字符串和 index 的 Map | 键值对形式，key 是表情的标识字符串，value 是表情 index，主要用于发表情消息。 |
|webim.BROWSER_INFO | 当前浏览器信息<br/>1)	webim.BROWSER_INFO.type-浏览器类型( 包括 ‘ie’，’safari’，’chrome’，’firefox’，’opera’，’unknow’)<br/>2)	webim.BROWSER_INFO.ver-版本号| 区分浏览器版本 |
|webim.CONNECTION_STATUS | 连接状态<br/>1)	webim.CONNECTION_STATUS.ON-连接状态正常，可正常收发消息<br/>2)	webim.CONNECTION_STATUS.OFF-连接已断开，当前用户已离线，无法收信息| 用于区分用户的当前连接状态 |

类对象

|对象 | 介绍 | 功能 |
|---------|---------|---------|
|webim.Session|一个会话对象|即聊天对象，包括获取会话类型（私聊还是群聊），对方帐号，未读消息数，总消息数等|
|webim.Msg|一条消息对象|消息发送、接收的 API 中都会涉及此类型的对象|
|webim.Tool|工具对象|提供了一些公用的函数。例如格式化时间戳函数 formatTimeStamp()，获取字符串（UTF-8 编码）所占字节数 getStrBytes() 等|
|webim.Log|控制台打印日志对象|方便查看接口的请求 URL，请求 data 和响应 data，在 IM SDK 登录时，可以传递一个布尔类型的变量来控制是否在控制台打印日志|

### 会话对象 Session

**对象名：**

```
webim.Session
```

当前用户和某个群或者好友的聊天描述类。目前主要在发送消息时用得到。**构造函数：**

```
webim.Session (
	type, id, name, icon, time, seq
)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
| type | 会话类型， 包括群聊和私聊，具体参考 webim. SESSION_TYPE 常量对象，必填|	string |
| id | 对方 ID , 群聊时，为群 ID；私聊时，对方帐号，必填 |String|
|name  |对方名称，群聊时，为群名称；私聊时，为对方昵称，暂未使用，选填  |String  |
|icon  | 对方头像 URL，暂未使用，选填 | String |
| time |当前会话中的最新消息的时间戳，UNIX timestamp 格式，暂未使用，选填  | Integer |
| seq | 当前会话的最新消息的序列号，暂未使用，选填 |Integer  |

**对象方法:**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|type()	|获取会话类型|	无|	String|
|id()	|获取对方 ID	|无|	String|
|name()	|获取对方名字，暂未使用|	无|	String|
|icon()	|获取对方头像，暂未使用	|无|	String |
|time()	|获取当前会话中最新消息的时间，暂未使用|	无|	Integer|
|curMaxMsgSeq()	|获取当前会话中最新消息的序列号，暂未使用|	无|	Integer|
|msgCount()|	获取会话的消息数，暂未使用|	无|	Integer|

### 消息对象 Msg

**对象名：**

```
webim.Msg
```

一条消息的描述类，消息发送、接收的 API 中都会涉及此类型的对象。**构造函数：**

```
webim.Msg(
	sess, isSend, seq, random,time,fromAccount,subType,fromAccountNick
)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|sess|	消息所属的会话（e.g：我与好友 A 的 C2C 会话，我与群组 G 的 GROUP 会话）|	webim.Session|
|isSend|	消息是否为自己发送标志:<br/>true：表示是我发出消息,<br/>false：表示是发给我的消息|	Boolean|
|subType|	消息子类型:<br/>C2C 消息时，参考 C2C 消息子类型对象：webim.C2C_MSG_SUB_TYPE <br/>群消息时，参考群消息子类型对象：webim.GROUP_MSG_SUB_TYPE|	Integer|
|fromAccount	|消息发送者帐号|	String |
|fromAccountNick	|消息发送者昵称，用户没有设置昵称时，则为发送者帐号|	String|
|seq	|消息序列号，用于消息判重	|Integer|
|random|消息随机数，用于消息判重|	Integer|
|time|消息时间戳，UNIX timestamp格式|	Integer|
|elems	|描述消息内容的元素数组|[webim.Msg.Elem]|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getSession()|	获取消息所属的会话|	无|	webim.Session|
|getIsSend()|获取消息是否为自己发送标志	|无|Boolean|
|getSubType()	|获取消息子类型|	无|	Integer|
|getFromAccount()	|获取消息发送者帐号	|无|	String |
|getFromAccountNick()|获取消息发送者昵称，用户没有设置昵称时，则为发送者帐号|	无|	String|
|getSeq()	|获取消息序列号|	无|	Integer|
|getRandom()	|获取消息随机数|	无|	Integer|
|getTime()	|获取消息时间戳，UNIX timestamp 格式	|无|	Integer|
|getElems()	|获取描述消息内容的元素数组|	无|	[webim.Msg.Elem]
|addText(text)	|向 elems 中添加一个 Text 元素|	text : Msg.Elem.Text|无|
|addFace(face)|	向 elems 中添加一个 Face 元素|	face : Msg.Elem.Face|	无|
|addImage(image)	|向 elems 中添加一个 Images 元素|	image: Msg.Elem.Images	|无|
|addSound(sound)|	向 elems 中添加一个 Sound 元素|	sound: Msg.Elem.Sound	|无|
|addFile(file)|	向 elems 中添加一个 File 元素|	file: Msg.Elem.File	|无|
|addLocation(location)|	向 elems 中添加一个 Location 元素|	location: sg.Elem.Location|	无|
|addCustom(custom)|	向 elems 中添加一个 Custom 元素|	custom：Msg.Elem.Custom	|无|
|addGroupTip(groupTip)|	向 elems 中添加一个 GroupTip 元素	|groupTip: Msg.Elem.GroupTip|	无|
|toHtml()|	将 elems 转成可展示的 HTML 代码，仅供参考，业务方可以自定义消息转换逻辑| 无|		String|

### 消息元素对象 Msg.Elem

**对象名：**

```
webim.Msg.Elem
```


一个消息元素的描述类，一条消息 webim.Msg 可以由多个 webim.Msg.Elem 组成。**构造函数：**

```
webim.Msg.Elem(type,content)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|type	|元素类型，具体请参考 webim.MSG_ELEMENT_TYPE|	String|
|content	|元素内容对象|	Object，可能为<br/>1）Msg.Elem.Text<br/>2）Msg.Elem.Face<br/>3）Msg.Elem.Images<br/>4）Msg.Elem.Location<br/>5）Msg.Elem.Sound<br/>6）Msg.Elem.File<br/>7）Msg.Elem.Custom<br/>8）Msg.Elem.GroupTip|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getType()|获取元素类型，具体请参考 webim.MSG_ELEMENT_TYPE|无|String|
|getContent()|获取元素内容对象|无|Object，类型参考属性说明|
|toHtml()|获取元素的 HTML 代码，仅供参考，业务方可自定义实现|无|String|

### 消息元素对象（文本）

**对象名：**

```
webim.Msg.Elem.Text
```

**构造函数：**

```
webim.Msg.Elem.Text(text)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|text	|文本|String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getText()	|获取文本	|无	|String|
|toHtml()	|获取文本元素的 HTML 代码，仅供参考，业务方可自定义实现|	无	|String|



### 消息元素对象（表情）

**对象名：**

```
webim.Msg.Elem.Face
```

**构造函数：**

```
webim.Msg.Elem.Face(index,data)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|index|	表情索引，必填	|Integer|
|data|	表情数据，选填	|String|


**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getIndex()	|获取表情索引|无|	Integer|
|getData()|	获取表情数据|	无|	String|
|toHtml()|	获取表情元素的 HTML 代码，仅供参考，业务方可自定义实现|	无	|String|

### 消息元素对象（图片数组）

**对象名：**

```
webim.Msg.Elem.Images
```

**构造函数：**

```
webim.Msg.Elem.Images(imageId)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|imageId|	图片 ID	|String|
|ImageInfoArray	|图片信息数组（小图，大图，原图）|	[Msg.Elem.Images.Image]|


**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getImageId()	|获取图片 ID	|无	|String|
|addImage(image)|	向 ImageInfoArray 增加一张图片|	image：Msg.Elem.Images.Image|	无|
|getImage(type)	|获取某类图片信息	|type，图片大小类型，详细定义请参考 webim.IMAGE_TYPE	|Msg.Elem.Images.Image|
|toHtml()|	获取图片数组元素的 HTML 代码，仅供参考，业务方可自定义实现|	无|	String|



### 消息元素对象（图片）

**对象名：**

```
webim.Msg.Elem.Images.Image
```

**构造函数：**

```
webim.Msg.Elem.Images.Image(type,size,width,height,url)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|type	|图片大小类型，详细定义请参考 webim.IMAGE_TYPE|	Integer|
|size	|图片大小，单位：字节|	Integerv
|width|	宽度，单位：像素|	Integer|
|height	|高度，单位：像素|	Integer|
|url	|图片地址	|String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getType()	|获取图片大小类型	|无	|Integer|
|getSize()	|获取大小|	无|	Integer|
|getWidth()|	获取宽度	|无	|Integer|
|getHeight()	|获取高度|	无|	Integer|
|getUrl()	|获取地址	|无	|String|
|toHtml()	|获取图片信息的 HTML 代码，仅供参考，业务方可自定义实现	|无	|String|



### 消息元素对象（位置）

**对象名：**

```
webim.Msg.Elem.Location
```

暂不支持。**构造函数：**

```
webim.Msg.Elem.Location(longitude,latitude,desc)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|longitude	|经度	|Float|
|latitude|	纬度	|Float|
|desc|	描述|	String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getLongitude()	|获取经度	|无|	Float|
|getLatitude()	|获取纬度|	无|	Float|
|getDesc()	|获取描述	|无	|String|
|toHtml()	|获取位置元素的 HTML 代码，仅供参考，业务方可自定义实现|	无|	String|

### 消息元素对象（语音）

**对象名：**

```
webim.Msg.Elem.Sound
```

**构造函数：**

```
webim.Msg.Elem.Sound(uuid,second,size,senderId,downUrl)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|uuid	|语音 ID	|String|
|second	|时长，单位：秒|	Integer|
|size	|大小，单位：字节|	Integer|
|senderId	|发送者帐号|	String|
|downUrl	|下载地址|	String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getUUID()	|获取语音 ID	|无	|String|
|getSecond()	|获取时长|	无|	Integer|
|getSize()	|获取大小	|无|	Integer|
|getSenderId()|	获取发送者帐号|	无|	String|
|getDownUrl()|	获取地址|	无|	String|
|toHtml()	|获取语音元素的 HTML 代码，仅供参考，业务方可自定义实现	|无|	String|

### 消息元素对象（文件）

**对象名：**

```
webim.Msg.Elem.File
```

**构造函数：**

```
webim.Msg.Elem.File(uuid,name,size,senderId,downUrl)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|uuid	|文件 ID	|String|
|name|	文件名	|String|
|size	|大小，单位：字节|	Integer|
|senderId	|发送者帐号|	String|
|downUrl	|下载地址|	String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getUUID()	|获取文件 ID	|无|	String|
|getSize()	|获取大小，单位：字节|	无|	Integer|
|getName()|	获取名称	|无|	String|
|getSenderId()	|获取发送者帐号	|无	|String|
|getDownUrl()|	获取地址|	无	|String|
|toHtml()	|获取文件元素的 HTML 代码，仅供参考，业务方可自定义实现	|无	|String|

### 消息元素对象（自定义）

**对象名：***

```
webim.Msg.Elem.Custom
```

Web 端和后台接口采用了 JSON 格式的数据协议，要实现 Android，iOS 和 Web 的自定义消息互通，需要对消息进行编解码，例如使用 BASE64 编解码。

**构造函数：**

```
webim.Msg.Elem.Custom(data,desc,ext)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|data	|数据	|String|
|desc	|描述	|String|
|ext	|扩展字段	|String|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getData()|	获取数据|	无|	String|
|getDesc()	|获取描述	|无	|String|
|getExt()	|获取扩展字段	|无|	String|
|toHtml()|	获取文本元素的 HTML 代码，仅供参考，业务方可自定义实现|	无	|String|

### 消息元素对象（群提示）

**对象名：**

```
webim.Msg.Elem.GroupTip
```

**构造函数：**

```
webim.Msg.Elem.GroupTip(opType,opUserId,groupId,groupName,userIdList)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|opType|	操作类型，详细定义请参考 webim.GROUP_TIP_TYPE|	Integer|
|opUserId	|操作者 ID|	String|
|groupId	|群 ID|	String|
|groupName|	群名称	|String|
|userIdList|	被操作的用户 ID 列表|	[String]|
|groupInfoList|	新的群信息列表，群资料变更时才有值|	[Msg.Elem.GroupTip.GroupInfo]|
|memberInfoList	|新的群成员信息列表，群成员资料变更时才有值|	[Msg.Elem.GroupTip.MemberInfo]|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|addGroupInfo(groupInfo)	|向 groupInfoList 添加一条群资料变更信息|	groupInfo:Msg.Elem.GroupTip.GroupInfo	|无|
|addMemberInfo(memberInfo)|向 memberInfoList 添加一条群成员变更信息	|memberInfo:Msg.Elem.GroupTip.MemberInfo	|无|
|getOpType()	|获取操作类型，详细定义请参考webim.GROUP_TIP_TYPE|	无|	Integer|
|getOpUserId()|	获取操作者 ID	|无|	String|
|getGroupId()|	获取群 ID	|无|	String|
|getGroupName()	|获取群名称|	无	|String|
|getUserIdList()|	获取被操作的用户 ID 列表	|无|	[String]|
|getGroupInfoList()|获取新的群信息列表，群资料变更时才有值	|无|	[Msg.Elem.GroupTip.GroupInfo]|
|getMemberInfoList()	|获取新的群成员信息列表，群成员资料变更时才有值	|无|	[Msg.Elem.GroupTip.MemberInfo]|
|toHtml()	|获取群提示消息元素的 HTML 代码，仅供参考，业务方可自定义实现	|无	|String|

### 消息元素对象（群资料信息）

**对象名：**

```
webim.Msg.Elem.GroupTip.GroupInfo
```

**构造函数：**

```
webim.Msg.Elem.GroupTip.GroupInfo(type,value)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|type|	群资料变更类型，详细定义请参考 webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE|	Integer|
|value	|对应的值	|String|


**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getType()	|获取群资料变更类型，详细定义请参考 webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE	|无|	Integer|
|getValue()	|获取新的值，如果为空，则表示该类型的群资料没有变更	|无|	String|

### 消息元素对象（群成员信息）

**对象名：**

```
webim.Msg.Elem.GroupTip.MemberInfo
```

**构造函数：**

```
webim.Msg.Elem.MemberInfo.GroupInfo(userId,shutupTime)
```

**对象属性：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|userId	|群成员 ID	|String|
|shutupTime|	群成员被禁言时间，0表示取消禁言，大于0表示被禁言时长，单位：秒|	Integer|

**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|getUserId()	|获取群成员 ID|	无	|String|
|getShutupTime()	|获取群成员被禁言时间，0表示取消禁言，大于0表示被禁言时长，单位：秒|	无|	Integer|

### 表情对象 Emotions

webim.Emotions 是表情对象，键值对形式，key 是表情 index，value 包括了表情标识字符串和表情数据（可以是 BASE64 编码或者地址）。

![](//mccdn.qcloud.com/static/img/28b535381f62f87d5b8464b819a5bcd1/image.png)

### 表情数据索引对象 EmotionDataIndexs

webim.EmotionDataIndexs 是表情标识字符串和 index 的映射关系对象，键值对形式，key 是表情的标识字符串，value 是表情 index，主要用于发表情消息时，需要将消息文本中的表情识别出来，并转换成对应的索引 index 传给后台接口。

![](//mccdn.qcloud.com/static/img/11a2b050d1b47aefa1d9fb0a4e3fc716/image.png)

### 工具对象 Tool

**对象名：**

```
webim.Tool
```

webim.Tool 提供了一些通用的函数。例如格式化时间戳函数 `formatTimeStamp()`，获取字符串所占字节数 `getStrBytes()`。**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|formatTimeStamp(time,format)	|将时间戳转换成字符串	|time：时间戳<br/>format：格式，默认是'yyyy-MM-dd hh:mm:ss'	|无|
|getStrBytes(str)	|获取字符串所占字节数|	str：字符串|	无|

### 控制台打印日志对象 Log

**对象名：**

```
webim.Log
```

主要作用是方便查看 IM SDK 调用后台接口的请求 URL，请求 data 和响应 data，在 IM SDK 登录时，可以传递一个布尔类型的变量来控制 IM SDK 是否在控制台打印日志。**对象方法：**

| 名称 | 说明 | 输入参数 |返回类型|
|---------|---------|---------|---------|
|debug(logStr)|	打印调试日志|	logStr ： String类型	|无|
|info(logStr)	|打印提示日志	|logStr ： String类型	|无|
|warn(logStr)	|打印警告日志|	logStr ： String类型	|无|
|error(logStr)	|打印错误日志|	logStr ： String类型	|无|
