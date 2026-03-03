package io.trtc.tuikit.atomicx.ai

import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageButton
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentManager
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.ai.SourceLanguage
import io.trtc.tuikit.atomicxcore.api.ai.TranslationLanguage

class TranscriberSettingsDialogFragment : DialogFragment() {

    private var currentSourceLanguage: SourceLanguage = SourceLanguage.CHINESE_ENGLISH
    private var currentTranslationLanguage: TranslationLanguage? = TranslationLanguage.ENGLISH
    private var isBilingualEnabled: Boolean = true

    private lateinit var tvSourceLanguageValue: TextView
    private lateinit var tvTranslationLanguageValue: TextView
    private lateinit var btnBilingual: AppCompatImageButton

    var onSettingsChanged: ((SourceLanguage, TranslationLanguage?, Boolean) -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, R.style.FullScreenDialogTheme)

        arguments?.let {
            currentSourceLanguage = SourceLanguage.values().find { lang ->
                lang.value == it.getString(ARG_SOURCE_LANGUAGE)
            } ?: SourceLanguage.CHINESE_ENGLISH

            currentTranslationLanguage = TranslationLanguage.values().find { lang ->
                lang.value == it.getString(ARG_TRANSLATION_LANGUAGE)
            }

            isBilingualEnabled = it.getBoolean(ARG_BILINGUAL_ENABLED, true)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.ai_dialog_transcriber_settings, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        view.findViewById<ImageView>(R.id.ai_iv_back).setOnClickListener {
            dismiss()
        }

        tvSourceLanguageValue = view.findViewById(R.id.ai_tv_source_language)
        tvTranslationLanguageValue = view.findViewById(R.id.ai_tv_translation_language)
        btnBilingual = view.findViewById(R.id.ai_btn_bilingual)
        btnBilingual.setImageResource(if (isBilingualEnabled) R.drawable.common_ic_switch_on else R.drawable.common_ic_switch_off)

        updateSourceLanguageDisplay()
        updateTranslationLanguageDisplay()

        view.findViewById<View>(R.id.ai_cl_source_language).setOnClickListener {
            showSourceLanguagePicker()
        }

        view.findViewById<View>(R.id.ai_cl_translation_language).setOnClickListener {
            showTranslationLanguagePicker()
        }
        btnBilingual.setOnClickListener {
            isBilingualEnabled = !isBilingualEnabled
            btnBilingual.setImageResource(if (isBilingualEnabled) R.drawable.common_ic_switch_on else R.drawable.common_ic_switch_off)
        }
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        onSettingsChanged?.invoke(currentSourceLanguage, currentTranslationLanguage, isBilingualEnabled)
    }

    private fun updateSourceLanguageDisplay() {
        val resId = LanguageProvider.getSourceLanguageResId(currentSourceLanguage)
        tvSourceLanguageValue.setText(resId)
    }

    private fun updateTranslationLanguageDisplay() {
        val resId = LanguageProvider.getTranslationLanguageResId(currentTranslationLanguage)
        tvTranslationLanguageValue.setText(resId)
    }

    private fun showSourceLanguagePicker() {
        if (childFragmentManager.findFragmentByTag(LanguagePickerDialogFragment.TAG) != null) return
        LanguagePickerDialogFragment.newInstanceForSource(currentSourceLanguage.value).apply {
            setOnLanguageSelectedListener(object : LanguagePickerDialogFragment.OnLanguageSelectedListener {
                override fun onLanguageSelected(value: String) {
                    LanguageProvider.findSourceLanguage(value)?.let { lang ->
                        currentSourceLanguage = lang
                        updateSourceLanguageDisplay()
                    }
                }
            })
        }.show(childFragmentManager, LanguagePickerDialogFragment.TAG)
    }

    private fun showTranslationLanguagePicker() {
        if (childFragmentManager.findFragmentByTag(LanguagePickerDialogFragment.TAG) != null) return
        LanguagePickerDialogFragment.newInstanceForTranslation(currentTranslationLanguage?.value ?: "").apply {
            setOnLanguageSelectedListener(object : LanguagePickerDialogFragment.OnLanguageSelectedListener {
                override fun onLanguageSelected(value: String) {
                    currentTranslationLanguage = if (value.isEmpty()) null else LanguageProvider.findTranslationLanguage(value)
                    updateTranslationLanguageDisplay()
                }
            })
        }.show(childFragmentManager, LanguagePickerDialogFragment.TAG)
    }

    companion object {
        private const val TAG = "TranscriberSettingsDialogFragment"
        private const val ARG_SOURCE_LANGUAGE = "source_language"
        private const val ARG_TRANSLATION_LANGUAGE = "translation_language"
        private const val ARG_BILINGUAL_ENABLED = "bilingual_enabled"

        fun show(
            fragmentManager: FragmentManager,
            sourceLanguage: SourceLanguage,
            translationLanguage: TranslationLanguage?,
            isBilingualEnabled: Boolean,
            onSettingsChanged: ((SourceLanguage, TranslationLanguage?, Boolean) -> Unit)
        ): TranscriberSettingsDialogFragment? {
            if (fragmentManager.findFragmentByTag(TAG) != null) {
                return null
            }
            return TranscriberSettingsDialogFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_SOURCE_LANGUAGE, sourceLanguage.value)
                    putString(ARG_TRANSLATION_LANGUAGE, translationLanguage?.value ?: "")
                    putBoolean(ARG_BILINGUAL_ENABLED, isBilingualEnabled)
                }
                this.onSettingsChanged = onSettingsChanged
            }.also {
                it.show(fragmentManager, TAG)
            }
        }
    }
}
