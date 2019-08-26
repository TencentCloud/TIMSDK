
**`logout` 函数名：**

```
webim.logout
```

**定义：**

```
webim.logout(cbOk, cbErr)
```

**参数列表：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|cbOk	|调用接口成功回调函数	|Function|
|cbErr	|调用接口失败回调函数	|Function|

**示例：**

```
//登出
function logout() {
    //登出
    webim.logout(
            function (resp) {
                webim.Log.info('登出成功');
                loginInfo.identifier = null;
                loginInfo.userSig = null;
                $("#video_sms_list").find("li").remove();
                var indexUrl = window.location.href;
                var pos = indexUrl.indexOf('?');
                if (pos >= 0) {
                    indexUrl = indexUrl.substring(0, pos);
                }
                window.location.href = indexUrl;
            }
    );
}
```
