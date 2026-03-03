package io.trtc.tuikit.atomicx.ai

import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.ai.SourceLanguage
import io.trtc.tuikit.atomicxcore.api.ai.TranslationLanguage

object LanguageProvider {

    fun getSourceLanguageResId(language: SourceLanguage): Int {
        return when (language) {
            SourceLanguage.CHINESE_ENGLISH -> R.string.ai_source_lang_zh_en
            SourceLanguage.CHINESE -> R.string.ai_source_lang_zh
            SourceLanguage.ENGLISH -> R.string.ai_source_lang_en
        }
    }

    fun getTranslationLanguageResId(language: TranslationLanguage?): Int {
        return when (language) {
            null -> R.string.ai_trans_lang_none
            TranslationLanguage.CHINESE -> R.string.ai_trans_lang_zh
            TranslationLanguage.ENGLISH -> R.string.ai_trans_lang_en
            TranslationLanguage.VIETNAMESE -> R.string.ai_trans_lang_vi
            TranslationLanguage.JAPANESE -> R.string.ai_trans_lang_ja
            TranslationLanguage.KOREAN -> R.string.ai_trans_lang_ko
            TranslationLanguage.INDONESIAN -> R.string.ai_trans_lang_id
            TranslationLanguage.THAI -> R.string.ai_trans_lang_th
            TranslationLanguage.PORTUGUESE -> R.string.ai_trans_lang_pt
            TranslationLanguage.ARABIC -> R.string.ai_trans_lang_ar
            TranslationLanguage.SPANISH -> R.string.ai_trans_lang_es
            TranslationLanguage.FRENCH -> R.string.ai_trans_lang_fr
            TranslationLanguage.MALAY -> R.string.ai_trans_lang_ms
            TranslationLanguage.GERMAN -> R.string.ai_trans_lang_de
            TranslationLanguage.ITALIAN -> R.string.ai_trans_lang_it
            TranslationLanguage.RUSSIAN -> R.string.ai_trans_lang_ru
        }
    }

    fun findSourceLanguage(value: String): SourceLanguage? {
        return SourceLanguage.values().find { it.value == value }
    }

    fun findTranslationLanguage(value: String): TranslationLanguage? {
        return TranslationLanguage.values().find { it.value == value }
    }

    fun getSourceLanguageList(): List<Pair<String, Int>> {
        return SourceLanguage.values().map { it.value to getSourceLanguageResId(it) }
    }

    fun getTranslationLanguageList(): List<Pair<String, Int>> {
        val list = mutableListOf<Pair<String, Int>>()
        list.add("" to R.string.ai_trans_lang_none)
        list.addAll(TranslationLanguage.values().map { it.value to getTranslationLanguageResId(it) })
        return list
    }
}
