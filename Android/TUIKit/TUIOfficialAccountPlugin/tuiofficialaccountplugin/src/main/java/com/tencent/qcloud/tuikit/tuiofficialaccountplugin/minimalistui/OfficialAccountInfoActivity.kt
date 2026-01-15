package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.cardview.widget.CardView
import com.bumptech.glide.Glide
import com.tencent.imsdk.v2.V2TIMConversation
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistTitleBar
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout.Position
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.R
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces.IOfficialAccountInfoView
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.presenter.OfficialAccountInfoPresenter
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog
import java.text.SimpleDateFormat
import java.util.*

class OfficialAccountInfoActivity : BaseMinimalistLightActivity(), IOfficialAccountInfoView {

    companion object {
        private const val TAG = "OfficialAccountInfoActivity"
        private const val EXTRA_OFFICIAL_ACCOUNT_ID = "official_account_id"

        fun start(context: Context, officialAccountId: String) {
            val intent = Intent(context, OfficialAccountInfoActivity::class.java)
            intent.putExtra(EXTRA_OFFICIAL_ACCOUNT_ID, officialAccountId)
            context.startActivity(intent)
        }

    }

    private lateinit var titleBar: MinimalistTitleBar
    private lateinit var avatarImage: AppCompatImageView
    private lateinit var nameText: AppCompatTextView
    private lateinit var fansText: AppCompatTextView
    private lateinit var followButton: CardView
    private lateinit var followButtonIcon: AppCompatImageView
    private lateinit var followButtonText: AppCompatTextView
    private lateinit var messageButton: CardView
    private lateinit var messageButtonText: AppCompatTextView
    private lateinit var introductionText: AppCompatTextView
    private lateinit var dateText: AppCompatTextView

    private var officialAccountId: String? = null
    private lateinit var presenter: OfficialAccountInfoPresenter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_official_account_info)

        initViews()
        initPresenter()
        initData()
        setupListeners()
        loadOfficialAccountInfo()
    }
    
    private fun initPresenter() {
        presenter = OfficialAccountInfoPresenter()
        presenter.setView(this)
    }

    private fun initViews() {
        titleBar = findViewById(R.id.official_account_title_bar)
        avatarImage = findViewById(R.id.iv_avatar)
        nameText = findViewById(R.id.tv_name)
        fansText = findViewById(R.id.tv_fans)
        followButton = findViewById(R.id.cv_follow)
        followButtonIcon = findViewById(R.id.iv_follow_icon)
        followButtonText = findViewById(R.id.tv_follow)
        messageButton = findViewById(R.id.cv_message)
        messageButtonText = findViewById(R.id.tv_message)
        introductionText = findViewById(R.id.tv_introduction)
        dateText = findViewById(R.id.tv_date)

        messageButton.visibility = View.GONE
        titleBar.setTitle(getString(R.string.official_account_official_channel), Position.MIDDLE)
    }

    private fun initData() {
        officialAccountId = intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID)
            ?: intent.getStringExtra(EXTRA_OFFICIAL_ACCOUNT_ID)
    }

    private fun setupListeners() {
        followButton.setOnClickListener {
            officialAccountId?.let { id ->
                if (presenter.isCurrentlySubscribed()) {
                    presenter.unsubscribeOfficialAccount(id)
                } else {
                    presenter.subscribeOfficialAccount(id)
                }
            }
        }

        messageButton.setOnClickListener {
            openChatPage()
        }
    }

    private fun loadOfficialAccountInfo() {
        officialAccountId?.let { id ->
            presenter.loadOfficialAccountInfo(id)
        }
    }
    
    override fun onOfficialAccountInfoLoaded(info: OfficialAccountInfo) {
        runOnUiThread {
            updateUI(info)
        }
    }

    override fun onLoadFailed(code: Int, desc: String?) {
        TUIOfficialAccountLog.e(TAG, "Load official account info failed, code:$code, desc:$desc")
        ToastUtil.toastShortMessage(getString(R.string.official_account_load_official_account_info_failed))
    }
    
    override fun onSubscriptionStatusChanged(isSubscribed: Boolean) {
        runOnUiThread {
            updateFollowButton(isSubscribed)
        }
    }
    
    override fun onSubscriptionFailed(code: Int, desc: String?) {
        TUIOfficialAccountLog.e(TAG, "Subscription operation failed, code:$code, desc:$desc")
    }

    private fun updateUI(info: OfficialAccountInfo) {
        Glide.with(this)
            .load(info.faceUrl)
            .placeholder(R.drawable.official_account_default_avatar)
            .into(avatarImage)

        nameText.text = info.name
        fansText.text = getString(R.string.official_account_channel_fans_count, formatNumber(info.subscriberNum))

        introductionText.text = info.introduction
        dateText.text = formatDate(info.createTime)
    }

    private fun updateFollowButton(isFollowing: Boolean) {
        if (isFollowing) {
            followButtonIcon.setImageResource(R.drawable.official_account_following_icon)
            followButtonText.text = getString(R.string.official_account_following)
            messageButton.visibility = View.VISIBLE
        } else {
            followButtonIcon.setImageResource(R.drawable.official_account_follow_icon)
            followButtonText.text = getString(R.string.official_account_follow)
            messageButton.visibility = View.GONE
        }
    }

    private fun openChatPage() {
        officialAccountId?.let { id ->
            val bundle = Bundle()
            bundle.putString(TUIConstants.TUIChat.CHAT_ID, id)
            bundle.putInt(TUIConstants.TUIChat.CHAT_TYPE, V2TIMConversation.V2TIM_C2C)
            TUICore.startActivity("TUIC2CChatMinimalistActivity", bundle)
        }
    }

    private fun formatNumber(number: Long): String {
        return when {
            number >= 1000000 -> String.format("%.1fM", number / 1000000.0)
            number >= 1000 -> String.format("%.1fK", number / 1000.0)
            else -> number.toString()
        }
    }

    private fun formatDate(timestamp: Long): String {
        val date = Date(timestamp * 1000)
        val formatter = SimpleDateFormat("yyyy/M/d", Locale.getDefault())
        return formatter.format(date)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        presenter.onDestroy()
    }
}
