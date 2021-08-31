package com.tencent.qcloud.tim.uikit;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.qcloud.tim.uikit.base.GroupListenerConstants;
import com.tencent.qcloud.tim.uikit.base.IMEventListener;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.face.FaceManager;
import com.tencent.qcloud.tim.uikit.config.GeneralConfig;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.modules.chat.C2CChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static com.tencent.qcloud.tim.uikit.utils.NetWorkUtils.sIMSDKConnected;

public class TUIKitImpl {

    private static final String TAG = "TUIKit";

    private static Context               sAppContext;
    private static TUIKitConfigs         sConfigs;
    private static List<IMEventListener> sIMEventListeners = new ArrayList<>();
    private static Gson                  sGson;
    /**
     * TUIKit的初始化函数
     *
     * @param context  应用的上下文，一般为对应应用的ApplicationContext
     * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
     * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
     */
    public static void init(Context context, int sdkAppID, TUIKitConfigs configs) {
        sAppContext = context;
        sConfigs = configs;
        if (sConfigs.getGeneralConfig() == null) {
            GeneralConfig generalConfig = new GeneralConfig();
            sConfigs.setGeneralConfig(generalConfig);
        }
        sConfigs.getGeneralConfig().setSDKAppId(sdkAppID);
        String dir = sConfigs.getGeneralConfig().getAppCacheDir();
        if (TextUtils.isEmpty(dir)) {
            TUIKitLog.e(TAG, "appCacheDir is empty, use default dir");
            sConfigs.getGeneralConfig().setAppCacheDir(context.getFilesDir().getPath());
        } else {
            File file = new File(dir);
            if (file.exists()) {
                if (file.isFile()) {
                    TUIKitLog.e(TAG, "appCacheDir is a file, use default dir");
                    sConfigs.getGeneralConfig().setAppCacheDir(context.getFilesDir().getPath());
                } else if (!file.canWrite()) {
                    TUIKitLog.e(TAG, "appCacheDir can not write, use default dir");
                    sConfigs.getGeneralConfig().setAppCacheDir(context.getFilesDir().getPath());
                }
            } else {
                boolean ret = file.mkdirs();
                if (!ret) {
                    TUIKitLog.e(TAG, "appCacheDir is invalid, use default dir");
                    sConfigs.getGeneralConfig().setAppCacheDir(context.getFilesDir().getPath());
                }
            }
        }
        initTUIKitLive(context);
        initIM(context, sdkAppID);
        BackgroundTasks.initInstance();
        FileUtil.initPath(); // 取决于app什么时候获取到权限，即使在application中初始化，首次安装时，存在获取不到权限，建议app端在activity中再初始化一次，确保文件目录完整创建
        FaceManager.loadFaceFiles();
    }

    public static void login(final String userid, final String usersig, final IUIKitCallBack callback) {
        TUIKitConfigs.getConfigs().getGeneralConfig().setUserId(userid);
        TUIKitConfigs.getConfigs().getGeneralConfig().setUserSig(usersig);
        V2TIMManager.getInstance().login(userid, usersig, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                callback.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                loginTUIKitLive(TUIKitConfigs.getConfigs().getGeneralConfig().getSDKAppId(),
                        userid,
                        usersig);
                callback.onSuccess(null);
            }
        });
    }

    public static void logout(final IUIKitCallBack callback) {
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                callback.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                callback.onSuccess(null);
                logoutTUIKitLive();
            }
        });
    }

    private static void initIM(final Context context, int sdkAppID) {
        V2TIMSDKConfig sdkConfig = sConfigs.getSdkConfig();
        if (sdkConfig == null) {
            sdkConfig = new V2TIMSDKConfig();
            sConfigs.setSdkConfig(sdkConfig);
        }
        GeneralConfig generalConfig = sConfigs.getGeneralConfig();
        sdkConfig.setLogLevel(generalConfig.getLogLevel());
        sGson = new Gson();
        V2TIMManager.getInstance().initSDK(context, sdkAppID, sdkConfig, new V2TIMSDKListener() {
            @Override
            public void onConnecting() {
            }

            @Override
            public void onConnectSuccess() {
                sIMSDKConnected = true;
                for (IMEventListener l : sIMEventListeners) {
                    l.onConnected();
                }
            }

            @Override
            public void onConnectFailed(int code, String error) {
                sIMSDKConnected = false;
                for (IMEventListener l : sIMEventListeners) {
                    l.onDisconnected(code, error);
                }
            }

            @Override
            public void onKickedOffline() {
                for (IMEventListener l : sIMEventListeners) {
                    l.onForceOffline();
                }
                unInit();
            }

            @Override
            public void onUserSigExpired() {
                for (IMEventListener l : sIMEventListeners) {
                    l.onUserSigExpired();
                }
                unInit();
            }
        });

        V2TIMManager.getConversationManager().setConversationListener(new V2TIMConversationListener() {
            @Override
            public void onSyncServerStart() {
                super.onSyncServerStart();
            }

            @Override
            public void onSyncServerFinish() {
                super.onSyncServerFinish();
            }

            @Override
            public void onSyncServerFailed() {
                super.onSyncServerFailed();
            }

            @Override
            public void onNewConversation(List<V2TIMConversation> conversationList) {
                ConversationManagerKit.getInstance().onRefreshConversation(conversationList);
                for (IMEventListener listener : sIMEventListeners) {
                    listener.onRefreshConversation(conversationList);
                }
            }

            @Override
            public void onConversationChanged(List<V2TIMConversation> conversationList) {
                ConversationManagerKit.getInstance().onRefreshConversation(conversationList);
                for (IMEventListener listener : sIMEventListeners) {
                    listener.onRefreshConversation(conversationList);
                }
            }

            @Override
            public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                ConversationManagerKit.getInstance().updateTotalUnreadMessageCount(totalUnreadCount);
            }
        });

        V2TIMManager.getInstance().setGroupListener(new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                TUIKitLog.i(TAG, "onMemberEnter groupID:" + groupID + ", size:" + memberList.size());
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_MEMBER_ENTER);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_MEMBER, sGson.toJson(memberList));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberList) {
                    String userID = v2TIMGroupMemberInfo.getUserID();
                    if (userID != null && userID.equals(V2TIMManager.getInstance().getLoginUser())) {
                        GroupChatManagerKit.getInstance().notifyJoinGroup(groupID, false);
                        return;
                    }
                }
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                TUIKitLog.i(TAG, "onMemberLeave groupID:" + groupID + ", memberID:" + member.getUserID());
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_MEMBER_LEAVE);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_MEMBER, sGson.toJson(member));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberList) {
                    String userID = v2TIMGroupMemberInfo.getUserID();
                    if (userID != null && userID.equals(V2TIMManager.getInstance().getLoginUser())) {
                        GroupChatManagerKit.getInstance().notifyJoinGroup(groupID, true);
                        return;
                    }
                }
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberList) {
                    String userID = v2TIMGroupMemberInfo.getUserID();
                    if (userID != null && userID.equals(V2TIMManager.getInstance().getLoginUser())) {
                        GroupChatManagerKit.getInstance().notifyKickedFromGroup(groupID);
                        return;
                    }
                }
            }

            @Override
            public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
            }

            @Override
            public void onGroupCreated(String groupID) {

            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_GROUP_DISMISSED);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_OP_USER, sGson.toJson(opUser));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                GroupChatManagerKit.getInstance().notifyGroupDismissed(groupID);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_GROUP_RECYCLED);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_OP_USER, sGson.toJson(opUser));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                GroupChatManagerKit.getInstance().notifyGroupDismissed(groupID);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_GROUP_INFO_CHANGED);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_INFO, sGson.toJson(changeInfos));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {

            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                if (!isAgreeJoin) {
                    GroupChatManagerKit.getInstance().notifyJoinGroupRefused(groupID);
                }
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {

            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {

            }

            @Override
            public void onQuitFromGroup(String groupID) {
                TUIKitLog.i(TAG, "onQuitFromGroup groupID:" + groupID);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_REV_CUSTOM_DATA);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_CUSTOM_DATA, customData);
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                GroupChatManagerKit.getInstance().notifyGroupRESTCustomSystemData(groupID, customData);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                Intent intent = new Intent(GroupListenerConstants.ACTION);
                intent.putExtra(GroupListenerConstants.KEY_METHOD, GroupListenerConstants.METHOD_ON_GROUP_ATTRS_CHANGED);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ID, groupID);
                intent.putExtra(GroupListenerConstants.KEY_GROUP_ATTR, sGson.toJson(groupAttributeMap));
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);

            }
        });

        //添加好友成功后有相关回调，可以自行实现通知
        /*V2TIMManager.getFriendshipManager().setFriendListener(new V2TIMFriendshipListener() {
            @Override
            public void onFriendListAdded(List<V2TIMFriendInfo> users) {
                C2CChatManagerKit.getInstance().notifyNewFriend(users);
            }
        });*/

        V2TIMManager.getMessageManager().addAdvancedMsgListener(new V2TIMAdvancedMsgListener() {
            @Override
            public void onRecvNewMessage(V2TIMMessage msg) {
                for (IMEventListener l : sIMEventListeners) {
                    l.onNewMessage(msg);
                }
            }

            @Override
            public void onRecvC2CReadReceipt(List<V2TIMMessageReceipt> receiptList) {
                C2CChatManagerKit.getInstance().onReadReport(receiptList);
            }

            @Override
            public void onRecvMessageRevoked(String msgID) {
                super.onRecvMessageRevoked(msgID);
            }

            @Override
            public void onRecvMessageModified(V2TIMMessage msg) {
                TUIKitLog.i(TAG, "onRecvMessageModified msgID:" + msg.getMsgID());
            }
        });

        V2TIMManager.getMessageManager().addAdvancedMsgListener(MessageRevokedManager.getInstance());
    }

    public static void unInit() {
        ConversationManagerKit.getInstance().destroyConversation();
        unInitTUIKitLive();
    }

    public static Context getAppContext() {
        return sAppContext;
    }

    public static TUIKitConfigs getConfigs() {
        if (sConfigs == null) {
            sConfigs = TUIKitConfigs.getConfigs();
        }
        return sConfigs;
    }

    public static void addIMEventListener(IMEventListener listener) {
        TUIKitLog.i(TAG, "addIMEventListener:" + sIMEventListeners.size() + "|l:" + listener);
        if (listener != null && !sIMEventListeners.contains(listener)) {
            sIMEventListeners.add(listener);
        }
    }

    public static void removeIMEventListener(IMEventListener listener) {
        TUIKitLog.i(TAG, "removeIMEventListener:" + sIMEventListeners.size() + "|l:" + listener);
        if (listener == null) {
            sIMEventListeners.clear();
        } else {
            sIMEventListeners.remove(listener);
        }
    }

    private static void initTUIKitLive(Context context) {
        try {
            Class<?> classz = Class.forName("com.tencent.qcloud.tim.tuikit.live.TUIKitLive");
            Method   method = classz.getMethod("init", Context.class);
            method.invoke(null, context);
        } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            TUIKitLog.e(TAG, "initTUIKitLive error: " + e.getMessage());
        }
    }

    private static void unInitTUIKitLive() {
        try {
            Class<?> classz = Class.forName("com.tencent.qcloud.tim.tuikit.live.TUIKitLive");
            Method   method = classz.getMethod("unInit");
            method.invoke(null);
        } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            TUIKitLog.e(TAG, "unInitTUIKitLive error: " + e.getMessage());
        }
    }

    private static void loginTUIKitLive(int sdkAppid, String userId, String userSig) {
        try {
            Class<?> classz = Class.forName("com.tencent.qcloud.tim.tuikit.live.TUIKitLive");
            Class<?> tClazz = Class.forName("com.tencent.qcloud.tim.tuikit.live.TUIKitLive$LoginCallback");

            // 反射修改isAttachedTUIKit的值
            Field field = classz.getDeclaredField("sIsAttachedTUIKit");
            field.setAccessible(true);
            field.set(null, true);

            Method   method = classz.getMethod("login", int.class, String.class, String.class, tClazz);
            method.invoke(null, sdkAppid, userId, userSig, null);
        }catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException | NoSuchFieldException e) {
           TUIKitLog.e(TAG, "loginTUIKitLive error: " + e.getMessage());
        }
    }

    private static void logoutTUIKitLive() {
        try {
            Class<?> classz = Class.forName("com.tencent.qcloud.tim.tuikit.live.TUIKitLive");
            Method   method = classz.getMethod("logout");
            method.invoke(null);
        } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            TUIKitLog.e(TAG, "logoutTUIKitLive error: " + e.getMessage());
        }
    }
}
