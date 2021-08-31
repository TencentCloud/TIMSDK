package com.tencent.qcloud.tim.uikit.modules.search;

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

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessageSearchParam;
import com.tencent.imsdk.v2.V2TIMMessageSearchResult;
import com.tencent.imsdk.v2.V2TIMMessageSearchResultItem;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseActvity;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchDataBean;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter;
import com.tencent.qcloud.tim.uikit.modules.search.view.PageRecycleView;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter.CONTACT_TYPE;
import static com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter.CONVERSATION_TYPE;
import static com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter.GROUP_TYPE;

public class SearchMainActivity extends BaseActvity {
    private static final String TAG = SearchMainActivity.class.getSimpleName();
    /**
     * 搜索框
     */
    private EditText mEdtSearch;
    /**
     * 删除按钮
     */
    private ImageView mImgvDelete;
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
    private Map<String, V2TIMMessageSearchResultItem> mMsgsCountInConversationMap = new HashMap<>();

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

        setListener();
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
                        chatInfo.setType(V2TIMConversation.V2TIM_C2C);
                        SearchDataBean searchDataBean = mContactSearchData.get(pos);
                        chatInfo.setId(searchDataBean.getUserID());
                        String chatName = searchDataBean.getUserID();
                        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                            chatName = searchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(searchDataBean.getNickname())) {
                            chatName = searchDataBean.getNickname();
                        }
                        chatInfo.setChatName(chatName);
                        Intent intent = new Intent();
                        intent.setAction("com.tencent.action.chat.activity");
                        intent.putExtra(TUIKitConstants.CHAT_INFO, chatInfo);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
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
                        chatInfo.setType(V2TIMConversation.V2TIM_GROUP);
                        chatInfo.setGroupType(searchDataBean.getGroupType());
                        String chatName = searchDataBean.getUserID();
                        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                            chatName = searchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(searchDataBean.getNickname())) {
                            chatName = searchDataBean.getNickname();
                        }
                        chatInfo.setChatName(chatName);
                        chatInfo.setId(searchDataBean.getGroupID());
                        Intent intent = new Intent();
                        intent.setAction("com.tencent.action.chat.activity");
                        intent.putExtra(TUIKitConstants.CHAT_INFO, chatInfo);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
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
                        intent.putExtra(TUIKitConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                        intent.putExtra(TUIKitConstants.SEARCH_DATA_BEAN, searchDataBean);
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
                intent.putExtra(TUIKitConstants.SEARCH_LIST_TYPE, CONTACT_TYPE);
                intent.putExtra(TUIKitConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                //intent.putParcelableArrayListExtra(TUIKitConstants.SEARCH_DATA_RESULT, (ArrayList<? extends Parcelable>) searchDataBeans);
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
                intent.putExtra(TUIKitConstants.SEARCH_LIST_TYPE, GROUP_TYPE);
                intent.putExtra(TUIKitConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                //intent.putParcelableArrayListExtra(TUIKitConstants.SEARCH_DATA_RESULT, (ArrayList<? extends Parcelable>) searchDataBeans);
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
                intent.putExtra(TUIKitConstants.SEARCH_LIST_TYPE, CONVERSATION_TYPE);
                intent.putExtra(TUIKitConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                //intent.putParcelableArrayListExtra(TUIKitConstants.SEARCH_DATA_RESULT, (ArrayList<? extends Parcelable>) searchDataBeans);
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

    private void searchConversation(final List<String> keywordList) {
        //search conversation
        final V2TIMMessageSearchParam v2TIMMessageSearchParam = new V2TIMMessageSearchParam();
        v2TIMMessageSearchParam.setKeywordList(keywordList);
        v2TIMMessageSearchParam.setPageSize(SearchFuntionUtils.CONVERSATION_MESSAGE_PAGE_SIZE);
        v2TIMMessageSearchParam.setPageIndex(0);
        V2TIMManager.getMessageManager().searchLocalMessages(v2TIMMessageSearchParam, new V2TIMValueCallback<V2TIMMessageSearchResult>() {
            @Override
            public void onSuccess(V2TIMMessageSearchResult v2TIMMessageSearchResult) {
                mConversationData.clear();
                mMsgsCountInConversationMap.clear();
                if (v2TIMMessageSearchResult == null || v2TIMMessageSearchResult.getTotalCount() == 0 || v2TIMMessageSearchResult.getMessageSearchResultItems().size() == 0){
                    TUIKitLog.d(TAG, "v2TIMMessageSearchResult is null, mConversationData.size() = " + mConversationData.size());
                    mConversationLayout.setVisibility(View.GONE);
                    mConversationRcSearchAdapter.setDataSource(null, CONVERSATION_TYPE);
                    mConversationRcSearchAdapter.setTotalCount(0);
                    return;
                }

                mConversationRcSearchAdapter.setTotalCount(v2TIMMessageSearchResult.getTotalCount());
                List<V2TIMMessageSearchResultItem> v2TIMMessageSearchResultItems = v2TIMMessageSearchResult.getMessageSearchResultItems();
                List<String> conversationIDList = new ArrayList<>();
                for(V2TIMMessageSearchResultItem v2TIMMessageSearchResultItem : v2TIMMessageSearchResultItems) {
                    conversationIDList.add(v2TIMMessageSearchResultItem.getConversationID());
                    mMsgsCountInConversationMap.put(v2TIMMessageSearchResultItem.getConversationID(), v2TIMMessageSearchResultItem);
                }
                V2TIMManager.getConversationManager().getConversationList(conversationIDList, new V2TIMValueCallback<List<V2TIMConversation>>() {
                    @Override
                    public void onSuccess(List<V2TIMConversation> v2TIMConversationList) {
                        if (v2TIMConversationList == null || v2TIMConversationList.size() == 0){
                            mConversationLayout.setVisibility(View.GONE);
                            mConversationRcSearchAdapter.setDataSource(null, CONVERSATION_TYPE);
                            mConversationRcSearchAdapter.setTotalCount(0);
                            return;
                        }

                        for (V2TIMConversation v2TIMConversation : v2TIMConversationList) {
                            if (mConversationData != null) {
                                SearchDataBean searchDataBean = new SearchDataBean();
                                searchDataBean.setConversationID(v2TIMConversation.getConversationID());
                                searchDataBean.setUserID(v2TIMConversation.getUserID());
                                searchDataBean.setGroupID(v2TIMConversation.getGroupID());
                                searchDataBean.setGroup(v2TIMConversation.getType() == 2 ? true : false);
                                searchDataBean.setIconPath(v2TIMConversation.getFaceUrl());
                                searchDataBean.setTitle(v2TIMConversation.getShowName());

                                mConversationData.add(searchDataBean);
                            }
                        }

                        TUIKitLog.d(TAG, "mConversationData.size() = " + mConversationData.size());
                        TUIKitLog.d(TAG, "mMsgsInConversationMap.size() = " + mMsgsCountInConversationMap.size());

                        if (mConversationData != null && mConversationData.size() > 0) {
                            mConversationLayout.setVisibility(View.VISIBLE);
                            if (mConversationData.size() > 3) {
                                mMoreConversationLayout.setVisibility(View.VISIBLE);
                            } else {
                                mMoreConversationLayout.setVisibility(View.GONE);
                            }

                            for (int i = 0; i < mConversationData.size(); i++) {
                                V2TIMMessageSearchResultItem v2TIMMessageSearchResultItem = mMsgsCountInConversationMap.get(mConversationData.get(i).getConversationID());
                                if (v2TIMMessageSearchResultItem != null) {
                                    int count = v2TIMMessageSearchResultItem.getMessageCount();
                                    if (count == 1) {
                                        mConversationData.get(i).setSubTitle(SearchFuntionUtils.getMessageText(v2TIMMessageSearchResultItem.getMessageList().get(0)));
                                        mConversationData.get(i).setSubTextMatch(1);
                                    } else if (count > 1) {
                                        mConversationData.get(i).setSubTitle(count + getString(R.string.chat_records));
                                        mConversationData.get(i).setSubTextMatch(0);
                                    }
                                }
                            }

                            mConversationRcSearchAdapter.setDataSource(mConversationData, CONVERSATION_TYPE);
                            mConversationRcSearchAdapter.setIsShowAll(false);
                        } else {
                            mConversationLayout.setVisibility(View.GONE);
                            mConversationRcSearchAdapter.setDataSource(null, CONVERSATION_TYPE);
                            mConversationRcSearchAdapter.setTotalCount(0);
                        }
                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "getConversation code = " + code + ", desc = " + desc);
                    }
                });
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "searchMessages code = " + code + ", desc = " + desc);
                mConversationLayout.setVisibility(View.GONE);
                mConversationRcSearchAdapter.setDataSource(null, CONVERSATION_TYPE);
                mConversationRcSearchAdapter.setTotalCount(0);
            }
        });
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

        SearchFuntionUtils.SearchContact(keywordList, mContactRcSearchAdapter, mContactLayout, mMoreContactLayout, false, new V2TIMValueCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> searchDataBeans) {
                mContactSearchData = searchDataBeans;
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
            }
        });
        SearchFuntionUtils.SearchGroup(keywordList, mGroupRcSearchAdapter, mGroupLayout, mMoreGroupLayout, false, new V2TIMValueCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> searchDataBeans) {
                mGroupSearchData = searchDataBeans;
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.d(TAG, "SearchContact onError code = " + code + ", desc = " + desc);
            }
        });
        searchConversation(keywordList);
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        mFriendRcSearch = (RecyclerView) findViewById(R.id.friend_rc_search);
        mGroupRcSearch = (RecyclerView) findViewById(R.id.group_rc_search);
        mConversationRcSearch = (PageRecycleView) findViewById(R.id.conversation_rc_search);
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
