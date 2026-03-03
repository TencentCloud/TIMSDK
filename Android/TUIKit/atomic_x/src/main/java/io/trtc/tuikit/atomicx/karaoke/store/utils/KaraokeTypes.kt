package io.trtc.tuikit.atomicx.karaoke.store.utils

enum class PlaybackState {
    IDLE, START, PAUSE, RESUME, STOP
}

data class MusicInfo(
    var musicId: String = "",
    var musicName: String = "",
    var artist: String = "",
    var lyricUrl: String = "",
    var originalUrl: String = "",
    var accompanyUrl: String = "",
    var coverUrl: String = "",
    var duration: Int = 0,
)

enum class LyricAlign {
    RIGHT,
    CENTER
}
