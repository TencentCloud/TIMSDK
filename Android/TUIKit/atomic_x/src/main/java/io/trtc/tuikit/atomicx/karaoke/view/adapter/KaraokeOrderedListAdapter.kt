package io.trtc.tuikit.atomicx.karaoke.view.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore
import io.trtc.tuikit.atomicx.karaoke.store.utils.PlaybackState
import io.trtc.tuikit.atomicx.karaoke.view.adapter.KaraokeOrderedListAdapter.SongViewHolder
import com.trtc.tuikit.common.imageloader.ImageLoader
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.widget.basicwidget.avatar.AtomicAvatar

class KaraokeOrderedListAdapter(private val store: KaraokeStore) :
    ListAdapter<TUISongListManager.SongInfo, SongViewHolder>(DIFF) {
    companion object {
        val DIFF = object : DiffUtil.ItemCallback<TUISongListManager.SongInfo>() {
            override fun areItemsTheSame(
                oldItem: TUISongListManager.SongInfo,
                newItem: TUISongListManager.SongInfo,
            ): Boolean {
                return oldItem == newItem
            }

            override fun areContentsTheSame(
                oldItem: TUISongListManager.SongInfo,
                newItem: TUISongListManager.SongInfo,
            ): Boolean {
                return false
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SongViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.karaoke_music_requested_item, parent, false)
        return SongViewHolder(view)
    }

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) {
        holder.bind(getItem(position), position)
    }

    inner class SongViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val imagePlaying: ImageView = itemView.findViewById(R.id.iv_playing)
        private val textOrderIndex: TextView = itemView.findViewById(R.id.tv_order_index)
        private val imageCover: ImageView = itemView.findViewById(R.id.iv_cover)
        private val textSongName: TextView = itemView.findViewById(R.id.tv_song_name)
        private val imageRequesterAvatar: AtomicAvatar =
            itemView.findViewById(R.id.iv_user_avatar)
        private val textRequesterName: TextView = itemView.findViewById(R.id.tv_requester_name)
        private val imagePause: ImageView = itemView.findViewById(R.id.iv_pause)
        private val imageNext: ImageView = itemView.findViewById(R.id.iv_next)
        private val imagePin: ImageView = itemView.findViewById(R.id.iv_pin)
        private val imageDelete: ImageView = itemView.findViewById(R.id.iv_delete)

        fun bind(song: TUISongListManager.SongInfo, position: Int) {
            textSongName.text = song.songName
            initMusicPositionView(position)
            initPlayingPauseView(position)
            initPlayingNextView(position)
            initMusicDeleteView(song, position)
            initMusicPinView(song, position)
            initOrderName(song)
            initAvatarView(song)
            initMusicCover(song)
            initFunctionVisible()
        }

        private fun initOrderName(song: TUISongListManager.SongInfo) {
            if (song.songName.isEmpty()) {
                textRequesterName.text = song.requester.userId
            } else {
                textRequesterName.text = song.requester.userName
            }
        }

        private fun initAvatarView(song: TUISongListManager.SongInfo) {
            imageRequesterAvatar.setContent(
                AtomicAvatar.AvatarContent.URL(
                    song.requester.avatarUrl,
                    R.drawable.karaoke_song_cover
                )
            )
        }

        private fun initMusicCover(music: TUISongListManager.SongInfo) {
            ImageLoader.load(
                imageCover.context,
                imageCover,
                music.coverUrl,
                R.drawable.karaoke_song_cover
            )
        }

        private fun initMusicPositionView(position: Int) {
            imagePlaying.visibility = if (position == 0) VISIBLE else GONE
            textOrderIndex.visibility = if (position == 0) GONE else VISIBLE
            textOrderIndex.text = (position + 1).toString()
        }

        private fun initPlayingPauseView(position: Int) {
            if (position == 0) {
                imagePause.visibility = VISIBLE
                val isPlaying = (store.playbackState.value != PlaybackState.STOP &&
                        store.playbackState.value != PlaybackState.PAUSE)
                imagePause.setImageResource(
                    if (isPlaying) R.drawable.karaoke_music_resume else R.drawable.karaoke_music_pause
                )
                imagePause.setOnClickListener {
                    val newIsPlaying =  (store.playbackState.value != PlaybackState.STOP &&
                            store.playbackState.value != PlaybackState.PAUSE)
                    if (newIsPlaying) {
                        store.pausePlayback()
                        imagePause.setImageResource(R.drawable.karaoke_music_pause)
                    } else {
                        store.resumePlayback()
                        imagePause.setImageResource(R.drawable.karaoke_music_resume)
                    }
                }
            } else {
                imagePause.visibility = GONE
                imagePause.setOnClickListener(null)
            }
        }

        private fun initPlayingNextView(position: Int) {
            imageNext.visibility = if (0 == position) VISIBLE else GONE
            imageNext.setOnClickListener {
                store.playNextSong()
                store.setIsDisplayScoreView(false)
            }
        }

        private fun initMusicDeleteView(music: TUISongListManager.SongInfo, position: Int) {
            imageDelete.visibility = if (0 != position) VISIBLE else GONE
            imageDelete.setOnClickListener {
                store.removeSong(music)
            }
        }

        private fun initMusicPinView(song: TUISongListManager.SongInfo, position: Int) {
            imagePin.visibility = if (position > 1) VISIBLE else GONE
            imagePin.setOnClickListener {
                store.setNextSong(song.songId)
            }
        }

        private fun initFunctionVisible() {
            if (store.isRoomOwner.value == false) {
                imagePause.visibility = GONE
                imageNext.visibility = GONE
                imagePin.visibility = GONE
                imageDelete.visibility = GONE
            }
        }
    }
}