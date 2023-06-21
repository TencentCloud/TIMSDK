package com.tencent.qcloud.tuikit.tuichat.util;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TUIChatUtils {
    public static final String SPLIT_TEXT = "split_result";
    public static final String SPLIT_TEXT_FOR_TRANSLATION = "split_translation";
    public static final String SPLIT_TEXT_INDEX_FOR_TRANSLATION = "split_translation_index";

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc, T data) {
        if (callBack != null) {
            callBack.onError(errCode, ErrorMessageConverter.convertIMError(errCode, desc), data);
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

    public static void callbackOnProgress(IUIKitCallback callBack, Object data) {
        if (callBack != null) {
            callBack.onProgress(data);
        }
    }

    public static String getConversationIdByUserId(String id, boolean isGroup) {
        String conversationIdPrefix = isGroup ? CONVERSATION_GROUP_PREFIX : CONVERSATION_C2C_PREFIX;
        return conversationIdPrefix + id;
    }

    public static boolean isC2CChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_C2C;
    }

    public static boolean isGroupChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_GROUP;
    }

    public static String getOriginImagePath(final TUIMessageBean msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }
        String localImgPath = ChatMessageParser.getLocalImagePath(msg);
        if (localImgPath == null) {
            String originUUID = null;
            for (V2TIMImageElem.V2TIMImage image : v2TIMImageElem.getImageList()) {
                if (image.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
                    originUUID = image.getUUID();
                    break;
                }
            }
            String originPath = ImageUtil.generateImagePath(originUUID, V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN);
            File file = new File(originPath);
            if (file.exists()) {
                localImgPath = originPath;
            }
        }
        return localImgPath;
    }

    public static String generateLargeImagePath(final TUIMessageBean msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }

        for (V2TIMImageElem.V2TIMImage image : v2TIMImageElem.getImageList()) {
            if (image.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE) {
                String uuid = image.getUUID();
                return ImageUtil.generateImagePath(uuid, V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE);
            }
        }
        return null;
    }

    public static String generateOriginImagePath(final TUIMessageBean msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }

        for (V2TIMImageElem.V2TIMImage image : v2TIMImageElem.getImageList()) {
            if (image.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
                String uuid = image.getUUID();
                return ImageUtil.generateImagePath(uuid, V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN);
            }
        }
        return null;
    }

    public static String generateThumbImagePath(final TUIMessageBean msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }

        for (V2TIMImageElem.V2TIMImage image : v2TIMImageElem.getImageList()) {
            if (image.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
                String uuid = image.getUUID();
                return ImageUtil.generateImagePath(uuid, V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB);
            }
        }
        return null;
    }

    public static boolean isCommunityGroup(String groupID) {
        if (TextUtils.isEmpty(groupID)) {
            return false;
        }

        return groupID.startsWith("@TGS#_");
    }

    public static boolean isTopicGroup(String groupID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        if (!isCommunityGroup(groupID)) {
            return false;
        }
        return groupID.contains("@TOPIC#_");
    }

    public static String getGroupIDFromTopicID(String topicID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        int index = topicID.indexOf("@TOPIC#_");
        return topicID.substring(0, index);
    }

    public static long getServerTime() {
        return V2TIMManager.getInstance().getServerTime();
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
