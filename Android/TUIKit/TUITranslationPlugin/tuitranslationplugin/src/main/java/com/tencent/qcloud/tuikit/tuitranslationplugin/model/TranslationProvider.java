package com.tencent.qcloud.tuikit.tuitranslationplugin.model;

import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_ELEM_TYPE_TEXT;

import android.text.TextUtils;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.message.MessageAtInfo;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuitranslationplugin.R;
import com.tencent.qcloud.tuikit.tuitranslationplugin.TUITranslationConfigs;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationLog;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TranslationProvider {
    private static final String TAG = "TranslationProvider";

    private V2TIMMessage v2TIMMessage;

    public TranslationProvider() {}

    public void translateMessage(TUIMessageBean messageBean, IUIKitCallback<String> callback) {
        V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
        if (v2TIMMessage == null) {
            TUITranslationUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "translateMessage v2TIMMessage is null");
            return;
        }

        if (v2TIMMessage.getElemType() != V2TIM_ELEM_TYPE_TEXT) {
            TUITranslationUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "translateMessage v2TIMMessage is not text type");
            return;
        }

        if (messageBean.getTranslationStatus() == TUIMessageBean.MSG_TRANSLATE_STATUS_HIDDEN) {
            messageBean.setTranslationStatus(TUIMessageBean.MSG_TRANSLATE_STATUS_SHOWN);
            TUITranslationUtils.callbackOnSuccess(callback, messageBean.getTranslation());
            return;
        }

        messageBean.setTranslationStatus(TUIMessageBean.MSG_TRANSLATE_STATUS_LOADING);
        String targetLanguageCode = TUITranslationConfigs.getInstance().getTargetLanguageCode();

        List<String> atUserIDList = v2TIMMessage.getGroupAtUserList();
        List<String> atRealUserIDList = new ArrayList<>();
        List<String> groupAtUserNicknameList = new ArrayList<>();
        List<Integer> atAllIndexList = new ArrayList<>();
        for (int i = 0; i < atUserIDList.size(); i++) {
            String userID = atUserIDList.get(i);
            if (userID.equals(V2TIMGroupAtInfo.AT_ALL_TAG)) {
                atAllIndexList.add(i);
            } else {
                atRealUserIDList.add(userID);
            }
        }

        if (atRealUserIDList.size() == 0) {
            for (Integer atAllIndex : atAllIndexList) {
                groupAtUserNicknameList.add(TUIChatService.getAppContext().getString(R.string.at_all));
            }

            translateMessage(messageBean, groupAtUserNicknameList, targetLanguageCode, callback);
        } else {
            V2TIMManager.getInstance().getUsersInfo(atRealUserIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                @Override
                public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                    for (String userID : v2TIMMessage.getGroupAtUserList()) {
                        for (V2TIMUserFullInfo userFullInfo : v2TIMUserFullInfos) {
                            if (userID.equals(MessageAtInfo.AT_ALL_TAG)) {
                                groupAtUserNicknameList.add(userID);
                                break;
                            }

                            if (userID.equals(userFullInfo.getUserID())) {
                                groupAtUserNicknameList.add(userFullInfo.getNickName());
                                break;
                            }
                        }
                    }

                    for (Integer atAllIndex : atAllIndexList) {
                        groupAtUserNicknameList.set(atAllIndex, TUIChatService.getAppContext().getString(R.string.at_all));
                    }

                    translateMessage(messageBean, groupAtUserNicknameList, targetLanguageCode, callback);
                }

                @Override
                public void onError(int code, String desc) {
                    messageBean.setTranslationStatus(TUIMessageBean.MSG_TRANSLATE_STATUS_UNKNOWN);
                    TUITranslationLog.e(TAG, "translateMessage getUsersInfo error code = " + code + ",des = " + desc);
                    TUITranslationUtils.callbackOnError(callback, TAG, BaseConstants.ERR_INVALID_PARAMETERS, "translateMessage-getUsersInfo failed");
                }
            });
        }
    }

    private void translateMessage(TUIMessageBean messageBean, List<String> groupAtUserNicknameList, String targetLanguage, IUIKitCallback<String> callback) {
        V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
        V2TIMTextElem timTextElem = v2TIMMessage.getTextElem();
        HashMap<String, List<String>> splitMap = TUITranslationUtils.splitTextByEmojiAndAtUsers(timTextElem.getText(), groupAtUserNicknameList);
        List<String> toTranslateTextList = splitMap.get(TUITranslationUtils.SPLIT_TEXT_FOR_TRANSLATION);

        if (toTranslateTextList == null || toTranslateTextList.isEmpty()) {
            List<String> splitTextList = splitMap.get(TUITranslationUtils.SPLIT_TEXT);
            String translateResult = "";
            if (splitTextList != null) {
                for (String result : splitTextList) {
                    translateResult += result;
                }
            }
            messageBean.setTranslation(translateResult);
            TUITranslationUtils.callbackOnSuccess(callback, translateResult);
            return;
        }

        V2TIMManager.getMessageManager().translateText(toTranslateTextList, null, targetLanguage, new V2TIMValueCallback<HashMap<String, String>>() {
            @Override
            public void onSuccess(HashMap<String, String> translateHashMap) {
                List<String> splitTextList = splitMap.get(TUITranslationUtils.SPLIT_TEXT);
                List<String> translationIndexList = splitMap.get(TUITranslationUtils.SPLIT_TEXT_INDEX_FOR_TRANSLATION);
                for (String indexString : translationIndexList) {
                    int index = Integer.valueOf(indexString);
                    String originText = splitTextList.get(index);
                    String translatedResult = translateHashMap.get(originText);
                    if (!TextUtils.isEmpty(translatedResult)) {
                        splitTextList.set(index, translatedResult);
                    }
                }

                String translateResult = "";
                for (String result : splitTextList) {
                    translateResult += result;
                }

                messageBean.setTranslation(translateResult);
                TUITranslationUtils.callbackOnSuccess(callback, translateResult);
            }

            @Override
            public void onError(int code, String desc) {
                messageBean.setTranslationStatus(TUIMessageBean.MSG_TRANSLATE_STATUS_UNKNOWN);
                TUITranslationLog.e(TAG, "translateText error code = " + code + ",des = " + desc);
                TUITranslationUtils.callbackOnError(callback, code, desc);
            }
        });
    }
}
