package com.tencent.qcloud.tuikit.tuisearch.classicui.page;

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
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.classicui.util.ClassicSearchUtils;
import com.tencent.qcloud.tuikit.tuisearch.classicui.widget.PageRecycleView;
import com.tencent.qcloud.tuikit.tuisearch.classicui.widget.SearchMoreMsgAdapter;
import com.tencent.qcloud.tuikit.tuisearch.model.SearchDataProvider;
import com.tencent.qcloud.tuikit.tuisearch.presenter.SearchMoreMsgPresenter;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;
import java.util.ArrayList;
import java.util.List;

public class SearchMoreMsgListActivity extends BaseLightActivity {
    private static final String TAG = SearchMoreMsgListActivity.class.getSimpleName();

    private EditText mEdtSearch;

    private ImageView mImgvDelete;
    private TextView mCancleView;

    private PageRecycleView mMessageRcSearch;

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

    private void init() {
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

    private void setListener() {
        mEdtSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

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
                doChangeColor(mKeyWords);
            }
        });
        mCancleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });

        if (mMessageRcSearchAdapter != null) {
            mMessageRcSearchAdapter.setOnItemClickListener(new SearchMoreMsgAdapter.OnItemClickListener() {
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

                        ClassicSearchUtils.startChatActivity(chatInfo);
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
                ClassicSearchUtils.startChatActivity(chatInfo);
            }
        });

        mMessageRcSearch.setLoadMoreMessageHandler(new PageRecycleView.OnLoadMoreHandler() {
            @Override
            public void loadMore() {
                final List<String> keywordList = new ArrayList<String>() {
                    { add(mKeyWords); }
                };

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
                int totalPage = (totalCount % SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE == 0)
                    ? (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE)
                    : (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE + 1);
                if (pageIndex < totalPage) {
                    return false;
                }

                return true;
            }
        });

        mImgvDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mEdtSearch.setText("");
                mMessageLayout.setVisibility(View.GONE);
            }
        });
    }

    private void doChangeColor(String text) {
        if (text.equals("")) {
            mMessageRcSearchAdapter.setText(null);
        } else {
            mMessageRcSearchAdapter.setText(text);
        }
    }

    private void initData(final String keyWords) {
        if (keyWords == null || TextUtils.isEmpty(keyWords)) {
            mMessageLayout.setVisibility(View.GONE);
            return;
        }

        final List<String> keywordList = new ArrayList<String>() {
            { add(keyWords); }
        };

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
            View v = getCurrentFocus();
            if (isShouldHideInput(v, ev)) {
                hideSoftInput(v.getWindowToken());
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    private boolean isShouldHideInput(View v, MotionEvent event) {
        if (v != null && (v instanceof EditText)) {
            int[] l = {0, 0};
            v.getLocationInWindow(l);
            int left = l[0];
            int top = l[1];
            int bottom = top + v.getHeight();
            int right = left + v.getWidth();
            if (event.getX() > left && event.getX() < right && event.getY() > top && event.getY() < bottom) {
                return false;
            } else {
                return true;
            }
        }
        return false;
    }

    private void hideSoftInput(IBinder token) {
        if (token != null) {
            InputMethodManager im = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            im.hideSoftInputFromWindow(token, InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
}
