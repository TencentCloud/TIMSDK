package io.trtc.tuikit.atomicx.karaoke.view

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.SeekBar
import android.widget.TextView
import androidx.appcompat.widget.SwitchCompat
import com.tencent.trtc.TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusAccompaniment
import com.tencent.trtc.TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore

class KaraokeSettingPanel @JvmOverloads constructor(
    private val context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private lateinit var textPlayoutVolume: TextView
    private lateinit var textCaptureVolume: TextView
    private lateinit var textMusicPitch: TextView
    private lateinit var store: KaraokeStore
    private var onBackButtonClickListener: OnBackButtonClickListener? = null

    init {
        LayoutInflater.from(this@KaraokeSettingPanel.context)
            .inflate(R.layout.karaoke_music_setting_panel, this, true)
    }

    fun init(store: KaraokeStore) {
        this@KaraokeSettingPanel.store = store
        initView()
    }

    private fun initView() {
        bindViewId()
        initFinishView()
        initPlayoutVolumeView()
        initCaptureVolumeView()
        initMusicPitchView()
        initEnableOriginView()
        initEnableScoreView()
    }

    private fun bindViewId() {
        textCaptureVolume = findViewById(R.id.tv_capture_volume)
        textPlayoutVolume = findViewById(R.id.tv_playout_volume)
        textMusicPitch = findViewById(R.id.tv_music_pitch)
    }

    private fun initEnableOriginView() {
        val switchOrigin = findViewById<SwitchCompat>(R.id.sc_enable_origin)
        switchOrigin.isChecked = store.currentTrack.value == TXChorusOriginalSong
        switchOrigin.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                store.switchMusicTrack(TXChorusOriginalSong)
            } else {
                store.switchMusicTrack(TXChorusAccompaniment)
            }
            switchOrigin.isChecked = store.currentTrack.value == TXChorusOriginalSong
        }
    }

    private fun initEnableScoreView() {
        val switchScore = findViewById<SwitchCompat>(R.id.sc_enable_score)
        switchScore.isChecked = store.enableScore.value == true
        switchScore.setOnCheckedChangeListener { _, enable ->
            store.setScoringEnabled(enable)
        }
    }

    private fun initCaptureVolumeView() {
        textCaptureVolume.text = store.publishVolume.value.toString()
        val seekMusicVolume = findViewById<SeekBar>(R.id.sb_capture_volume)
        seekMusicVolume.progress = store.publishVolume.value ?: 0
        seekMusicVolume.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar, i: Int, b: Boolean) {
                textCaptureVolume.text = i.toString()
            }

            override fun onStartTrackingTouch(seekBar: SeekBar) {}

            override fun onStopTrackingTouch(seekBar: SeekBar) {
                store.setPublishVolume(seekBar.progress)
            }
        })
    }

    private fun initPlayoutVolumeView() {
        textPlayoutVolume.text = store.playoutVolume.value.toString()
        val seekPlayoutVolume = findViewById<SeekBar>(R.id.sb_playout_volume)
        seekPlayoutVolume.progress = store.playoutVolume.value ?: 0
        seekPlayoutVolume.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar, i: Int, b: Boolean) {
                textPlayoutVolume.text = i.toString()
            }

            override fun onStartTrackingTouch(seekBar: SeekBar) {}

            override fun onStopTrackingTouch(seekBar: SeekBar) {
                store.setPlayoutVolume(seekBar.progress)
            }
        })
    }

    private fun initMusicPitchView() {
        val seekBar = findViewById<SeekBar>(R.id.sb_music_pitch)
        val initialPitch = store.songPitch.value ?: 0f
        var initProgress = ((initialPitch + 1.0f) * 10).toInt()
        initProgress = initProgress.coerceIn(0, 20)
        seekBar.progress = initProgress

        textMusicPitch.text = String.format("%.1f", initialPitch)

        seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
                val pitch = (progress - 10) * 0.1f
                textMusicPitch.text = String.format("%.1f", pitch)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar) {}

            override fun onStopTrackingTouch(seekBar: SeekBar) {
                val pitch = (seekBar.progress - 10) * 0.1f
                store.setMusicPitch(pitch)
            }
        })
    }

    private fun initFinishView() {
        findViewById<TextView>(R.id.tv_finish).setOnClickListener {
            onBackButtonClickListener?.onClick()
        }
    }

    fun setOnBackButtonClickListener(listener: OnBackButtonClickListener?) {
        onBackButtonClickListener = listener
    }

    interface OnBackButtonClickListener {
        fun onClick()
    }
}