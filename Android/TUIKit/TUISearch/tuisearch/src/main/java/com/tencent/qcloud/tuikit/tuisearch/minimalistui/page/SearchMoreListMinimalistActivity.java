package com.tencent.qcloud.tuikit.tuisearch.minimalistui.page;

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
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.minimalistui.util.MinimalistSearchUtils;
import com.tencent.qcloud.tuikit.tuisearch.minimalistui.widget.PageRecycleView;
import com.tencent.qcloud.tuikit.tuisearch.minimalistui.widget.SearchResultAdapter;
import com.tencent.qcloud.tuikit.tuisearch.model.SearchDataProvider;
import com.tencent.qcloud.tuikit.tuisearch.presenter.SearchMainPresenter;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import java.util.ArrayList;
import java.util.List;

public class SearchMoreListMinimalistActivity extends BaseMinimalistLightActivity {
    private static final String TAG = SearchMoreListMinimalistActivity.class.getSimpleName();

    private EditText mEdtSearch;

    private ImageView mImgvDelete;
    private TextView mCancleView;
    private View searchBackButton;

    private RecyclerView mFriendRcSearch;
    private RecyclerView mGroupRcSearch;
    private PageRecycleView mConversationRcSearch;

    private SearchResultAdapter mContactRcSearchAdapter;
    private SearchResultAdapter mGroupRcSearchAdapter;
    private SearchResultAdapter mConversationRcSearchAdapter;

    private RelativeLayout mContactLayout;
    private RelativeLayout mGroupLayout;
    private RelativeLayout mConversationLayout;

    private View mMoreContactButton;
    private View mMoreGroupButton;
    private View mMoreConversationButton;
    private View notFoundArea;

    private int mViewType = -1;
    private String mKeyWords;
    private int pageIndex = 0;

    private SearchMainPresenter presenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_search_main_activity);
        init();
    }

    private void init() {
        initView();

        if (mContactRcSearchAdapter == null) {
            mContactRcSearchAdapter = new SearchResultAdapter(this);
            mFriendRcSearch.setAdapter(mContactRcSearchAdapter);
        }

        if (mGroupRcSearchAdapter == null) {
            mGroupRcSearchAdapter = new SearchResultAdapter(this);
            mGroupRcSearch.setAdapter(mGroupRcSearchAdapter);
        }

        if (mConversationRcSearchAdapter == null) {
            mConversationRcSearchAdapter = new SearchResultAdapter(this);
            mConversationRcSearch.setAdapter(mConversationRcSearchAdapter);
        }

        initPresenter();

        Intent intent = getIntent();
        if (intent != null) {
            mViewType = intent.getIntExtra(TUISearchConstants.SEARCH_LIST_TYPE, -1);
            mKeyWords = intent.getStringExtra(TUISearchConstants.SEARCH_KEY_WORDS);
            pageIndex = 0;

            // also ok
            initData(mKeyWords);

            mEdtSearch.setText(mKeyWords);
            doChangeColor(mKeyWords);
        }

        setListener();
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        searchBackButton = (ImageView) findViewById(R.id.search_back_icon);
        mFriendRcSearch = (RecyclerView) findViewById(R.id.friend_rc_search);
        mGroupRcSearch = (RecyclerView) findViewById(R.id.group_rc_search);
        mConversationRcSearch = (PageRecycleView) findViewById(R.id.conversation_rc_search);
        mCancleView = (TextView) findViewById(R.id.cancel_button);
        mFriendRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mGroupRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mConversationRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mFriendRcSearch.setNestedScrollingEnabled(false);
        mGroupRcSearch.setNestedScrollingEnabled(false);
        mConversationRcSearch.setNestedScrollingEnabled(true);
        mContactLayout = (RelativeLayout) findViewById(R.id.contact_layout);
        mMoreContactButton = findViewById(R.id.more_contact_button);
        mGroupLayout = (RelativeLayout) findViewById(R.id.group_layout);
        mMoreGroupButton = findViewById(R.id.more_group_button);
        mConversationLayout = findViewById(R.id.conversation_layout);
        mMoreConversationButton = findViewById(R.id.more_conversation_button);
        notFoundArea = findViewById(R.id.not_found_area);

        searchBackButton.setVisibility(View.VISIBLE);
        searchBackButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        mMoreContactButton.setVisibility(View.GONE);
        mMoreConversationButton.setVisibility(View.GONE);
        mMoreGroupButton.setVisibility(View.GONE);
    }

    private void initPresenter() {
        presenter = new SearchMainPresenter();
        presenter.setContactAdapter(mContactRcSearchAdapter);
        presenter.setConversationAdapter(mConversationRcSearchAdapter);
        presenter.setGroupAdapter(mGroupRcSearchAdapter);
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
                mConversationRcSearch.setNestedScrollingEnabled(true);
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

        if (mContactRcSearchAdapter != null) {
            mContactRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.OnItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    List<SearchDataBean> searchDataBeans = mContactRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        SearchDataBean searchDataBean = searchDataBeans.get(pos);
                        ChatInfo chatInfo = new ChatInfo();
                        chatInfo.setType(ChatInfo.TYPE_C2C);
                        chatInfo.setId(searchDataBean.getUserID());
                        String chatName = searchDataBean.getUserID();
                        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                            chatName = searchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(searchDataBean.getNickName())) {
                            chatName = searchDataBean.getNickName();
                        }
                        chatInfo.setChatName(chatName);
                        MinimalistSearchUtils.startChatActivity(chatInfo);
                    }
                }
            });
        }
        if (mGroupRcSearchAdapter != null) {
            mGroupRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.OnItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    List<SearchDataBean> searchDataBeans = mGroupRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        SearchDataBean searchDataBean = searchDataBeans.get(pos);
                        ChatInfo chatInfo = new ChatInfo();
                        chatInfo.setType(ChatInfo.TYPE_GROUP);
                        chatInfo.setGroupType(searchDataBean.getGroupType());
                        String chatName = searchDataBean.getUserID();
                        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                            chatName = searchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(searchDataBean.getNickName())) {
                            chatName = searchDataBean.getNickName();
                        }
                        chatInfo.setChatName(chatName);
                        chatInfo.setId(searchDataBean.getGroupID());
                        MinimalistSearchUtils.startChatActivity(chatInfo);
                    }
                }
            });
        }
        if (mConversationRcSearchAdapter != null) {
            mConversationRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.OnItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mConversationRcSearchAdapter == null) {
                        return;
                    }
                    List<SearchDataBean> searchDataBeans = mConversationRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        SearchDataBean searchDataBean = searchDataBeans.get(pos);
                        Intent intent = new Intent(getApplicationContext(), SearchMoreMsgListMinimalistActivity.class);
                        intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                        intent.putExtra(TUISearchConstants.SEARCH_DATA_BEAN, searchDataBean);
                        startActivity(intent);
                    }
                }
            });

            mConversationRcSearch.setLoadMoreMessageHandler(new PageRecycleView.OnLoadMoreHandler() {
                @Override
                public void loadMore() {
                    final List<String> keywordList = new ArrayList<String>() {
                        { add(mKeyWords); }
                    };
                    presenter.searchConversation(keywordList, ++pageIndex, new IUIKitCallback<List<SearchDataBean>>() {
                        @Override
                        public void onSuccess(List<SearchDataBean> data) {
                            if (data.size() > 0) {
                                mConversationLayout.setVisibility(View.VISIBLE);
                            } else {
                                mConversationLayout.setVisibility(View.GONE);
                                mMoreConversationButton.setVisibility(View.GONE);
                            }
                            mConversationRcSearchAdapter.onIsShowAllChanged(true);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            mConversationLayout.setVisibility(View.GONE);
                            mMoreConversationButton.setVisibility(View.GONE);
                        }
                    });
                }

                @Override
                public boolean isListEnd(int postion) {
                    mConversationRcSearch.setNestedScrollingEnabled(false);

                    if (mConversationRcSearchAdapter == null || mConversationRcSearchAdapter.getTotalCount() == 0) {
                        return true;
                    }

                    int totalCount = mConversationRcSearchAdapter.getTotalCount();
                    int totalPage = (totalCount % SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE == 0)
                        ? (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE)
                        : (totalCount / SearchDataProvider.CONVERSATION_MESSAGE_PAGE_SIZE + 1);
                    if (pageIndex + 1 < totalPage) {
                        return false;
                    }

                    return true;
                }
            });
        }

        mImgvDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mEdtSearch.setText("");
                mContactLayout.setVisibility(View.GONE);
                mGroupLayout.setVisibility(View.GONE);
                mConversationLayout.setVisibility(View.GONE);
            }
        });
    }

    private void doChangeColor(String text) {
        if (text.equals("")) {
            mContactRcSearchAdapter.setText(null);
            mGroupRcSearchAdapter.setText(null);
            mConversationRcSearchAdapter.setText(null);
        } else {
            mContactRcSearchAdapter.setText(text);
            mGroupRcSearchAdapter.setText(text);
            mConversationRcSearchAdapter.setText(text);
        }
    }

    private void invalidNotFoundInfo() {
        if (mContactLayout.getVisibility() == View.GONE && mGroupLayout.getVisibility() == View.GONE && mConversationLayout.getVisibility() == View.GONE) {
            notFoundArea.setVisibility(View.VISIBLE);
        } else {
            notFoundArea.setVisibility(View.GONE);
        }
    }

    private void initData(final String keyWords) {
        if (keyWords == null || TextUtils.isEmpty(keyWords)) {
            mContactLayout.setVisibility(View.GONE);
            mGroupLayout.setVisibility(View.GONE);
            mConversationLayout.setVisibility(View.GONE);
            notFoundArea.setVisibility(View.GONE);
            return;
        }

        final List<String> keywordList = new ArrayList<String>() {
            { add(keyWords); }
        };

        if (mViewType == TUISearchConstants.CONTACT_TYPE) {
            presenter.searchContact(keywordList, new IUIKitCallback<List<SearchDataBean>>() {
                @Override
                public void onSuccess(List<SearchDataBean> searchDataBeans) {
                    if (searchDataBeans.isEmpty()) {
                        mContactLayout.setVisibility(View.GONE);
                    } else {
                        mContactLayout.setVisibility(View.VISIBLE);
                    }
                    mContactRcSearchAdapter.onIsShowAllChanged(true);
                    invalidNotFoundInfo();
                }

                @Override
                public void onError(String module, int code, String desc) {
                    TUISearchLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
                    invalidNotFoundInfo();
                }
            });
        } else if (mViewType == TUISearchConstants.GROUP_TYPE) {
            presenter.searchGroup(keywordList, new IUIKitCallback<List<SearchDataBean>>() {
                @Override
                public void onSuccess(List<SearchDataBean> searchDataBeans) {
                    if (searchDataBeans.size() > 0) {
                        mGroupLayout.setVisibility(View.VISIBLE);
                    } else {
                        mGroupLayout.setVisibility(View.GONE);
                    }
                    mGroupRcSearchAdapter.onIsShowAllChanged(true);
                    invalidNotFoundInfo();
                }

                @Override
                public void onError(String module, int code, String desc) {
                    TUISearchLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
                    invalidNotFoundInfo();
                }
            });
        } else if (mViewType == TUISearchConstants.CONVERSATION_TYPE) {
            presenter.searchConversation(keywordList, 0, new IUIKitCallback<List<SearchDataBean>>() {
                public void onSuccess(List<SearchDataBean> data) {
                    if (data.size() > 0) {
                        mConversationLayout.setVisibility(View.VISIBLE);
                    } else {
                        mConversationLayout.setVisibility(View.GONE);
                        mMoreConversationButton.setVisibility(View.GONE);
                    }
                    mConversationRcSearchAdapter.onIsShowAllChanged(true);
                    invalidNotFoundInfo();
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    mConversationLayout.setVisibility(View.GONE);
                    mMoreConversationButton.setVisibility(View.GONE);
                    invalidNotFoundInfo();
                }
            });
        } else {
            TUISearchLog.e(TAG, "mViewType is invalid :" + mViewType);
        }
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
