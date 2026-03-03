package io.trtc.tuikit.atomicx.karaoke.store

abstract class MusicCatalogService {
    abstract fun getSongList(callback: GetSongListCallBack)
    abstract fun generateUserSig(userId: String, callback: ActionCallback)
    open fun queryPlayToken(musicId: String, userId: String, callback: QueryPlayTokenCallBack) {}
}