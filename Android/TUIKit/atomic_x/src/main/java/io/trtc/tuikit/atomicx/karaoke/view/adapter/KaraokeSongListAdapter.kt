package io.trtc.tuikit.atomicx.karaoke.view.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.View.GONE
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine
import com.trtc.tuikit.common.imageloader.ImageLoader
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore
import io.trtc.tuikit.atomicx.karaoke.store.utils.MusicInfo

class KaraokeSongListAdapter(private val store: KaraokeStore) :
    ListAdapter<MusicInfo, KaraokeSongListAdapter.SongViewHolder>(DIFF) {
    companion object {
        val DIFF = object : DiffUtil.ItemCallback<MusicInfo>() {
            override fun areItemsTheSame(oldItem: MusicInfo, newItem: MusicInfo): Boolean {
                return oldItem == newItem
            }

            override fun areContentsTheSame(oldItem: MusicInfo, newItem: MusicInfo): Boolean {
                return false
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SongViewHolder {
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.karaoke_music_library_item, parent, false)
        return SongViewHolder(view)
    }

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class SongViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val imageCover: ImageView = itemView.findViewById(R.id.iv_cover)
        private val textSongName: TextView = itemView.findViewById(R.id.tv_song_name)
        private val textSinger: TextView = itemView.findViewById(R.id.tv_singer)
        private val buttonRequestSong: Button = itemView.findViewById(R.id.btn_request_music)

        fun bind(music: MusicInfo) {
            textSongName.text = music.musicName
            textSinger.text = music.artist
            initRequestSongButton(music)
            initMusicCover(music)
            initFunctionVisible()
        }

        private fun initMusicCover(music: MusicInfo) {
            ImageLoader.load(
                imageCover.context,
                imageCover,
                music.coverUrl,
                R.drawable.karaoke_song_cover
            )
        }

        private fun initRequestSongButton(music: MusicInfo) {
            val isOrdered = store.songQueue.value?.any { it.songId == music.musicId } == true
            if (isOrdered) {
                buttonRequestSong.apply {
                    background =
                        ContextCompat.getDrawable(context, R.drawable.karaoke_btn_grey_edge_bg)
                    text = context.getString(R.string.karaoke_ordered)
                    isEnabled = false
                    setOnClickListener(null)
                }
            } else {
                buttonRequestSong.apply {
                    background = ContextCompat.getDrawable(context, R.drawable.karaoke_btn_blue_bg)
                    text = context.getString(R.string.karaoke_order_song)
                    isEnabled = true
                    setOnClickListener {
                        val selfInfo: TUIRoomDefine.LoginUserInfo = TUIRoomEngine.getSelfInfo()
                        val songInfo : TUISongListManager.SongInfo = TUISongListManager.SongInfo()
                        songInfo.songId = music.musicId
                        songInfo.songName = music.musicName
                        songInfo.artistName = music.artist
                        songInfo.duration = music.duration
                        songInfo.coverUrl = music.coverUrl
                        songInfo.requester.userId = selfInfo.userId
                        songInfo.requester.userName = selfInfo.userName
                        songInfo.requester.avatarUrl = selfInfo.avatarUrl
                        store.addSong(songInfo)
                    }
                }
            }
        }

        private fun initFunctionVisible() {
            if (store.isRoomOwner.value == false) {
                buttonRequestSong.visibility = GONE
            }
        }
    }
}