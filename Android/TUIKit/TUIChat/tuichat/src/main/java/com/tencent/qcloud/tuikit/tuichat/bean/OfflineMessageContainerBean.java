package com.tencent.qcloud.tuikit.tuichat.bean;

/**
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
