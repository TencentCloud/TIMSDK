package com.tencent.qcloud.tuikit.tuivoicetotextplugin.model;

import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_ELEM_TYPE_SOUND;

import android.text.TextUtils;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.util.TUIVoiceToTextUtils;

import org.json.JSONException;
import org.json.JSONObject;

public class VoiceToTextProvider {
    private static final String TAG = "VoiceToTextProvider";

    /**
     * 消息转换初始化状态
     *
     * message conversion unknown state
     */
    public static final int MSG_VOICE_TO_TEXT_STATUS_UNKNOWN = 0;
    /**
     * 消息转换隐藏状态
     *
     * message conversion hidden state
     */
    public static final int MSG_VOICE_TO_TEXT_STATUS_HIDDEN = 1;
    /**
     * 消息转换进行中状态
     *
     * message conversion loading state
     */
    public static final int MSG_VOICE_TO_TEXT_STATUS_LOADING = 2;
    /**
     * 消息转换展示状态
     *
     * message conversion shown state
     */
    public static final int MSG_VOICE_TO_TEXT_STATUS_SHOWN = 3;

    private static final String KEY_VOICE_TO_TEXT = "voice_to_text";
    private static final String KEY_VOICE_TO_TEXT_VIEW_STATUS = "voice_to_text_view_status";

    public VoiceToTextProvider() {}

    public void convertMessage(TUIMessageBean messageBean, IUIKitCallback<String> callback) {
        V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
        if (v2TIMMessage == null) {
            TUIVoiceToTextUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "convertMessage v2TIMMessage is null");
            return;
        }

        if (v2TIMMessage.getElemType() != V2TIM_ELEM_TYPE_SOUND) {
            TUIVoiceToTextUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "convertMessage v2TIMMessage is not sound type");
            return;
        }

        V2TIMSoundElem soundElem = v2TIMMessage.getSoundElem();
        if (soundElem == null) {
            TUIVoiceToTextUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "soundElem is null");
            return;
        }

        String convertedText = getConvertedText(v2TIMMessage);
        if (!TextUtils.isEmpty(convertedText)) {
            saveConvertedResult(v2TIMMessage, convertedText, MSG_VOICE_TO_TEXT_STATUS_SHOWN);
            TUIVoiceToTextUtils.callbackOnSuccess(callback, convertedText);
            return;
        }

        saveConvertedResult(v2TIMMessage, "", MSG_VOICE_TO_TEXT_STATUS_LOADING);
        soundElem.convertVoiceToText("", new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String result) {
                if (TextUtils.isEmpty(result)) {
                    saveConvertedResult(v2TIMMessage, result, MSG_VOICE_TO_TEXT_STATUS_UNKNOWN);
                    TUIVoiceToTextUtils.callbackOnError(callback, TAG, -1, "result is empty");
                } else {
                    saveConvertedResult(v2TIMMessage, result, MSG_VOICE_TO_TEXT_STATUS_SHOWN);
                    TUIVoiceToTextUtils.callbackOnSuccess(callback, convertedText);
                }
            }

            @Override
            public void onError(int code, String desc) {
                saveConvertedResult(v2TIMMessage, "", MSG_VOICE_TO_TEXT_STATUS_UNKNOWN);
                TUIVoiceToTextUtils.callbackOnError(callback, TAG, code, desc);
            }
        });
    }

    public void saveConvertedResult(V2TIMMessage v2TIMMessage, String text, int status) {
        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            JSONObject customJson = new JSONObject();
            try {
                if (!TextUtils.isEmpty(localCustomData)) {
                    customJson = new JSONObject(localCustomData);
                }
                customJson.put(KEY_VOICE_TO_TEXT, text);
                customJson.put(KEY_VOICE_TO_TEXT_VIEW_STATUS, status);
                v2TIMMessage.setLocalCustomData(customJson.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public String getConvertedText(V2TIMMessage v2TIMMessage) {
        String result = "";
        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            if (TextUtils.isEmpty(localCustomData)) {
                return result;
            }
            try {
                JSONObject customJson = new JSONObject(localCustomData);
                if (customJson.has(KEY_VOICE_TO_TEXT)) {
                    result = customJson.getString(KEY_VOICE_TO_TEXT);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return result;
    }

    public int getConvertedTextStatus(V2TIMMessage v2TIMMessage) {
        int convertedStatus = MSG_VOICE_TO_TEXT_STATUS_UNKNOWN;

        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            if (TextUtils.isEmpty(localCustomData)) {
                return convertedStatus;
            }
            try {
                JSONObject customJson = new JSONObject(localCustomData);
                if (customJson.has(KEY_VOICE_TO_TEXT_VIEW_STATUS)) {
                    convertedStatus = customJson.getInt(KEY_VOICE_TO_TEXT_VIEW_STATUS);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return convertedStatus;
    }
}
