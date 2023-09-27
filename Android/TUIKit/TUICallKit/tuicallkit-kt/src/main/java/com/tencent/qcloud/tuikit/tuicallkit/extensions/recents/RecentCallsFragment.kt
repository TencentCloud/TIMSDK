package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents

import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.tabs.TabLayout
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.RecentCallsFilter
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit.Companion.createInstance
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces.ICallRecordItemListener
import com.tencent.qcloud.tuikit.tuicallkit.view.common.SlideRecyclerView

class RecentCallsFragment : Fragment {
    private lateinit var rootView: View
    private lateinit var buttonEdit: Button
    private lateinit var buttonStartCall: Button
    private lateinit var buttonEditDone: Button
    private lateinit var buttonClear: Button
    private lateinit var layoutTab: TabLayout
    private lateinit var recyclerRecent: SlideRecyclerView
    private lateinit var layoutTitle: ConstraintLayout
    private lateinit var listAdapter: RecentCallsListAdapter
    private lateinit var viewModel: RecentCallsViewModel
    private var bottomSheetDialog: BottomSheetDialog? = null
    private var chatViewStyle = RecentCalls.UI_STYLE_MINIMALIST
    private var type = TYPE_ALL

    constructor() {}
    constructor(style: String) {
        chatViewStyle = style
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        rootView = inflater.inflate(R.layout.tuicallkit_record_fragment_main, container, false)
        initView()
        initData()
        initListener()
        return rootView
    }

    override fun onResume() {
        super.onResume()
        refreshData()
    }

    private fun initView() {
        buttonEdit = rootView.findViewById(R.id.btn_call_edit)
        buttonStartCall = rootView.findViewById(R.id.btn_start_call)
        buttonEditDone = rootView.findViewById(R.id.btn_edit_done)
        buttonClear = rootView.findViewById(R.id.btn_clear)
        layoutTab = rootView.findViewById(R.id.tab_layout)
        recyclerRecent = rootView.findViewById(R.id.recycle_view_list)
        layoutTitle = rootView.findViewById(R.id.cl_record_title)
        if (RecentCalls.UI_STYLE_MINIMALIST == chatViewStyle) {
            layoutTitle?.setBackgroundColor(resources.getColor(R.color.tuicalling_color_white))
        }
    }

    private fun initData() {
        listAdapter = RecentCallsListAdapter()
        listAdapter.setHasStableIds(true)
        recyclerRecent.layoutManager = LinearLayoutManager(context)
        recyclerRecent.adapter = listAdapter
        setAdapterListener()
        viewModel = ViewModelProvider(requireActivity()).get(RecentCallsViewModel::class.java)
        viewModel.callHistoryList.observe(requireActivity()) { recordList: List<CallRecords>? ->
            if (listAdapter != null && TYPE_ALL == type) {
                listAdapter.onDataSourceChanged(recordList)
            }
        }
        viewModel.callMissedList.observe(requireActivity()) { recordList: List<CallRecords>? ->
            if (listAdapter != null && TYPE_MISS == type) {
                listAdapter.onDataSourceChanged(recordList)
            }
        }
        if (viewModel != null) {
            viewModel.queryRecentCalls(filter)
        }
    }

    private val filter: RecentCallsFilter
        private get() {
            val filter = RecentCallsFilter()
            if (TYPE_MISS == type) {
                filter.result = CallRecords.Result.Missed
            }
            return filter
        }

    private fun initListener() {
        buttonEdit.setOnClickListener { v: View? ->
            startMultiSelect()
            updateTabViews(true)
        }
        buttonStartCall.setOnClickListener { v: View? ->
            TUICore.startActivity(
                "StartC2CChatMinimalistActivity",
                null
            )
        }
        buttonEditDone.setOnClickListener { v: View? ->
            stopMultiSelect()
            updateTabViews(false)
        }
        buttonClear.setOnClickListener { v: View? -> showDeleteHistoryDialog() }
        layoutTab.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                type = if (tab.position == 1) TYPE_MISS else TYPE_ALL
                updateTabViews(false)
                stopMultiSelect()
                refreshData()
            }

            override fun onTabUnselected(tab: TabLayout.Tab) {}
            override fun onTabReselected(tab: TabLayout.Tab) {}
        })
    }

    private fun refreshData() {
        if (viewModel != null) {
            viewModel.queryRecentCalls(filter)
        }
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
                if (callRecords.scene == TUICallDefine.Scene.GROUP_CALL) {
                    startGroupInfoActivity(callRecords)
                    ToastUtil.toastLongMessage(getString(R.string.tuicallkit_group_recall_unsupport))
                    return
                }
                if (TUICallDefine.Role.Caller == callRecords.role) {
                    createInstance(context!!).call(callRecords.inviteList[0], callRecords.mediaType)
                } else {
                    createInstance(context!!).call(callRecords.inviter, callRecords.mediaType)
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
                if (TUICallDefine.Scene.SINGLE_CALL == records.scene) {
                    startFriendProfileActivity(records)
                } else if (TUICallDefine.Scene.GROUP_CALL == records.scene) {
                    startGroupInfoActivity(records)
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
            adapter.setShowMultiSelectCheckBox(false)
            adapter.notifyDataSetChanged()
        }
        recyclerRecent.disableRecyclerViewSlide(false)
        recyclerRecent.closeMenu()
    }

    private fun deleteRecordCalls(selectItem: List<CallRecords>) {
        if (viewModel != null) {
            viewModel.deleteRecordCalls(selectItem)
        }
        stopMultiSelect()
    }

    private fun clearRecentCalls() {
        var selectedItems: List<CallRecords?>? = ArrayList()
        if (listAdapter != null) {
            selectedItems = listAdapter.selectedItem
        }
        if (selectedItems == null) {
            return
        }
        val recordList: MutableList<CallRecords> = ArrayList()
        for (records in selectedItems) {
            if (records != null && !TextUtils.isEmpty(records.callId)) {
                recordList.add(records)
            }
        }
        if (viewModel != null) {
            viewModel.deleteRecordCalls(recordList)
        }
    }

    private fun showDeleteHistoryDialog() {
        if (bottomSheetDialog == null) {
            bottomSheetDialog = BottomSheetDialog(requireContext(), R.style.TUICallBottomSelectSheet)
        }
        bottomSheetDialog?.setContentView(R.layout.tuicallkit_record_dialog)
        bottomSheetDialog?.setCanceledOnTouchOutside(false)
        val textPositive = bottomSheetDialog?.findViewById<TextView>(R.id.tv_clear_call_history)
        val textCancel = bottomSheetDialog?.findViewById<TextView>(R.id.tv_clear_cancel)
        textPositive?.setOnClickListener { v: View? ->
            clearRecentCalls()
            bottomSheetDialog?.dismiss()
            stopMultiSelect()
        }
        textCancel?.setOnClickListener { v: View? -> bottomSheetDialog?.dismiss() }
        bottomSheetDialog?.show()
    }

    companion object {
        const val TYPE_ALL = "AllCall"
        const val TYPE_MISS = "MissedCall"
    }
}