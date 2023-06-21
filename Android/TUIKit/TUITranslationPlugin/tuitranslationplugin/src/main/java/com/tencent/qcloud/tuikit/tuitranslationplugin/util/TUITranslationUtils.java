package com.tencent.qcloud.tuikit.tuitranslationplugin.util;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TUITranslationUtils {
    public static final String SPLIT_TEXT = "split_result";
    public static final String SPLIT_TEXT_FOR_TRANSLATION = "split_translation";
    public static final String SPLIT_TEXT_INDEX_FOR_TRANSLATION = "split_translation_index";

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(null, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callBack, T data) {
        if (callBack != null) {
            callBack.onSuccess(data);
        }
    }

    /**
     * Slice string using both emoji and @user. For instance,
     * Origin string is "hello[Grin]world, @user1 see you!", and users is ["user1"];
     * Return value is:
     * {
     *    "split_result": ["hello", "[Grin]", "world, ", "@user1", " see you!"],
     *    "split_translation": ["hello", "world, ", "see you!"],
     *    "split_translation_index": [0, 2, 4]
     * }
     * split_result contains all elements after splited.
     * split_translation contains all text elements in split_result, excluding emoji an @user infos.
     * split_translation_index contains the position of texts in textArray located in split_result.
     *
     */
    public static HashMap<String, List<String>> splitTextByEmojiAndAtUsers(String text, List<String> userList) {
        if (TextUtils.isEmpty(text)) {
            return null;
        }

        List<String> result = new ArrayList<>();
        List<String> atUsers = new ArrayList<>();
        if (userList != null && userList.size() > 0) {
            for (String user : userList) {
                String atUser = "@" + user;
                atUsers.add(atUser);
            }
        }

        List<String> splitResultByAtUsers = splitByKeyList(atUsers, text);
        int textIndex = 0;
        List<String> needTranslationTextIndexList = new ArrayList<>();
        for (int i = 0; i < splitResultByAtUsers.size(); i++) {
            String splitString = splitResultByAtUsers.get(i);
            String atUser = "";
            if (atUsers.size() > 0) {
                atUser = atUsers.get(0);
            }

            if (!TextUtils.isEmpty(atUser) && splitString.equals(atUser)) {
                result.add(splitString);
                atUsers.remove(0);
                textIndex++;
            } else {
                List<String> emojiKeyList = FaceManager.findEmojiKeyListFromText(splitString);
                if (emojiKeyList != null && emojiKeyList.size() > 0) {
                    List<String> splitByEmojiResultList = splitByKeyList(emojiKeyList, splitString);
                    for (int j = 0; j < splitByEmojiResultList.size(); j++) {
                        String splitStringByEmoji = splitByEmojiResultList.get(j);
                        result.add(splitStringByEmoji);
                        String emojiKey = "";
                        if (emojiKeyList.size() > 0) {
                            emojiKey = emojiKeyList.get(0);
                        }

                        if (!TextUtils.isEmpty(emojiKey) && splitStringByEmoji.equals(emojiKey)) {
                            emojiKeyList.remove(0);
                        } else {
                            needTranslationTextIndexList.add(String.valueOf(textIndex));
                        }
                        textIndex++;
                    }
                } else {
                    if (!TextUtils.isEmpty(splitString.trim())) {
                        needTranslationTextIndexList.add(String.valueOf(textIndex));
                    }
                    result.add(splitString);
                    textIndex++;
                }
            }
        }

        List<String> needTranslationTextList = new ArrayList<>();
        for (int i = 0; i < needTranslationTextIndexList.size(); i++) {
            int needTranslationIndex = Integer.valueOf(needTranslationTextIndexList.get(i));
            needTranslationTextList.add(result.get(needTranslationIndex));
        }
        HashMap<String, List<String>> resultMap = new HashMap<>();
        resultMap.put(SPLIT_TEXT, result);
        resultMap.put(SPLIT_TEXT_FOR_TRANSLATION, needTranslationTextList);
        resultMap.put(SPLIT_TEXT_INDEX_FOR_TRANSLATION, needTranslationTextIndexList);

        return resultMap;
    }

    public static List<String> splitByKeyList(List<String> keyList, String text) {
        List<String> splitResultByKeyList = new ArrayList<>();
        if (TextUtils.isEmpty(text)) {
            return splitResultByKeyList;
        }

        if (keyList == null || keyList.isEmpty()) {
            splitResultByKeyList.add(text);
            return splitResultByKeyList;
        }

        int fromIndex = 0;
        for (String key : keyList) {
            int keyIndex = text.indexOf(key, fromIndex);
            if (keyIndex >= 0) {
                if (fromIndex < keyIndex) {
                    String resultBeforeKeyCharacter = text.substring(fromIndex, keyIndex);
                    splitResultByKeyList.add(resultBeforeKeyCharacter);
                }
                splitResultByKeyList.add(key);
                fromIndex = keyIndex + key.length();
            }
        }

        if (fromIndex < text.length()) {
            splitResultByKeyList.add(text.substring(fromIndex));
        }

        return splitResultByKeyList;
    }
}
