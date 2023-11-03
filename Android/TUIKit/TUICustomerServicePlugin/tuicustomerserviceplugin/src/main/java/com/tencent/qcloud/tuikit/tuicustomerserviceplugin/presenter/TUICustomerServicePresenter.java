package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUICustomerServiceProductInfo;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.model.TUICustomerServiceProvider;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util.TUICustomerServiceLog;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;

public class TUICustomerServicePresenter {
    private static final String TAG = "TUICustomerServicePresenter";
    private TUIMessageBean messageBean;
    private TUICustomerServiceProvider provider;

    public TUICustomerServicePresenter() {
        provider = new TUICustomerServiceProvider();
    }

    public void setMessage(TUIMessageBean currentMessage) {
        messageBean = currentMessage;
    }

    public void getCustomerServiceUserInfo(V2TIMValueCallback<List<V2TIMUserFullInfo>> callback) {
        provider.getCustomerServiceUserInfo(callback);
    }

    public boolean allowSelection() {
        if (messageBean instanceof BranchMessageBean) {
            BranchMessageBean branchMessageBean = (BranchMessageBean) messageBean;
            if (branchMessageBean.getBranchBean().getSelectedItem() != null) {
                return false;
            } else {
                return true;
            }
        } else if (messageBean instanceof CollectionMessageBean) {
            CollectionMessageBean collectionMessageBean = (CollectionMessageBean) messageBean;
            if (collectionMessageBean.getCollectionBean().getSelectedItem() != null) {
                return false;
            } else {
                return true;
            }
        }

        return false;
    }

    public void OnItemContentSelected(String content) {
        if (messageBean == null) {
            TUICustomerServiceLog.e(TAG, "OnItemContentSelected, messageBean is null");
            return;
        }

        String chatID = messageBean.getUserId();
        TUIMessageBean messageBean = ChatMessageBuilder.buildTextMessage(content);
        TUIChatService.getInstance().sendMessage(messageBean, chatID, V2TIMConversation.V2TIM_C2C, false);
    }

    public void sendTextMessage(String userID, String content) {
        TUIMessageBean messageBean = ChatMessageBuilder.buildTextMessage(content);
        TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, false);
    }

    public void getEvaluationSetting(String userID) {
        JSONObject getEvaluationSettingJson = new JSONObject();
        try {
            getEvaluationSettingJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY, 0);
            getEvaluationSettingJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_BUSINESS_ID_SRC_KEY,
                TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_GET_EVALUATION_SETTING);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        if (!TextUtils.isEmpty(getEvaluationSettingJson.toString())) {
            TUIMessageBean messageBean = ChatMessageBuilder.buildCustomMessage(getEvaluationSettingJson.toString(), "", null);
            TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, true);
        }
    }

    public void sendEvaluationMessage(EvaluationBean.Menu submitMenu, String sessionID) {
        if (messageBean == null) {
            TUICustomerServiceLog.e(TAG, "sendEvaluationMessage, messageBean is null");
            return;
        }

        JSONObject submitMenuJson = new JSONObject();
        try {
            submitMenuJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY, 0);
            submitMenuJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_BUSINESS_ID_SRC_KEY,
                TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION_SELECTED);
            JSONObject menuSelectedJson = new JSONObject();
            menuSelectedJson.put(TUICustomerServiceConstants.DESK_KIT_ITEM_ID, submitMenu.getId());
            menuSelectedJson.put(TUICustomerServiceConstants.DESK_KIT_ITEM_CONTENT, submitMenu.getContent());
            menuSelectedJson.put(TUICustomerServiceConstants.DESK_KIT_SESSION_ID, sessionID);
            submitMenuJson.put(TUICustomerServiceConstants.DESK_KIT_ITEM_MENU_SELECTED, menuSelectedJson);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        if (!TextUtils.isEmpty(submitMenuJson.toString())) {
            String chatID = messageBean.getUserId();
            TUIMessageBean messageBean = ChatMessageBuilder.buildCustomMessage(submitMenuJson.toString(), "", null);
            TUIChatService.getInstance().sendMessage(messageBean, chatID, V2TIMConversation.V2TIM_C2C, true);
        }
    }

    public void triggerEvaluation(String userID) {
        JSONObject triggerEvaluationJson = new JSONObject();
        try {
            triggerEvaluationJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY, 0);
            triggerEvaluationJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_BUSINESS_ID_SRC_KEY,
                TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TRIGGER_EVALUATION);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        if (!TextUtils.isEmpty(triggerEvaluationJson.toString())) {
            TUIMessageBean messageBean = ChatMessageBuilder.buildCustomMessage(triggerEvaluationJson.toString(), "", null);
            TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, true);
        }
    }

    public void sendProductMessage(String userID, TUICustomerServiceProductInfo productInfo) {
        if (productInfo == null) {
            return;
        }

        JSONObject productMessageJson = new JSONObject();
        try {
            productMessageJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_MESSAGE_KEY, 0);
            productMessageJson.put(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_BUSINESS_ID_SRC_KEY,
                TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_CARD);
            JSONObject productJson = new JSONObject();
            productJson.put(TUICustomerServiceConstants.DESK_KIT_HEADER, productInfo.getName());
            productJson.put(TUICustomerServiceConstants.DESK_KIT_ITEM_DESCRIPTION, productInfo.getDescription());
            productJson.put(TUICustomerServiceConstants.DESK_KIT_CARD_PIC, productInfo.getPictureUrl());
            productJson.put(TUICustomerServiceConstants.DESK_KIT_CARD_URL, productInfo.getJumpUrl());
            productMessageJson.put(TUICustomerServiceConstants.DESK_KIT_CONTENT, productJson);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        if (!TextUtils.isEmpty(productMessageJson.toString())) {
            TUIMessageBean messageBean = ChatMessageBuilder.buildCustomMessage(productMessageJson.toString(), "", null);
            TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, true);
        }
    }
}
