
**登出 `logout` 函数名：**

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

```javascript
//登出
function quitClick() {
    if (loginInfo.identifier) {
        //SDK 登出
        webim.logout(
                function (resp) {
                    loginInfo.identifier = null;
                    loginInfo.userSig = null;
                    document.getElementById("webim_demo").style.display = "none";
                    var indexUrl = window.location.href;
                    var pos = indexUrl.indexOf('?');
                    if (pos >= 0) {
                        indexUrl = indexUrl.substring(0, pos);
                    }
                    window.location.href = indexUrl;
                }
        );
    } else {
        alert('未登录');
    }
}
```
