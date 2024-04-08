package com.tencent.qcloud.tuikit.tuiemojiplugin;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import com.google.auto.service.AutoService;
import com.tencent.imsdk.manager.BaseManager;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessageReaction;
import com.tencent.imsdk.v2.V2TIMMessageReactionChangeInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopActivity;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget.ChatClassicPopMenuReactProxy;
import com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget.ChatClassicReactionPreviewProxy;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.OnMessageReactionsChangedListener;
import com.tencent.qcloud.tuikit.tuiemojiplugin.minimalistui.widget.ChatMinimalistPopMenuReactProxy;
import com.tencent.qcloud.tuikit.tuiemojiplugin.minimalistui.widget.ChatMinimalistReactionPreviewProxy;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionBeanCache;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.TUIEmojiPresenter;
import com.tencent.qcloud.tuikit.tuiemojiplugin.util.TUIEmojiLog;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONObject;

@AutoService(TUIInitializer.class)
@TUIInitializerID("TUIEmojiPlugin")
@TUIInitializerDependency("TUIChat")
public class TUIEmojiPluginService implements TUIInitializer, ITUINotification, ITUIExtension {
    public static final String TAG = TUIEmojiPluginService.class.getSimpleName();
    public static final long PLUGIN_REPORT_CODE = 18;

    private static TUIEmojiPluginService instance;

    private final List<WeakReference<OnMessageReactionsChangedListener>> reactionsChangedListener = new ArrayList<>();

    private final TUIEmojiPresenter presenter = new TUIEmojiPresenter();

    private static TUIEmojiPluginService getInstance() {
        return instance;
    }

    @Override
    public void init(Context context) {
        instance = this;
        initEvent();
        initExtension();
        initIMListener();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.EXTENSION_ID, this);
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUIChat.Event.MessageStatus.KEY, TUIConstants.TUIChat.Event.MessageStatus.SUB_KEY_PROCESS_MESSAGE, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIChat.Event.MessageStatus.KEY)) {
            if (TextUtils.equals(subKey, TUIConstants.TUIChat.Event.MessageStatus.SUB_KEY_PROCESS_MESSAGE)) {
                List<TUIMessageBean> messageBeans = (List<TUIMessageBean>) param.get(TUIConstants.TUIChat.Event.MessageStatus.MESSAGE_LIST);
                presenter.getMessageReactions(messageBeans, 10, new TUIValueCallback<List<MessageReactionBean>>() {
                    @Override
                    public void onSuccess(List<MessageReactionBean> object) {
                        TUIEmojiLog.i(TAG, "get message reactions success");
                        for (TUIMessageBean messageBean : messageBeans) {
                            for (MessageReactionBean reactionBean : object) {
                                if (TextUtils.equals(messageBean.getId(), reactionBean.getMessageID())) {
                                    MessageReactionBeanCache.putMessageReactionBean(messageBean, reactionBean);
                                    if (reactionBean.getReactionCount() != 0) {
                                        messageBean.setHasReaction(true);
                                        TUIChatService.getInstance().refreshMessage(messageBean);
                                    }
                                }
                            }
                        }
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        TUIEmojiLog.e(TAG, "get message reactions failed, code = " + errorCode + ", message = " + errorMessage);
                    }
                });
            }
        } else if (TextUtils.equals(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, key)) {
            if (TextUtils.equals(TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, subKey)) {
                reportTUIPollComponentUsage();
            }
        }
    }

    private static void reportTUIPollComponentUsage() {
        try {
            JSONObject reportParam = new JSONObject();
            reportParam.put("UIComponentType", PLUGIN_REPORT_CODE);
            long uiStyleType = BaseManager.TUI_STYLE_TYPE_CLASSIC;
            try {
                Class c = Class.forName("com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService");
                if (c != null) {
                    uiStyleType = BaseManager.TUI_STYLE_TYPE_MINIMALIST;
                }
            } catch (Exception e) {
            }
            reportParam.put("UIStyleType", uiStyleType);
            V2TIMManager.getInstance().callExperimentalAPI("reportTUIComponentUsage", reportParam.toString(), new V2TIMValueCallback<Object>() {
                @Override
                public void onError(int code, String desc) {
                    TUIEmojiLog.e(TAG, "report TUIEmojiPlugin usage err = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                }
                @Override
                public void onSuccess(Object data) {
                    TUIEmojiLog.i(TAG, "report TUIEmojiPlugin usage success");
                }
            });
        } catch (Exception e) {
        }
    }

    private void initIMListener() {
        V2TIMManager.getMessageManager().addAdvancedMsgListener(new V2TIMAdvancedMsgListener() {
            @Override
            public void onRecvMessageReactionsChanged(List<V2TIMMessageReactionChangeInfo> changeInfos) {
                for (V2TIMMessageReactionChangeInfo changeInfo : changeInfos) {
                    String messageID = changeInfo.getMessageID();
                    MessageReactionBean cachedMessageReactionBean = MessageReactionBeanCache.getMessageReactionBean(messageID);
                    if (cachedMessageReactionBean == null) {
                        continue;
                    }
                    List<V2TIMMessageReaction> v2TIMMessageReactions = changeInfo.getReactionList();
                    if (v2TIMMessageReactions == null || v2TIMMessageReactions.isEmpty()) {
                        continue;
                    }

                    Map<String, ReactionBean> messageReactionBeanMap = cachedMessageReactionBean.getMessageReactionBeanMap();
                    for (V2TIMMessageReaction v2TIMMessageReaction : v2TIMMessageReactions) {
                        if (v2TIMMessageReaction.getTotalUserCount() <= 0) {
                            messageReactionBeanMap.remove(v2TIMMessageReaction.getReactionID());
                        } else {
                            ReactionBean reactionBean = convertToReactionBean(v2TIMMessageReaction);
                            messageReactionBeanMap.put(reactionBean.getReactionID(), reactionBean);
                        }
                    }
                    List<OnMessageReactionsChangedListener> listeners = getReactionsChangedListenerList();
                    for (OnMessageReactionsChangedListener listener : listeners) {
                        listener.onMessageReactionsChanged(cachedMessageReactionBean);
                    }
                }
            }
        });
    }

    private static ReactionBean convertToReactionBean(V2TIMMessageReaction v2TIMMessageReaction) {
        ReactionBean reactionBean = new ReactionBean();
        reactionBean.setReactionID(v2TIMMessageReaction.getReactionID());
        reactionBean.setByMySelf(v2TIMMessageReaction.getReactedByMyself());
        reactionBean.setTotalUserCount(v2TIMMessageReaction.getTotalUserCount());
        List<V2TIMUserInfo> v2TIMUserInfoList = v2TIMMessageReaction.getPartialUserList();
        List<UserBean> userBeanList = new ArrayList<>();
        if (v2TIMUserInfoList != null) {
            for (V2TIMUserInfo v2TIMUserInfo : v2TIMUserInfoList) {
                UserBean reactUserBean = new UserBean();
                reactUserBean.setUserId(v2TIMUserInfo.getUserID());
                reactUserBean.setNikeName(v2TIMUserInfo.getNickName());
                reactUserBean.setFaceUrl(v2TIMUserInfo.getFaceUrl());
                userBeanList.add(reactUserBean);
            }
            reactionBean.setPartialUserList(userBeanList);
        }
        return reactionBean;
    }

    private List<OnMessageReactionsChangedListener> getReactionsChangedListenerList() {
        List<OnMessageReactionsChangedListener> listeners = new ArrayList<>();
        Iterator<WeakReference<OnMessageReactionsChangedListener>> iterator = reactionsChangedListener.listIterator();
        while (iterator.hasNext()) {
            WeakReference<OnMessageReactionsChangedListener> listenerWeakReference = iterator.next();
            OnMessageReactionsChangedListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public static void addReactionsChangedListener(OnMessageReactionsChangedListener messageReactionsChangedListener) {
        if (messageReactionsChangedListener == null) {
            return;
        }

        for (WeakReference<OnMessageReactionsChangedListener> listenerWeakReference : getInstance().reactionsChangedListener) {
            if (listenerWeakReference.get() == messageReactionsChangedListener) {
                return;
            }
        }
        getInstance().reactionsChangedListener.add(new WeakReference<>(messageReactionsChangedListener));
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

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        return null;
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.EXTENSION_ID)) {
            int viewType = getOrDefault(param, TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE,
                TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE_CLASSIC);
            Object messageBeanObj = param.get(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.MESSAGE);
            if (viewType == TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE_CLASSIC) {
                if (messageBeanObj instanceof TUIMessageBean && parentView instanceof FrameLayout) {
                    ChatClassicReactionPreviewProxy.fill((TUIMessageBean) messageBeanObj, (FrameLayout) parentView);
                }
            } else {
                if (messageBeanObj instanceof TUIMessageBean && parentView instanceof FrameLayout) {
                    ChatMinimalistReactionPreviewProxy.fill((TUIMessageBean) messageBeanObj, (FrameLayout) parentView);
                }
            }
            return true;
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.EXTENSION_ID)) {
            Object chatPopMenuObj = param.get(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.CHAT_POP_MENU);
            if (chatPopMenuObj instanceof ChatPopMenu) {
                ChatClassicPopMenuReactProxy chatClassicPopMenuReactProxy = new ChatClassicPopMenuReactProxy();
                chatClassicPopMenuReactProxy.setChatPopMenu((ChatPopMenu) chatPopMenuObj);
                chatClassicPopMenuReactProxy.fill();
            }

            Object chatPopActivity = param.get(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.CHAT_POP_MENU);
            if (chatPopActivity instanceof ChatPopActivity) {
                ChatMinimalistPopMenuReactProxy chatMinimalistPopMenuReactProxy = new ChatMinimalistPopMenuReactProxy();
                chatMinimalistPopMenuReactProxy.setChatPopActivity((ChatPopActivity) chatPopActivity);
                chatMinimalistPopMenuReactProxy.fill();
            }

            return true;
        }
        return false;
    }
}
