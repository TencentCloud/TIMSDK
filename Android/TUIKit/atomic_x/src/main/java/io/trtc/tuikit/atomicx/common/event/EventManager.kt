package io.trtc.tuikit.atomicx.common.event

import android.text.TextUtils
import android.util.Log
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Notification registration, removal and triggering
 */
class EventManager private constructor() {
    private val eventMap: MutableMap<Pair<String, String>, MutableList<INotification>> = ConcurrentHashMap()

    companion object {
        private const val TAG = "EventManager"

        @JvmStatic
        val instance: EventManager by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
            EventManager()
        }
    }

    fun registerEvent(key: String?, subKey: String?, notification: INotification?) {
        Log.i(TAG, "registerEvent : key : $key, subKey : $subKey, notification : $notification")
        if (key.isNullOrEmpty() || subKey.isNullOrEmpty() || notification == null) {
            return
        }
        val keyPair = Pair(key, subKey)
        var list = eventMap[keyPair]
        if (list == null) {
            list = CopyOnWriteArrayList()
            eventMap[keyPair] = list
        }
        if (!list.contains(notification)) {
            list.add(notification)
        }
    }

    fun unRegisterEvent(key: String?, subKey: String?, notification: INotification?) {
        Log.i(TAG, "removeEvent : key : $key, subKey : $subKey notification : $notification")
        if (key.isNullOrEmpty() || subKey.isNullOrEmpty() || notification == null) {
            return
        }
        val keyPair = Pair(key, subKey)
        val list = eventMap[keyPair] ?: return
        list.remove(notification)
    }

    fun unRegisterEvent(notification: INotification?) {
        Log.i(TAG, "removeEvent : notification : $notification")
        if (notification == null) {
            return
        }
        eventMap.values.forEach { it.removeAll { item -> item === notification } }
    }

    fun notifyEvent(key: String?, subKey: String?, param: Map<String, Any?>?) {
        Log.d(TAG, "notifyEvent : key : $key, subKey : $subKey")
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(subKey)) {
            return
        }
        val keyPair = Pair(key!!, subKey!!)
        val notificationList = eventMap[keyPair]
        notificationList?.forEach { notification ->
            notification.onNotifyEvent(key, subKey, param)
        }
    }
}
