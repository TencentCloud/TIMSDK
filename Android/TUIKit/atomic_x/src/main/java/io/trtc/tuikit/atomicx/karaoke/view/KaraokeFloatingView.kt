package io.trtc.tuikit.atomicx.karaoke.view


import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.Observer
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager
import com.tencent.trtc.TXChorusMusicPlayer
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore
import io.trtc.tuikit.atomicx.karaoke.store.utils.PlaybackState
import io.trtc.tuikit.atomicx.widget.basicwidget.popover.AtomicPopover
import io.trtc.tuikit.atomicxcore.api.live.CoHostStore
import io.trtc.tuikit.atomicxcore.api.live.CoHostStore.Companion.create
import io.trtc.tuikit.atomicxcore.api.live.SeatUserInfo
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlin.math.abs

class KaraokeFloatingView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0,
) : ConstraintLayout(context, attrs, defStyleAttr) {
    enum class FloatingMode { RIGHT_HALF_MOVE, CENTER_FIXED }

    private lateinit var store: KaraokeStore
    private lateinit var liveID: String
    private var coHostStore: CoHostStore? = null
    private var subscribeStateJob: Job? = null
    private lateinit var imagePause: ImageView
    private lateinit var imageNext: ImageView
    private lateinit var imageRequestMusic: ImageView
    private lateinit var imageSetting: ImageView
    private lateinit var imageEnableOriginal: ImageView
    private lateinit var lyricView: LyricView
    private lateinit var pitchView: PitchView
    private lateinit var frameFunction: FrameLayout
    private lateinit var layoutRoot: LinearLayout
    private lateinit var songRequestPanel: SongRequestPanel
    private var parentView: ViewGroup? = null
    private var mode: FloatingMode = FloatingMode.RIGHT_HALF_MOVE
    private var isDragging = false
    private var lastY = 0f
    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    private var moveRangeTop = 0f
    private var moveRangeBottom = 0f
    private val rightMarginPx: Float = 10 * context.resources.displayMetrics.density
    private val playQueueObserver = Observer(this::onPlayQueueChanged)
    private val progressObserver = Observer(this::onProgressChanged)
    private val isDisplayFloatViewObserver = Observer(this::onDisplayFloatViewChanged)
    private val playbackStateObserver = Observer(this::onPlaybackStateChanged)
    private val pitchListObserver = Observer(this::onPitchListChanged)
    private val currentPitchObserver = Observer(this::onCurrentPitchChanged)
    private val currentScoreObserver = Observer(this::onCurrentScoreChanged)
    private val enableScoreObserver = Observer(this::onEnableScoreChanged)
    private val remoteScoresObserver = Observer(this::onRemoteScoresChanged)
    private val remotePitchesObserver = Observer(this::onRemotePitchesChanged)
    private val currentTrackObserver = Observer(this::onCurrentTrackChanged)

    init {
        LayoutInflater.from(context).inflate(R.layout.karaoke_floating_view, this, true)
        setBackgroundColor(Color.TRANSPARENT)
        isClickable = true
        bindViewId()
    }

    fun init(roomId: String, isOwner: Boolean) {
        store = KaraokeStore.getInstance(context)
        liveID = roomId
        coHostStore = create(roomId)
        store.init(roomId, isOwner)
        songRequestPanel = SongRequestPanel(context, store, isOwner)
        setupDynamicViews()
        initClickListeners()
        addObservers()
    }

    fun release() {
        removeObservers()
        KaraokeStore.destroyInstance()
    }

    fun attachAsFloating(parent: ViewGroup, mode: FloatingMode) {
        this@KaraokeFloatingView.mode = mode
        parentView = parent
        isClickable = true
        this.visibility = INVISIBLE
        (this.parent as? ViewGroup)?.removeView(this)
        parent.addView(
            this, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
        )
        post {
            updateFloatingLayout()
            this.visibility = VISIBLE
        }
    }

    fun detachFromFloating() {
        (this.parent as? ViewGroup)?.removeView(this)
    }

    fun showSongRequestPanel() {
        songRequestPanel.show()
    }

    private fun bindViewId() {
        layoutRoot = findViewById(R.id.ll_root)
        imagePause = findViewById(R.id.iv_pause)
        imageNext = findViewById(R.id.iv_next)
        imageRequestMusic = findViewById(R.id.iv_order_music)
        imageSetting = findViewById(R.id.iv_setting)
        imageEnableOriginal = findViewById(R.id.iv_original)
        frameFunction = findViewById(R.id.fl_function)
    }

    private fun setupDynamicViews() {
        if (layoutRoot is ViewGroup) {
            (layoutRoot as ViewGroup).clipChildren = false
            (layoutRoot as ViewGroup).clipToPadding = false
        }
        pitchView = PitchView(context)
        val width = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, 177f, resources.displayMetrics
        ).toInt()
        val height = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, 50f, resources.displayMetrics
        ).toInt()
        val layoutParams = LinearLayout.LayoutParams(width, height)
        layoutParams.topMargin = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, 20f,
            resources.displayMetrics
        ).toInt()
        pitchView.layoutParams = layoutParams
        layoutRoot.addView(pitchView, 0)
        lyricView = LyricView(context, store)
        val params = LinearLayout.LayoutParams(width, height)
        lyricView.layoutParams = params
        val index: Int = layoutRoot.indexOfChild(pitchView)
        layoutRoot.addView(lyricView, index + 1)
    }

    private fun initClickListeners() {
        imagePause.setOnClickListener {
            if (store.playbackState.value == PlaybackState.START || store.playbackState.value == PlaybackState.RESUME) {
                store.pausePlayback()
            } else {
                store.resumePlayback()
            }
        }
        imageNext.setOnClickListener {
            store.playNextSong()
            store.setIsDisplayScoreView(false)
        }
        imageRequestMusic.setOnClickListener { view ->
            view.post {
                if (songRequestPanel.isShowing) {
                    return@post
                }
                songRequestPanel.show()
            }
        }
        frameFunction.setOnClickListener { view ->
            view.post {
                if (songRequestPanel.isShowing) {
                    return@post
                }
                songRequestPanel.show()
            }
        }
        imageSetting.setOnClickListener {
            val atomicPopover = AtomicPopover(context)
            val karaokeSettingPanel = KaraokeSettingPanel(context)
            karaokeSettingPanel.init(store)
            karaokeSettingPanel.setOnBackButtonClickListener(object :
                KaraokeSettingPanel.OnBackButtonClickListener {
                override fun onClick() {
                    atomicPopover.dismiss()
                }
            })
            atomicPopover.setContent(karaokeSettingPanel)
            atomicPopover.show()
        }
        imageEnableOriginal.setOnClickListener {
            if (store.currentTrack.value == TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong) {
                store.switchMusicTrack(TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusAccompaniment)
            } else {
                store.switchMusicTrack(TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong)
            }
        }
    }

    private fun addObservers() {
        store.playbackProgressMs.observeForever(progressObserver)
        store.songQueue.observeForever(playQueueObserver)
        store.isDisplayFloatView.observeForever(isDisplayFloatViewObserver)
        store.playbackState.observeForever(playbackStateObserver)
        store.pitchList.observeForever(pitchListObserver)
        store.currentPitch.observeForever(currentPitchObserver)
        store.currentScore.observeForever(currentScoreObserver)
        store.enableScore.observeForever(enableScoreObserver)
        store.hostScore.observeForever(remoteScoresObserver)
        store.hostPitch.observeForever(remotePitchesObserver)
        store.currentTrack.observeForever(currentTrackObserver)
        addConnectionObserver()
    }

    private fun removeObservers() {
        store.playbackProgressMs.removeObserver(progressObserver)
        store.songQueue.removeObserver(playQueueObserver)
        store.isDisplayFloatView.removeObserver(isDisplayFloatViewObserver)
        store.playbackState.removeObserver(playbackStateObserver)
        store.pitchList.removeObserver(pitchListObserver)
        store.currentPitch.removeObserver(currentPitchObserver)
        store.currentScore.removeObserver(currentScoreObserver)
        store.enableScore.removeObserver(enableScoreObserver)
        store.hostScore.removeObserver(remoteScoresObserver)
        store.hostPitch.removeObserver(remotePitchesObserver)
        store.currentTrack.removeObserver(currentTrackObserver)
        subscribeStateJob?.cancel()
    }

    fun addConnectionObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            coHostStore?.coHostState?.connected?.collect {
                onConnectedListChanged(it)
            }
        }
    }

    fun onConnectedListChanged(connectedRoomList: List<SeatUserInfo>) {
        val isConnected = connectedRoomList.any { it.liveID == liveID }
        if (isConnected) {
            store.enableRequestMusic(false)
        } else {
            store.enableRequestMusic(true)
        }
    }

    private fun onProgressChanged(progress: Long) {
        lyricView.setPlayProgress(progress)
        pitchView.setPlayProgress(progress)
    }

    private fun onDisplayFloatViewChanged(isDisplay: Boolean) {
        layoutRoot.visibility = if (isDisplay) VISIBLE else GONE
        if (isDisplay && isAttachedToWindow) {
            post { updateFloatingLayout() }
        }
    }

    private fun onPlaybackStateChanged(playbackState: PlaybackState) {
        if (playbackState == PlaybackState.START) {
            imagePause.setImageResource(R.drawable.karaoke_music_resume)
        } else if (playbackState == PlaybackState.RESUME) {
            imagePause.setImageResource(R.drawable.karaoke_music_resume)
        } else if (playbackState == PlaybackState.PAUSE) {
            imagePause.setImageResource(R.drawable.karaoke_music_pause)
        } else {
            imagePause.setImageResource(R.drawable.karaoke_music_pause)
        }
    }

    private fun onPitchListChanged(pitchList: List<TXChorusMusicPlayer.TXReferencePitch>) {
        pitchView.setPitchList(pitchList)
    }

    private fun onCurrentPitchChanged(pitch: Int) {
        pitchView.setUserPitch(pitch)
    }

    private fun onCurrentScoreChanged(score: Int) {
        pitchView.setScore(score)
    }

    private fun onEnableScoreChanged(enableScore: Boolean) {
        pitchView.setScoringEnabled(enableScore)
    }

    private fun onRemoteScoresChanged(score: Int) {
        if (store.isRoomOwner.value == false) {
            pitchView.setScore(score)
        }
    }

    private fun onRemotePitchesChanged(pitch: Int) {
        if (store.isRoomOwner.value == false) {
            pitchView.setUserPitch(pitch)
        }
    }

    private fun onCurrentTrackChanged(currentTrack: TXChorusMusicPlayer.TXChorusMusicTrack) {
        val resource =
            if (currentTrack == TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong) R.drawable.karaoke_original_on
            else R.drawable.karaoke_original_off
        imageEnableOriginal.setImageResource(resource)
    }

    private fun onPlayQueueChanged(list: List<TUISongListManager.SongInfo>) {
        val isOwner = store.isRoomOwner.value == true
        val isQueueEmpty = list.isEmpty()

        val showFunctionBar = isOwner && !isQueueEmpty
        frameFunction.visibility = if (showFunctionBar) VISIBLE else GONE
        imageRequestMusic.visibility = if (showFunctionBar) GONE else VISIBLE

        val showLyricAndPitch = !isQueueEmpty
        lyricView.visibility = if (showLyricAndPitch) VISIBLE else GONE
        pitchView.visibility = if (showLyricAndPitch) VISIBLE else GONE
    }

    private fun updateFloatingLayout() {
        val parent = parentView ?: return
        val parentW = parent.width
        val parentH = parent.height
        val myW = width
        val myH = height

        if (mode == FloatingMode.RIGHT_HALF_MOVE) {
            moveRangeTop = parentH / 4f
            moveRangeBottom = parentH * 3f / 4f - myH
            this.y = parentH / 2f - myH / 2f
            this.x = parentW - rightMarginPx - myW
        } else if (mode == FloatingMode.CENTER_FIXED) {
            val d110 = context.resources.displayMetrics.density * 110
            this.y = d110
            this.x = (parentW - myW) / 2f
        }
    }

    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        if (ev == null || mode != FloatingMode.RIGHT_HALF_MOVE) return false
        when (ev.action) {
            MotionEvent.ACTION_DOWN -> {
                lastY = ev.rawY
                isDragging = false
            }

            MotionEvent.ACTION_MOVE -> {
                if (abs(ev.rawY - lastY) > touchSlop) {
                    isDragging = true
                    return true
                }
            }
        }
        return false
    }

    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (!this::store.isInitialized) {
            return
        }
        if (visibility == VISIBLE) {
            store.setFullScreenUIMode(false)
        }
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event == null) return false
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                lastY = event.rawY
                isDragging = false
                performClick()
                return true
            }

            MotionEvent.ACTION_MOVE -> {
                if (mode != FloatingMode.RIGHT_HALF_MOVE) return false
                val dy = event.rawY - lastY
                this.y = (y + dy).coerceIn(moveRangeTop, moveRangeBottom)
                val parentW = parentView?.width ?: 0
                this.x = parentW - rightMarginPx - width
                lastY = event.rawY
                return true
            }

            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isDragging = false
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    override fun performClick(): Boolean {
        super.performClick()
        return true
    }
}