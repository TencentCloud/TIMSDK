package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui

import android.os.Bundle
import androidx.appcompat.widget.AppCompatTextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistTitleBar
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout.Position
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.R
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces.IOfficialAccountListView
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.adapter.OfficialAccountListAdapter
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.adapter.OfficialAccountSectionItem
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.presenter.OfficialAccountListPresenter
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog

class OfficialAccountListActivity : BaseMinimalistLightActivity(), IOfficialAccountListView {

    companion object {
        private const val TAG = "OfficialAccountListActivity"
    }

    private lateinit var titleBar: MinimalistTitleBar
    private lateinit var titleText: AppCompatTextView
    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: OfficialAccountListAdapter
    private lateinit var presenter: OfficialAccountListPresenter
    
    private var isInitialLoad = true
    private var subscribedAccountsLoaded = false
    private var allAccountsLoaded = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_official_account_list)

        initViews()
        initPresenter()
        setupRecyclerView()
        loadData()
    }

    private fun initViews() {
        titleBar = findViewById(R.id.official_account_list_title_bar)
        recyclerView = findViewById(R.id.recycler_view)

        titleBar.setTitle(getString(R.string.official_account_official_channel), Position.MIDDLE)
    }
    
    private fun initPresenter() {
        presenter = OfficialAccountListPresenter()
        presenter.setView(this)
    }

    private fun setupRecyclerView() {
        adapter = OfficialAccountListAdapter { accountInfo, actionType ->
            when (actionType) {
                OfficialAccountListAdapter.ACTION_CLICK -> {
                    OfficialAccountInfoActivity.start(this, accountInfo.officialAccount)
                }
                OfficialAccountListAdapter.ACTION_FOLLOW -> {
                    handleFollowAction(accountInfo)
                }
            }
        }
        
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter
        
        recyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                
                if (dy > 0) {
                    val layoutManager = recyclerView.layoutManager as? LinearLayoutManager
                    layoutManager?.let {
                        val visibleItemCount = it.childCount
                        val totalItemCount = it.itemCount
                        val firstVisibleItemPosition = it.findFirstVisibleItemPosition()
                        
                        if (!presenter.isLoadingData() && presenter.hasMoreData()) {
                            if (visibleItemCount + firstVisibleItemPosition >= totalItemCount - 5) {
                                TUIOfficialAccountLog.i(TAG, "Loading more official accounts...")
                                presenter.loadMoreOfficialAccounts()
                            }
                        }
                    }
                }
            }
        })
    }

    private fun loadData() {
        presenter.loadSubscribedOfficialAccounts()
        presenter.loadOfficialAccounts()
    }
    
    override fun onSubscribedAccountsChanged() {
        runOnUiThread {
            if (isInitialLoad) {
                subscribedAccountsLoaded = true
            }
            refreshDisplayList()
        }
    }
    
    override fun onAllAccountsChanged() {
        runOnUiThread {
            if (isInitialLoad) {
                allAccountsLoaded = true
            }
            refreshDisplayList()
        }
    }
    
    override fun onLoadFailed(code: Int, desc: String?) {
        TUIOfficialAccountLog.e(TAG, "Load official accounts failed, code:$code, desc:$desc")
    }
    
    override fun onSubscribeSuccess(officialAccountId: String) {
        TUIOfficialAccountLog.i(TAG, "Subscribe success: $officialAccountId")
    }
    
    override fun onSubscribeFailed(officialAccountId: String, code: Int, desc: String?) {
        TUIOfficialAccountLog.e(TAG, "Subscribe failed, code:$code, desc:$desc")
    }
    
    override fun onUnsubscribeSuccess(officialAccountId: String) {
        TUIOfficialAccountLog.i(TAG, "Unsubscribe success: $officialAccountId")
    }
    
    override fun onUnsubscribeFailed(officialAccountId: String, code: Int, desc: String?) {
        TUIOfficialAccountLog.e(TAG, "Unsubscribe failed, code:$code, desc:$desc")
    }
    
    override fun onLastMessageUpdated(officialAccountId: String, lastMessage: String?) {
        runOnUiThread {
            TUIOfficialAccountLog.i(TAG, "Last message updated for: $officialAccountId")
            refreshDisplayList()
        }
    }
    
    private fun refreshDisplayList() {
        val sectionItems = mutableListOf<OfficialAccountSectionItem>()
        val currentUserId = presenter.getCurrentUserId()
        
        val subscribedAccounts = presenter.getSubscribedAccountsList()
        val myCreations = subscribedAccounts.filter { it.ownerAccount == currentUserId }
        val myFollowings = subscribedAccounts.filter { it.ownerAccount != currentUserId }
        
        if (myCreations.isNotEmpty()) {
            sectionItems.add(OfficialAccountSectionItem.SectionHeader(getString(R.string.official_account_my_creations)))
            myCreations.forEach { account ->
                val lastMessage = presenter.getLastMessageForAccount(account.officialAccount)
                sectionItems.add(OfficialAccountSectionItem.AccountItem(account, false, lastMessage))
            }
        }
        
        if (myFollowings.isNotEmpty()) {
            sectionItems.add(OfficialAccountSectionItem.SectionHeader(getString(R.string.official_account_my_followings)))
            myFollowings.forEach { account ->
                val lastMessage = presenter.getLastMessageForAccount(account.officialAccount)
                sectionItems.add(OfficialAccountSectionItem.AccountItem(account, true, lastMessage))
            }
        }
        
        val unsubscribedAccounts = presenter.getAllAccountsList()
        if (unsubscribedAccounts.isNotEmpty()) {
            sectionItems.add(OfficialAccountSectionItem.SectionHeader(getString(R.string.official_account_find_official_channels)))
            unsubscribedAccounts.forEach { account ->
                sectionItems.add(OfficialAccountSectionItem.RecommendationItem(account))
            }
        }
        
        val shouldScrollToTop = isInitialLoad && subscribedAccountsLoaded && allAccountsLoaded
        
        if (sectionItems.isEmpty()) {
            adapter.submitList(emptyList()) {
                handleInitialLoadComplete(shouldScrollToTop)
            }
        } else {
            adapter.submitList(sectionItems) {
                handleInitialLoadComplete(shouldScrollToTop)
            }
        }
    }
    
    private fun handleInitialLoadComplete(shouldScrollToTop: Boolean) {
        if (shouldScrollToTop) {
            recyclerView.scrollToPosition(0)
            isInitialLoad = false
            TUIOfficialAccountLog.i(TAG, "Initial load completed, scrolled to top")
        }
    }

    private fun handleFollowAction(accountInfo: OfficialAccountInfo) {
        val subscribedAccountIds = presenter.getSubscribedAccountsList().map { it.officialAccount }.toSet()
        if (subscribedAccountIds.contains(accountInfo.officialAccount)) {
            presenter.unsubscribeOfficialAccount(accountInfo.officialAccount)
        } else {
            presenter.subscribeOfficialAccount(accountInfo.officialAccount)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        presenter.onDestroy()
    }
}
