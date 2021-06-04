package com.tencent.qcloud.tim.uikit.utils;

import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;

public class TUIKitUtils {

    public static boolean ignoreNotification(V2TIMMessage msg) {
        if (msg == null) {
            return false;
        }
        V2TIMCustomElem elem = msg.getCustomElem();
        if (elem == null) {
            return false;
        }
        byte[] bytes = elem.getData();
        if (bytes == null) {
            return false;
        }
        if (MessageInfoUtil.isTyping(bytes) || MessageInfoUtil.isOnlineIgnored(msg)) {
            return true;
        }
        return false;
    }

    /**
     * 比较版本号的大小,前者大则返回一个正数,后者大返回一个负数,相等则返回0
     *
     * @param version1 版本号1
     * @param version2 版本号2
     * @return 前者大则返回一个正数, 后者大返回一个负数, 相等则返回0
     */
    public static int compareVersion(String version1, String version2) {
        if (version1 == null || version2 == null) {
            return 0;
        }
        String[] versionArray1 = version1.split("\\.");//注意此处为正则匹配，不能用"."；
        String[] versionArray2 = version2.split("\\.");
        int idx = 0;
        int minLength = Math.min(versionArray1.length, versionArray2.length);//取最小长度值
        int diff = 0;
        while (idx < minLength
                && (diff = versionArray1[idx].length() - versionArray2[idx].length()) == 0//先比较长度
                && (diff = versionArray1[idx].compareTo(versionArray2[idx])) == 0) {//再比较字符
            ++idx;
        }
        //如果已经分出大小，则直接返回，如果未分出大小，则再比较位数，有子版本的为大；
        diff = (diff != 0) ? diff : versionArray1.length - versionArray2.length;
        return diff;
    }
}
