package io.trtc.tuikit.atomicx.karaoke.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.View.GONE
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener
import com.tencent.cloud.tuikit.engine.extension.TUISongListManager
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore
import io.trtc.tuikit.atomicx.karaoke.store.utils.MusicInfo
import io.trtc.tuikit.atomicx.karaoke.view.adapter.KaraokeOrderedListAdapter
import io.trtc.tuikit.atomicx.karaoke.view.adapter.KaraokeSongListAdapter
import io.trtc.tuikit.atomicx.widget.basicwidget.popover.AtomicPopover

class SongRequestPanel(
    context: Context,
    private val store: KaraokeStore,
    private val isDisplayExitView: Boolean,
) : AtomicPopover(context) {
    private lateinit var recyclerSongBrowserView: RecyclerView
    private lateinit var recyclerOrderedListView: RecyclerView
    private var orderedTabView: TextView? = null
    private val adapterSongList = KaraokeSongListAdapter(store)
    private val adapterOrderedList = KaraokeOrderedListAdapter(store)
    private val songSelectedListObserver = Observer(this::songSelectedListChange)
    private val roomDismissedObserver = Observer(this::roomDismissedChange)
    private val songLibraryListObserver = Observer(this::songLibraryListChange)

    init {
        initView()
    }

    private fun initView() {
        val view: View =
            LayoutInflater.from(context).inflate(R.layout.karaoke_song_request_panel, null)

        setPanelHeight(PanelHeight.Ratio(0.6F))
        initTabLayout(view)
        initExitView(view)
        initSongBrowserView(view)
        initQueueManagerView(view)
        configDialogHeight(view)
        setContent(view)
    }

    private fun addObserve() {
        store.songCatalog.observeForever(songLibraryListObserver)
        store.songQueue.observeForever(songSelectedListObserver)
        store.isRoomDismissed.observeForever(roomDismissedObserver)
    }

    private fun removeObserve() {
        store.songCatalog.removeObserver(songLibraryListObserver)
        store.songQueue.removeObserver(songSelectedListObserver)
        store.isRoomDismissed.removeObserver(roomDismissedObserver)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        addObserve()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        removeObserve()
    }

    private fun songLibraryListChange(list: List<MusicInfo>) {
        adapterSongList.submitList(list.toList())
    }

    private fun songSelectedListChange(list: List<TUISongListManager.SongInfo>) {
        orderedTabView?.text = context.getString(R.string.karaoke_ordered_count, list.size)
        adapterOrderedList.submitList(list.toList())
        store.updateSongCatalog(adapterSongList.currentList)
        adapterSongList.submitList(adapterSongList.currentList)
        triggerSongListRefresh()
    }

    private fun triggerSongListRefresh() {
        val currentList = adapterSongList.currentList
        adapterSongList.submitList(currentList.toList())
    }

    private fun roomDismissedChange(isRoomDismissed: Boolean) {
        if (isRoomDismissed && this.isShowing) {
            hide()
        }
    }

    private fun initSongBrowserView(view: View) {
        recyclerSongBrowserView = view.findViewById(R.id.rv_song_browser_list)
        recyclerSongBrowserView.layoutManager = LinearLayoutManager(context)
        recyclerSongBrowserView.adapter = adapterSongList
        recyclerSongBrowserView.visibility = View.VISIBLE
    }

    private fun initQueueManagerView(view: View) {
        recyclerOrderedListView = view.findViewById(R.id.rv_ordered_list)
        recyclerOrderedListView.layoutManager = LinearLayoutManager(context)
        recyclerOrderedListView.adapter = adapterOrderedList
        recyclerOrderedListView.visibility = GONE
    }

    private fun initExitView(view: View) {
        val exitView: FrameLayout = view.findViewById(R.id.fl_exit_request)
        if (store.isRoomOwner.value == false || !isDisplayExitView) {
            exitView.visibility = GONE
        }
        exitView.setOnClickListener {
            super.hide()
            store.enableRequestMusic(false)
        }
    }

    override fun show() {
        super.show()
        if (store.isDisplayFloatView.value == false) {
            store.enableRequestMusic(true)
        }
    }

    private fun initTabLayout(view: View) {
        val tabLayout = view.findViewById<TabLayout>(R.id.tab)
        tabLayout.removeAllTabs()
        val tabTitles = listOf(
            R.string.karaoke_order_song,
            R.string.karaoke_ordered_count
        )
        val tabColors = listOf(
            R.color.karaoke_color_white,
            R.color.karaoke_text_color_grey_4d
        )

        tabTitles.forEachIndexed { index, titleRes ->
            tabLayout.addTab(createTab(view, titleRes, tabColors[index], index), index == 0)
        }

        tabLayout.addOnTabSelectedListener(object : OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                setTabTextColor(tab, R.color.karaoke_color_white)
                when (tab.position) {
                    0 -> {
                        recyclerSongBrowserView.visibility = View.VISIBLE
                        recyclerOrderedListView.visibility = GONE
                    }

                    1 -> {
                        recyclerSongBrowserView.visibility = GONE
                        recyclerOrderedListView.visibility = View.VISIBLE
                    }
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab) {
                setTabTextColor(tab, R.color.karaoke_text_color_grey_4d)

            }

            override fun onTabReselected(tab: TabLayout.Tab) {}
        })
    }

    private fun createTab(view: View, titleRes: Int, textColorRes: Int, index: Int): TabLayout.Tab {
        val context = view.context
        val tabView =
            LayoutInflater.from(context).inflate(R.layout.karaoke_tab_item, null) as TextView
        tabView.text = context.getString(titleRes)
        tabView.setTextColor(ContextCompat.getColor(context, textColorRes))
        if (index == 1) {
            orderedTabView = tabView
        }
        return (view.findViewById<TabLayout>(R.id.tab)).newTab().setCustomView(tabView)
    }

    private fun setTabTextColor(tab: TabLayout.Tab, colorRes: Int) {
        val tabView = tab.customView as? TextView ?: return
        tabView.setTextColor(ContextCompat.getColor(tabView.context, colorRes))
    }

    private fun configDialogHeight(view: View) {
        view.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            (context.resources.displayMetrics.heightPixels * 0.6).toInt()
        )
    }
}