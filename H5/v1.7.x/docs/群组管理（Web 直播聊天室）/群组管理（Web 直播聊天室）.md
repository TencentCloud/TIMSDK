
## 进群

**`applyJoinBigGroup` 函数名：**

```
webim.applyJoinBigGroup
```

**定义：**

```
webim.applyJoinBigGroup(options,cbOk, cbErr)
```

**参数列表：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|options|	进群信息对象|	Object|
|cbOk	|调用接口成功回调函数	|Function|
|cbErr	|调用接口失败回调函数	|Function|

**其中 `options` 对象属性定义如下：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|GroupId	|要加入的群 ID	|String|

**示例：**

```
//加入直播大群
function applyJoinBigGroup(groupId) {
    var options = {
        'GroupId': groupId//群 ID
    };
    webim.applyJoinBigGroup(
            options,
            function (resp) {
                //JoinedSuccess:加入成功; WaitAdminApproval:等待管理员审批
                if (resp.JoinedStatus && resp.JoinedStatus == 'JoinedSuccess') {
                    webim.Log.info('加入房间成功');
                } else {
                    alert('加入房间失败');
                }
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
}
```

## 退群

**`quitBigGroup` 函数名：**

```
webim.quitBigGroup
```

**定义：**

```
webim.quitBigGroup(options,cbOk, cbErr)
```

**参数列表：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|options	|退群信息对象	|Object|
|cbOk	|调用接口成功回调函数	|Function|
|cbErr	|调用接口失败回调函数	|Function|

**其中 `options` 对象属性定义如下：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|GroupId|要退出的群 ID	|String|

**示例：**

```
//退出大群
function quitBigGroup() {
    var options = {
        'GroupId': avChatRoomId//群 ID
    };
    webim.quitBigGroup(
            options,
            function (resp) {
                webim.Log.info('退群成功');
                $("#video_sms_list").find("li").remove(); 
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
}
```
