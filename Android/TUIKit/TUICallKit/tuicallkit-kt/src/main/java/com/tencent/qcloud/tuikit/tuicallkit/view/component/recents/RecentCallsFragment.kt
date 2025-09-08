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
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.CallRecords
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.RecentCallsFilter
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.recents.interfaces.ICallRecordItemListener
import com.trtc.tuikit.common.livedata.LiveListObserver
import com.trtc.tuikit.common.ui.PopupDialog
import com.trtc.tuikit.common.util.ToastUtil

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

    private val callHistoryObserver = object : LiveListObserver<CallRecords>() {
        override fun onDataChanged(list: List<CallRecords>) {
            if (listAdapter != null && TYPE_ALL == type) {
                listAdapter.onDataSourceChanged(list)
            }
        }
    }
    private val callMissObserver = object : LiveListObserver<CallRecords>() {
        override fun onDataChanged(list: List<CallRecords>) {
            if (listAdapter != null && TYPE_MISS == type) {
                listAdapter.onDataSourceChanged(list)
            }
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
    }

    private fun unregisterObserver() {
        recentCallsManager.callMissedList.removeObserver(callMissObserver)
        recentCallsManager.callHistoryList.removeObserver(callHistoryObserver)
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
            layoutTitle.setBackgroundColor(ContextCompat.getColor(context!!, R.color.tuicallkit_color_white))
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
        recentCallsManager = RecentCallsManager(requireContext())
        recentCallsManager.queryRecentCalls(filter)
    }

    private val filter: RecentCallsFilter
        private get() {
            val filter = RecentCallsFilter()
            if (TYPE_MISS == type) {
                filter.result = CallRecords.Result.Missed
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
            override fun onItemClick(view: View?, viewType: Int, callRecords: CallRecords?) {
                if (callRecords == null) {
                    return
                }
                if (listAdapter.isMultiSelectMode) {
                    return
                }
                if (!callRecords.groupId.isNullOrEmpty()) {
                    startGroupInfoActivity(callRecords)
                    ToastUtil.toastLongMessage(getString(R.string.tuicallkit_group_recall_unsupport))
                    return
                }
                if (GlobalState.instance.enableForceUseV2API) {
                    var user = callRecords.inviter
                    if (TUICallDefine.Role.Caller == callRecords.role) {
                        user = callRecords.inviteList[0]
                    }
                    TUICallKit.createInstance(context!!).call(user, callRecords.mediaType)
                } else {
                    val userList = ArrayList<String>()
                    userList.add(callRecords.inviter)
                    userList.addAll(callRecords.inviteList)
                    userList.remove(TUILogin.getLoginUser())

                    TUICallKit.createInstance(context!!).calls(userList, callRecords.mediaType, null, null)
                }
            }

            override fun onItemDeleteClick(view: View?, viewType: Int, callRecords: CallRecords?) {
                if (callRecords == null) {
                    return
                }
                val list: MutableList<CallRecords> = ArrayList()
                list.add(callRecords)
                deleteRecordCalls(list)
            }

            override fun onDetailViewClick(view: View?, records: CallRecords?) {
                if (records == null) {
                    return
                }
                if (!records.groupId.isNullOrEmpty()) {
                    startGroupInfoActivity(records)
                    return
                }

                if (records.inviteList.size <= 1) {
                    startFriendProfileActivity(records)
                }
            }
        })
    }

    private fun startFriendProfileActivity(records: CallRecords) {
        val bundle = Bundle()
        if (TUICallDefine.Role.Caller == records.role) {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, records.inviteList[0])
        } else {
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, records.inviter)
        }
        var activityName = "FriendProfileActivity"
        if (RecentCalls.UI_STYLE_MINIMALIST == chatViewStyle) {
            activityName = "FriendProfileMinimalistActivity"
        }
        TUICore.startActivity(activityName, bundle)
    }

    private fun startGroupInfoActivity(records: CallRecords) {
        val bundle = Bundle()
        bundle.putString("group_id", records.groupId)
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

    private fun deleteRecordCalls(selectItem: List<CallRecords>) {
        recentCallsManager.deleteRecordCalls(selectItem)
        needCloseMultiMode = !listAdapter.isMultiSelectMode
        stopMultiSelect()
    }

    private fun clearRecentCalls() {
        val selectedItems: List<CallRecords?>?
        selectedItems = listAdapter.selectedItem
        if (selectedItems == null) {
            return
        }
        val recordList: MutableList<CallRecords> = ArrayList()
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
        private const val TYPE_ALL = "AllCall"
        private const val TYPE_MISS = "MissedCall"
    }
}