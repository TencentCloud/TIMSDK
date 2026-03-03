package io.trtc.tuikit.atomicx.ai

import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import io.trtc.tuikit.atomicx.R

class LanguagePickerDialogFragment : DialogFragment() {

    interface OnLanguageSelectedListener {
        fun onLanguageSelected(value: String)
    }

    private var listener: OnLanguageSelectedListener? = null
    private var languages: List<Pair<String, Int>> = emptyList()
    private var selectedValue: String? = null
    private var titleResId: Int = 0

    fun setOnLanguageSelectedListener(listener: OnLanguageSelectedListener) {
        this.listener = listener
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, R.style.FullScreenDialogThemeFromBottom)
        arguments?.let {
            selectedValue = it.getString(ARG_SELECTED_VALUE)
            titleResId = it.getInt(ARG_TITLE_RES_ID)
            val isSourceLanguage = it.getBoolean(ARG_IS_SOURCE_LANGUAGE, true)
            languages = if (isSourceLanguage) {
                LanguageProvider.getSourceLanguageList()
            } else {
                LanguageProvider.getTranslationLanguageList()
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.ai_dialog_language_picker, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        view.findViewById<ImageView>(R.id.ai_iv_back).setOnClickListener {
            dismiss()
        }

        view.findViewById<TextView>(R.id.ai_tv_picker_title).setText(titleResId)

        val recyclerView = view.findViewById<RecyclerView>(R.id.ai_rv_language_list)
        recyclerView.layoutManager = LinearLayoutManager(context)
        recyclerView.adapter = LanguageAdapter(languages, selectedValue) { value ->
            listener?.onLanguageSelected(value)
            dismiss()
        }
    }

    private inner class LanguageAdapter(
        private val items: List<Pair<String, Int>>,
        private val selectedValue: String?,
        private val onItemClick: (String) -> Unit
    ) : RecyclerView.Adapter<LanguageAdapter.ViewHolder>() {

        inner class ViewHolder(itemView: View, val textView: TextView) : RecyclerView.ViewHolder(itemView)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val textView = TextView(parent.context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    (52 * resources.displayMetrics.density).toInt()
                )
                gravity = Gravity.START or Gravity.CENTER_VERTICAL
                textSize = 16f
            }
            val container = LinearLayout(parent.context).apply {
                orientation = LinearLayout.VERTICAL
                addView(View(context).apply {
                    layoutParams = LinearLayout.LayoutParams(MATCH_PARENT, 1).apply {
                        setMargins(0, 0, 0, 0)
                    }
                    setBackgroundColor(0xFFEEEEEE.toInt())
                })
                addView(textView)
            }

            return ViewHolder(container, textView)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val (value, resId) = items[position]
            holder.textView.setText(resId)
            holder.textView.setTextColor(if (value == selectedValue) 0xFF1C66E5.toInt() else 0xED000000.toInt())
            holder.textView.setOnClickListener {
                onItemClick(value)
            }
        }

        override fun getItemCount(): Int = items.size
    }

    companion object {
        const val TAG = "LanguagePickerDialogFragment"

        private const val ARG_SELECTED_VALUE = "selected_value"
        private const val ARG_IS_SOURCE_LANGUAGE = "is_source_language"
        private const val ARG_TITLE_RES_ID = "title_res_id"

        fun newInstanceForSource(selectedValue: String?): LanguagePickerDialogFragment {
            return LanguagePickerDialogFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_SELECTED_VALUE, selectedValue)
                    putBoolean(ARG_IS_SOURCE_LANGUAGE, true)
                    putInt(ARG_TITLE_RES_ID, R.string.ai_transcriber_select_source_language)
                }
            }
        }

        fun newInstanceForTranslation(selectedValue: String?): LanguagePickerDialogFragment {
            return LanguagePickerDialogFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_SELECTED_VALUE, selectedValue)
                    putBoolean(ARG_IS_SOURCE_LANGUAGE, false)
                    putInt(ARG_TITLE_RES_ID, R.string.ai_transcriber_select_translation_language)
                }
            }
        }
    }
}
