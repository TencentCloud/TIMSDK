//退出
function quitClick() {
    if (loginInfo.identifier) {
        //sdk登出
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

//被新实例踢下线的回调处理
function onKickedEventCall(){
    webim.Log.error("其他地方登录，被T了");
    document.getElementById("webim_demo").style.display = "none";
}



//多终端登录被T
function onMultipleDeviceKickedOut() {
    webim.Log.error("多终端登录，被T了");
    document.getElementById("webim_demo").style.display = "none";
}

