package com.tencent.qcloud.tuikit.tuicustomerserviceplugin;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
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
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CardMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CardMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CustomerServiceTypingMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.InvisibleMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.page.CustomerServiceMemberListActivity;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.page.CustomerServiceProfileActivity;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.BranchHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.BranchReplyView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.CardHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.CardReplyView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.CollectionHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.CollectionReplyView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.EvaluationHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.EvaluationReplyView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.InputViewFloatLayerProxy;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.InvisibleHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUICustomerServiceConfig;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util.TUICustomerServiceUtils;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency({"TUIChatClassic", "TUIContact"})
@TUIInitializerID("TUICustomerServicePlugin")
public class TUICustomerServicePluginService implements TUIInitializer, ITUINotification, ITUIExtension {
    public static final String TAG = TUICustomerServicePluginService.class.getSimpleName();
    private static TUICustomerServicePluginService instance;

    public static TUICustomerServicePluginService getInstance() {
        return instance;
    }

    private Context appContext;
    private boolean canTriggerEvaluation = false;

    @Override
    public void init(Context context) {
        appContext = context;
        instance = this;
        initTheme();
        initExtension();
        initMessage();
    }

    private void initMessage() {
        Map<String, Object> branchParam = new HashMap<>();
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_BRANCH);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, BranchMessageBean.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, BranchHolder.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, BranchMessageReplyQuoteBean.class);
        branchParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, BranchReplyView.class);
        TUICore.callService(
            TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, branchParam);

        Map<String, Object> collectionParam = new HashMap<>();
        collectionParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_COLLECTION);
        collectionParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, CollectionMessageBean.class);
        collectionParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, CollectionHolder.class);
        collectionParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, CollectionMessageReplyQuoteBean.class);
        collectionParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, CollectionReplyView.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, collectionParam);

        Map<String, Object> cardParam = new HashMap<>();
        cardParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_CARD);
        cardParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, CardMessageBean.class);
        cardParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, CardHolder.class);
        cardParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, CardMessageReplyQuoteBean.class);
        cardParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, CardReplyView.class);
        TUICore.callService(
            TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, cardParam);

        Map<String, Object> evaluationParam = new HashMap<>();
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION);
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, EvaluationMessageBean.class);
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, EvaluationHolder.class);
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_BEAN_CLASS, EvaluationMessageReplyQuoteBean.class);
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_REPLY_VIEW_CLASS, EvaluationReplyView.class);
        evaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.IS_NEED_EMPTY_VIEW_GROUP, true);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, evaluationParam);

        Map<String, Object> invisibleEndParam = new HashMap<>();
        invisibleEndParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_END);
        invisibleEndParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleEndParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleEndParam);

        Map<String, Object> invisibleTimeoutParam = new HashMap<>();
        invisibleTimeoutParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TIMEOUT);
        invisibleTimeoutParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleTimeoutParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleTimeoutParam);

        Map<String, Object> invisibleEvaluationSettingParam = new HashMap<>();
        invisibleEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION_SETTING);
        invisibleEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleEvaluationSettingParam);

        Map<String, Object> invisibleEvaluationSelectedParam = new HashMap<>();
        invisibleEvaluationSelectedParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION_SELECTED);
        invisibleEvaluationSelectedParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleEvaluationSelectedParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleEvaluationSelectedParam);

        Map<String, Object> invisibleTriggerEvaluationParam = new HashMap<>();
        invisibleTriggerEvaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TRIGGER_EVALUATION);
        invisibleTriggerEvaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleTriggerEvaluationParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleTriggerEvaluationParam);

        Map<String, Object> invisibleGetEvaluationSettingParam = new HashMap<>();
        invisibleGetEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY
                + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_GET_EVALUATION_SETTING);
        invisibleGetEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, InvisibleMessageBean.class);
        invisibleGetEvaluationSettingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS, InvisibleHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, invisibleGetEvaluationSettingParam);

        Map<String, Object> typingParam = new HashMap<>();
        typingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
            TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY + TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TYPING);
        typingParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, CustomerServiceTypingMessageBean.class);
        TUICore.callService(
            TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME, TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, typingParam);
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputViewFloatLayer.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.ContactItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatUserIconClickedProcessor.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatView.GET_CONFIG_PARAMS, this);
    }

    private void initTheme() {
        TUIThemeManager.addLightTheme(R.style.TUICustomerServiceLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.TUICustomerServiceLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.TUICustomerServiceSeriousTheme);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID)) {
            if (!canTriggerEvaluation) {
                return null;
            }

            if (param != null && !param.isEmpty()) {
                String userID = getOrDefault(param, TUIConstants.TUIChat.Extension.InputMore.USER_ID, null);
                if (!TextUtils.isEmpty(userID)) {
                    TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                    extensionInfo.setWeight(200);
                    extensionInfo.setText(appContext.getString(R.string.extension_satisfaction_evaluation));
                    extensionInfo.setIcon(R.drawable.tui_evaluation_ic);
                    extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                        @Override
                        public void onClicked(Map<String, Object> param) {
                            TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
                            presenter.triggerEvaluation(userID);
                        }
                    });
                    return Collections.singletonList(extensionInfo);
                }
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIContact.Extension.ContactItem.CLASSIC_EXTENSION_ID)) {
            TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
            extensionInfo.setWeight(200);
            extensionInfo.setText(appContext.getString(R.string.customer_service));
            extensionInfo.setIcon(TUIThemeManager.getAttrResId(appContext, R.attr.customer_service_icon));
            extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                @Override
                public void onClicked(Map<String, Object> param) {
                    TUICustomerServiceUtils.checkCustomerServiceAbility(
                        TUICustomerServiceConstants.CUSTOMER_SERVICE_PLUGIN_ABILITY, new IUIKitCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean isSupportPlugin) {
                                if (isSupportPlugin) {
                                    Intent intent = new Intent(TUICustomerServicePluginService.getAppContext(), CustomerServiceMemberListActivity.class);
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    TUICustomerServicePluginService.getAppContext().startActivity(intent);
                                } else {
                                    Context context = getOrDefault(param, TUIConstants.TUIContact.CONTEXT, null);
                                    if (context != null) {
                                        TUICustomerServiceUtils.showNotSupportDialog(context);
                                    }
                                }
                            }
                        });
                }
            });
            return Collections.singletonList(extensionInfo);
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID)) {
            Object userID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID);
            if (userID instanceof String && TUICustomerServiceConfig.getInstance().getCustomerServiceAccounts().contains(userID)) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setIcon(
                    TUIThemeManager.getAttrResId(getAppContext(), com.tencent.qcloud.tuikit.tuicontact.R.attr.contact_chat_extension_title_bar_more_menu));
                extensionInfo.setWeight(200);
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), CustomerServiceProfileActivity.class);
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
                if (TUICustomerServiceConfig.getInstance().getCustomerServiceAccounts().contains(userID)) {
                    TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                    extensionInfo.setIcon(
                        TUIThemeManager.getAttrResId(getAppContext(), com.tencent.qcloud.tuikit.tuicontact.R.attr.contact_chat_extension_title_bar_more_menu));
                    extensionInfo.setWeight(100);
                    extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                        @Override
                        public void onClicked(Map<String, Object> param) {
                            Intent intent = new Intent(getAppContext(), CustomerServiceProfileActivity.class);
                            intent.putExtra(TUIConstants.TUIChat.CHAT_ID, userID);
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            getAppContext().startActivity(intent);
                        }
                    });
                    return Collections.singletonList(extensionInfo);
                }
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatView.GET_CONFIG_PARAMS)) {
            Object userIDObj = param.get(TUIConstants.TUIChat.CHAT_ID);
            if (userIDObj instanceof String) {
                String userID = (String) userIDObj;
                if (TUICustomerServiceConfig.getInstance().getCustomerServiceAccounts().contains(userID)) {
                    TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                    Map<String, Object> extensionMap = new HashMap<>();
                    extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.MESSAGE_NEED_READ_RECEIPT, true);
                    extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_VIDEO_CALL, false);
                    extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_AUDIO_CALL, false);
                    extensionMap.put(TUIConstants.TUIChat.Extension.ChatView.ENABLE_CUSTOM_HELLO_MESSAGE, false);
                    extensionInfo.setData(extensionMap);

                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
                            presenter.getEvaluationSetting(userID);
                        }
                    }, 200);

                    return Collections.singletonList(extensionInfo);
                }
            }
        }

        return null;
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.InputViewFloatLayer.CLASSIC_EXTENSION_ID)) {
            if (parentView == null || param == null) {
                return false;
            }

            ViewGroup viewGroup = null;
            if (parentView instanceof ViewGroup) {
                viewGroup = (ViewGroup) parentView;
            }
            if (viewGroup == null) {
                return false;
            }

            Object objChatInfo = param.get(TUIChatConstants.CHAT_INFO);
            if (!(objChatInfo instanceof ChatInfo)) {
                return false;
            }

            ChatInfo chatInfo = (ChatInfo) objChatInfo;
            if (chatInfo.getType() != ChatInfo.TYPE_C2C) {
                return false;
            }

            if (!TUICustomerServiceConfig.getInstance().getCustomerServiceAccounts().contains(chatInfo.getId())) {
                return false;
            }

            if (TUICustomerServiceConfig.getInstance().isOnlineShopping(chatInfo.getId())) {
                InputViewFloatLayerProxy inputViewFloatLayerProxy = new InputViewFloatLayerProxy(chatInfo);
                inputViewFloatLayerProxy.showFloatLayerContent(viewGroup);
                return true;
            }
        }

        return false;
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

    public void setCanTriggerEvaluation(boolean canTriggerEvaluation) {
        this.canTriggerEvaluation = canTriggerEvaluation;
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
