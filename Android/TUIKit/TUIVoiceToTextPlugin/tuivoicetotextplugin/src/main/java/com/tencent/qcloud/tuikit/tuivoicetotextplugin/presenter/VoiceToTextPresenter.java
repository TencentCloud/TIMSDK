package com.tencent.qcloud.tuikit.tuivoicetotextplugin.presenter;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.model.VoiceToTextProvider;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.util.TUIVoiceToTextLog;
import java.util.HashMap;
import java.util.Map;

public class VoiceToTextPresenter {
    private static final String TAG = "VoiceToTextPresenter";

    public VoiceToTextProvider provider;

    public VoiceToTextPresenter() {
        provider = new VoiceToTextProvider();
    }

    public void convertMessage(TUIMessageBean tuiMessageBean, IUIKitCallback<String> callback) {
        provider.convertMessage(tuiMessageBean, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String result) {
                TUIChatLog.d(TAG, "convertMessage success:" + result);
                // notify Chat that message has been changed
                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, tuiMessageBean);
                param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION_WITHOUT_HIGH_LIGHT);
                TUICore.notifyEvent(TUIConstants.TUIVoiceToTextPlugin.EVENT_KEY_VOICE_TO_TEXT_EVENT,
                    TUIConstants.TUIVoiceToTextPlugin.EVENT_SUB_KEY_VOICE_TO_TEXT_CHANGED, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIVoiceToTextLog.e(TAG, "convertMessage failed code:" + errCode + ", msg:" + errMsg);
                if (callback != null) {
                    callback.onError(TAG, errCode, errMsg);
                }

                Map<String, Object> param = new HashMap<>();
                param.put(TUIChatConstants.MESSAGE_BEAN, tuiMessageBean);
                param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
                TUICore.notifyEvent(TUIConstants.TUIVoiceToTextPlugin.EVENT_KEY_VOICE_TO_TEXT_EVENT,
                    TUIConstants.TUIVoiceToTextPlugin.EVENT_SUB_KEY_VOICE_TO_TEXT_CHANGED, param);
            }
        });

        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.MESSAGE_BEAN, tuiMessageBean);
        param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        TUICore.notifyEvent(
            TUIConstants.TUIVoiceToTextPlugin.EVENT_KEY_VOICE_TO_TEXT_EVENT, TUIConstants.TUIVoiceToTextPlugin.EVENT_SUB_KEY_VOICE_TO_TEXT_CHANGED, param);
    }

    public void saveConvertedResult(V2TIMMessage v2TIMMessage, String text, int status) {
        provider.saveConvertedResult(v2TIMMessage, text, status);
    }

    public String getConvertedText(V2TIMMessage v2TIMMessage) {
        return provider.getConvertedText(v2TIMMessage);
    }

    public int getConvertedTextStatus(V2TIMMessage v2TIMMessage) {
        return provider.getConvertedTextStatus(v2TIMMessage);
    }
}
