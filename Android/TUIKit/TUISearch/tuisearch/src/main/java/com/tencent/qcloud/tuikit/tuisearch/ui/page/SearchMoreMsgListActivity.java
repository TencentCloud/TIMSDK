package com.tencent.qcloud.tuikit.tuisearch.ui.page;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;

import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.model.SearchDataProvider;
import com.tencent.qcloud.tuikit.tuisearch.presenter.SearchMoreMsgPresenter;
import com.tencent.qcloud.tuikit.tuisearch.ui.view.SearchMoreMsgAdapter;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.ui.view.PageRecycleView;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;

import java.util.ArrayList;
import java.util.List;

public class SearchMoreMsgListActivity extends BaseLightActivity {
    private static final String TAG = SearchMoreMsgListActivity.class.getSimpleName();
    /**
     * 搜索框
     */
    private EditText mEdtSearch;
    /**
     * 删除按钮
     */
    private ImageView mImgvDelete;
    private TextView mCancleView;
    /**
     * recyclerview
     */
    private PageRecycleView mMessageRcSearch;
    /**
     * 全部匹配的适配器
     */
    private SearchMoreMsgAdapter mMessageRcSearchAdapter;

    private RelativeLayout mMessageLayout;

    private String mKeyWords;
    private String mConversationId;
    private boolean mIsGroup;
    private SearchDataBean mSearchDataBean;
    private int pageIndex = 0;

    private SearchMoreMsgPresenter presenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search_more_msg_activity);
        init();
    }

    private void init(){
        initView();

        if (mMessageRcSearchAdapter == null) {
            mMessageRcSearchAdapter = new SearchMoreMsgAdapter(this);
            mMessageRcSearch.setAdapter(mMessageRcSearchAdapter);
        }

        initPresenter();

        Intent intent = getIntent();
        if (intent != null) {
            mKeyWords = intent.getStringExtra(TUISearchConstants.SEARCH_KEY_WORDS);
            mSearchDataBean = intent.getParcelableExtra(TUISearchConstants.SEARCH_DATA_BEAN);
            pageIndex = 0;

            mMessageRcSearchAdapter.setSearchDataBean(mSearchDataBean);
            if (mSearchDataBean != null) {
                mIsGroup = mSearchDataBean.isGroup();
                if (mIsGroup) {
                    mConversationId = TUISearchUtils.getConversationIdByUserId(mSearchDataBean.getGroupID(), true);
                } else {
                    mConversationId = TUISearchUtils.getConversationIdByUserId(mSearchDataBean.getUserID(), false);
                }
            }

            initData(mKeyWords);
            mEdtSearch.setText(mKeyWords);
            doChangeColor(mKeyWords);
        }
        setListener();
    }

    private void initPresenter() {
        presenter = new SearchMoreMsgPresenter();
        presenter.setAdapter(mMessageRcSearchAdapter);
    }

    /**
     * 设置监听
     */
    private void setListener() {
        //edittext的监听
        mEdtSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            //每次edittext内容改变时执行 控制删除按钮的显示隐藏
            @Override
            public void afterTextChanged(Editable editable) {
                if (editable.length() == 0) {
                    mImgvDelete.setVisibility(View.GONE);
                } else {
                    mImgvDelete.setVisibility(View.VISIBLE);
                }
                mKeyWords = editable.toString().trim();
                pageIndex = 0;
                mMessageRcSearch.setNestedScrollingEnabled(true);
                initData(mKeyWords);
                //匹配文字 变色
                doChangeColor(mKeyWords);
            }
        });
        mCancleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });
        //recyclerview的点击监听
        if (mMessageRcSearchAdapter != null) {
            mMessageRcSearchAdapter.setOnItemClickListener(new SearchMoreMsgAdapter.onItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mSearchDataBean == null) {
                        TUISearchLog.e(TAG, "mSearchDataBean == null");
                        return;
                    }
                    List<SearchDataBean> searchDataBeans = mMessageRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        SearchDataBean searchDataBean = searchDataBeans.get(pos);
                        ChatInfo chatInfo = presenter.generateChatInfo(searchDataBean);

                        TUISearchUtils.startChatActivity(chatInfo);
                    }
                }
            });
        }

        mMessageRcSearchAdapter.setOnConversationClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mSearchDataBean == null) {
                    TUISearchLog.e(TAG, "mSearchDataBean == null");
                    return;
                }
                ChatInfo chatInfo = new ChatInfo();
                if (mSearchDataBean.isGroup()) {
                    chatInfo.setType(ChatInfo.TYPE_GROUP);
                    chatInfo.setId(mSearchDataBean.getGroupID());
                    chatInfo.setGroupType(mSearchDataBean.getGroupType());
                } else {
                    chatInfo.setType(ChatInfo.TYPE_C2C);
                    chatInfo.setId(mSearchDataBean.getUserID());
                }
                String chatName = mSearchDataBean.getUserID();
                if (!TextUtils.isEmpty(mSearchDataBean.getRemark())) {
                    chatName = mSearchDataBean.getRemark();
                } else if (!TextUtils.isEmpty(mSearchDataBean.getNickName())) {
                    chatName = mSearchDataBean.getNickName();
                }
                chatInfo.setChatName(chatName);
                TUISearchUtils.startChatActivity(chatInfo);

            }
        });

        mMessageRcSearch.setLoadMoreMessageHandler(new PageRecycleView.OnLoadMoreHandler() {
            @Override
            public void loadMore() {
                final List<String> keywordList = new ArrayList<String>() {{
                    add(mKeyWords);
                }};

                presenter.searchMessage(keywordList, mConversationId, ++pageIndex, new IUIKitCallback<List<SearchDataBean>>() {
                    @Override
                    public void onSuccess(List<SearchDataBean> data) {
                        if (data.isEmpty() && pageIndex == 0) {
                            mMessageRcSearchAdapter.setConversationVisible(false);
                            mMessageLayout.setVisibility(View.GONE);
                        } else {
                            mMessageRcSearchAdapter.setConversationVisible(true);
                            mMessageLayout.setVisibility(View.VISIBLE);
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        mMessageRcSearchAdapter.setConversationVisible(false);
                        mMessageLayout.setVisibility(View.GONE);
                    }
                });
            }

            @Override
            public boolean isListEnd(int position) {
                if (mMessageRcSearchAdapter == null || mMessageRcSearchAdapter.getTotalCount() == 0) {
                    return true;
                }

                int totalCount = mMessageRcSearchAdapter.getTotalCount();
                int totalPage = (totalCount % SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE == 0) ?
                        (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE) : (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE + 1);
                if (pageIndex < totalPage) {
                    return false;
                }

                return true;
            }
        });
        //删除按钮的监听
        mImgvDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mEdtSearch.setText("");
                mMessageLayout.setVisibility(View.GONE);
            }
        });
    }

    /**
     * 字体匹配方法
     */
    private void doChangeColor(String text) {
        if (text.equals("")) {
            mMessageRcSearchAdapter.setText(null);
        } else {
            //设置要变色的关键字
            mMessageRcSearchAdapter.setText(text);
        }
    }

    private void initData(final String keyWords) {
        if (keyWords == null || TextUtils.isEmpty(keyWords)){
            mMessageLayout.setVisibility(View.GONE);
            return;
        }

        final List<String> keywordList = new ArrayList<String>() {{
            add(keyWords);
        }};

        presenter.searchMessage(keywordList, mConversationId, pageIndex, new IUIKitCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> data) {
                if (data.isEmpty() && pageIndex == 0) {
                    mMessageRcSearchAdapter.setConversationVisible(false);
                    mMessageLayout.setVisibility(View.GONE);
                } else {
                    mMessageRcSearchAdapter.setConversationVisible(true);
                    mMessageLayout.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mMessageRcSearchAdapter.setConversationVisible(false);
                mMessageLayout.setVisibility(View.GONE);
            }
        });
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        mMessageRcSearch = (PageRecycleView) findViewById(R.id.message_rc_search);
        mCancleView = (TextView) findViewById(R.id.cancel_button);
        mMessageRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mMessageLayout = (RelativeLayout) findViewById(R.id.message_layout);
    }
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            // 获得当前得到焦点的View，一般情况下就是EditText（特殊情况就是轨迹求或者实体案件会移动焦点）
            View v = getCurrentFocus();
            if (isShouldHideInput(v, ev)) {
                hideSoftInput(v.getWindowToken());
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    /**
     * 根据EditText所在坐标和用户点击的坐标相对比，来判断是否隐藏键盘，因为当用户点击EditText时没必要隐藏
     *
     * @param v
     * @param event
     * @return
     */
    private boolean isShouldHideInput(View v, MotionEvent event) {
        if (v != null && (v instanceof EditText)) {
            int[] l = {0, 0};
            v.getLocationInWindow(l);
            int left = l[0], top = l[1], bottom = top + v.getHeight(), right = left
                    + v.getWidth();
            if (event.getX() > left && event.getX() < right && event.getY() > top && event.getY() < bottom) {
                // 点击EditText的事件，忽略它。
                return false;
            } else {
                return true;
            }
        }
        // 如果焦点不是EditText则忽略，这个发生在视图刚绘制完，第一个焦点不在EditView上，和用户用轨迹球选择其他的焦点
        return false;
    }

    /**
     * 多种隐藏软件盘方法的其中一种
     *
     * @param token
     */
    private void hideSoftInput(IBinder token) {
        if (token != null) {
            InputMethodManager im = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            im.hideSoftInputFromWindow(token, InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
}
