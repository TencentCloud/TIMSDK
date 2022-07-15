package com.reactnativetimjs;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import com.reactnativetimjs.manager.SDKManager;
import com.reactnativetimjs.manager.FriendshipManager;
import com.reactnativetimjs.manager.GroupManager;
import com.reactnativetimjs.manager.ConversationManager;
import com.reactnativetimjs.manager.MessageManager;
import com.reactnativetimjs.manager.OfflinePushManager;
import com.reactnativetimjs.manager.SignalingManager;
import com.reactnativetimjs.util.CommonUtils;

import java.util.HashMap;
import java.util.Map;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

@ReactModule(name = TimJsModule.NAME)
public class TimJsModule extends ReactContextBaseJavaModule {
    public static final String NAME = "TimJs";
    public static SDKManager sdkManager;
    public static FriendshipManager friendshipManager;
    public static GroupManager groupManager;
    public static MessageManager messageManager;
    public static ConversationManager conversationManager;
    public static OfflinePushManager offlinePushManager;
    private static SignalingManager signalingManager;

    public static ReactApplicationContext reactContext;

    public TimJsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        TimJsModule.reactContext = reactContext;
        TimJsModule.sdkManager = new SDKManager(reactContext.getApplicationContext());
        TimJsModule.friendshipManager = new FriendshipManager();
        TimJsModule.messageManager = new MessageManager();
        TimJsModule.conversationManager = new ConversationManager();
        TimJsModule.offlinePushManager = new OfflinePushManager();
        TimJsModule.signalingManager = new SignalingManager();
        TimJsModule.groupManager = new GroupManager();
    }

    public static void sendEvent(String eventName, WritableMap params) {
        TimJsModule.reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    public void multiply(int a, int b, Promise promise) {
        promise.resolve(a * b);
    }

    @ReactMethod
    public void call(String mananger, String methodName, ReadableMap arguments, Promise promise) {
        CommonUtils.logFromNative("Request method: " + methodName + " arguments: " + arguments);
        Field field = null;
        Method method = null;
        try {
            field = TimJsModule.class.getDeclaredField(mananger);
            method = field.get(new Object()).getClass().getDeclaredMethod(methodName, Promise.class, ReadableMap.class);
            method.invoke(field.get(new Object()), promise, arguments);
        } catch (NoSuchFieldException e) {
            CommonUtils.logFromNative("error:" + e);
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            CommonUtils.logFromNative("error:" + e);
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            CommonUtils.logFromNative("error:" + e);
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            CommonUtils.logFromNative("error:" + e.getTargetException());
            // e.printStackTrace();
        }
    }

    public static native int nativeMultiply(int a, int b);
}
