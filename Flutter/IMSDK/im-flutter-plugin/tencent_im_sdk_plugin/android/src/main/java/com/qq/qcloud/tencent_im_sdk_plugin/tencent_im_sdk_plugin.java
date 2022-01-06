package com.qq.qcloud.tencent_im_sdk_plugin;


import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.qq.qcloud.tencent_im_sdk_plugin.manager.ConversationManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.FriendshipManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.GroupManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.MessageManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.OfflinePushManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.SignalingManager;
import com.qq.qcloud.tencent_im_sdk_plugin.manager.TimManager;
import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


/**
 * tencent_im_sdk_plugin
 */
public class
tencent_im_sdk_plugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    /**
     * 日志签名
     */
    public static String TAG = "tencent_im_sdk_plugin";

    /**
     * 全局上下文
     */
    public static Context context;

    /**
     * 与Flutter的通信管道
     */
    private static MethodChannel channel;
    private static MessageManager messageManager;
    private static GroupManager groupManager;
    private static SignalingManager signalingManager;
    private static ConversationManager conversationManager;
    private static FriendshipManager friendshipManager;
    private static OfflinePushManager offlinePushManager;
    public static TimManager timManager;

    public tencent_im_sdk_plugin() {
    }

    private tencent_im_sdk_plugin(Context context, MethodChannel channel) {
        tencent_im_sdk_plugin.context = context;
        tencent_im_sdk_plugin.channel = channel;
        tencent_im_sdk_plugin.messageManager = new MessageManager(channel);
        tencent_im_sdk_plugin.groupManager = new GroupManager(channel);
        tencent_im_sdk_plugin.signalingManager = new SignalingManager(channel);
        tencent_im_sdk_plugin.conversationManager = new ConversationManager(channel);
        tencent_im_sdk_plugin.friendshipManager = new FriendshipManager(channel);
        tencent_im_sdk_plugin.offlinePushManager = new OfflinePushManager(channel);
        tencent_im_sdk_plugin.timManager = new TimManager(channel, context);
//        JSON.DEFAULT_GENERATE_FEATURE |= SerializerFeature.DisableCircularReferenceDetect.mask;

    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine");
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tencent_im_sdk_plugin");

    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        String TIMManagerName = CommonUtil.getParam(call, result, "TIMManagerName");
        Field field = null;
        Method method = null;
        try {
            field = tencent_im_sdk_plugin.class.getDeclaredField(TIMManagerName);
            method = field.get(new Object()).getClass().getDeclaredMethod(call.method, MethodCall.class, Result.class);
            method.invoke(field.get(new Object()), call, result);
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        Log.i(TAG, "onDetachedFromEngine");
        // channel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onAttachedToActivity");
        channel.setMethodCallHandler(new tencent_im_sdk_plugin(binding.getActivity().getApplicationContext(), channel));
    }


    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onReattachedToActivityForConfigChanges");
        channel.setMethodCallHandler(new tencent_im_sdk_plugin(binding.getActivity().getApplicationContext(), channel));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "onDetachedFromActivityForConfigChanges");
        // channel = null;
    }


    @Override
    public void onDetachedFromActivity() {
        Log.i(TAG, "onDetachedFromActivity");
        // channel = null;
    }
}
