package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents

import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.tabs.TabLayout
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import com.tencent.qcloud.tuikit.tuicallkit.view.component.recents.interfaces.ICallRecordItemListener
import com.trtc.tuikit.common.livedata.LiveListObserver
import com.trtc.tuikit.common.ui.PopupDialog
import com.trtc.tuikit.common.util.ToastUtil
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import io.trtc.tuikit.atomicxcore.api.call.CallDirection
import io.trtc.tuikit.atomicxcore.api.call.CallEndReason
import io.trtc.tuikit.atomicxcore.api.call.CallInfo
import io.trtc.tuikit.atomicxcore.api.call.CallListener
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallStore

class RecentCallsFragment(style: String) : Fragment() {
    private lateinit var buttonEdit: Button
    private lateinit var buttonStartCall: Button
    private lateinit var buttonEditDone: Button
    private lateinit var buttonClear: Button
    private lateinit var recyclerRecent: SlideRecyclerView
    private lateinit var listAdapter: RecentCallsListAdapter
    private lateinit var recentCallsManager: RecentCallsManager
    private var bottomDialog: PopupDialog? = null

    private var chatViewStyle = style
    private var type = TYPE_ALL
    private var needCloseMultiMode = false

    constructor() : this(style = RecentCalls.UI_STYLE_CLASSIC)

    private val callHistoryObserver = object : LiveListObserver<CallInfo>() {
        override fun onDataChanged(list: List<CallInfo>) {
            if (listAdapter != null && TYPE_ALL == type) {
                listAdapter.onDataSourceChanged(list)
            }
        }
    }
    private val callMissObserver = object : LiveListObserver<CallInfo>() {
        override fun onDataChanged(list: List<CallInfo>) {
            if (listAdapter != null && TYPE_MISS == type) {
                listAdapter.onDataSourceChanged(list)
            }
        }
    }

    private val callObserver: CallListener = object : CallListener() {
        override fun onCallEnded(callId: String, mediaType: CallMediaType, reason: CallEndReason, userId: String) {
            refreshData()
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val rootView = inflater.inflate(R.layout.tuicallkit_record_fragment_main, container, false)
        initView(rootView)
        initData()
        registerObserver()
        return rootView
    }

    override fun onResume() {
        super.onResume()
        refreshData()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        unregisterObserver()
    }

    private fun registerObserver() {
        recentCallsManager.callMissedList.observe(callMissObserver)
        recentCallsManager.callHistoryList.observe(callHistoryObserver)
        CallStore.shared.addListener(callObserver)
    }

    private fun unregisterObserver() {
        recentCallsManager.callMissedList.removeObserver(callMissObserver)
        recentCallsManager.callHistoryList.removeObserver(callHistoryObserver)
        CallStore.shared.removeListener(callObserver)
    }

    private fun initView(rootView: View) {
        buttonEdit = rootView.findViewById(R.id.btn_call_edit)
        buttonStartCall = rootView.findViewById(R.id.btn_start_call)
        buttonEditDone = rootView.findViewById(R.id.btn_edit_done)
        buttonClear = rootView.findViewById(R.id.btn_clear)
        recyclerRecent = rootView.findViewById(R.id.recycle_view_list)
        val layoutTab: TabLayout = rootView.findViewById(R.id.tab_layout)
        val layoutTitle: ConstraintLayout = rootView.findViewById(R.id.cl_record_title)
        if (RecentCalls.UI_STYLE_MINIMALIST == chatViewStyle) {
            layoutTitle.setBackgroundColor(ContextCompat.getColor(context!!, R.color.callkit_color_white))
        }

        buttonEdit.setOnClickListener {
            startMultiSelect()
            updateTabViews(true)
        }
        buttonStartCall.setOnClickListener {
            TUICore.startActivity("StartC2CChatMinimalistActivity", null)
        }
        buttonEditDone.setOnClickListener {
            needCloseMultiMode = true
            stopMultiSelect()
            updateTabViews(false)
        }
        buttonClear.setOnClickListener { v: View? -> showDeleteHistoryDialog() }
        layoutTab.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                type = if (tab.position == 1) TYPE_MISS else TYPE_ALL
                updateTabViews(false)
                needCloseMultiMode = true
                stopMultiSelect()
                refreshData()
            }

            override fun onTabUnselected(tab: TabLayout.Tab) {}
            override fun onTabReselected(tab: TabLayout.Tab) {}
        })
    }

    private fun initData() {
        listAdapter = RecentCallsListAdapter()
        listAdapter.setHasStableIds(true)
        recyclerRecent.layoutManager = LinearLayoutManager(context)
        recyclerRecent.adapter = listAdapter
        setAdapterListener()
        recentCallsManager = RecentCallsManager()
        recentCallsManager.queryRecentCalls(filter)
    }

    private val filter: CallInfo
        private get() {
            val filter = CallInfo()
            if (TYPE_MISS == type) {
                filter.result = CallDirection.Missed
            }
            return filter
        }

    private fun refreshData() {
        recentCallsManager.queryRecentCalls(filter)
    }

    private fun updateTabViews(isEditable: Boolean) {
        if (isEditable) {
            buttonEdit.visibility = View.GONE
            buttonStartCall.visibility = View.GONE
            buttonEditDone.visibility = View.VISIBLE
            buttonClear.visibility = View.VISIBLE
        } else {
            buttonEdit.visibility = View.VISIBLE
            buttonStartCall.visibility = View.GONE
            buttonEditDone.visibility = View.GONE
            buttonClear.visibility = View.GONE
        }
    }

    private fun setAdapterListener() {
        listAdapter.setOnCallRecordItemListener(object : ICallRecordItemListener {
            override fun onItemClick(view: View?, viewType: Int, callInfo: CallInfo?) {
                if (callInfo == null) {
                    return
                }
                if (listAdapter.isMultiSelectMode) {
                    return
                }
                if (callInfo.chatGroupId.isNotEmpty() || callInfo.inviteeIds.size > 1) {
                    context?.let {
                        AtomicToast.show(it, it.getString(R.string.callkit_group_recall_unsupport) , AtomicToast.Style.ERROR)
                    }
                    return
                }
                var mediaType = CallMediaType.Audio
                if (callInfo.mediaType == CallMediaType.Video) {
                    mediaType = CallMediaType.Video
                }

                val userList = ArrayList<String>()
                userList.add(callInfo.inviterId)
                userList.addAll(callInfo.inviteeIds)
                userList.remove(TUILogin.getLoginUser())
                TUICallKit.createInstance(context!!).calls(userList, mediaType, null, null)

            }

            override fun onItemDeleteClick(view: View?, viewType: Int, callInfo: CallInfo?) {
                if (callInfo == null) {
                    return
                }
                val list: MutableList<CallInfo> = ArrayList()
                list.add(callInfo)
                deleteRecordCalls(list)
            }

            override fun onDetailViewClick(view: View?, callInfo: CallInfo?) {
                if (callInfo == null) {
                    return
                }
                if (!callInfo.chatGroupId.isNullOrEmpty()) {
                    startGroupInfoActivity(callInfo)
                    return
                }

                if (callInfo.inviteeIds.size <= 1) {
                    startFriendProfileActivity(callInfo)
                }
            }
        })
    }

    private fun startFriendProfileActivity(callInfo: CallInfo) {
        val bundle = Bundle()
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        if (callInfo.inviterId == selfId) {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, callInfo.inviteeIds.first())
        } else {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, callInfo.inviterId)
        }
        var activityName = "FriendProfileActivity"
        if (RecentCalls.UI_STYLE_MINIMALIST == chatViewStyle) {
            activityName = "FriendProfileMinimalistActivity"
        }
        TUICore.startActivity(activityName, bundle)
    }

    private fun startGroupInfoActivity(callInfo: CallInfo) {
        val bundle = Bundle()
        bundle.putString("group_id", callInfo.chatGroupId)
        var activityName = "GroupInfoActivity"
        if (RecentCalls.UI_STYLE_MINIMALIST == chatViewStyle) {
            activityName = "GroupInfoMinimalistActivity"
        }
        TUICore.startActivity(context, activityName, bundle)
    }

    private fun startMultiSelect() {
        val adapter = recyclerRecent.adapter as RecentCallsListAdapter?
        if (adapter != null) {
            adapter.setShowMultiSelectCheckBox(true)
            adapter.notifyDataSetChanged()
        }
        recyclerRecent.disableRecyclerViewSlide(true)
        recyclerRecent.closeMenu()
    }

    private fun stopMultiSelect() {
        val adapter = recyclerRecent.adapter as RecentCallsListAdapter?
        if (adapter != null) {
            if (needCloseMultiMode) {
                adapter.setShowMultiSelectCheckBox(false)
            }
            adapter.notifyDataSetChanged()
        }
        if (needCloseMultiMode) {
            recyclerRecent.disableRecyclerViewSlide(false)
        }
        recyclerRecent.closeMenu()
    }

    private fun deleteRecordCalls(selectItem: List<CallInfo>) {
        recentCallsManager.deleteRecordCalls(selectItem)
        needCloseMultiMode = !listAdapter.isMultiSelectMode
        stopMultiSelect()
    }

    private fun clearRecentCalls() {
        val selectedItems: List<CallInfo?>?
        selectedItems = listAdapter.selectedItem
        if (selectedItems == null) {
            return
        }
        val recordList: MutableList<CallInfo> = ArrayList()
        for (records in selectedItems) {
            if (records != null && !TextUtils.isEmpty(records.callId)) {
                recordList.add(records)
            }
        }
        recentCallsManager.deleteRecordCalls(recordList)
    }

    private fun showDeleteHistoryDialog() {
        if (bottomDialog == null) {
            bottomDialog = PopupDialog(requireContext())
        }
        val view = LayoutInflater.from(activity).inflate(R.layout.tuicallkit_record_dialog, null)
        bottomDialog!!.setView(view)
        val textPositive = view.findViewById<TextView>(R.id.tv_clear_call_history)
        val textCancel = view.findViewById<TextView>(R.id.tv_clear_cancel)
        textPositive?.setOnClickListener {
            clearRecentCalls()
            bottomDialog?.dismiss()
            needCloseMultiMode = true
            stopMultiSelect()
        }
        textCancel?.setOnClickListener { v: View? -> bottomDialog?.dismiss() }
        bottomDialog?.show()
    }

    companion object {
        private const val TAG = "RecentCallsFragment"
        private const val TYPE_ALL = "AllCall"
        private const val TYPE_MISS = "MissedCall"
    }
}