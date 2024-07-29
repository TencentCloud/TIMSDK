package com.tencent.qcloud.tuikit.tuichat;

import android.content.Context;
import android.text.TextUtils;
import androidx.datastore.preferences.core.Preferences;
import androidx.datastore.preferences.rxjava3.RxPreferenceDataStoreBuilder;
import androidx.datastore.rxjava3.RxDataStore;
import com.google.auto.service.AutoService;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IBaseMessageSender;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.TotalUnreadCountListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.DataStoreUtil;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency("TIMCommon")
@TUIInitializerID("TUIChat")
public class TUIChatService implements TUIInitializer, ITUIService, ITUINotification {
    public static final String TAG = TUIChatService.class.getSimpleName();
    private static TUIChatService instance;

    public static TUIChatService getInstance() {
        return instance;
    }

    private Context appContext;

    private final List<WeakReference<GroupChatEventListener>> groupChatEventListenerList = new ArrayList<>();

    private final List<WeakReference<C2CChatEventListener>> c2CChatEventListenerList = new ArrayList<>();

    private WeakReference<IBaseMessageSender> messageSender;

    private final List<WeakReference<TotalUnreadCountListener>> unreadCountListenerList = new ArrayList<>();

    private final List<WeakReference<NetworkConnectionListener>> connectListenerList = new ArrayList<>();

    private final Map<String, Class<? extends TUIMessageBean>> customMessageMap = new HashMap<>();
    private final Set<Class<? extends TUIMessageBean>> extensionMessageClass = new HashSet<>();
    private RxDataStore<Preferences> mChatDataStore = null;

    @Override
    public void init(Context context) {
        instance = this;
        appContext = context;
        initMessageType();
        initService();
        initEvent();
        initIMListener();
        initDataStore();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIChat.SERVICE_NAME, this);
    }

    private void initDataStore() {
        if (mChatDataStore == null) {
            mChatDataStore = new RxPreferenceDataStoreBuilder(getAppContext(), TUIChatConstants.DataStore.DATA_STORE_NAME).build();
        }
        DataStoreUtil.getInstance().setDataStore(mChatDataStore);
    }

    public RxDataStore<Preferences> getChatDataStore() {
        return mChatDataStore;
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_JOIN_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_INVITED_GROUP, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, this);
        TUICore.registerEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING, TUIChatConstants.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING, this);
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_MESSAGE_INFO_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.Event.GroupApplication.KEY_GROUP_APPLICATION,
            TUIConstants.TUIGroup.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        if (TextUtils.equals(TUIConstants.TUIChat.METHOD_SEND_MESSAGE, method)) {
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            int chatType = (int) getOrDefault(param.get(TUIConstants.TUIChat.CHAT_TYPE), 0);
            String content = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_CONTENT), "");
            String description = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_DESCRIPTION), "");
            String extension = (String) getOrDefault(param.get(TUIConstants.TUIChat.MESSAGE_EXTENSION), "");
            IBaseMessageSender messageSender = getMessageSender();
            if (messageSender != null) {
                TUIMessageBean message = ChatMessageBuilder.buildCustomMessage(content, description, extension.getBytes());
                return messageSender.sendMessage(message, chatId, TUIChatUtils.isGroupChat(chatType), false);
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_EXIT_CHAT, method)) {
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            boolean isGroupChat = (boolean) param.get(TUIConstants.TUIChat.IS_GROUP_CHAT);
            if (isGroupChat) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.exitGroupChat(chatId);
                }
            } else {
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.exitC2CChat(chatId);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_GET_DISPLAY_STRING, method)) {
            if (param != null) {
                V2TIMMessage v2TIMMessage = (V2TIMMessage) param.get(TUIConstants.TUIChat.V2TIMMESSAGE);
                if (v2TIMMessage != null) {
                    return ChatMessageParser.getDisplayString(v2TIMMessage);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_ADD_MESSAGE_TO_CHAT, method)) {
            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.MESSAGE_BEAN);
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            boolean isGroupChat = (boolean) param.get(TUIConstants.TUIChat.IS_GROUP_CHAT);
            if (isGroupChat) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.addMessage(messageBean, chatId);
                }
            } else {
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.addMessage(messageBean, chatId);
                }
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.METHOD_UPDATE_DATA_STORE_CHAT_URI, method)) {
            String uri = (String) param.get(TUIConstants.TUIChat.CHAT_BACKGROUND_URI);
            String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
            if (!TextUtils.isEmpty(uri)) {
                DataStoreUtil.getInstance().putValue(chatId, uri);
            }
        } else if (TextUtils.equals(TUIConstants.TUIChat.Method.GetMessagesDisplayString.METHOD_NAME, method)) {
            getMessagesDisplayString(param);
        } else if (TextUtils.equals(TUIConstants.TUIChat.Method.GetTUIMessageBean.METHOD_NAME, method)) {
            return getTUIMessagesBean(param);
        }
        return null;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIGroup.EVENT_GROUP)) {
            handleGroupEvent(subKey, param);
        } else if (key.equals(TUIConstants.TUIContact.EVENT_USER)) {
            handleContactUserEvent(subKey, param);
        } else if (key.equals(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED)) {
            handleFriendInfChangedEvent(subKey, param);
        } else if (key.equals(TUIConstants.TUIConversation.EVENT_UNREAD)) {
            handleUnreadChangedEvent(subKey, param);
        } else if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED)) {
            handleInitStatusEvent(subKey);
        } else if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            handleLoginStatusEvent(subKey);
        } else if (TextUtils.equals(key, TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED)) {
            handleMessageStatusChangedEvent(subKey, param);
        } else if (TextUtils.equals(key, TUIChatConstants.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
            handleOfflineRingEvent(subKey, param);
        } else if (TextUtils.equals(key, TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT)) {
            handleMessageChangedEvent(subKey, param);
        } else if (TextUtils.equals(TUIConstants.TUIGroup.Event.GroupApplication.KEY_GROUP_APPLICATION, key)) {
            handleGroupApplicationEvent(subKey, param);
        }
    }

    private void handleOfflineRingEvent(String subKey, Map<String, Object> param) {
        if (TextUtils.equals(subKey, TUIChatConstants.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
            Boolean isPrivateRing = (Boolean) param.get(TUIChatConstants.OFFLINE_MESSAGE_PRIVATE_RING);
            TUIChatConfigs.getConfigs().getGeneralConfig().setEnableAndroidPrivateRing(isPrivateRing);

            Map<String, Object> paramRing = new HashMap<>();
            paramRing.put(TUIConstants.TIMPush.CONFIG_FCM_CHANNEL_ID_KEY, OfflinePushInfoUtils.FCM_PUSH_CHANNEL_ID);
            paramRing.put(TUIConstants.TIMPush.CONFIG_FCM_PRIVATE_RING_NAME_KEY, OfflinePushInfoUtils.PRIVATE_RING_NAME);
            paramRing.put(TUIConstants.TIMPush.CONFIG_ENABLE_FCM_PRIVATE_RING_KEY, isPrivateRing);
            TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME, TUIConstants.TIMPush.METHOD_SET_CUSTOM_FCM_RING, paramRing);
        }
    }

    private void handleMessageStatusChangedEvent(String subKey, Map<String, Object> param) {
        if (TextUtils.equals(subKey, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND)) {
            Object msgBeanObj = param.get(TUIChatConstants.MESSAGE_BEAN);
            if (msgBeanObj instanceof TUIMessageBean) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onMessageChanged((TUIMessageBean) msgBeanObj, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                }
                List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onMessageChanged((TUIMessageBean) msgBeanObj, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                }
            }
        }
    }

    public void refreshMessage(TUIMessageBean messageBean) {
        List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
        for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
            groupChatEventListener.onMessageChanged(messageBean, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        }
        List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
        for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
            c2CChatEventListener.onMessageChanged(messageBean, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        }
    }

    private void handleUnreadChangedEvent(String subKey, Map<String, Object> param) {
        if (subKey.equals(TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED)) {
            long unreadCount = (long) param.get(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT);
            List<TotalUnreadCountListener> totalUnreadCountListenerList = getUnreadCountListenerList();
            for (TotalUnreadCountListener totalUnreadCountListener : totalUnreadCountListenerList) {
                totalUnreadCountListener.onTotalUnreadCountChanged(unreadCount);
            }
        }
    }

    private void handleFriendInfChangedEvent(String subKey, Map<String, Object> param) {
        if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED)) {
            if (param == null || param.isEmpty()) {
                return;
            }
            String id = (String) param.get(TUIConstants.TUIContact.FRIEND_ID);
            String remark = (String) param.get(TUIConstants.TUIContact.FRIEND_REMARK);
            List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
            for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                c2CChatEventListener.onFriendNameChanged(id, remark);
            }
        }
    }

    private void handleContactUserEvent(String subKey, Map<String, Object> param) {
        if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
            if (param == null || param.isEmpty()) {
                return;
            }
            String userID = (String) getOrDefault(param.get(TUIConstants.TUIContact.FRIEND_ID), "");
            List<C2CChatEventListener> c2CChatEventListenerList = getC2CChatEventListenerList();
            for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                c2CChatEventListener.clearC2CMessage(userID);
            }
        }
    }

    private void handleMessageChangedEvent(String subKey, Map<String, Object> param) {
        if (TextUtils.equals(subKey, TUIConstants.TUIChat.EVENT_SUB_KEY_MESSAGE_INFO_CHANGED)) {
            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.MESSAGE_BEAN);
            int dataChangeType = (int) param.get(TUIChatConstants.DATA_CHANGE_TYPE);
            List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
            for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                c2CChatEventListener.onMessageChanged(messageBean, dataChangeType);
            }
            List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
            for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                groupChatEventListener.onMessageChanged(messageBean, dataChangeType);
            }
        }
    }

    private void handleLoginStatusEvent(String subKey) {
        if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS)) {
            // Set whether to open the floating window for voice and video calls
            Map<String, Object> enableFloatWindowParam = new HashMap<>();
            enableFloatWindowParam.put(
                TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW, TUIChatConfigs.getConfigs().getGeneralConfig().isEnableFloatWindowForCall());
            TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, enableFloatWindowParam);

            // Set Whether to enable multi-terminal login function for audio and video calls
            Map<String, Object> enableMultiDeviceParam = new HashMap<>();
            enableMultiDeviceParam.put(
                TUIConstants.TUICalling.PARAM_NAME_ENABLE_MULTI_DEVICE, TUIChatConfigs.getConfigs().getGeneralConfig().isEnableMultiDeviceForCall());
            TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_ENABLE_MULTI_DEVICE, enableMultiDeviceParam);

            // Set whether to enable incoming banner when user received audio and video calls
            Map<String, Object> incomingBannerParam = new HashMap<>();
            incomingBannerParam.put(
                TUIConstants.TUICalling.PARAM_NAME_ENABLE_INCOMING_BANNER, TUIChatConfigs.getConfigs().getGeneralConfig().isEnableIncomingBanner());
            TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_ENABLE_INCOMING_BANNER, incomingBannerParam);
        }
    }

    private void handleInitStatusEvent(String subKey) {
        if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT)) {
            loadBuildInFaces();
        }
    }

    private void loadBuildInFaces() {
        ThreadUtils.execute(() -> {
            FaceGroup<Emoji> emojiFaceGroup = new FaceGroup<>();
            // load chat default emojis
            String[] emojiKeys = getAppContext().getResources().getStringArray(R.array.chat_buildin_emoji_key);
            String[] emojiNames = getAppContext().getResources().getStringArray(R.array.chat_buildin_emoji_name);
            String[] emojiPath = getAppContext().getResources().getStringArray(R.array.chat_buildin_emoji_file_name);
            int emojiSize = getAppContext().getResources().getDimensionPixelSize(com.tencent.qcloud.tuikit.tuichat.R.dimen.chat_default_load_emoji_size);
            for (int i = 0; i < emojiKeys.length; i++) {
                String emojiKey = emojiKeys[i];
                String emojiFilePath = "chatbuildinemojis/" + emojiPath[i];
                Emoji emoji = FaceManager.loadAssetEmoji(emojiKey, emojiFilePath, emojiSize);
                if (emoji != null) {
                    emoji.setFaceName(emojiNames[i]);
                    emojiFaceGroup.addFace(emojiKey, emoji);
                }
            }
            emojiFaceGroup.setPageColumnCount(FaceManager.EMOJI_COLUMN_COUNT);
            emojiFaceGroup.setPageRowCount(FaceManager.EMOJI_ROW_COUNT);
            emojiFaceGroup.setFaceGroupIconUrl(com.tencent.qcloud.tuikit.tuichat.R.drawable.tuiemoji_default_emoji_group_icon);
            FaceManager.addFaceGroup(FaceManager.EMOJI_GROUP_ID, emojiFaceGroup);
        });
    }

    private void handleGroupEvent(String subKey, Map<String, Object> param) {
        if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP)
            || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS)
            || TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE)) {
            List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
            String groupId = null;
            if (param != null) {
                groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
            }
            for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                groupChatEventListener.onGroupForceExit(groupId);
            }
        } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED)) {
            if (param == null) {
                return;
            }
            String newGroupName = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_NAME), null);
            String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
            String groupFaceUrl = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_FACE_URL), null);

            if (TextUtils.isEmpty(groupId)) {
                return;
            }
            if (!TextUtils.isEmpty(newGroupName)) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGroupNameChanged(groupId, newGroupName);
                }
            }
            if (!TextUtils.isEmpty(groupFaceUrl)) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGroupFaceUrlChanged(groupId, groupFaceUrl);
                }
            }
        } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP)) {
            if (param == null) {
                return;
            }
            String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
            ArrayList<String> memberList = (ArrayList<String>) param.get(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST);
            if (TextUtils.isEmpty(groupId) || memberList == null || memberList.isEmpty()) {
                return;
            }
            String selfId = TUILogin.getLoginUser();
            if (memberList.contains(selfId)) {
                List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGroupForceExit(groupId);
                }
            }
        } else if (TextUtils.equals(subKey, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE)) {
            String groupId = (String) getOrDefault(param.get(TUIConstants.TUIGroup.GROUP_ID), "");
            List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
            for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                groupChatEventListener.clearGroupMessage(groupId);
            }
        }
    }

    private void handleGroupApplicationEvent(String subKey, Map<String, Object> param) {
        if (TextUtils.equals(subKey, TUIConstants.TUIGroup.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED)) {
            List<GroupChatEventListener> groupChatEventListenerList = getGroupChatEventListenerList();
            for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                groupChatEventListener.onApplied();
            }
        }
    }

    private Object getOrDefault(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }

    private <T> T getOrDefault(Map map, Object key, T defaultValue) {
        if (map == null || map.isEmpty()) {
            return defaultValue;
        }
        Object object = map.get(key);
        try {
            if (object != null) {
                return (T) object;
            }
        } catch (ClassCastException e) {
            return defaultValue;
        }
        return defaultValue;
    }

    private void initIMListener() {
        V2TIMManager.getMessageManager().addAdvancedMsgListener(new V2TIMAdvancedMsgListener() {
            @Override
            public void onRecvNewMessage(V2TIMMessage msg) {
                TUIMessageBean message = ChatMessageParser.parsePresentMessage(msg);
                if (message == null) {
                    return;
                }

                HashMap<String, Object> param = new HashMap<>();
                String conversationID;
                if (TextUtils.isEmpty(msg.getGroupID())) {
                    List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                    for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                        c2CChatEventListener.onRecvNewMessage(message);
                    }
                    conversationID = TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX + msg.getUserID();
                    if (message instanceof MessageTypingBean) {
                        param.put(TUIConstants.TUIChat.IS_TYPING_MESSAGE, true);
                    } else {
                        param.put(TUIConstants.TUIChat.IS_TYPING_MESSAGE, false);
                    }
                } else {
                    List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onRecvNewMessage(message);
                    }
                    conversationID = TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX + msg.getGroupID();
                }

                param.put(TUIConstants.TUIChat.CONVERSATION_ID, conversationID);
                TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_RECEIVE_MESSAGE, TUIConstants.TUIChat.EVENT_SUB_KEY_CONVERSATION_ID, param);
            }

            @Override
            public void onRecvMessageReadReceipts(List<V2TIMMessageReceipt> receiptList) {
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();

                List<MessageReceiptInfo> messageReceiptInfos = new ArrayList<>();
                for (V2TIMMessageReceipt messageReceipt : receiptList) {
                    MessageReceiptInfo messageReceiptInfo = new MessageReceiptInfo();
                    messageReceiptInfo.setMessageReceipt(messageReceipt);
                    messageReceiptInfos.add(messageReceiptInfo);
                }
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onReadReport(messageReceiptInfos);
                }
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onReadReport(messageReceiptInfos);
                }
            }

            @Override
            public void onRecvMessageRevoked(String msgID, V2TIMUserFullInfo operateUser, String reason) {
                UserBean userBean = new UserBean();
                userBean.setUserId(operateUser.getUserID());
                userBean.setNikeName(operateUser.getNickName());
                userBean.setFaceUrl(operateUser.getFaceUrl());
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onRecvMessageRevoked(msgID, userBean, reason);
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onRecvMessageRevoked(msgID, userBean, reason);
                }
            }

            @Override
            public void onRecvMessageModified(V2TIMMessage msg) {
                TUIMessageBean message = ChatMessageParser.parsePresentMessage(msg);
                if (message == null) {
                    return;
                }
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    c2CChatEventListener.onRecvMessageModified(message);
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onRecvMessageModified(message);
                }
                TUIChatLog.i(TAG, "onRecvMessageModified msgID:" + msg.getMsgID());
            }

            @Override
            public void onGroupMessagePinned(String groupID, V2TIMMessage v2TIMMessage, boolean isPinned, V2TIMGroupMemberInfo opUser) {
                UserBean userBean = new UserBean();
                userBean.setUserId(opUser.getUserID());
                userBean.setNikeName(opUser.getNickName());
                userBean.setFaceUrl(opUser.getFaceUrl());
                userBean.setFriendRemark(opUser.getFriendRemark());
                userBean.setNameCard(opUser.getNameCard());
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                if (isPinned) {
                    TUIMessageBean messageBean = ChatMessageParser.parseMessage(v2TIMMessage);
                    if (messageBean == null) {
                        return;
                    }
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onGroupMessagePinned(groupID, messageBean, userBean);
                    }
                } else {
                    for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                        groupChatEventListener.onGroupMessageUnPinned(groupID, v2TIMMessage.getMsgID(), userBean);
                    }
                }
            }
        });

        V2TIMManager.getFriendshipManager().addFriendListener(new V2TIMFriendshipListener() {
            @Override
            public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
                List<C2CChatEventListener> c2CChatEventListenerList = getInstance().getC2CChatEventListenerList();
                for (C2CChatEventListener c2CChatEventListener : c2CChatEventListenerList) {
                    for (V2TIMFriendInfo info : infoList) {
                        if (TextUtils.isEmpty(info.getFriendRemark())) {
                            String nickName = info.getUserProfile().getNickName();
                            if (TextUtils.isEmpty(nickName)) {
                                c2CChatEventListener.onFriendNameChanged(info.getUserID(), info.getUserID());
                            } else {
                                c2CChatEventListener.onFriendNameChanged(info.getUserID(), nickName);
                            }
                        } else {
                            c2CChatEventListener.onFriendNameChanged(info.getUserID(), info.getFriendRemark());
                        }
                        c2CChatEventListener.onFriendFaceUrlChanged(info.getUserID(), info.getUserProfile().getFaceUrl());
                    }
                }
            }
        });

        V2TIMManager.getInstance().addGroupListener(new V2TIMGroupListener() {
            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                List<String> userIDs = new ArrayList<>();
                for (V2TIMGroupMemberInfo info : memberList) {
                    userIDs.add(info.getUserID());
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onGrantGroupAdmin(groupID, userIDs);
                }
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                List<String> userIDs = new ArrayList<>();
                for (V2TIMGroupMemberInfo info : memberList) {
                    userIDs.add(info.getUserID());
                }
                List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                    groupChatEventListener.onRevokeGroupAdmin(groupID, userIDs);
                }
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                for (V2TIMGroupChangeInfo changeInfo : changeInfos) {
                    if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                        List<GroupChatEventListener> groupChatEventListenerList = getInstance().getGroupChatEventListenerList();
                        for (GroupChatEventListener groupChatEventListener : groupChatEventListenerList) {
                            groupChatEventListener.onGrantGroupOwner(groupID, changeInfo.getValue());
                        }
                    }
                }
            }
        });

        V2TIMManager.getInstance().addIMSDKListener(new V2TIMSDKListener() {
            @Override
            public void onConnectSuccess() {
                for (WeakReference<NetworkConnectionListener> listenerWeakReference : connectListenerList) {
                    NetworkConnectionListener listener = listenerWeakReference.get();
                    if (listener != null) {
                        listener.onConnected();
                    }
                }
            }
        });
    }

    public void registerNetworkListener(NetworkConnectionListener listener) {
        if (listener == null) {
            return;
        }

        for (WeakReference<NetworkConnectionListener> weakReference : connectListenerList) {
            NetworkConnectionListener networkConnectionListener = weakReference.get();
            if (networkConnectionListener == listener) {
                return;
            }
        }

        WeakReference<NetworkConnectionListener> weakReference = new WeakReference<>(listener);
        connectListenerList.add(weakReference);
    }

    // Initialize custom message types
    private void initMessageType() {
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_HELLO, CustomLinkMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_EVALUATION, CustomEvaluationMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_ORDER, CustomOrderMessageBean.class);
        addCustomMessageType(TUIChatConstants.BUSINESS_ID_CUSTOM_TYPING, MessageTypingBean.class);
    }

    /**
     *
     * Register a custom message type
     * @param businessId Custom message unique identifier（cannot be repeated）
     * @param beanClass  MessageBean type
     */
    public void addCustomMessageType(String businessId, Class<? extends TUIMessageBean> beanClass, boolean isDefault) {
        if (customMessageMap.containsKey(businessId)) {
            TUIChatLog.i(TAG, "addCustomMessageType: businessID already exists: " + businessId);
            return;
        }
        customMessageMap.put(businessId, beanClass);
        if (!isDefault) {
            extensionMessageClass.add(beanClass);
        }
    }

    /**
     *
     * Register a custom message type
     * @param businessId Custom message unique identifier（cannot be repeated）
     * @param beanClass  MessageBean type
     */
    public void addCustomMessageType(String businessId, Class<? extends TUIMessageBean> beanClass) {
        addCustomMessageType(businessId, beanClass, true);
    }

    public Class<? extends TUIMessageBean> getMessageBeanClass(String businessId) {
        return customMessageMap.get(businessId);
    }

    public Set<Class<? extends TUIMessageBean>> getExtensionMessageClassSet() {
        return extensionMessageClass;
    }

    private List<GroupChatEventListener> getGroupChatEventListenerList() {
        List<GroupChatEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<GroupChatEventListener>> iterator = groupChatEventListenerList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<GroupChatEventListener> listenerWeakReference = iterator.next();
            GroupChatEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addGroupChatEventListener(GroupChatEventListener groupChatListener) {
        if (groupChatListener == null) {
            return;
        }
        for (WeakReference<GroupChatEventListener> listenerWeakReference : groupChatEventListenerList) {
            if (listenerWeakReference.get() == groupChatListener) {
                return;
            }
        }
        groupChatEventListenerList.add(new WeakReference<>(groupChatListener));
    }

    private List<C2CChatEventListener> getC2CChatEventListenerList() {
        List<C2CChatEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<C2CChatEventListener>> iterator = c2CChatEventListenerList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<C2CChatEventListener> listenerWeakReference = iterator.next();
            C2CChatEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addC2CChatEventListener(C2CChatEventListener c2cChatEventListener) {
        if (c2cChatEventListener == null) {
            return;
        }
        for (WeakReference<C2CChatEventListener> listenerWeakReference : c2CChatEventListenerList) {
            if (listenerWeakReference.get() == c2cChatEventListener) {
                return;
            }
        }
        c2CChatEventListenerList.add(new WeakReference<>(c2cChatEventListener));
    }

    public void removeC2CChatEventListener(C2CChatEventListener c2cChatEventListener) {
        Iterator<WeakReference<C2CChatEventListener>> iterator = c2CChatEventListenerList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<C2CChatEventListener> listenerWeakReference = iterator.next();
            C2CChatEventListener listener = listenerWeakReference.get();
            if (listener == c2cChatEventListener) {
                iterator.remove();
            }
        }
    }

    public void setMessageSender(IBaseMessageSender baseMessageSender) {
        messageSender = new WeakReference<>(baseMessageSender);
    }

    public void addUnreadCountListener(TotalUnreadCountListener unreadCountListener) {
        if (unreadCountListener == null) {
            return;
        }
        for (WeakReference<TotalUnreadCountListener> listenerWeakReference : unreadCountListenerList) {
            if (listenerWeakReference.get() == unreadCountListener) {
                return;
            }
        }
        unreadCountListenerList.add(new WeakReference<>(unreadCountListener));
    }

    private List<TotalUnreadCountListener> getUnreadCountListenerList() {
        List<TotalUnreadCountListener> listeners = new ArrayList<>();
        Iterator<WeakReference<TotalUnreadCountListener>> iterator = unreadCountListenerList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<TotalUnreadCountListener> listenerWeakReference = iterator.next();
            TotalUnreadCountListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    private IBaseMessageSender getMessageSender() {
        if (messageSender != null) {
            return messageSender.get();
        }
        return null;
    }

    public String sendMessage(TUIMessageBean messageBean, String chatId, int chatType, boolean onlineUserOnly) {
        IBaseMessageSender messageSender = getMessageSender();
        if (messageSender != null) {
            return messageSender.sendMessage(messageBean, chatId, TUIChatUtils.isGroupChat(chatType), onlineUserOnly);
        } else {
            return null;
        }
    }

    public static Context getAppContext() {
        return instance.appContext;
    }

    private TUIMessageBean getTUIMessagesBean(Map<String, Object> param) {
        Object v2TIMMessageObj = param.get(TUIConstants.TUIChat.Method.GetTUIMessageBean.V2TIM_MESSAGE);
        if (v2TIMMessageObj instanceof V2TIMMessage) {
            return ChatMessageParser.parsePresentMessage((V2TIMMessage) v2TIMMessageObj);
        }
        return null;
    }

    private void getMessagesDisplayString(Map<String, Object> param) {
        Map<String, TUIMessageBean> conversationMessageBeanMap =
                (Map<String, TUIMessageBean>) param.get(TUIConstants.TUIChat.Method.GetMessagesDisplayString.MESSAGE_MAP);
        for (Map.Entry<String, TUIMessageBean> entry : conversationMessageBeanMap.entrySet()) {
            String conversationID = entry.getKey();
            TUIMessageBean tuiMessageBean = entry.getValue();
            Set<String> userIDSet = tuiMessageBean.getAdditionalUserIDList();
            if (userIDSet.isEmpty()) {
                notifyMessageDisplayStringUpdated(conversationID, tuiMessageBean);
                continue;
            }
            ChatPresenter chatPresenter;
            if (conversationID.startsWith(TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX)) {
                chatPresenter = new C2CChatPresenter();
                C2CChatInfo c2CChatInfo = new C2CChatInfo();
                c2CChatInfo.setId(conversationID.substring(TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX.length()));
                ((C2CChatPresenter) chatPresenter).setChatInfo(c2CChatInfo);
            } else {
                chatPresenter = new GroupChatPresenter();
                GroupChatInfo groupChatInfo = new GroupChatInfo();
                groupChatInfo.setId(conversationID.substring(TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX.length()));
                ((GroupChatPresenter) chatPresenter).setGroupInfo(groupChatInfo);
            }

            chatPresenter.getUserBean(userIDSet, new IUIKitCallback<Map<String, UserBean>>() {
                @Override
                public void onSuccess(Map<String, UserBean> userBeanMap) {
                    for (String userID : userIDSet) {
                        UserBean userBean = userBeanMap.get(userID);
                        tuiMessageBean.setUserBean(userID, userBean);
                    }
                    notifyMessageDisplayStringUpdated(conversationID, tuiMessageBean);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "getUserBean failed, errCode: " + errCode + ", errMsg: " + errMsg);
                }
            });
        }
    }

    private void notifyMessageDisplayStringUpdated(String conversationID, TUIMessageBean messageBean) {
        ThreadUtils.postOnUiThread(() -> {
            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIChat.Event.MessageDisplayString.CONVERSATION_ID, conversationID);
            param.put(TUIConstants.TUIChat.Event.MessageDisplayString.MESSAGE_BEAN, messageBean);
            TUICore.notifyEvent(
                TUIConstants.TUIChat.Event.MessageDisplayString.KEY, TUIConstants.TUIChat.Event.MessageDisplayString.SUB_KEY_PROCESS_MESSAGE, param);
        });
    }
}
