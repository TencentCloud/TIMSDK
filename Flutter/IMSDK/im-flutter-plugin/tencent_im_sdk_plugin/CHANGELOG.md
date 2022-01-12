## 0.0.1

* init version

## 0.0.2

* change sdk name

## 0.0.3

* change licese 

## 0.0.4

* add readme

## 0.0.5

* change conversion return data

## 0.0.6

* add document

## 0.0.7

* add other document

## 0.0.8

* change document

## 0.0.9

* change document

## 0.0.9

* 设置对外不可见

## 0.0.12

* 更改配置

## 0.0.13

* 更改会话列表传参类型

## 0.0.13

* 已知bug修复

## 0.0.15

* 新增insertMessageToLocalStorage接口

## 0.0.16

* 修改插入本地消息的类型textMessage to customMessage

## 0.0.17

* 兼容R8

## 0.0.18

* update native sdk

## 0.0.19

* 正式上线版本

## 1.0.0

* 更新最新版文档

## 1.0.1

* 更新最新版文档

## 1.0.2

* 更新最新版文档

## 1.0.3

* 更新最新版文档

## 1.0.4

* 更新native sdk到5.1.129

## 1.0.5

* 修复deleteFriendApplication传参错误

## 1.0.6

* 更新native sdk到5.1.132

## 1.0.7

* 更新native sdk到5.1.137

## 1.0.8

* 修改信令邀请接口传参bug

## 1.0.9

* 修复信令接口不返回id

## 1.0.10

* 修改sdk压缩配置

## 1.0.11

* 修改sdk压缩配置

## 1.0.12

* 修改信令回调bug

## 1.0.13

* 修改自定义消息返回数据

## 1.0.14

* 【重要】信令消息返回内容格式修改，用到信令请更新到该版本或以上版本

## 1.0.15

* 新增群成员自定义字段

## 1.0.16

* 修改一些已知bug

## 1.0.17

* 完善ios信令

## 1.0.18

* 修复已知bug

## 1.0.19

* iOS信令bug修复

## 1.0.20

* iOS信令bug修复

## 1.0.21

* iOS信令bug修复

## 1.0.22

* 自定义字段解析成String返回

## 1.0.23

* 优化设置个人自定义字段

## 1.0.24

* 优化设置个人自定义字段

## 1.0.25

* 更新Android getHistoryMessageList

## 1.0.26

* 修复Android端checkFriend传参错误

## 1.0.27

* 修复Android端checkFriend传参错误

## 1.0.28

* 【重要】checkFriends接口入参改变

## 1.0.29

* 【重要】修复获取群成员列表传参报错

## 1.0.30

* 修复自定义消息data字段为null时crash

## 1.0.31

* 修复自定义消息data字段为null时crash

## 1.0.32

* 修复会话信息lastMessage为空时crash

## 1.0.33

* 修改sdk的minSdkVersion到16

## 1.0.34

* 修复ios获取历史消息报错

## 1.0.35

* 修复安卓manifest配置冲突

## 1.0.36

* 修复Android设置好友自定义字段失败

## 1.0.37

* 信令补充invitee字段

## 1.1.0

* ios端消息实例新增seq字段

## 2.0.0

* 【重要】flutter升级到2.0,支持空安全

## 2.0.1

* 修复返回数据类型错误

## 2.0.2

* ios修复修改群资料报错

## 2.0.3

* ios修复修改群资料报错（二）

## 2.0.4

* ios/android，新增高级消息，发送文本消息sendTextMessage
* android，修复sendCustomMessage不传递extension报错

## 2.0.5

* 修复会话isFinish的bug

## 2.0.6

* 修复事件监听传参


## 3.0.0
* 发送高级消息新增offlinePushInfo
* 高级消息发送失败将失败的消息返回
* 新增reSendMessage用做失败重发
* 修改listener注册方式
* 新增api sendTextAtMessage、sendLocationMessage、sendFaceMessage、sendMergerMessage、sendForwardMessage、setC2CReceiveMessageOpt
setGroupReceiveMessageOpt、getC2CReceiveMessageOpt、getConversationListByConversaionIds、pinConversation、getTotalUnreadMessageCount、* tCloudCustomData、setLocalCustomInt、setLocalCustomData
* 更换新包，上报、关键节点日志
* 支持发送高级消息不计入未读数
* V2TimMessage对象新增mergeElem、random、isExcludedFromUnreadCount
* 提升性能，修改部分方法传参

## 3.0.1
* 修复若干问题

## 3.0.2
* 修复信令inviteID为空

## 3.0.3
* 修复信令接收回调异常

## 3.0.4
* 修复groupListener回调异常

## 3.0.5
* 修复信令回调异常

## 3.0.6
* 修复groupListener回调异常

## 3.0.7
* 修复已知问题

## 3.0.8
* ios修复直播群发送消息无返回的问题
* ios修改createFriendGroup返回的字段名

## 3.0.9
* 修复groupListener回调异常

## 3.1.0
* 修复会话回调异常

## 3.1.1
* 修复sendForwardMessage bug

## 3.1.2
* ios修复发消息错误时返回的数据格式

## 3.1.3
* ios已知问题修复

## 3.1.4
* ios返回数据异常

## 3.1.5
* 获取群属性，keys字段改成非必传&去掉demo，demo请在官网直接体验和下载

## 3.1.6
* ios已知问题修复

## 3.1.7
* 新增接口getHistoryMessageListWithoutFormat

## 3.1.8
* 更新Android Native SDK到5.3.435
* 新增接口getConversationListWithoutFormat
* 修复信令接口crash

## 3.1.9
* 修改sdk压缩混淆选项

## 3.2.0
* 修复会话中lastMessage转化异常

## 3.2.1
* ios修复已知问题

## 3.2.2
* ios修复已知问题

## 3.2.3
* ios升级native sdk

## 3.2.4
* ios修复已知问题

## 3.2.5
* seq修改为string类型

## 3.2.6
* ios修复已知问题

## 3.2.7
* ios修复invite无推送的问题

## 3.2.8
* 修复invite参数

## 3.2.9
* 拉历史消息新增seq参数

## 3.3.0
* 修复iOSSound参数

## 3.3.1
* 修复已知问题

## 3.3.2
* Android权限修改

## 3.3.3
* 打包时支持混淆

## 3.3.4
* 修正path返回

## 3.3.5
* ios修复onSyncServerStart等事件

## 3.3.6
* ios bug修复

## 3.3.7
* ios bug修复

## 3.3.8
* ios 修复饭初始化crash

## 3.3.9
* 兼容firebase
* 升级底层sdk

## 3.4.0
* 修复disable字段错误

## 3.4.1
* 修复群tips信息不完善

## 3.4.2
* disablePush字段对齐

## 3.4.3
* Hydra命名空间

## 3.4.4
* Hydra命名空间

## 3.5.0
* 新增接口
* callExperimentalAPI 
* clearC2CHistoryMessage
* clearGroupHistoryMessage
* searchLocalMessages
* findMessages
* searchGroups
* searchGroupMembers
* getSignalingInfo
* addInvitedSignaling
* searchFriends

## 3.5.1
* 数组越界兼容逻辑

## 3.5.2
* add web support

## 3.5.3
* 新增onTotalUnreadMessageCountChanged事件
* V2TimConversation新增orderkey字段，用于会话排序

## 3.5.4
* 新增downloadMergeMesasge接口

## 3.5.5
* 架构调整

## 3.5.6
* 修复checkFriend失败问题
* 修复getC2CHistoryMessageList无法获取后续消息问题

## 3.6.0
* 各个模块支持listener多次注册，多次回调
* 新增api markAllMessageAsRead 设置全部会话已读
* 新增组合消息解析
* 升级native 版本至5.8.1668

## 3.6.1
* 修复文件进度事件丢失

## 3.6.2
* 修复移除高级消息未传uuid

## 3.6.3
* addFriend 接口优化: addType 由int 变更为 FriendTypeEnum
* acceptFriendApplication 接口优化: acceptType 由int 变更为 FriendResponseTypeEnum
* checkFriend 接口优化: checkType 由int 变更为 FriendTypeEnum
* createGroup 接口优化: addOpt 由int 变更为 GroupAddOptTypeEnum
* deleteFromFriendList 接口优化: deleteType 由int 变更为 FriendTypeEnum
* getGroupMemberList 接口优化: filter 由int 变更为 GroupMemberFilterTypeEnum
* getHistoryMessageList 接口优化: type 由int 变更为 HistoryMsgGetTypeEnum
* getHistoryMessageListWithoutFormat 接口优化: type 由int 变更为 HistoryMsgGetTypeEnum
* getGroupMemberList 接口优化: type 由int 变更为 GroupMemberFilterTypeEnum
* getGroupMemberList 接口优化: filter 由int 变更为 GroupMemberFilterTypeEnum
* initSDK 接口优化: loglevel 由int 变更为 LogLevelEnum
* refuseFriendApplication 接口优化: acceptType 由int 变更为 FriendApplicationTypeEnum
* sendCustomMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendFaceMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendFileMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendForwardMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendImageMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendLocationMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendMergerMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendSoundMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendTextAtMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* sendTextMessage 接口优化: priority 由int 变更为 MessagePriorityEnum
* setGroupMemberRole 接口优化: role 由int 变更为 GroupMemberRoleTypeEnum
* 事件回调注册返回修改为异步


## 3.6.4
* 修复安卓异步注册事件无返回bug
* 修复移除基础监听事件报错
* 消息进度事件增加发送中的消息的uuid

## 3.6.5
* 修复java语法错误

## 3.6.6
* 添加消息回复接口
* 修复web端release mode 下报错问题

## 3.6.7
* ios编译环境从8.0升到9.0

## 3.6.8
* 回复消息接口优化

## 3.6.9
* 回复消息参数优化

## 3.7.0
* 优化cloudCustomData解包

## 3.7.1
* 消息发送进度事件返回创建消息的id
* 优化回调部分，提示业务方回调的错误在SDK中被catch需业务方修改