package com.tencent.qcloud.tuikit.tuitranslationplugin;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.SPUtils;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class TUITranslationConfigs {
    public static final String PREFERENCE_NAME = "translationLanguage";
    public static final String SP_KEY_LANGUAGE_NAME = "languageName";
    private String languageName;
    private ArrayList<String> targetLanguageNameList;
    private Map<String, String> targetLanguageMap;

    private static TUITranslationConfigs instance;

    private TUITranslationConfigs() {
        initTargetLanguage();
    }

    public static TUITranslationConfigs getInstance() {
        if (instance == null) {
            instance = new TUITranslationConfigs();
        }
        return instance;
    }

    public String getTargetLanguageName() {
        if (TextUtils.isEmpty(languageName)) {
            languageName = SPUtils.getInstance(PREFERENCE_NAME).getString(SP_KEY_LANGUAGE_NAME);
        }

        if (TextUtils.isEmpty(languageName)) {
            String languageCode = TUIThemeManager.getInstance().getCurrentLanguage();
            for (String key : targetLanguageMap.keySet()) {
                if (TextUtils.equals(targetLanguageMap.get(key), languageCode)) {
                    languageName = key;
                    break;
                }
            }
        }
        if (TextUtils.isEmpty(languageName)) {
            languageName = "English";
        }

        return languageName;
    }

    public void setTargetLanguageName(String languageName) {
        this.languageName = languageName;
        SPUtils.getInstance(PREFERENCE_NAME).put(SP_KEY_LANGUAGE_NAME, languageName);
    }

    public String getTargetLanguageCode() {
        return targetLanguageMap.get(getTargetLanguageName());
    }

    public ArrayList<String> getTargetLanguageNameList() {
        return targetLanguageNameList;
    }

    public Map<String, String> getTargetLanguageMap() {
        return targetLanguageMap;
    }

    private void initTargetLanguage() {
        targetLanguageNameList = new ArrayList<>();
        targetLanguageNameList.add("简体中文");
        targetLanguageNameList.add("繁體中文");
        targetLanguageNameList.add("English");
        targetLanguageNameList.add("日本語");
        targetLanguageNameList.add("한국어");
        targetLanguageNameList.add("Français");
        targetLanguageNameList.add("Español");
        targetLanguageNameList.add("Italiano");
        targetLanguageNameList.add("Deutsch");
        targetLanguageNameList.add("Türkçe");
        targetLanguageNameList.add("Русский");
        targetLanguageNameList.add("Português");
        targetLanguageNameList.add("Tiếng Việt");
        targetLanguageNameList.add("Bahasa Indonesia");
        targetLanguageNameList.add("ภาษาไทย");
        targetLanguageNameList.add("Bahasa Melayu");
        targetLanguageNameList.add("हिन्दी");

        targetLanguageMap = new HashMap<>();
        targetLanguageMap.put("简体中文", "zh");
        targetLanguageMap.put("繁體中文", "zh-TW");
        targetLanguageMap.put("English", "en"); // English
        targetLanguageMap.put("日本語", "ja"); // Japanese
        targetLanguageMap.put("한국어", "ko"); // Korean
        targetLanguageMap.put("Français", "fr"); // French
        targetLanguageMap.put("Español", "es"); // Spanish
        targetLanguageMap.put("Italiano", "it"); // Italian
        targetLanguageMap.put("Deutsch", "de"); // German
        targetLanguageMap.put("Türkçe", "tr"); // Turkish
        targetLanguageMap.put("Русский", "ru"); // Russian
        targetLanguageMap.put("Português", "pt"); // Portuguese
        targetLanguageMap.put("Tiếng Việt", "vi"); // Vietnamese
        targetLanguageMap.put("Bahasa Indonesia", "id"); // Indonesian
        targetLanguageMap.put("ภาษาไทย", "th"); // Thai
        targetLanguageMap.put("Bahasa Melayu", "ms"); // Malaysian
        targetLanguageMap.put("हिन्दी", "hi"); // Hindi language
    }
}
