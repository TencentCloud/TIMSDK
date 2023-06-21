package com.tencent.qcloud.tim.demo.push;

/**
 * Function：离线推送消息的透传字段可以通过接口 V2TIMOfflinePushInfo.setExt(ext) 设置，当用户收到推送点击通知栏时，可以在启动界面内获取该透传字段。
 *           OfflineMessageContainerBean 是 TUIKitDemo 的透传参数 ext 对应的 Javabean。
 *
 * Format：设置透传字段格式
 *           new Gson().toJson(OfflineMessageContainerBean).getBytes()
 *         获取透传字段格式
 *           {"entity":"xxxxxx"}
 *
 * Attention：OfflineMessageContainerBean 转化为 json 多了一层包装解析为 {"entity":"xxxxxx"} 格式，
 *            因为 OPPO 透传消息解析方法有：收到数据时用bundle.keySet()解析需要 key-value 格式，不然无法简单转化为bean而获取失败。
 *
 *
 *
 *
 * Function：The transparent transmission field of the offline push message can be set through the interface V2TIMOfflinePushInfo.setExt(ext)，
 *           When the user receives the push and clicks on the notification bar, the transparent transmission field can be obtained in the startup interface.
 *           OfflineMessageContainerBean is the Javabean corresponding to the transparent parameter ext of TUIKitDemo.
 *
 * Format：Set the transparent transmission field format
 *           new Gson().toJson(OfflineMessageContainerBean).getBytes()
 *         Get the transparent transmission field format
 *           {"entity":"xxxxxx"}
 *
 * Attention：OfflineMessageContainerBean is converted to json with an extra layer of packaging and parsed as {"entity":"xxxxxx"} format，
 *            Because OPPO's transparent message parsing methods are: when data is received, the key-value format is required for parsing with bundle.keySet(),
 *            otherwise it cannot be simply converted into a bean and the acquisition fails.
 *
 */
public class OfflineMessageContainerBean {

    public OfflineMessageBean entity;

}
