package com.tencent.qcloud.tuicore;

import android.content.Context;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

/**
 * TUI Plugin core class, mainly responsible for data transfer between TUI plugins, notification broadcast, function extension, etc.
 */
public class TUICore {
    private static final String TAG = TUICore.class.getSimpleName();

    /**
     * Register Service
     * @param serviceName    service name
     * @param service        service object
     */
    public static void registerService(String serviceName, ITUIService service) {
        ServiceManager.getInstance().registerService(serviceName, service);
    }

    /**
     * unregister Service
     *
     * @param serviceName service name
     */
    public static void unregisterService(String serviceName) {
        ServiceManager.getInstance().unregisterService(serviceName);
    }

    /**
     * get Service
     *
     * @param serviceName service name
     * @return service
     */
    public static ITUIService getService(String serviceName) {
        return ServiceManager.getInstance().getService(serviceName);
    }

    /**
     * Call Service
     *
     *  @param serviceName     service name
     *  @param method          method name
     *  @param param           pass parameters
     *  @return                object
     */
    public static Object callService(String serviceName, String method, Map<String, Object> param) {
        return ServiceManager.getInstance().callService(serviceName, method, param);
    }

    /**
     * start Activity
     * @param activityName     activity name，such as "TUIGroupChatActivity"
     * @param param            pass parameters
     */
    public static void startActivity(String activityName, Bundle param) {
        startActivity(null, activityName, param, -1);
    }

    /**
     * start Activity
     * @param starter         Initiator, either {@link Context} or {@link Fragment}
     * @param activityName    activity name，such as "TUIGroupChatActivity"
     * @param param           pass parameters
     */
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param) {
        startActivity(starter, activityName, param, -1);
    }

    /**
     * start Activity
     * @param starter         Initiator, either {@link Context} or {@link Fragment}
     * @param activityName    activity name，such as "TUIGroupChatActivity"
     * @param param           pass parameters
     * @param requestCode     The request value passed to the Activity, used to return the result in the initiator's 
     *                        onActivityResult method when the Activity ends, greater than or equal to 0 is valid.
     */
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param, int requestCode) {
        TUIRouter.Navigation navigation = TUIRouter.getInstance().setDestination(activityName).putExtras(param);
        if (starter instanceof Fragment) {
            navigation.navigate((Fragment) starter, requestCode);
        } else if (starter instanceof Context) {
            navigation.navigate((Context) starter, requestCode);
        } else {
            navigation.navigate((Context) null, requestCode);
        }
    }

    /**
     *  Register event
     */
    public static void registerEvent(String key, String subKey, ITUINotification notification) {
        EventManager.getInstance().registerEvent(key, subKey, notification);
    }

    /**
     *  Unregister event
     */
    public static void unRegisterEvent(String key, String subKey, ITUINotification notification) {
        EventManager.getInstance().unRegisterEvent(key, subKey, notification);
    }

    /**
     *  Removes all notifications for the specified notification object
     */
    public static void unRegisterEvent(ITUINotification notification) {
        EventManager.getInstance().unRegisterEvent(notification);
    }

    /**
     *  Notify event
     */
    public static void notifyEvent(String key, String subKey, Map<String, Object> param) {
        EventManager.getInstance().notifyEvent(key, subKey, param);
    }

    /**
     *  Register extension
     */
    public static void registerExtension(String key, ITUIExtension extension) {
        ExtensionManager.getInstance().registerExtension(key, extension);
    }

    /**
     *  Unregister extension
     */
    public static void unRegisterExtension(String key, ITUIExtension extension) {
        ExtensionManager.getInstance().unRegisterExtension(key, extension);
    }

    /**
     *  Get Extension
     */
    public static Map<String, Object> getExtensionInfo(String key, Map<String, Object> param) {
        return ExtensionManager.getInstance().getExtensionInfo(key, param);
    }

}
