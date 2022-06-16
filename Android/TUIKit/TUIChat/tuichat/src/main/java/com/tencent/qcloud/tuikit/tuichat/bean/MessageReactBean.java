package com.tencent.qcloud.tuikit.tuichat.bean;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

public class MessageReactBean implements Serializable {
    public static final int VERSION = 1;

    private Map<String, Set<String>> reacts;
    private int version = VERSION;

    private transient Map<String, ReactUserBean> reactUserBeanMap;

    public void operateUser(String emojiId, String userId) {
        if (reacts == null) {
            reacts = new LinkedHashMap<>();
        }
        Set<String> userList = reacts.get(emojiId);
        if (userList == null) {
            userList = new LinkedHashSet<>();
            reacts.put(emojiId, userList);
        }
        if (userList.contains(userId)) {
            userList.remove(userId);
        } else {
            userList.add(userId);
        }
        if (userList.isEmpty()) {
            reacts.remove(emojiId);
        }
    }

    public Map<String, Set<String>> getReacts() {
        return reacts;
    }

    public void setReacts(Map<String, Set<String>> reacts) {
        this.reacts = reacts;
    }

    public int getReactSize() {
        if (reacts != null) {
            return reacts.size();
        }
        return 0;
    }

    public void setReactUserBeanMap(Map<String, ReactUserBean> reactUserBeanMap) {
        this.reactUserBeanMap = reactUserBeanMap;
    }

    public Map<String, ReactUserBean> getReactUserBeanMap() {
        return reactUserBeanMap;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }
}
