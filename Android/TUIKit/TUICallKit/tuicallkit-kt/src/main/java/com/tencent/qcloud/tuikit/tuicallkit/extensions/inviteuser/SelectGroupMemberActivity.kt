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
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants

class SelectGroupMemberActivity : AppCompatActivity() {
    private var mRecyclerUserList: RecyclerView? = null
    private var mGroupId: String? = null
    private val mGroupMemberList: MutableList<GroupMemberInfo> = ArrayList()
    private var mAlreadySelectList: List<String?> = ArrayList()
    private var mAdapter: SelectGroupMemberAdapter? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.tuicallkit_activity_group_user)
        mActivity = this
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
            if (mAdapter != null) {
                val selectUsers: MutableList<String?> = ArrayList()
                for (info in mGroupMemberList) {
                    if (info != null && !TextUtils.isEmpty(info.userId) && info.isSelected) {
                        selectUsers.add(info.userId)
                    }
                }
                val map: MutableMap<String, Any> = HashMap()
                map[Constants.SELECT_MEMBER_LIST] = selectUsers
                TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_GROUP_MEMBER_SELECTED, map)
            }
            finish()
        }
        mRecyclerUserList = findViewById(R.id.rv_user_list)
    }

    private fun initData() {
        val intent = intent
        mGroupId = intent.getStringExtra(Constants.GROUP_ID)
        mAlreadySelectList = ArrayList(intent.getStringArrayListExtra(Constants.SELECT_MEMBER_LIST))
        mAdapter = SelectGroupMemberAdapter()
        mRecyclerUserList!!.layoutManager = LinearLayoutManager(applicationContext)
        mRecyclerUserList!!.adapter = mAdapter
        updateGroupUserList()
    }

    private fun updateGroupUserList() {
        val filter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL
        V2TIMManager.getGroupManager().getGroupMemberList(mGroupId, filter, 0,
            object : V2TIMValueCallback<V2TIMGroupMemberInfoResult?> {
                override fun onError(errorCode: Int, errorMsg: String) {}
                override fun onSuccess(v2TIMGroupMemberInfoResult: V2TIMGroupMemberInfoResult?) {
                    val results = v2TIMGroupMemberInfoResult?.memberInfoList
                    mGroupMemberList.clear()
                    if (results == null) {
                        return
                    }
                    for (info in results) {
                        val userInfo = GroupMemberInfo()
                        userInfo.userId = info.userID
                        userInfo.avatar = info.faceUrl
                        userInfo.userName = info.nickName
                        userInfo.isSelected = mAlreadySelectList?.contains(userInfo.userId) == true
                        mGroupMemberList.add(userInfo)
                    }
                    if (mAdapter != null) {
                        mAdapter!!.setDataSource(mGroupMemberList)
                        mAdapter!!.notifyDataSetChanged()
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
        private var mActivity: AppCompatActivity? = null
        fun finishActivity() {
            if (mActivity == null || mActivity!!.isFinishing) {
                return
            }
            mActivity!!.finish()
            mActivity = null
        }
    }
}