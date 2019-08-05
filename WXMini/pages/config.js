const CONFIG = {

    // 2019/8/5 
    // 更新登录方式
    // 可以直接在 debug 下的 GenerateTestUserSig.js 里配置好自己的 sdkappid 和 privateKey 直接就可登录，无需手动生成 identifier 和 usersig

    app: {
        sdkappid : 'SDKAppID' // 填入创建腾讯云通讯应用获取到的 sdkappid
    },


    // users:[ // 将下面内容替换成通过控制台开发辅助工具生成的几组 identifier 和 userSig
    //     {
    //         identifier: 'identifier',
    //         userSig: 'userSig'
            
    //     }
    // ],


    
    avChatRoomId: 'xxxxxxxxx', // 群ID, 必选，填入创建的类型为互动直播聊天室的群 ID。
}

module.exports = CONFIG;