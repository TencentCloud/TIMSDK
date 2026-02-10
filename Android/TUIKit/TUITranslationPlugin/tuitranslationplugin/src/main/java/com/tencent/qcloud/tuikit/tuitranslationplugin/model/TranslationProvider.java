package com.tencent.qcloud.tuikit.tuitranslationplugin.model;

import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_ELEM_TYPE_TEXT;

import android.text.TextUtils;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuitranslationplugin.TUITranslationConfigs;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationLog;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TranslationProvider {
    private static final String TAG = "TranslationProvider";

    /**
     * message translation unknown
     */
    public static final int MSG_TRANSLATE_STATUS_UNKNOWN = 0;
    /**
     * message translation hidden
     */
    public static final int MSG_TRANSLATE_STATUS_HIDDEN = 1;
    /**
     * message translation loading
     */
    public static final int MSG_TRANSLATE_STATUS_LOADING = 2;
    /**
     * message translation shown
     */
    public static final int MSG_TRANSLATE_STATUS_SHOWN = 3;

    private static final String TRANSLATION_KEY = "translation";
    private static final String TRANSLATION_VIEW_STATUS_KEY = "translation_view_status";

    // @mention pattern: @xxx followed by space
    private static final Pattern AT_MENTION_PATTERN = Pattern.compile("@[^ ]+ ");

    /**
     * Part type for text splitting
     */
    private enum PartType {
        MENTION,  // @xxx format
        EMOJI,    // TUIKit [xxx] and Unicode emoji
        TEXT      // Normal translatable text
    }

    /**
     * Text part after splitting
     */
    private static class TextPart {
        PartType type;
        String content;

        TextPart(PartType type, String content) {
            this.type = type;
            this.content = content;
        }
    }

    /**
     * Split result containing parts and text array for translation
     */
    private static class SplitResult {
        List<TextPart> parts;
        List<String> textArray;

        SplitResult(List<TextPart> parts, List<String> textArray) {
            this.parts = parts;
            this.textArray = textArray;
        }
    }

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

        if (getTranslationStatus(v2TIMMessage) == MSG_TRANSLATE_STATUS_HIDDEN) {
            setTranslationStatus(v2TIMMessage, MSG_TRANSLATE_STATUS_SHOWN);
            TUITranslationUtils.callbackOnSuccess(callback, getTranslationText(v2TIMMessage));
            return;
        }

        // Directly translate without fetching user info
        translateMessageInternal(messageBean, callback);
    }

    private void translateMessageInternal(TUIMessageBean messageBean, IUIKitCallback<String> callback) {
        V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
        V2TIMTextElem timTextElem = v2TIMMessage.getTextElem();
        String targetLanguage = TUITranslationConfigs.getInstance().getTargetLanguageCode();
        String originalText = timTextElem.getText();

        if (TextUtils.isEmpty(originalText)) {
            saveTranslationResult(v2TIMMessage, "", MSG_TRANSLATE_STATUS_SHOWN);
            TUITranslationUtils.callbackOnSuccess(callback, "");
            return;
        }

        // Split text into @mentions, emojis, and translatable text (without fetching user info)
        SplitResult splitResult = splitTextByAtMentionAndEmoji(originalText);
        List<String> textArray = splitResult.textArray;

        if (textArray.isEmpty()) {
            // Nothing needs to be translated (only @mentions and emoji)
            saveTranslationResult(v2TIMMessage, originalText, MSG_TRANSLATE_STATUS_SHOWN);
            TUITranslationUtils.callbackOnSuccess(callback, originalText);
            return;
        }

        // Check if already translated
        String translatedText = getTranslationText(v2TIMMessage);
        if (!TextUtils.isEmpty(translatedText)) {
            saveTranslationResult(v2TIMMessage, translatedText, MSG_TRANSLATE_STATUS_SHOWN);
            TUITranslationUtils.callbackOnSuccess(callback, translatedText);
        } else {
            saveTranslationResult(v2TIMMessage, "", MSG_TRANSLATE_STATUS_LOADING);
            TUITranslationUtils.callbackOnSuccess(callback, "");
        }

        // Send translate request
        V2TIMManager.getMessageManager().translateText(textArray, null, targetLanguage, new V2TIMValueCallback<HashMap<String, String>>() {
            @Override
            public void onSuccess(HashMap<String, String> translateHashMap) {
                if (translateHashMap == null || translateHashMap.isEmpty()) {
                    setTranslationStatus(v2TIMMessage, MSG_TRANSLATE_STATUS_UNKNOWN);
                    TUITranslationLog.e(TAG, "translateText result is empty");
                    TUITranslationUtils.callbackOnError(callback, BaseConstants.ERR_INVALID_PARAMETERS, "translateText result is empty");
                    return;
                }

                // Rebuild text with translations, keeping @mentions and emoji
                String result = rebuildTextWithTranslations(splitResult.parts, textArray, translateHashMap);
                saveTranslationResult(v2TIMMessage, result, MSG_TRANSLATE_STATUS_SHOWN);
                TUITranslationUtils.callbackOnSuccess(callback, result);
            }

            @Override
            public void onError(int code, String desc) {
                setTranslationStatus(v2TIMMessage, MSG_TRANSLATE_STATUS_UNKNOWN);
                TUITranslationLog.e(TAG, "translateText error code = " + code + ",des = " + desc);
                TUITranslationUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    // MARK: - Helper Methods for Text Splitting

    /**
     * Split text by @mention and emoji
     * @mention format: @xxx followed by space
     * Keep @mentions and emojis as is, only translate normal text
     */
    private static SplitResult splitTextByAtMentionAndEmoji(String text) {
        List<TextPart> parts = new ArrayList<>();
        List<String> textArray = new ArrayList<>();

        if (TextUtils.isEmpty(text)) {
            return new SplitResult(parts, textArray);
        }

        // Step 1: Find all @mention ranges (@xxx followed by space)
        List<int[]> mentionRanges = new ArrayList<>();
        Matcher matcher = AT_MENTION_PATTERN.matcher(text);
        while (matcher.find()) {
            mentionRanges.add(new int[]{matcher.start(), matcher.end()});
        }

        // Step 2: Process text by @mention ranges
        int currentIndex = 0;
        for (int[] range : mentionRanges) {
            int start = range[0];
            int end = range[1];

            // Process text before @mention
            if (currentIndex < start) {
                String beforeText = text.substring(currentIndex, start);
                processTextWithEmoji(beforeText, parts, textArray);
            }

            // Add @mention as is
            String mentionText = text.substring(start, end);
            parts.add(new TextPart(PartType.MENTION, mentionText));

            currentIndex = end;
        }

        // Process remaining text after last @mention
        if (currentIndex < text.length()) {
            String remainingText = text.substring(currentIndex);
            processTextWithEmoji(remainingText, parts, textArray);
        }

        return new SplitResult(parts, textArray);
    }

    /**
     * Process text with emoji detection
     * Split text into emoji and normal text parts
     */
    private static void processTextWithEmoji(String text, List<TextPart> parts, List<String> textArray) {
        if (TextUtils.isEmpty(text)) {
            return;
        }

        // Find emoji keys from text using FaceManager
        List<String> emojiKeys = FaceManager.findEmojiKeyListFromText(text);

        if (emojiKeys == null || emojiKeys.isEmpty()) {
            // No emoji, entire text is translatable
            if (!TextUtils.isEmpty(text.trim())) {
                parts.add(new TextPart(PartType.TEXT, text));
                textArray.add(text);
            } else if (!TextUtils.isEmpty(text)) {
                // Whitespace only, keep as text but don't translate
                parts.add(new TextPart(PartType.TEXT, text));
            }
            return;
        }

        // Split text by emoji
        int currentPos = 0;
        for (String emojiKey : emojiKeys) {
            int emojiIndex = text.indexOf(emojiKey, currentPos);
            if (emojiIndex < 0) {
                continue;
            }

            // Add text before emoji
            if (currentPos < emojiIndex) {
                String textContent = text.substring(currentPos, emojiIndex);
                if (!TextUtils.isEmpty(textContent)) {
                    parts.add(new TextPart(PartType.TEXT, textContent));
                    if (!TextUtils.isEmpty(textContent.trim())) {
                        textArray.add(textContent);
                    }
                }
            }

            // Add emoji
            parts.add(new TextPart(PartType.EMOJI, emojiKey));
            currentPos = emojiIndex + emojiKey.length();
        }

        // Add remaining text
        if (currentPos < text.length()) {
            String textContent = text.substring(currentPos);
            if (!TextUtils.isEmpty(textContent)) {
                parts.add(new TextPart(PartType.TEXT, textContent));
                if (!TextUtils.isEmpty(textContent.trim())) {
                    textArray.add(textContent);
                }
            }
        }
    }

    /**
     * Rebuild text with translations
     * Keep @mentions and emojis as is, replace text parts with translations
     */
    private static String rebuildTextWithTranslations(List<TextPart> parts, List<String> textArray, HashMap<String, String> translations) {
        StringBuilder result = new StringBuilder();
        int textIndex = 0;

        for (TextPart part : parts) {
            switch (part.type) {
                case MENTION:
                case EMOJI:
                    // Keep @mention and emoji as is
                    result.append(part.content);
                    break;
                case TEXT:
                    // Replace with translation if available
                    if (!TextUtils.isEmpty(part.content.trim()) && textIndex < textArray.size()) {
                        String original = textArray.get(textIndex);
                        String translated = translations.get(original);
                        if (!TextUtils.isEmpty(translated)) {
                            result.append(translated);
                        } else {
                            result.append(part.content);
                        }
                        textIndex++;
                    } else {
                        result.append(part.content);
                    }
                    break;
            }
        }

        return result.toString();
    }

    public void saveTranslationResult(V2TIMMessage v2TIMMessage, String text, int status) {
        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            JSONObject customJson = new JSONObject();
            try {
                if (!TextUtils.isEmpty(localCustomData)) {
                    customJson = new JSONObject(localCustomData);
                }
                customJson.put(TRANSLATION_KEY, text);
                customJson.put(TRANSLATION_VIEW_STATUS_KEY, status);
                v2TIMMessage.setLocalCustomData(customJson.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public void setTranslationStatus(V2TIMMessage v2TIMMessage, int status) {
        if (status != MSG_TRANSLATE_STATUS_UNKNOWN && status != MSG_TRANSLATE_STATUS_HIDDEN && status != MSG_TRANSLATE_STATUS_SHOWN
                && status != MSG_TRANSLATE_STATUS_LOADING) {
            return;
        }

        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            JSONObject customJson = new JSONObject();
            try {
                if (!TextUtils.isEmpty(localCustomData)) {
                    customJson = new JSONObject(localCustomData);
                }

                if (customJson.has(TRANSLATION_VIEW_STATUS_KEY)) {
                    int oldTranslationStatus = customJson.getInt(TRANSLATION_VIEW_STATUS_KEY);
                    if (oldTranslationStatus == status) {
                        return;
                    }
                }
                
                customJson.put(TRANSLATION_VIEW_STATUS_KEY, status);
                v2TIMMessage.setLocalCustomData(customJson.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public String getTranslationText(V2TIMMessage v2TIMMessage) {
        String result = "";
        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            if (TextUtils.isEmpty(localCustomData)) {
                return result;
            }
            try {
                JSONObject customJson = new JSONObject(localCustomData);
                if (customJson.has(TRANSLATION_KEY)) {
                    result = customJson.getString(TRANSLATION_KEY);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return result;
    }

    public int getTranslationStatus(V2TIMMessage v2TIMMessage) {
        int translationStatus = MSG_TRANSLATE_STATUS_UNKNOWN;
        if (v2TIMMessage != null) {
            String localCustomData = v2TIMMessage.getLocalCustomData();
            if (TextUtils.isEmpty(localCustomData)) {
                return translationStatus;
            }
            try {
                JSONObject customJson = new JSONObject(localCustomData);
                if (customJson.has(TRANSLATION_VIEW_STATUS_KEY)) {
                    translationStatus = customJson.getInt(TRANSLATION_VIEW_STATUS_KEY);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return translationStatus;
    }
}
