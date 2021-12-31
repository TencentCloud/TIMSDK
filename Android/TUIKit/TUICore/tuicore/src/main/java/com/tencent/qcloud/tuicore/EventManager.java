package com.tencent.qcloud.tuicore;


import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 负责通知注册、移除和触发
 */
class EventManager {
    private static final String TAG = ServiceManager.class.getSimpleName();

    private static class EventManagerHolder {
        private static final EventManager eventManager = new EventManager();
    }

    public static EventManager getInstance() {
        return EventManagerHolder.eventManager;
    }

    private final Map<Pair<String, String>, List<ITUINotification>> eventMap = new ConcurrentHashMap<>();

    private EventManager() {}

    public void registerEvent(String key, String subKey, ITUINotification notification) {
        Log.i(TAG, "registerEvent : key : " + key + ", subKey : " + subKey + ", notification : " + notification);
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(subKey) || notification == null) {
            return;
        }
        Pair<String, String> keyPair = new Pair<>(key, subKey);
        List<ITUINotification> list = eventMap.get(keyPair);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            eventMap.put(keyPair, list);
        }
        if (!list.contains(notification)) {
            list.add(notification);
        }
    }

    public void unRegisterEvent(String key, String subKey, ITUINotification notification) {
        Log.i(TAG, "removeEvent : key : " + key + ", subKey : " + subKey + " notification : " + notification);
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(subKey) || notification == null) {
            return;
        }
        Pair<String, String> keyPair = new Pair<>(key, subKey);
        List<ITUINotification> list = eventMap.get(keyPair);
        if (list == null) {
            return;
        }
        list.remove(notification);
    }

    public void unRegisterEvent(ITUINotification notification) {
        Log.i(TAG, "removeEvent : notification : " + notification);
        if (notification == null) {
            return;
        }
        for (Pair<String, String> key : eventMap.keySet()) {
            List<ITUINotification> value = eventMap.get(key);
            if (value == null) {
                continue;
            }
            Iterator<ITUINotification> notificationIterator = value.iterator();
            while (notificationIterator.hasNext()) {
                ITUINotification item = notificationIterator.next();
                if (item == notification) {
                    notificationIterator.remove();
                }
            }

        }
    }

    public void notifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.i(TAG, "notifyEvent : key : " + key + ", subKey : " + subKey);
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(subKey)) {
            return;
        }
        Pair<String, String> keyPair = new Pair<>(key, subKey);
        List<ITUINotification> notificationList = eventMap.get(keyPair);
        if (notificationList != null) {
            for(ITUINotification notification : notificationList) {
                notification.onNotifyEvent(key, subKey, param);
            }
        }
    }

}
