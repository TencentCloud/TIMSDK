### 腾讯云即时通信 IM Unity SDK，官方使用交流群（764231117）



1. ##### 下载最新的SDK，打开Unity编辑器通过Assets->import packages->custom package导入

2. ##### 前往腾讯云即时通信控制台创建应用，获得sdk_app_id和secret信息，sdk_app_id在初始化SDK时使用，secret在生成usersig时使用。

3. ##### 在控制台->辅助工具生成userisg（生产环境，usersig请在后台生成）。

4. ##### 初始化SDK

   ```c#
   
   // 第一步中申请的sdk_app_id;
   long sdk_app_id = 0;
   
   SdkConfig sdkConfig = new SdkConfig();
   
   // 指定使用SDK时缓存数据的存储位置，注意文件的读写权限
   sdkConfig.sdk_config_config_file_path = Application.persistentDataPath + "/TIM-Config";
   // 指定使用SDK时日志的存储位置，注意文件的读写权限
   sdkConfig.sdk_config_log_file_path = Application.persistentDataPath + "/TIM-Log";
   
   TIMResult res = TencentIMSDK.Init(sdk_app_id, sdkConfig);
   
   ```

5. 注册全局事件监听

   ```c#
   
   // 例如注册收到消息回调
   RecvNewMsgCallback(List<Message> message, string user_data){
     
   }
   
   TencentIMSDK.AddRecvNewMsgCallback(RecvNewMsgCallback);
   
   // 其他回调注册，如会话回调，收到加好友申请回调等，都在这里注册
   ```

6. 登录SDK

   ```c#
   
   string user_id = "";
   
   string user_sig = "";
   
   callback(int code, string desc, string json_param, string user_data) {
     
   }
   TIMResult res = TencentIMSDK.Login(user_id,user_sig, callback);
   
   
   ```

7. 发送消息

   ```c#
   
   // 此处演示发送C2C文本消息
   string conv_id = "user_id";
   Message message = new Message();
   message.message_conv_id = conv_id;
   message.message_conv_type = TIMConvType.kTIMConv_C2C;
   List<Elem> messageElems = new List<Elem>();
   Elem textMessage = new Elem();
   textMessage.elem_type = TIMElemType.kTIMElem_Text;
   textMessage.text_elem_content = "hello";
   messageElems.Add(textMessage);
   message.message_elem_array = messageElems;
   StringBuilder messageId = new StringBuilder(128);
   
   callback(int code, string desc, string json_param, string user_data) {
     
   }
   
   TIMResult res = TencentIMSDK.MsgSendMessage(conv_id, TIMConvType.kTIMConv_C2C, message, messageId, callback);
   
   ```


9. #### 常见问题

   1. editor调试SDK务必保证在代码热时调用Uninit，并且停止play
   2. editor调试设置如下unity->perferences->general->script change while playing 为stop playing and recompile。
   3. mac调试如显示IMSdkForMac.dylib显示已损坏，可执行sudo xattr -r -d com.apple.quarantine  ImSDKForMac.dylib


