package io.trtc.tuikit.atomicx.karaoke.store

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager.SongInfo
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager.SongListChangeReason
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager.SongListResult
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.GetRoomMetadataCallback
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RoomDismissedReason
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudDef.TRTCParams
import com.tencent.trtc.TRTCCloudListener
import com.tencent.trtc.TXChorusMusicPlayer
import com.tencent.trtc.TXChorusMusicPlayer.TXChorusRole
import com.tencent.trtc.txcopyrightedmedia.TXCopyrightedMedia
import com.trtc.tuikit.common.util.ToastUtil
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.service.SongServiceFactory
import io.trtc.tuikit.atomicx.karaoke.store.utils.LyricsFileReader
import io.trtc.tuikit.atomicx.karaoke.store.utils.MusicInfo
import io.trtc.tuikit.atomicx.karaoke.store.utils.PlaybackState
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import io.trtc.tuikit.atomicxcore.api.live.LiveListStore
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer

private const val TAG = "KaraokeStore"
private const val LOCAL_MUSIC_PREFIX = "local_demo"
private const val KEY_ENABLE_REQUEST_MUSIC = "EnableRequestMusic"
private const val KEY_ENABLE_SCORE = "EnableScore"

class KaraokeStore private constructor(private val context: Context) {
    companion object {
        @Volatile
        private var instance: KaraokeStore? = null

        @JvmStatic
        fun getInstance(context: Context): KaraokeStore {
            return instance ?: synchronized(this) {
                instance ?: KaraokeStore(context.applicationContext).also { instance = it }
            }
        }

        @JvmStatic
        fun destroyInstance() {
            instance?.destroy()
            instance = null
        }
    }

    var isAwaitingScoreDisplay = true

    val hostPitch: LiveData<Int> get() = _hostPitch
    val hostScore: LiveData<Int> get() = _hostScore
    val currentPlayingSong: LiveData<SongInfo> get() = _currentPlayingSong
    val isRoomOwner: LiveData<Boolean> get() = _isRoomOwner
    val songCatalog: LiveData<List<MusicInfo>> get() = _songCatalog
    val songQueue: LiveData<List<SongInfo>> get() = _songQueue
    val currentTrack: LiveData<TXChorusMusicPlayer.TXChorusMusicTrack> get() = _currentAudioTrack
    val playbackProgressMs: LiveData<Long> get() = _playbackProgressMs
    val songDurationMs: LiveData<Long> get() = _songDurationMs
    val playbackState: LiveData<PlaybackState> get() = _playbackState
    val isDisplayFloatView: LiveData<Boolean> get() = _isDisplayFloatView
    val pitchList: LiveData<List<TXChorusMusicPlayer.TXReferencePitch>> get() = _pitchList
    val songLyrics: LiveData<List<TXChorusMusicPlayer.TXLyricLine>> get() = _songLyrics
    val currentScore: LiveData<Int> get() = _currentScore
    val averageScore: LiveData<Int> get() = _averageScore
    val currentPitch: LiveData<Int> get() = _currentPitch
    val publishVolume: LiveData<Int> get() = _publishVolume
    val playoutVolume: LiveData<Int> get() = _playoutVolume
    val songPitch: LiveData<Float> get() = _songPitch
    val enableScore: LiveData<Boolean> get() = _enableScore
    val isRoomDismissed: LiveData<Boolean> get() = _isRoomDismissed
    private val songListManager: TUISongListManager = TUIRoomEngine.sharedInstance().songListManager
    private val trtcCloud: TRTCCloud = TUIRoomEngine.sharedInstance().trtcCloud
    private val gson = Gson()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var musicCatalogService: MusicCatalogService? = null
    private var chorusPlayer: TXChorusMusicPlayer? = null
    private lateinit var userId: String
    private var ownerId: String? = null
    private var isFullScreenUIMode = false
    private var _isManualStop = false
    private var _isSwitchingToNext = false
    private var _isCurrentSongRemoved = false
    private var _loadingMusicId: String? = null

    private val _hostPitch = MutableLiveData(0)
    private val _hostScore = MutableLiveData(-1)
    private val _currentPlayingSong = MutableLiveData<SongInfo>()
    private val _isRoomOwner = MutableLiveData(false)
    private val _songCatalog = MutableLiveData<List<MusicInfo>>(emptyList())
    private val _songQueue = MutableLiveData<List<SongInfo>>(emptyList())
    private val _currentAudioTrack = MutableLiveData(TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong)
    private val _playbackProgressMs = MutableLiveData(0L)
    private val _songDurationMs = MutableLiveData(0L)
    private val _playbackState = MutableLiveData(PlaybackState.IDLE)
    private val _isDisplayFloatView = MutableLiveData(true)
    private val _pitchList = MutableLiveData<List<TXChorusMusicPlayer.TXReferencePitch>>(emptyList())
    private val _songLyrics = MutableLiveData<List<TXChorusMusicPlayer.TXLyricLine>>(emptyList())
    private val _currentScore = MutableLiveData(-1)
    private val _averageScore = MutableLiveData(0)
    private val _currentPitch = MutableLiveData(0)
    private val _publishVolume = MutableLiveData(60)
    private val _playoutVolume = MutableLiveData(95)
    private val _songPitch = MutableLiveData(0.0F)
    private val _enableScore = MutableLiveData(true)
    private val _isRoomDismissed = MutableLiveData(false)

    fun init(roomId: String, isOwner: Boolean) {
        Log.d(TAG, "init: roomId=$roomId, isOwner=$isOwner")
        if (chorusPlayer != null) return
        _isRoomOwner.value = isOwner
        ownerId = LiveListStore.shared().liveState.currentLive.value.liveOwner.userID
        userId = TUIRoomEngine.getSelfInfo().userId
        musicCatalogService = SongServiceFactory.getInstance()
        setupChorusPlayer(roomId)
        copyAllAssetsToStorage()
        fetchRoomMetadata()
        getWaitingList()
        loadMusicCatalog()
        addObserver()
        if (isOwner) {
            setScoringEnabled(enableScore.value == true)
            applyDefaultAudioEffects()
        }
    }

    fun destroy() {
        Log.d(TAG, "destroy: called")
        stopPlayback()
        _isRoomDismissed.value = true
        _songQueue.value = emptyList()
        _currentPlayingSong.value = SongInfo()
        _playbackProgressMs.value = 0L
        _songLyrics.value = emptyList()
        _pitchList.value = emptyList()
        _currentScore.value = 0
        _playbackState.value = PlaybackState.IDLE
        _isManualStop = true
        _isSwitchingToNext = false
        _isCurrentSongRemoved = false
        _loadingMusicId = null
        _averageScore.value = 100
        _currentAudioTrack.value = TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong
        removeObserver()
        chorusPlayer?.destroy()
        chorusPlayer = null
    }

    fun addObserver() {
        Log.d(TAG, "addObserver")
        songListManager.addObserver(songListObserver)
        TUIRoomEngine.sharedInstance().addObserver(roomEngineObserver)
        TUIRoomEngine.sharedInstance().trtcCloud.setAudioFrameListener(audioFrameListener)
    }

    fun removeObserver() {
        Log.d(TAG, "removeObserver")
        songListManager.removeObserver(songListObserver)
        TUIRoomEngine.sharedInstance().removeObserver(roomEngineObserver)
        TUIRoomEngine.sharedInstance().trtcCloud.setAudioFrameListener(null)
    }

    fun enableRequestMusic(enable: Boolean) {
        Log.d(TAG, "enableRequestMusic: enable=$enable")
        if (_isDisplayFloatView.value != enable) {
            val metadata = hashMapOf(KEY_ENABLE_REQUEST_MUSIC to enable.toString())
            TUIRoomEngine.sharedInstance().setRoomMetadataByAdmin(metadata, null)
            if (!enable) {
                clearAllSongs()
                _songQueue.value = emptyList()
                _currentPlayingSong.value = SongInfo()
                _playbackProgressMs.value = 0L
                _songLyrics.value = emptyList()
                _pitchList.value = emptyList()
                _currentScore.value = 0
                _playbackState.value = PlaybackState.IDLE
                _averageScore.value = 100
                _currentAudioTrack.value =
                    TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong
                _isManualStop = true
                stopPlayback()
            }
        }
    }

    private fun loadMusicByLeadSinger() {
        Log.d(TAG, "loadMusicByLeadSinger: isOwner=${isRoomOwner.value}, queueSize=${songQueue.value?.size}")
        if (isRoomOwner.value == false) return
        val songQueueValue = songQueue.value
        if (songQueueValue.isNullOrEmpty()) {
            _playbackState.value = PlaybackState.IDLE
            _loadingMusicId = null
            _isCurrentSongRemoved = false
            return
        }
        val firstSong = songQueueValue.first()
        val songId = firstSong.songId
        if (!songId.isNullOrEmpty()) {
            _isCurrentSongRemoved = false
            _loadingMusicId = songId
            Log.d(TAG, "loadMusicByLeadSinger: loading songId=$songId, songName=${firstSong.songName}")
            loadMusic(songId)
        }
    }

    private fun loadMusic(musicId: String) {
        Log.d(TAG, "loadMusic: musicId=$musicId")
        if (musicId.startsWith(LOCAL_MUSIC_PREFIX)) {
            loadLocalDemoMusic(musicId)
        } else loadCopyrightedMusic(musicId)
    }

    private fun loadLocalDemoMusic(musicId: String) {
        Log.d(TAG, "loadLocalDemoMusic: musicId=$musicId")
        val musicInfo = findSongInCatalog(musicId) ?: return
        val params = TXChorusMusicPlayer.TXChorusExternalMusicParams().apply {
            this.musicId = musicInfo.musicId
            musicUrl = musicInfo.originalUrl
            accompanyUrl = musicInfo.accompanyUrl
            encryptBlockLength = 0
            isEncrypted = false
        }
        chorusPlayer?.loadExternalMusic(params)
    }

    private fun loadCopyrightedMusic(musicId: String) {
        Log.d(TAG, "loadCopyrightedMusic: musicId=$musicId")
        musicCatalogService?.queryPlayToken(musicId, userId, object : QueryPlayTokenCallBack {
            override fun onSuccess(
                musicId: String,
                playToken: String,
                copyrightedLicenseKey: String?,
                copyrightedLicenseUrl: String?,
            ) {
                Log.d(TAG, "loadCopyrightedMusic: queryPlayToken success, musicId=$musicId")
                val params = TXChorusMusicPlayer.TXChorusCopyrightedMusicParams().apply {
                    this.musicId = musicId
                    this.playToken = playToken
                    this.copyrightedLicenseKey = copyrightedLicenseKey
                    this.copyrightedLicenseUrl = copyrightedLicenseUrl
                }
                chorusPlayer?.loadMusic(params)
            }

            override fun onFailure(code: Int, desc: String) {
                Log.e(TAG, "loadCopyrightedMusic: queryPlayToken failed, code=$code, desc=$desc")
                onKaraokeError(code, desc)
            }
        })
    }

    fun loadMusicCatalog() {
        Log.d(TAG, "loadMusicCatalog")
        musicCatalogService?.getSongList(object : GetSongListCallBack {
            override fun onSuccess(songList: List<MusicInfo>) {
                Log.d(TAG, "loadMusicCatalog: success, count=${songList.size}")
                _songCatalog.postValue(songList)
            }

            override fun onFailure(code: Int, desc: String) {
                Log.e(TAG, "loadMusicCatalog: failed, code=$code, desc=$desc")
                onKaraokeError(code, desc)
            }
        })
    }

    fun setChorusRole(roomId: String, chorusRole: TXChorusRole) {
        Log.d(TAG, "setChorusRole: roomId=$roomId, role=$chorusRole")
        val robotID = "${roomId}_bgm"
        musicCatalogService?.generateUserSig(robotID, object : ActionCallback {
            override fun onSuccess(robotSig: String) {
                Log.d(TAG, "setChorusRole: generateUserSig success")
                val params = TRTCParams().apply {
                    this.sdkAppId = TUILogin.getSdkAppId()
                    strRoomId = roomId
                    userId = robotID
                    userSig = robotSig
                }
                chorusPlayer?.setChorusRole(chorusRole, params)
            }

            override fun onFailed(code: Int, msg: String?) {
                Log.e(TAG, "setChorusRole: generateUserSig failed, code=$code")
                onKaraokeError(code, msg)
            }

        })

    }

    fun startPlayback() {
        Log.d(TAG, "startPlayback: isOwner=${isRoomOwner.value}")
        if (isRoomOwner.value == true) {
            chorusPlayer?.start()
            switchMusicTrack(TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong, true)
        }
    }

    fun stopPlayback() {
        Log.d(TAG, "stopPlayback: isOwner=${isRoomOwner.value}")
        if (isRoomOwner.value == true) {
            chorusPlayer?.stop()
        }
    }

    fun pausePlayback() {
        Log.d(TAG, "pausePlayback: isOwner=${isRoomOwner.value}")
        if (isRoomOwner.value == true) {
            chorusPlayer?.pause()
        }
    }

    fun resumePlayback() {
        Log.d(TAG, "resumePlayback: isOwner=${isRoomOwner.value}")
        if (isRoomOwner.value == true) {
            chorusPlayer?.resume()
        }
    }

    fun switchMusicTrack(
        trackType: TXChorusMusicPlayer.TXChorusMusicTrack,
        isInitial: Boolean = false
    ) {
        Log.d(TAG, "switchMusicTrack: trackType=$trackType, isInitial=$isInitial")
        if (isRoomOwner.value != true) return

        val songId = songQueue.value?.firstOrNull()?.songId ?: return
        val media = TXCopyrightedMedia.instance()
        media.init()
        val hasOrigin = !media.genMusicURI(songId, 0, "audio/hi").isNullOrEmpty()
        val hasAccompany = !media.genMusicURI(songId, 1, "audio/hi").isNullOrEmpty()

        val finalTrack = if (isInitial) {
            if (hasOrigin) TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong
            else if (hasAccompany) TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusAccompaniment
            else null
        } else {
            val isTargetAvailable = if (trackType == TXChorusMusicPlayer.TXChorusMusicTrack.TXChorusOriginalSong) hasOrigin else hasAccompany

            if (!isTargetAvailable) {
                AtomicToast.show(context, context.getString(R.string.karaoke_cant_switch_tracks), AtomicToast.Style.ERROR)
                return
            }
            trackType
        }

        finalTrack?.let {
            chorusPlayer?.switchMusicTrack(it)
            _currentAudioTrack.value = it
        }
    }

    fun setPlayoutVolume(volume: Int?) {
        Log.d(TAG, "setPlayoutVolume: volume=$volume")
        volume?.let {
            chorusPlayer?.setPlayoutVolume(it)
            _playoutVolume.value = it
        }
    }

    fun setPublishVolume(volume: Int?) {
        Log.d(TAG, "setPublishVolume: volume=$volume")
        volume?.let {
            chorusPlayer?.setPublishVolume(it)
            _publishVolume.value = it
        }
    }

    fun setMusicPitch(pitch: Float?) {
        Log.d(TAG, "setMusicPitch: pitch=$pitch")
        pitch?.let {
            chorusPlayer?.setMusicPitch(it)
            _songPitch.value = it
        }
    }

    fun addSong(song: SongInfo) {
        Log.d(TAG, "addSong: songId=${song.songId}, songName=${song.songName}")
        songListManager.addSong(listOf(song), object : TUIRoomDefine.ActionCallback {
            override fun onSuccess() {
                Log.d(TAG, "addSong: success")
            }

            override fun onError(
                code: TUICommonDefine.Error?,
                message: String?,
            ) {
                Log.e(TAG, "addSong: error, code=${code?.value}, msg=$message")
                onKaraokeError(code?.value, message)
            }

        })
    }

    fun removeSong(song: SongInfo) {
        Log.d(TAG, "removeSong: songId=${song.songId}")
        songListManager.removeSong(listOf(song.songId), object : TUIRoomDefine.ActionCallback {
            override fun onSuccess() {
                Log.d(TAG, "removeSong: success")
            }

            override fun onError(
                code: TUICommonDefine.Error?,
                message: String?,
            ) {
                Log.e(TAG, "removeSong: error, code=${code?.value}, msg=$message")
                onKaraokeError(code?.value, message)
            }

        })
    }

    fun clearAllSongs() {
        Log.d(TAG, "clearAllSongs: queueSize=${_songQueue.value?.size}")
        val currentQueue = _songQueue.value.orEmpty()
        if (currentQueue.isEmpty()) {
            return
        }
        songListManager.removeSong( currentQueue.map { it.songId }, object : TUIRoomDefine.ActionCallback {
            override fun onSuccess() {
                Log.d(TAG, "clearAllSongs: success")
            }

            override fun onError(
                code: TUICommonDefine.Error?,
                message: String?,
            ) {
                Log.e(TAG, "clearAllSongs: error, code=${code?.value}")
                onKaraokeError(code?.value, message)
            }
        })
    }

    fun setNextSong(targetSongId: String) {
        Log.d(TAG, "setNextSong: targetSongId=$targetSongId")
        songListManager.setNextSong(targetSongId, object : TUIRoomDefine.ActionCallback {
            override fun onSuccess() {
                Log.d(TAG, "setNextSong: success")
            }

            override fun onError(
                code: TUICommonDefine.Error?,
                message: String?,
            ) {
                Log.e(TAG, "setNextSong: error, code=${code?.value}")
                onKaraokeError(code?.value, message)
            }
        })
    }

    fun playNextSong() {
        val currentQueue = _songQueue.value.orEmpty()
        Log.d(TAG, "playNextSong: called, isRoomOwner=${_isRoomOwner.value}, queueSize=${currentQueue.size}, isSwitchingToNext=$_isSwitchingToNext, currentPlaying=${_currentPlayingSong.value?.songName}")
        if (_isRoomOwner.value != true) {
            Log.d(TAG, "playNextSong: not room owner, set IDLE")
            _playbackState.value = PlaybackState.IDLE
            return
        }
        if (currentQueue.isEmpty()) {
            Log.d(TAG, "playNextSong: song queue is empty, skip playNextSong")
            _playbackState.value = PlaybackState.IDLE
            return
        }
        if (_isSwitchingToNext) {
            Log.d(TAG, "playNextSong: already switching, skip")
            return
        }
        _isSwitchingToNext = true
        Log.d(TAG, "playNextSong: start switching to next song, will remove first: ${currentQueue.firstOrNull()?.songName}")

        songListManager.playNextSong(object : TUIRoomDefine.ActionCallback {
            override fun onSuccess() {
                Log.d(TAG, "playNextSong: SDK playNextSong success")
            }

            override fun onError(
                code: TUICommonDefine.Error?,
                message: String?,
            ) {
                Log.e(TAG, "playNextSong: SDK playNextSong error: $message")
                _isSwitchingToNext = false
                onKaraokeError(code?.value, message)
            }
        })
    }

    fun setIsDisplayScoreView(isDisplay: Boolean) {
        Log.d(TAG, "setIsDisplayScoreView: isDisplay=$isDisplay")
        isAwaitingScoreDisplay = isDisplay
    }

    fun setFullScreenUIMode(isFullScreen: Boolean) {
        Log.d(TAG, "setFullScreenUIMode: isFullScreen=$isFullScreen")
        this.isFullScreenUIMode = isFullScreen
    }

    fun updatePlaybackStatus(state: PlaybackState) {
        Log.d(TAG, "updatePlaybackStatus: state=$state, currentState=${_playbackState.value}")
        if (_playbackState.value == PlaybackState.STOP) {
            _playbackState.value = state
        }
    }

    fun setScoringEnabled(enable: Boolean) {
        Log.d(TAG, "setScoringEnabled: enable=$enable")
        _enableScore.value = enable
        val metadata = hashMapOf(KEY_ENABLE_SCORE to enable.toString())
        TUIRoomEngine.sharedInstance().setRoomMetadataByAdmin(metadata, null)
    }

    fun updateSongCatalog(selectedList: List<MusicInfo>) {
        Log.d(TAG, "updateSongCatalog: count=${selectedList.size}")
        _songCatalog.value = selectedList
    }

    private fun setupChorusPlayer(roomId: String) {
        Log.d(TAG, "setupChorusPlayer: roomId=$roomId, isOwner=${_isRoomOwner.value}")
        chorusPlayer = TXChorusMusicPlayer.create(trtcCloud, roomId, chorusMusicObserver)
        val role = if (_isRoomOwner.value == true) {
            TXChorusRole.TXChorusRoleLeadSinger
        } else {
            TXChorusRole.TXChorusRoleAudience
        }
        setChorusRole(roomId, role)
    }

    private fun getWaitingList() {
        Log.d(TAG, "getWaitingList")
        val allSongsAccumulator = mutableListOf<SongInfo>()
        fetchNextPage(null, allSongsAccumulator, false)
    }

    private fun fetchWaitingListAndLoadFirst() {
        Log.d(TAG, "fetchWaitingListAndLoadFirst: clearing loadingMusicId=$_loadingMusicId")
        _loadingMusicId = null
        val allSongsAccumulator = mutableListOf<SongInfo>()
        fetchNextPage(null, allSongsAccumulator, true)
    }

    private fun fetchNextPage(cursor: String?, currentAccumulator: MutableList<SongInfo>, loadFirstAfterFetch: Boolean) {
        val count = 20
        songListManager.getWaitingList(cursor, count, object : TUISongListManager.SongListCallback {
            override fun onSuccess(result: SongListResult?) {
                if (result == null) {
                    _songQueue.value = currentAccumulator
                    if (loadFirstAfterFetch) {
                        Log.d(TAG, "fetchNextPage: fetch complete (null result), loading first song")
                        loadMusicByLeadSinger()
                    }
                    return
                }
                if (!result.songList.isNullOrEmpty()) {
                    currentAccumulator.addAll(result.songList)
                }
                val nextCursor = result.cursor
                val hasMoreData = !nextCursor.isNullOrEmpty()

                if (hasMoreData) {
                    fetchNextPage(nextCursor, currentAccumulator, loadFirstAfterFetch)
                } else {
                    Log.i(TAG, "finished fetching all songs. total count: ${currentAccumulator.size}, songs=${currentAccumulator.map { it.songName }}")
                    _songQueue.value = currentAccumulator
                    if (loadFirstAfterFetch) {
                        Log.d(TAG, "fetchNextPage: fetch complete, loading first song: ${currentAccumulator.firstOrNull()?.songName}")
                        loadMusicByLeadSinger()
                    }
                }
            }

            override fun onError(code: TUICommonDefine.Error?, msg: String?) {
                onKaraokeError(code?.value, msg)
                if (loadFirstAfterFetch) {
                    loadMusicByLeadSinger()
                }
            }
        })
    }

    private fun fetchRoomMetadata() {
        Log.d(TAG, "fetchRoomMetadata")
        TUIRoomEngine.sharedInstance().getRoomMetadata(
            listOf(KEY_ENABLE_SCORE, KEY_ENABLE_REQUEST_MUSIC), object : GetRoomMetadataCallback {
                override fun onSuccess(map: HashMap<String?, String?>?) {
                    Log.d(TAG, "fetchRoomMetadata: success, map=$map")
                    map?.let {
                        if (isRoomOwner.value == true) {
                            if (_enableScore.value == false) {
                                setScoringEnabled(true)
                            }
                        } else {
                            _enableScore.value = it[KEY_ENABLE_SCORE]?.toBoolean() ?: true
                            _isDisplayFloatView.value =
                                it[KEY_ENABLE_REQUEST_MUSIC]?.toBoolean() ?: true
                        }
                    }
                }

                override fun onError(error: TUICommonDefine.Error?, message: String) {
                    Log.e(TAG, "fetchRoomMetadata: error, code=${error?.value}, msg=$message")
                    onError(error, message)
                }
            })
    }

    private fun findSongInCatalog(musicId: String): MusicInfo? {
        return songCatalog.value?.firstOrNull { it.musicId == musicId }
    }

    private fun findSongLyricPath(musicId: String): String {
        return _songCatalog.value?.find { it.musicId == musicId }?.lyricUrl ?: ""
    }

    private fun getSongInfoById(musicId: String): SongInfo {
        val songInQueue = _songQueue.value?.find { it.songId == musicId }
        if (songInQueue != null) {
            return songInQueue
        }
        return SongInfo().apply {
            this.songId = musicId
        }
    }

    private val songListObserver: TUISongListManager.Observer =
        object : TUISongListManager.Observer() {
            override fun onWaitingListChanged(
                reason: SongListChangeReason?,
                changedSongs: MutableList<SongInfo?>?,
            ) {
                Log.d(TAG, "onWaitingListChanged: reason=$reason, changedCount=${changedSongs?.size}")
                updateSongQueue(reason, changedSongs)
                handlePlayOperation(reason, changedSongs)
            }
        }

    private fun updateSongQueue(
        reason: SongListChangeReason?,
        changedSongs: MutableList<SongInfo?>?,
    ) {
        val currentQueue = _songQueue.value.orEmpty().toMutableList()
        if (reason == null || changedSongs.isNullOrEmpty()) {
            return
        }
        Log.d(
            TAG,
            "updateSongQueue: reason=${reason.name}, changedSongs=${changedSongs.mapNotNull { it?.songName }}, currentQueue=${currentQueue.map { it.songName }}"
        )
        when (reason) {
            SongListChangeReason.ADD -> {
                changedSongs.filterNotNull().forEach { newSong ->
                    if (currentQueue.none { it.songId == newSong.songId }) {
                        currentQueue.add(newSong)
                    }
                }
                _songQueue.value = currentQueue
            }

            SongListChangeReason.REMOVE -> {
                val removeSongIds = changedSongs.filterNotNull().map { it.songId }
                val songsToRemove = currentQueue.filter { it.songId in removeSongIds }
                currentQueue.removeAll(songsToRemove)
                _songQueue.value = currentQueue
                Log.d(TAG, "updateSongQueue REMOVE: removed=${songsToRemove.map { it.songName }}, remaining=${currentQueue.map { it.songName }}")
            }

            SongListChangeReason.ORDER_CHANGED -> {
                if (_isSwitchingToNext) {
                    val songToRemove = changedSongs.filterNotNull().firstOrNull()
                    if (songToRemove != null) {
                        currentQueue.removeAll { it.songId == songToRemove.songId }
                        _songQueue.value = currentQueue
                        Log.d(TAG, "updateSongQueue ORDER_CHANGED (switching): removed ${songToRemove.songName}, remaining=${currentQueue.map { it.songName }}")
                        return
                    }
                }
                
                val songToMoveUp = changedSongs.filterNotNull().firstOrNull()
                if (songToMoveUp == null) {
                    Log.d(TAG, "updateSongQueue ORDER_CHANGED: no song to move")
                    return
                }
                
                currentQueue.removeAll { it.songId == songToMoveUp.songId }
                val targetIndex = minOf(1, currentQueue.size)
                currentQueue.add(targetIndex, songToMoveUp)
                _songQueue.value = currentQueue
                Log.d(TAG, "updateSongQueue ORDER_CHANGED: moved ${songToMoveUp.songName} to index $targetIndex, newQueue=${currentQueue.map { it.songName }}")
            }

            SongListChangeReason.UNKNOWN -> {
                val newQueue = changedSongs.filterNotNull()
                Log.d(TAG, "updateSongQueue UNKNOWN: using server queue=${newQueue.map { it.songName }}")
                _songQueue.value = newQueue
                return
            }
        }

        val currentPlayingId = _currentPlayingSong.value?.songId
        if (!currentPlayingId.isNullOrEmpty()) {
            val finalQueue = _songQueue.value.orEmpty()
            val songInNewQueue = finalQueue.find { it.songId == currentPlayingId }
            if (songInNewQueue != null) {
                _currentPlayingSong.postValue(songInNewQueue)
                Log.d(TAG, "Sync current playing info from new queue: ${songInNewQueue.songName}")
            }
        }
        Log.d(TAG, "updateSongQueue: final songQueue=${_songQueue.value?.map { it.songName }}")
    }

    private fun handlePlayOperation(
        reason: SongListChangeReason?,
        changedSongs: MutableList<SongInfo?>?,
    ) {
        if (reason == null || changedSongs.isNullOrEmpty()) {
            return
        }
        Log.d(TAG, "handlePlayOperation: reason=$reason, changedSongs=${changedSongs.mapNotNull { it?.songName }}")
        when (reason) {
            SongListChangeReason.ADD -> {
                val isNeedLoadMusic = songQueue.value?.size == changedSongs.size
                Log.d(TAG, "handlePlayOperation ADD: queueSize=${songQueue.value?.size}, changedSize=${changedSongs.size}, isNeedLoadMusic=$isNeedLoadMusic")
                if (isNeedLoadMusic) loadMusicByLeadSinger()
            }

            SongListChangeReason.REMOVE -> {
                val currentPlayingId = _currentPlayingSong.value?.songId
                val isCurrentSongAffected = changedSongs.any { it?.songId == currentPlayingId }
                Log.d(TAG, "handlePlayOperation REMOVE: currentPlayingId=$currentPlayingId, isCurrentSongAffected=$isCurrentSongAffected, isSwitchingToNext=$_isSwitchingToNext")

                if (_isRoomOwner.value == true) {
                    if (_isSwitchingToNext) {
                        Log.d(TAG, "handlePlayOperation REMOVE: switching to next, refetch queue and load first song")
                        _isCurrentSongRemoved = true
                        stopPlayback()
                        
                        fetchWaitingListAndLoadFirst()
                    } else if (isCurrentSongAffected) {
                        Log.d(TAG, "handlePlayOperation REMOVE: current song removed manually")
                        _isCurrentSongRemoved = true
                        stopPlayback()
                        loadMusicByLeadSinger()
                    }
                }
            }

            SongListChangeReason.ORDER_CHANGED -> {
                if (_isSwitchingToNext && _isRoomOwner.value == true) {
                    val currentPlayingId = _currentPlayingSong.value?.songId
                    val newQueueFirst = _songQueue.value?.firstOrNull()
                    Log.d(TAG, "handlePlayOperation ORDER_CHANGED: isSwitching=true, currentPlayingId=$currentPlayingId, newQueueFirst=${newQueueFirst?.songName}")
                    
                    if (newQueueFirst != null && newQueueFirst.songId != currentPlayingId) {
                        Log.d(TAG, "handlePlayOperation ORDER_CHANGED: switching to next, refetch queue and load first song")
                        _isCurrentSongRemoved = true
                        stopPlayback()
                        fetchWaitingListAndLoadFirst()
                    }
                }
            }
            
            SongListChangeReason.UNKNOWN -> {
                if (_isSwitchingToNext && _isRoomOwner.value == true) {
                    val currentPlayingId = _currentPlayingSong.value?.songId
                    val newQueue = changedSongs.filterNotNull()
                    val isCurrentSongStillInQueue = newQueue.any { it.songId == currentPlayingId }
                    Log.d(TAG, "handlePlayOperation UNKNOWN: isSwitching=true, currentPlayingId=$currentPlayingId, isCurrentSongStillInQueue=$isCurrentSongStillInQueue, newQueue=${newQueue.map { it.songName }}")
                    
                    if (!isCurrentSongStillInQueue || (newQueue.isNotEmpty() && newQueue.first().songId != currentPlayingId)) {
                        Log.d(TAG, "handlePlayOperation UNKNOWN: switching to next, refetch queue and load first song")
                        _isCurrentSongRemoved = true
                        stopPlayback()
                        fetchWaitingListAndLoadFirst()
                    }
                }
            }
        }
    }

    private val roomEngineObserver: TUIRoomObserver = object : TUIRoomObserver() {
        override fun onRoomDismissed(
            roomId: String?,
            reason: RoomDismissedReason?,
        ) {
            Log.d(TAG, "onRoomDismissed: roomId=$roomId, reason=$reason")
            destroy()
        }

        override fun onRoomMetadataChanged(key: String?, value: String?) {
            Log.d(TAG, "onRoomMetadataChanged: key=$key, value=$value")
            when (key) {
                KEY_ENABLE_SCORE -> {
                    _enableScore.value = value?.toBoolean() ?: true
                }

                KEY_ENABLE_REQUEST_MUSIC -> {
                    _isDisplayFloatView.value = value?.toBoolean() ?: true
                }
            }
        }
    }

    private val audioFrameListener: TRTCCloudListener.TRTCAudioFrameListener =
        object : TRTCCloudListener.TRTCAudioFrameListener {

            private var lastSentJsonData: String? = null
            private var sendCounter = 0
            val userIdKey = "u"
            val pitchKey = "p"
            val scoreKey = "s"
            val avgScoreKey = "a"

            override fun onCapturedAudioFrame(p0: TRTCCloudDef.TRTCAudioFrame?) {

            }

            override fun onLocalProcessedAudioFrame(frame: TRTCCloudDef.TRTCAudioFrame?) {
                frame ?: return

                if (_isRoomOwner.value != true || (_playbackState.value != PlaybackState.START && _playbackState.value != PlaybackState.RESUME)) {
                    lastSentJsonData = null
                    sendCounter = 0
                    return
                }

                val dataMap = mutableMapOf<String, Any>()
                dataMap[userIdKey] = userId

                _currentPitch.value?.let { pitch -> dataMap[pitchKey] = pitch }
                _currentScore.value?.let { score -> dataMap[scoreKey] = score }
                _averageScore.value?.let { avgScore -> dataMap[avgScoreKey] = avgScore }

                if (dataMap.size > 1) {
                    val currentJsonString = gson.toJson(dataMap)
                    if (currentJsonString != lastSentJsonData) {
                        lastSentJsonData = currentJsonString
                        sendCounter = 5
                    }
                }

                if (sendCounter > 0 && lastSentJsonData != null) {
                    val dataBytes = lastSentJsonData!!.toByteArray(Charsets.UTF_8)
                    frame.extraData = dataBytes
                    sendCounter--
                }
            }

            override fun onRemoteUserAudioFrame(
                frame: TRTCCloudDef.TRTCAudioFrame?,
                userId: String?,
            ) {
                frame?.extraData ?: return
                userId ?: return
                if (frame.extraData.isEmpty()) return
                if (ownerId == null) return

                try {
                    val jsonString = String(frame.extraData, Charsets.UTF_8)
                    val type = object : TypeToken<Map<String, Any>>() {}.type
                    val dataMap: Map<String, Any> = gson.fromJson(jsonString, type)

                    val itemUserId = dataMap[userIdKey] as? String
                    if (itemUserId != ownerId) {
                        return
                    }

                    (dataMap[pitchKey] as? Double)?.toInt()?.let { pitch ->
                        if (_hostPitch.value != pitch) {
                            _hostPitch.postValue(pitch)
                        }
                    }

                    (dataMap[scoreKey] as? Double)?.toInt()?.let { score ->
                        if (_hostScore.value != score) {
                            _hostScore.postValue(score)
                        }
                    }

                    (dataMap[avgScoreKey] as? Double)?.toInt()?.let { avgScore ->
                        if (_averageScore.value != avgScore) {
                            _averageScore.postValue(avgScore)
                        }
                    }

                } catch (e: Exception) {
                }
            }

            override fun onMixedPlayAudioFrame(p0: TRTCCloudDef.TRTCAudioFrame?) {
            }

            override fun onMixedAllAudioFrame(p0: TRTCCloudDef.TRTCAudioFrame?) {
            }

            override fun onVoiceEarMonitorAudioFrame(p0: TRTCCloudDef.TRTCAudioFrame?) {
            }
        }

    private val chorusMusicObserver: TXChorusMusicPlayer.ITXChorusPlayerListener =
        object : TXChorusMusicPlayer.ITXChorusPlayerListener {
            override fun onChorusMusicLoadSucceed(
                musicId: String,
                lyricList: List<TXChorusMusicPlayer.TXLyricLine>,
                pitchList: List<TXChorusMusicPlayer.TXReferencePitch>,
            ) {
                Log.d(TAG, "onChorusMusicLoadSucceed: musicId=$musicId, lyricCount=${lyricList.size}, pitchCount=${pitchList.size}, loadingMusicId=$_loadingMusicId, isSwitching=$_isSwitchingToNext, isRemoved=$_isCurrentSongRemoved")
                
                if (_isCurrentSongRemoved) {
                    Log.d(TAG, "onChorusMusicLoadSucceed: ignoring callback because current song was removed")
                    return
                }
                
                if (_loadingMusicId != null && _loadingMusicId != musicId) {
                    Log.d(TAG, "onChorusMusicLoadSucceed: ignoring stale callback, expected=$_loadingMusicId, got=$musicId")
                    return
                }
                
                val queueFirst = _songQueue.value?.firstOrNull()
                if (queueFirst != null && queueFirst.songId != musicId) {
                    Log.d(TAG, "onChorusMusicLoadSucceed: musicId mismatch with queue first, reloading. queueFirst=${queueFirst.songId}")
                    loadMusicByLeadSinger()
                    return
                }

                if (musicId.startsWith(LOCAL_MUSIC_PREFIX)) {
                    val musicPathTest = findSongLyricPath(musicId)
                    _songLyrics.value = LyricsFileReader().parseLyricInfo(musicPathTest)
                } else {
                    _songLyrics.value = lyricList
                    _pitchList.value = pitchList
                }
                _currentScore.postValue(-1)
                _averageScore.postValue(0)
                _hostPitch.postValue(0)
                _hostScore.postValue(-1)
                _currentPitch.postValue(0)
                _currentPlayingSong.postValue(getSongInfoById(musicId))
                _loadingMusicId = null
                _isCurrentSongRemoved = false
                _isSwitchingToNext = false
                startPlayback()
            }

            override fun onChorusError(error: TXChorusMusicPlayer.TXChorusError, errMsg: String) {
                Log.e(TAG, "onChorusError: error=$error, errMsg=$errMsg")
                if (error == TXChorusMusicPlayer.TXChorusError.TXChorusErrorMusicLoadFailed) {
                    val content = context.getString(R.string.karaoke_music_loading_error)
                    AtomicToast.show(context,"$content (${error.ordinal})", AtomicToast.Style.ERROR)
                    playNextSong()
                }
            }

            override fun onNetworkQualityUpdated(userId: Int, upQuality: Int, downQuality: Int) {}

            override fun onChorusRequireLoadMusic(musicId: String) {
                Log.d(TAG, "onChorusRequireLoadMusic: musicId=$musicId")
                loadMusic(musicId)
            }

            override fun onChorusMusicLoadProgress(musicId: String, progress: Float) {
                Log.d(TAG, "onChorusMusicLoadProgress: musicId=$musicId, progress=$progress")
            }

            override fun onChorusStarted() {
                Log.d(TAG, "onChorusStarted")
                _playbackState.value = PlaybackState.START
                isAwaitingScoreDisplay = true
                if (isRoomOwner.value == true) {
                    enableReverb(true)
                }
            }

            override fun onChorusPaused() {
                Log.d(TAG, "onChorusPaused: isOwner=${_isRoomOwner.value}, queueSize=${_songQueue.value?.size}")
                if (_isRoomOwner.value == false && _songQueue.value.orEmpty().isEmpty()) {
                    return
                }
                _playbackState.value = PlaybackState.PAUSE
            }

            override fun onChorusResumed() {
                Log.d(TAG, "onChorusResumed")
                _playbackState.value = PlaybackState.RESUME
            }

            override fun onChorusStopped() {
                Log.d(TAG, "onChorusStopped: isManualStop=$_isManualStop, isSwitchingToNext=$_isSwitchingToNext, isCurrentSongRemoved=$_isCurrentSongRemoved, isRoomOwner=${_isRoomOwner.value}, queueSize=${_songQueue.value?.size}, currentPlaying=${_currentPlayingSong.value?.songName}")

                if (_isManualStop) {
                    _isManualStop = false
                    _playbackState.value = PlaybackState.IDLE
                    return
                }
                if (_isCurrentSongRemoved) {
                    Log.d(TAG, "onChorusStopped: current song already removed, skip playNextSong")
                    _playbackState.value = PlaybackState.STOP
                    return
                }
                if (_isSwitchingToNext) {
                    Log.d(TAG, "onChorusStopped: switching in progress, skip playNextSong")
                    _playbackState.value = PlaybackState.STOP
                    return
                }
                if (_isRoomOwner.value == true) {
                    enableReverb(false)
                }
                _playbackState.value = PlaybackState.STOP
                val shouldDelayForScore =
                    isFullScreenUIMode && isAwaitingScoreDisplay && enableScore.value == true

                if (shouldDelayForScore) {
                    mainHandler.postDelayed({
                        _songQueue.value?.size?.let {
                            if (it <= 1) {
                                _playbackState.value = PlaybackState.IDLE
                            }
                            playNextSong()
                        }
                    }, 5000)
                } else {
                    playNextSong()
                }
            }

            override fun onMusicProgressUpdated(progressMs: Long, durationMs: Long) {
                _playbackProgressMs.value = progressMs
                _songDurationMs.value = durationMs
                if (isRoomOwner.value == false) {
                    if (isAwaitingScoreDisplay && progressMs / 1000 != durationMs / 1000) {
                        isAwaitingScoreDisplay = false
                    } else if (!isAwaitingScoreDisplay && progressMs / 1000 == durationMs / 1000) {
                        isAwaitingScoreDisplay = true
                    }
                }
            }

            override fun onVoicePitchUpdated(pitch: Int, hasVoice: Boolean, progressMs: Long) {
                _currentPitch.value = if (pitch == -1) 0 else pitch
            }

            override fun onVoiceScoreUpdated(
                currentScore: Int,
                averageScore: Int,
                currentLine: Int,
            ) {
                Log.d(TAG, "onVoiceScoreUpdated: current=$currentScore, avg=$averageScore, line=$currentLine")
                _currentScore.value = currentScore
                _averageScore.value = averageScore
            }

            override fun shouldDecryptAudioData(audioData: ByteBuffer) {

            }
        }

    private fun applyDefaultAudioEffects() {
        Log.d(TAG, "applyDefaultAudioEffects")
        enableDsp()
        enableHIFI()
        enableAIECModel2()
        enableAIEC()
        enableAI()
    }

    private fun callTRTCExperimentalApi(api: String, params: Map<String, Any>) {
        val json = gson.toJson(mapOf("api" to api, "params" to params))
        trtcCloud.callExperimentalAPI(json)
    }

    private fun enableDsp() {
        val params = mapOf(
            "configs" to listOf(
                mapOf(
                    "key" to "Liteav.Audio.common.dsp.version", "value" to "2", "default" to "1"
                )
            )
        )
        callTRTCExperimentalApi("setPrivateConfig", params)
    }

    private fun enableHIFI() {
        val params = mapOf(
            "configs" to listOf(
                mapOf(
                    "key" to "Liteav.Audio.common.smart.3a.strategy.flag",
                    "value" to "16",
                    "default" to "1"
                )
            )
        )
        callTRTCExperimentalApi("setPrivateConfig", params)
    }

    private fun enableAIECModel2() {
        val params = mapOf(
            "configs" to listOf(
                mapOf(
                    "key" to "Liteav.Audio.common.ai.ec.model.type",
                    "value" to "2",
                    "default" to "2"
                )
            )
        )
        callTRTCExperimentalApi("setPrivateConfig", params)
    }

    private fun enableAIEC() {
        val params = mapOf(
            "configs" to listOf(
                mapOf(
                    "key" to "Liteav.Audio.common.enable.ai.ec.module",
                    "value" to "1",
                    "default" to "1"
                )
            )
        )
        callTRTCExperimentalApi("setPrivateConfig", params)
    }

    private fun enableAI() {
        val params = mapOf(
            "configs" to listOf(
                mapOf(
                    "key" to "Liteav.Audio.common.ai.module.enabled",
                    "value" to "1",
                    "default" to "1"
                )
            )
        )
        callTRTCExperimentalApi("setPrivateConfig", params)
    }

    private fun enableReverb(enable: Boolean) {
        Log.d(TAG, "enableReverb: enable=$enable")
        val params = mapOf(
            "enable" to enable,
            "RoomSize" to 60,
            "PreDelay" to 20,
            "Reverberance" to 40,
            "Damping" to 50,
            "ToneLow" to 30,
            "ToneHigh" to 100,
            "WetGain" to -3,
            "DryGain" to 0,
            "StereoWidth" to 40,
            "WetOnly" to false
        )
        callTRTCExperimentalApi("setCustomReverbParams", params)
    }


    private fun copyAllAssetsToStorage() {
        val assetFiles = listOf(
            "nuannuan_bz.mp3", "nuannuan_yc.mp3", "nuannuan_lrc.vtt"
        )
        assetFiles.forEach { copyAssetToFile(it) }
    }

    private fun copyAssetToFile(assetName: String) {
        val savePath = ContextCompat.getExternalFilesDirs(context, null)[0].absolutePath
        val destinationFile = File(savePath, assetName)
        if (destinationFile.exists()) return
        try {
            destinationFile.parentFile?.mkdirs()
            context.assets.open(assetName).use { inputStream ->
                FileOutputStream(destinationFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun onKaraokeError(code: Int?, desc: String?) {
        val errorCode = code ?: -1
        val errorMessage = desc ?: "Unknown error"
        Log.e(TAG, "errorCode: $errorCode, errorMessage: $errorMessage")

        mainHandler.post {
            val frequencyLimit = -2
            if (errorCode == frequencyLimit) {
                val content = context.getString(R.string.common_client_error_freq_limit)
                AtomicToast.show(context,"$content (${errorCode})", AtomicToast.Style.ERROR)
            } else {
                AtomicToast.show(context,"$errorMessage ($errorCode)", AtomicToast.Style.ERROR)
            }
        }
    }
}