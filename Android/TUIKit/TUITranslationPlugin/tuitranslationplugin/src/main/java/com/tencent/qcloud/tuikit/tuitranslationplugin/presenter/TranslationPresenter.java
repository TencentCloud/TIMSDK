package com.tencent.qcloud.tuikit.tuitranslationplugin.presenter;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuitranslationplugin.R;
import com.tencent.qcloud.tuikit.tuitranslationplugin.model.TranslationProvider;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationLog;
import java.util.HashMap;
import java.util.Map;

public class TranslationPresenter {
    private static final String TAG = "TranslationPresenter";

    public TranslationProvider provider;

    public TranslationPresenter() {
        provider = new TranslationProvider();
    }

    public void translateMessage(TUIMessageBean messageBean, IUIKitCallback<String> callback) {
        provider.translateMessage(messageBean, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                TUIChatLog.d(TAG, "translateMessage success:" + data);
                // notify Chat that message has been changed
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, messageBean);
                param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION_WITHOUT_HIGH_LIGHT);
                TUICore.notifyEvent(
                    TUIConstants.TUITranslationPlugin.EVENT_KEY_TRANSLATION_EVENT, TUIConstants.TUITranslationPlugin.EVENT_SUB_KEY_TRANSLATION_CHANGED, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUITranslationLog.e(TAG, "translateMessage failed code:" + errCode + ", msg:" + errMsg);
                if (errCode == 30007) {
                    ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.translation_language_not_support));
                } else {
                    ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.translation_fail));
                }
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, messageBean);
                param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                TUICore.notifyEvent(
                    TUIConstants.TUITranslationPlugin.EVENT_KEY_TRANSLATION_EVENT, TUIConstants.TUITranslationPlugin.EVENT_SUB_KEY_TRANSLATION_CHANGED, param);
            }
        });

        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.MESSAGE_BEAN, messageBean);
        param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        TUICore.notifyEvent(TUIConstants.TUITranslationPlugin.EVENT_KEY_TRANSLATION_EVENT, TUIConstants.TUITranslationPlugin.EVENT_SUB_KEY_TRANSLATION_CHANGED, param);
    }

    public int getTranslationStatus(V2TIMMessage v2TIMMessage) {
        return provider.getTranslationStatus(v2TIMMessage);
    }

    public void setTranslationStatus(V2TIMMessage v2TIMMessage, int status) {
        provider.setTranslationStatus(v2TIMMessage, status);
    }

    public String getTranslationText(V2TIMMessage v2TIMMessage) {
        return provider.getTranslationText(v2TIMMessage);
    }
}
