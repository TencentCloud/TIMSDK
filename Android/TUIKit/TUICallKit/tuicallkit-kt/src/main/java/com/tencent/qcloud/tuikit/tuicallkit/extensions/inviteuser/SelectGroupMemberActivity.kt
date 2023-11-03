package com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.WindowManager
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager

class SelectGroupMemberActivity : AppCompatActivity() {
    private var recyclerUserList: RecyclerView? = null
    private var groupId: String? = null
    private val groupMemberList: MutableList<GroupMemberInfo> = ArrayList()
    private var alreadySelectList: List<String?> = ArrayList()
    private var adapter: SelectGroupMemberAdapter? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.tuicallkit_activity_group_user)
        activity = this
        initStatusBar()
        initView()
        initData()
    }

    private fun initView() {
        val toolbar = findViewById<Toolbar>(R.id.toolbar_group)
        toolbar.navigationIcon?.isAutoMirrored = true
        toolbar.setNavigationOnClickListener { v: View? -> finish() }
        val btnOK = findViewById<Button>(R.id.btn_group_ok)
        btnOK.setOnClickListener { v: View? ->
            if (adapter != null) {
                val selectUsers: MutableList<String?> = ArrayList()
                for (info in groupMemberList) {
                    if (info != null && !TextUtils.isEmpty(info.userId) && info.isSelected
                        && !alreadySelectList.contains(info.userId)
                    ) {
                        selectUsers.add(info.userId)
                    }
                }
                if (selectUsers.isNotEmpty()) {
                    EngineManager.instance.inviteUser(selectUsers)
                }
            }
            finish()
        }
        recyclerUserList = findViewById(R.id.rv_user_list)
    }

    private fun initData() {
        val intent = intent
        groupId = intent.getStringExtra(Constants.GROUP_ID)
        alreadySelectList = ArrayList(intent.getStringArrayListExtra(Constants.SELECT_MEMBER_LIST))
        adapter = SelectGroupMemberAdapter()
        recyclerUserList!!.layoutManager = LinearLayoutManager(applicationContext)
        recyclerUserList!!.adapter = adapter
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
                        userInfo.isSelected = alreadySelectList?.contains(userInfo.userId) == true
                        groupMemberList.add(userInfo)
                    }
                    if (adapter != null) {
                        adapter!!.setDataSource(groupMemberList)
                        adapter!!.notifyDataSetChanged()
                    }
                }
            })
    }

    private fun initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val window = window
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.statusBarColor = Color.TRANSPARENT
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        }
    }

    companion object {
        private var activity: AppCompatActivity? = null
        fun finishActivity() {
            if (activity == null || activity!!.isFinishing) {
                return
            }
            activity!!.finish()
            activity = null
        }
    }
}