package com.tencent.qcloud.tuicore;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import java.util.List;
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
     * Call service asynchronously
     *
     *  @param serviceName     service name
     *  @param method          method name
     *  @param param           pass parameters
     *  @return                object
     */
    public static Object callService(String serviceName, String method, Map<String, Object> param, TUIServiceCallback callback) {
        return ServiceManager.getInstance().callService(serviceName, method, param, callback);
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
     * @note The method has been deprecated：use {@link #startActivityForResult}
     */
    @Deprecated
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param, int requestCode) {
        TUIRouter.startActivity(starter, activityName, param, requestCode);
    }

    /**
     * Start the activity and get the result asynchronously
     * @param caller          {@link androidx.activity.result.ActivityResultCaller}
     * @param activityName    activity name，such as "TUIGroupChatActivity"
     * @param param           pass parameters
     * @param resultCallback  the result callback
     */
    public static void startActivityForResult(
        @Nullable ActivityResultCaller caller, String activityName, Bundle param, ActivityResultCallback<ActivityResult> resultCallback) {
        TUIRouter.startActivityForResult(caller, activityName, param, resultCallback);
    }

    /**
     * Start the activity and get the result asynchronously
     * @param caller          {@link androidx.activity.result.ActivityResultCaller}
     * @param activityClazz   activity's Class Object
     * @param param           pass parameters
     * @param resultCallback  the result callback
     */
    public static void startActivityForResult(
        @Nullable ActivityResultCaller caller, Class<? extends Activity> activityClazz, Bundle param, ActivityResultCallback<ActivityResult> resultCallback) {
        TUIRouter.startActivityForResult(caller, activityClazz, param, resultCallback);
    }

    /**
     * Start the activity and get the result asynchronously
     * @param caller          {@link androidx.activity.result.ActivityResultCaller}
     * @param intent          the intent
     * @param resultCallback  the result callback
     */
    public static void startActivityForResult(@Nullable ActivityResultCaller caller, Intent intent, ActivityResultCallback<ActivityResult> resultCallback) {
        TUIRouter.startActivityForResult(caller, intent, resultCallback);
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
    public static void registerExtension(String extensionID, ITUIExtension extension) {
        ExtensionManager.getInstance().registerExtension(extensionID, extension);
    }

    /**
     *  Unregister extension
     */
    public static void unRegisterExtension(String key, ITUIExtension extension) {
        ExtensionManager.getInstance().unRegisterExtension(key, extension);
    }

    /**
     *  Get Extension
     *  @note The method has been deprecated：use {@link #getExtensionList}
     */
    @Deprecated
    public static Map<String, Object> getExtensionInfo(String key, Map<String, Object> param) {
        return ExtensionManager.getInstance().getExtensionInfo(key, param);
    }

    /**
     *  Get Extension list
     */
    public static List<TUIExtensionInfo> getExtensionList(String extensionID, Map<String, Object> param) {
        return ExtensionManager.getInstance().getExtensionList(extensionID, param);
    }

    /**
     *  invoke Extension
     */
    public static void raiseExtension(String key, View parentView, Map<String, Object> param) {
        ExtensionManager.getInstance().raiseExtension(key, parentView, param);
    }

    /**
     *  Register object factory
     */
    public static void registerObjectFactory(String factoryName, ITUIObjectFactory objectFactory) {
        ObjectManager.getInstance().registerObjectFactory(factoryName, objectFactory);
    }

    /**
     *  Unregister object factory
     */
    public static void unregisterObjectFactory(String factoryName) {
        ObjectManager.getInstance().unregisterObjectFactory(factoryName);
    }

    /**
     *  Create object and get
     */
    public static Object createObject(String objectFactory, String objectName, Map<String, Object> param) {
        return ObjectManager.getInstance().createObject(objectFactory, objectName, param);
    }
}
