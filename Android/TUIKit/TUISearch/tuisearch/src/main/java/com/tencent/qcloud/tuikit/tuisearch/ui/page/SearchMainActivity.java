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
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.presenter.SearchMainPresenter;
import com.tencent.qcloud.tuikit.tuisearch.ui.view.SearchResultAdapter;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.ui.view.PageRecycleView;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.qcloud.tuikit.tuisearch.ui.view.SearchResultAdapter.CONTACT_TYPE;
import static com.tencent.qcloud.tuikit.tuisearch.ui.view.SearchResultAdapter.CONVERSATION_TYPE;
import static com.tencent.qcloud.tuikit.tuisearch.ui.view.SearchResultAdapter.GROUP_TYPE;

public class SearchMainActivity extends BaseLightActivity {
    private static final String TAG = SearchMainActivity.class.getSimpleName();
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
    private RecyclerView mFriendRcSearch;
    private RecyclerView mGroupRcSearch;
    private PageRecycleView mConversationRcSearch;
    /**
     * 全部匹配的适配器
     */
    private SearchResultAdapter mContactRcSearchAdapter;
    private SearchResultAdapter mGroupRcSearchAdapter;
    private SearchResultAdapter mConversationRcSearchAdapter;
    
    private RelativeLayout mContactLayout;
    private RelativeLayout mGroupLayout;
    private RelativeLayout mConversationLayout;

    private RelativeLayout mMoreContactLayout;
    private RelativeLayout mMoreGroupLayout;
    private RelativeLayout mMoreConversationLayout;

    private List<SearchDataBean> mContactSearchData = new ArrayList<>();
    private List<SearchDataBean> mGroupSearchData = new ArrayList<>();
    private List<SearchDataBean> mConversationData = new ArrayList<>();

    private SearchMainPresenter presenter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search_main_activity);
        init();
    }

    private void init(){
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
        setListener();
    }

    public void initPresenter() {
        presenter = new SearchMainPresenter();
        presenter.setGroupAdapter(mGroupRcSearchAdapter);
        presenter.setContactAdapter(mContactRcSearchAdapter);
        presenter.setConversationAdapter(mConversationRcSearchAdapter);
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
                initData(editable.toString().trim());
                //匹配文字 变色
                doChangeColor(editable.toString().trim());
            }
        });
        //recyclerview的点击监听
        if (mContactRcSearchAdapter != null) {
            mContactRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.onItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mContactSearchData != null && pos < mContactSearchData.size()) {
                        ChatInfo chatInfo = new ChatInfo();
                        chatInfo.setType(ChatInfo.TYPE_C2C);
                        SearchDataBean searchDataBean = mContactSearchData.get(pos);
                        chatInfo.setId(searchDataBean.getUserID());
                        String chatName = searchDataBean.getUserID();
                        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                            chatName = searchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(searchDataBean.getNickName())) {
                            chatName = searchDataBean.getNickName();
                        }
                        chatInfo.setChatName(chatName);
                        TUISearchUtils.startChatActivity(chatInfo);

                    }
                }
            });
        }
        if (mGroupRcSearchAdapter != null) {
            mGroupRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.onItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mGroupSearchData != null && pos < mGroupSearchData.size()) {
                        SearchDataBean searchDataBean = mGroupSearchData.get(pos);
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
                        TUISearchUtils.startChatActivity(chatInfo);

                    }
                }
            });
        }
        if (mConversationRcSearchAdapter != null) {
            mConversationRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.onItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mConversationRcSearchAdapter == null){
                        return;
                    }
                    List<SearchDataBean> searchDataBeans = mConversationRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        SearchDataBean searchDataBean = searchDataBeans.get(pos);
                        Intent intent = new Intent(getApplicationContext(), SearchMoreMsgListActivity.class);
                        intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                        intent.putExtra(TUISearchConstants.SEARCH_DATA_BEAN, searchDataBean);
                        startActivity(intent);
                    }
                }
            });
        }
        //删除按钮的监听
        mImgvDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mEdtSearch.setText("");
                mContactLayout.setVisibility(View.GONE);
                mGroupLayout.setVisibility(View.GONE);
                mConversationLayout.setVisibility(View.GONE);
            }
        });

        mCancleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });

        mMoreContactLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mContactRcSearchAdapter == null){
                    return;
                }
                List<SearchDataBean> searchDataBeans = mContactRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4){
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, CONTACT_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
            }
        });

        mMoreGroupLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mGroupRcSearchAdapter== null){
                    return;
                }
                List<SearchDataBean> searchDataBeans = mGroupRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4){
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, GROUP_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
            }
        });

        mMoreConversationLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mConversationRcSearchAdapter== null){
                    return;
                }
                List<SearchDataBean> searchDataBeans = mConversationRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4){
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, CONVERSATION_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
            }
        });
    }

    /**
     * 字体匹配方法
     */
    private void doChangeColor(String text) {
        if (text.equals("")) {
            //防止匹配过文字之后点击删除按钮 字体仍然变色的问题
            mContactRcSearchAdapter.setText(null);
            mGroupRcSearchAdapter.setText(null);
            mConversationRcSearchAdapter.setText(null);
        } else {
            //设置要变色的关键字
            mContactRcSearchAdapter.setText(text);
            mGroupRcSearchAdapter.setText(text);
            mConversationRcSearchAdapter.setText(text);
        }
    }

    private void initData(final String keyWords) {
       if (keyWords == null || TextUtils.isEmpty(keyWords)){
           mContactLayout.setVisibility(View.GONE);
           mGroupLayout.setVisibility(View.GONE);
           mConversationLayout.setVisibility(View.GONE);
           return;
       }

        final List<String> keywordList = new ArrayList<String>() {{
                add(keyWords);
        }};

        presenter.searchContact(keywordList, new IUIKitCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> searchDataBeans) {
                mContactSearchData = searchDataBeans;
                if (searchDataBeans.isEmpty()) {
                    mContactLayout.setVisibility(View.GONE);
                    mMoreContactLayout.setVisibility(View.GONE);
                } else {
                    mContactLayout.setVisibility(View.VISIBLE);
                    if (searchDataBeans.size() > 3) {
                        mMoreContactLayout.setVisibility(View.VISIBLE);
                    } else {
                        mMoreContactLayout.setVisibility(View.GONE);
                    }
                }
                mContactRcSearchAdapter.onIsShowAllChanged(false);
            }

            @Override
            public void onError(String module, int code, String desc) {
                TUISearchLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
            }
        });

        presenter.searchGroup(keywordList, new IUIKitCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> searchDataBeans) {
                mGroupSearchData = searchDataBeans;

                if (searchDataBeans.size() > 0) {
                    mGroupLayout.setVisibility(View.VISIBLE);
                    if (searchDataBeans.size() > 3) {
                        mMoreGroupLayout.setVisibility(View.VISIBLE);
                    } else {
                        mMoreGroupLayout.setVisibility(View.GONE);
                    }
                } else {
                    mGroupLayout.setVisibility(View.GONE);
                    mMoreGroupLayout.setVisibility(View.GONE);
                }
                mGroupRcSearchAdapter.onIsShowAllChanged(false);

            }

            @Override
            public void onError(String module, int code, String desc) {
                TUISearchLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
            }
        });

        presenter.searchConversation(keywordList, 0, new IUIKitCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> data) {
                if (data.size() > 0) {
                    mConversationLayout.setVisibility(View.VISIBLE);
                    if (data.size() > 3) {
                        mMoreConversationLayout.setVisibility(View.VISIBLE);
                    } else {
                        mMoreConversationLayout.setVisibility(View.GONE);
                    }
                } else {
                    mConversationLayout.setVisibility(View.GONE);
                    mMoreConversationLayout.setVisibility(View.GONE);
                }
                mConversationRcSearchAdapter.onIsShowAllChanged(false);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mConversationLayout.setVisibility(View.GONE);
                mMoreConversationLayout.setVisibility(View.GONE);
            }
        });
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        mFriendRcSearch = (RecyclerView) findViewById(R.id.friend_rc_search);
        mGroupRcSearch = (RecyclerView) findViewById(R.id.group_rc_search);
        mConversationRcSearch = (PageRecycleView) findViewById(R.id.conversation_rc_search);
        mCancleView = (TextView) findViewById(R.id.cancel_button);
        //Recyclerview的配置
        mFriendRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mGroupRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mConversationRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mFriendRcSearch.setNestedScrollingEnabled(false);
        mGroupRcSearch.setNestedScrollingEnabled(false);
        mConversationRcSearch.setNestedScrollingEnabled(false);
        mContactLayout = (RelativeLayout) findViewById(R.id.contact_layout);
        mMoreContactLayout = (RelativeLayout) findViewById(R.id.more_contact_layout);
        mGroupLayout = (RelativeLayout) findViewById(R.id.group_layout);
        mMoreGroupLayout = (RelativeLayout) findViewById(R.id.more_group_layout);
        mConversationLayout = (RelativeLayout) findViewById(R.id.conversation_layout);
        mMoreConversationLayout = (RelativeLayout) findViewById(R.id.more_conversation_layout);
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
