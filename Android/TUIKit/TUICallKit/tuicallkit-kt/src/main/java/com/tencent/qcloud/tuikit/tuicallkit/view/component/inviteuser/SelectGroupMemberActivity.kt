package com.tencent.qcloud.tuikit.tuicallkit.view.component.inviteuser

import android.os.Bundle
import android.widget.Button
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.FullScreenActivity
import com.trtc.tuikit.common.livedata.Observer

class SelectGroupMemberActivity : FullScreenActivity() {
    private lateinit var recyclerUserList: RecyclerView
    private lateinit var adapter: SelectGroupMemberAdapter
    private var groupId: String? = null
    private val groupMemberList: MutableList<GroupMemberInfo> = ArrayList()
    private var alreadySelectList: List<String?> = ArrayList()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.tuicallkit_activity_group_user)
        initView()
        initData()
        registerObserver()
    }

    private fun initView() {
        val toolbar = findViewById<Toolbar>(R.id.toolbar_group)
        toolbar.navigationIcon?.isAutoMirrored = true
        toolbar.setNavigationOnClickListener {
            finish()
        }
        val btnOK: Button = findViewById(R.id.btn_group_ok)
        btnOK.setOnClickListener {
            val selectUsers: MutableList<String?> = ArrayList()
            for (info in groupMemberList) {
                if (!info.userId.isNullOrEmpty() && info.isSelected && !alreadySelectList.contains(info.userId)) {
                    selectUsers.add(info.userId)
                }
            }
            if (selectUsers.isNotEmpty()) {
                CallManager.instance.inviteUser(selectUsers, null)
            }
            finish()
        }
        recyclerUserList = findViewById(R.id.rv_user_list)
    }

    private fun initData() {
        groupId = intent.getStringExtra("groupId")
        alreadySelectList = ArrayList(intent.getStringArrayListExtra("selectMemberList"))
        adapter = SelectGroupMemberAdapter()
        recyclerUserList.layoutManager = LinearLayoutManager(applicationContext)
        recyclerUserList.adapter = adapter
        updateGroupUserList()
    }

    private fun updateGroupUserList() {
        val filter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL
        V2TIMManager.getGroupManager().getGroupMemberList(groupId, filter, 0,
            object : V2TIMValueCallback<V2TIMGroupMemberInfoResult?> {
                override fun onError(errorCode: Int, errorMsg: String) {}
                override fun onSuccess(v2TIMGroupMemberInfoResult: V2TIMGroupMemberInfoResult?) {
                    val results = v2TIMGroupMemberInfoResult?.memberInfoList
                    groupMemberList.clear()
                    if (results == null) {
                        return
                    }
                    for (info in results) {
                        val userInfo = GroupMemberInfo()
                        userInfo.userId = info.userID
                        userInfo.avatar = info.faceUrl
                        userInfo.userName = info.nickName
                        userInfo.isSelected = alreadySelectList.contains(userInfo.userId)
                        groupMemberList.add(userInfo)
                    }
                    adapter.setDataSource(groupMemberList)
                    adapter.notifyDataSetChanged()
                }
            })
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterObserver()
    }
}