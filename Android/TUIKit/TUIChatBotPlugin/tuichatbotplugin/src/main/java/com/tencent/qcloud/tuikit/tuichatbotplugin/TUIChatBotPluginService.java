package com.tencent.qcloud.tuikit.tuichatbotplugin;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.text.TextUtils;
import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.InvisibleMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.RichTextMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.RichTextMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.StreamTextMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.StreamTextMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.page.ChatBotListActivity;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.page.ChatBotProfileActivity;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.BranchHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.BranchReplyView;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.InvisibleHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.RichTextHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.RichTextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.StreamTextHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.StreamTextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichatbotplugin.presenter.TUIChatBotPresenter;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.TUIChatBotUtils;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency({"TUIChatClassic", "TUIContact"})
@TUIInitializerID("TUIChatBotPlugin")
public class TUIChatBotPluginService implements TUIInitializer, ITUINotification, ITUIExtension {
    public static final String TAG = TUIChatBotPluginService.class.getSimpleName();
    private static TUIChatBotPluginService instance;

    public static TUIChatBotPluginService getInstance() {
        return instance;
    }

    private Context appContext;

    @Override
    public void init(Context context) {
        appContext = context;
        instance = this;
        initTheme();
        initExtension();
        initMessage();
    }

    private void initTheme() {
        TUIThemeManager.addLightTheme(R.style.TUIChatBotLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.TUIChatBotLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.TUIChatBotSeriousTheme);
    }

    private void initMessage() {
        Map<String, Object> invisibleHelloRequestParam = new HashMap<>();
        invisibleHelloRequestParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_KEY + TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_HELLO_REQUEST);
        invisibleHelloRequestParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleHelloRequestParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleHelloRequestParam);

        Map<String, Object> branchParam = new HashMap<>();
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_KEY + TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_RESPONSE);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, BranchMessageBean.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, BranchHolder.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, BranchMessageReplyQuoteBean.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, BranchReplyView.class);
        TUICore.callService(
            TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, branchParam);

        Map<String, Object> streamTextParam = new HashMap<>();
        streamTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_KEY + TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_STREAM_TEXT);
        streamTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, StreamTextMessageBean.class);
        streamTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, StreamTextHolder.class);
        streamTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, StreamTextMessageReplyQuoteBean.class);
        streamTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, StreamTextReplyQuoteView.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, streamTextParam);

        Map<String, Object> richTextParam = new HashMap<>();
        richTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
                TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_KEY + TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_RICH_TEXT);
        richTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, RichTextMessageBean.class);
        richTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, RichTextHolder.class);
        richTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, RichTextMessageReplyQuoteBean.class);
        richTextParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, RichTextReplyQuoteView.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, richTextParam);
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.ContactItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatUserIconClickedProcessor.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MultiSelectMessageBar.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatView.GET_CONFIG_PARAMS, this);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIContact.Extension.ContactItem.CLASSIC_EXTENSION_ID)) {
            TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
            extensionInfo.setWeight(190);
            extensionInfo.setText(appContext.getString(R.string.chat_bot));
            extensionInfo.setIcon(TUIThemeManager.getAttrResId(appContext, R.attr.chat_bot_icon));
            extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                @Override
                public void onClicked(Map<String, Object> param) {
                    TUIChatBotUtils.checkChatBotAbility(TUIChatBotConstants.CHAT_BOT_PLUGIN_ABILITY, new IUIKitCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean isSupportPlugin) {
                            if (isSupportPlugin) {
                                Intent intent = new Intent(TUIChatBotPluginService.getAppContext(), ChatBotListActivity.class);
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                TUIChatBotPluginService.getAppContext().startActivity(intent);
                            } else {
                                Context context = getOrDefault(param, TUIConstants.TUIContact.CONTEXT, null);
                                if (context != null) {
                                    TUIChatBotUtils.showNotSupportDialog(context);
                                }
                            }
                        }
                    });
                }
            });
            return Collections.singletonList(extensionInfo);
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID)) {
            Object userID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID);
            if (userID instanceof String && TextUtils.equals((String) userID, TUIChatBotConstants.CHAT_BOT_ID)) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setIcon(
                    TUIThemeManager.getAttrResId(getAppContext(), com.tencent.qcloud.tuikit.tuicontact.R.attr.contact_chat_extension_title_bar_more_menu));
                extensionInfo.setWeight(200);
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), ChatBotProfileActivity.class);
                        intent.putExtra(TUIConstants.TUIChat.CHAT_ID, (String) userID);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        getAppContext().startActivity(intent);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatUserIconClickedProcessor.CLASSIC_EXTENSION_ID)) {
            Object userIDObj = param.get(TUIConstants.TUIChat.Extension.ChatUserIconClickedProcessor.USER_ID);
            if (userIDObj instanceof String) {
                String userID = (String) userIDObj;
                if (TextUtils.equals(userID, TUIChatBotConstants.CHAT_BOT_ID)) {
                    TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                    extensionInfo.setIcon(
                        TUIThemeManager.getAttrResId(getAppContext(), com.tencent.qcloud.tuikit.tuicontact.R.attr.contact_chat_extension_title_bar_more_menu));
                    extensionInfo.setWeight(100);
                    extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                        @Override
                        public void onClicked(Map<String, Object> param) {
                            Intent intent = new Intent(getAppContext(), ChatBotProfileActivity.class);
                            intent.putExtra(TUIConstants.TUIChat.CHAT_ID, userID);
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            getAppContext().startActivity(intent);
                        }
                    });
                    return Collections.singletonList(extensionInfo);
                }
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MultiSelectMessageBar.CLASSIC_EXTENSION_ID)) {
            Object userID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID);
            if (userID instanceof String && TextUtils.equals((String) userID, TUIChatBotConstants.CHAT_BOT_ID)) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                Map<String, Object> extensionMap = new HashMap<>();
                extensionMap.put(TUIConstants.TUIChat.Extension.MultiSelectMessageBar.ENABLE_FORWARD_MESSAGE, false);
                extensionInfo.setData(extensionMap);
                return Collections.singletonList(extensionInfo);
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatView.GET_CONFIG_PARAMS)) {
            Object userIDObj = param.get(TUIConstants.TUIChat.CHAT_ID);
            if (userIDObj instanceof String && TextUtils.equals((String) userIDObj, TUIChatBotConstants.CHAT_BOT_ID)) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                Map<String, Object> extensionMap = new HashMap<>();
                extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_VIDEO_CALL, false);
                extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_AUDIO_CALL, false);
                extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.MESSAGE_NEED_READ_RECEIPT, false);
                extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_CUSTOM_HELLO_MESSAGE, false);
                extensionInfo.setData(extensionMap);

                Handler handler = new Handler();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        TUIChatBotPresenter presenter = new TUIChatBotPresenter();
                        presenter.sayHelloToChatBot((String) userIDObj);
                    }
                }, 200);

                return Collections.singletonList(extensionInfo);
            }
        }

        return null;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {}

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

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
