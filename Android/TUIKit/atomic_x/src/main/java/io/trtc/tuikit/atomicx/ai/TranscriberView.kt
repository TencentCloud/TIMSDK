package io.trtc.tuikit.atomicx.ai

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet

import android.view.GestureDetector
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView

import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.ai.AITranscriberStore
import io.trtc.tuikit.atomicxcore.api.ai.SourceLanguage
import io.trtc.tuikit.atomicxcore.api.ai.TranscriberConfig
import io.trtc.tuikit.atomicxcore.api.ai.TranscriberMessage
import io.trtc.tuikit.atomicxcore.api.ai.TranslationLanguage
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.login.LoginStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class TranscriberView(context: Context, attrs: AttributeSet?) : FrameLayout(context, attrs) {

    companion object {
        var currentSourceLanguage: SourceLanguage = SourceLanguage.CHINESE_ENGLISH
        var currentTranslationLanguage: TranslationLanguage? = TranslationLanguage.ENGLISH
        var isBilingualEnabled: Boolean = true
    }

    private lateinit var messageListView: RecyclerView
    private val adapter = MessageListAdapter()
    private val transcriberStore = AITranscriberStore.shared
    private var collectJob: Job? = null
    private var isAutoRefreshMessage: Boolean = true

    private val dataObserver = object : RecyclerView.AdapterDataObserver() {
        override fun onItemRangeInserted(positionStart: Int, itemCount: Int) {
            scrollToBottomIfNeeded()
        }

        private fun scrollToBottomIfNeeded() {
            if (isAutoRefreshMessage && adapter.itemCount > 0) {
                messageListView.scrollToPosition(adapter.itemCount - 1)
            }
        }
    }

    init {
        initView()
    }

    private fun initView() {
        inflate(context, R.layout.ai_view_transcriber, this)
        messageListView = findViewById(R.id.ai_recycler_message_list)
        messageListView.adapter = adapter
        val layoutManager = LinearLayoutManager(context)
        layoutManager.stackFromEnd = true
        messageListView.layoutManager = layoutManager
        messageListView.itemAnimator = null
        messageListView.addItemDecoration(SpaceItemDecoration(context, 8))
        adapter.registerAdapterDataObserver(dataObserver)
        setupRecyclerViewGesture()
        setupScrollListener()
    }

    private fun setupScrollListener() {
        messageListView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                when (newState) {
                    RecyclerView.SCROLL_STATE_DRAGGING,
                    RecyclerView.SCROLL_STATE_SETTLING -> {
                        isAutoRefreshMessage = false
                    }
                    RecyclerView.SCROLL_STATE_IDLE -> {
                        isAutoRefreshMessage = isAtBottom()
                    }
                }
            }
        })
    }

    private fun setupRecyclerViewGesture() {
        val gestureDetector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onSingleTapUp(e: MotionEvent): Boolean {
                openSettings()
                return true
            }
        })
        messageListView.addOnItemTouchListener(object : RecyclerView.SimpleOnItemTouchListener() {
            override fun onInterceptTouchEvent(rv: RecyclerView, e: MotionEvent): Boolean {
                gestureDetector.onTouchEvent(e)
                return false
            }
        })
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        collectJob = CoroutineScope(Dispatchers.Main).launch {
            transcriberStore.transcriberState.realtimeMessageList.collect { messages ->
                adapter.submitList(messages.toList())
            }
        }
    }

    private fun isAtBottom(): Boolean {
        val layoutManager = messageListView.layoutManager as? LinearLayoutManager ?: return true
        val lastVisiblePosition = layoutManager.findLastVisibleItemPosition()
        val itemCount = adapter.itemCount
        return lastVisiblePosition >= itemCount - 2
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        collectJob?.cancel()
        collectJob = null
    }

    private fun openSettings() {
        if (!isCaller()) {
            return
        }
        val activity = context as? FragmentActivity ?: return
        TranscriberSettingsDialogFragment.show(
            fragmentManager = activity.supportFragmentManager,
            sourceLanguage = currentSourceLanguage,
            translationLanguage = currentTranslationLanguage,
            isBilingualEnabled = isBilingualEnabled
        ) { source, translation, bilingual ->
            if (isBilingualEnabled != bilingual) {
                isBilingualEnabled = bilingual
                adapter.notifyDataSetChanged()
            }
            if (source != currentSourceLanguage || translation != currentTranslationLanguage) {
                currentSourceLanguage = source
                currentTranslationLanguage = translation
                updateTranscriberConfig(source, translation)
            }
        }
    }

    private fun updateTranscriberConfig(source: SourceLanguage, translation: TranslationLanguage?) {
        val languages = if (translation != null) mutableListOf(translation) else mutableListOf()
        val config = TranscriberConfig(
            sourceLanguage = source,
            translationLanguages = languages
        )
        AITranscriberStore.shared.updateRealtimeTranscriber(config, null)
    }

    private fun isCaller(): Boolean {
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return selfId == callerId
    }

    private inner class MessageListAdapter :
        ListAdapter<TranscriberMessage, TranscriberViewHolder>(TranscriberDiffCallback) {
        val selfId: String = LoginStore.shared.loginState.loginUserInfo.value?.userID ?: ""

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TranscriberViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.ai_view_subtitle_item, parent, false)
            return TranscriberViewHolder(view, selfId)
        }

        override fun onBindViewHolder(holder: TranscriberViewHolder, position: Int) {
            var preItem: TranscriberMessage? = null
            if (position > 0) {
                preItem = currentList[position -1]
            }
            holder.bind(getItem(position), preItem, isBilingualEnabled)
        }
    }

    private class TranscriberViewHolder(itemView: View, val selfId: String) : RecyclerView.ViewHolder(itemView) {
        private val userName: TextView = itemView.findViewById(R.id.ai_tv_user_name)
        private val sourceText: TextView = itemView.findViewById(R.id.ai_tv_source_text)
        private val translationText: TextView = itemView.findViewById(R.id.ai_tv_translation_text)

        fun bind(message: TranscriberMessage, preItemMessage: TranscriberMessage?, isBilingualEnabled: Boolean) {
            userName.text = getUserName(message)
            sourceText.text = message.sourceText
            sourceText.visibility = if (isBilingualEnabled) VISIBLE else GONE
            translationText.text = message.translationTexts.values.firstOrNull()
            userName.visibility = if (message.speakerUserId == preItemMessage?.speakerUserId) GONE else VISIBLE
        }

        private fun getUserName(message: TranscriberMessage): String {
            val me = if (message.speakerUserId == selfId) itemView.context.getString(R.string.ai_transcriber_me) else ""
            val displayName = if (message.speakerUserName.isEmpty()) message.speakerUserId else message.speakerUserName
            return itemView.context.getString(R.string.ai_transcriber_user_name, displayName, me)
        }
    }

    private object TranscriberDiffCallback : DiffUtil.ItemCallback<TranscriberMessage>() {
        override fun areItemsTheSame(oldItem: TranscriberMessage, newItem: TranscriberMessage): Boolean {
            return oldItem.segmentId == newItem.segmentId
        }

        override fun areContentsTheSame(oldItem: TranscriberMessage, newItem: TranscriberMessage): Boolean {
            return false
        }
    }

    private class SpaceItemDecoration(context: Context, spaceDp: Int) : RecyclerView.ItemDecoration() {
        private val spacePx = (spaceDp * context.resources.displayMetrics.density).toInt()

        override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
            outRect.bottom = spacePx
        }
    }
}
