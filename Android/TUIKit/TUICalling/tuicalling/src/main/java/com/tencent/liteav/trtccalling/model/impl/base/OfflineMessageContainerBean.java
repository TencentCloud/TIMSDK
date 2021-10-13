package com.tencent.liteav.trtccalling.model.impl.base;

/**
 * 为什么离线消息要做两层嵌套，主要是因为后台在携带离线数据时的包装不一样
 *
 * 比如我们发消息的时候想在V2TIMOfflinePushInfo.setExt设置的数据为{"a":1,"b":2}
 * 那后台对不同的厂商会有不同的包装：
 *
 * 小米：{"ext":"{\"a\":1, \"b\":2}"}，小米解析ext字段出来就可以
 * OPPO：没有用ext包装，所以oppo收到数据时用bundle.keySet()解析为两个key：a和b，值分别为1和2，无法简单转化为bean
 *
 * 所以现在的做法时，在发送离线消息时，统一包装为{"entity":"xxxxxx"}，实际内容放在entity中，这样对应各个平台的解析：
 *
 * 小米：{"ext":"{\"entity\": \"xxxxxx\"}，小米解析ext字段，用容器类OfflineMessageContainerBean获取到entity
 * OPPO：用bundle.keySet()解析出entity的key，直接就可以获取实际消息OfflineMessageBean
 */
public class OfflineMessageContainerBean {

    public OfflineMessageBean entity;

}
