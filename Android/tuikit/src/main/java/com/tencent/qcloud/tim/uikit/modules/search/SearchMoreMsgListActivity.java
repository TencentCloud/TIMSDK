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
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageSearchParam;
import com.tencent.imsdk.v2.V2TIMMessageSearchResult;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseActvity;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchDataBean;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchMoreMsgAdapter;
import com.tencent.qcloud.tim.uikit.modules.search.view.PageRecycleView;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.List;

public class SearchMoreMsgListActivity extends BaseActvity {
    private static final String TAG = SearchMoreMsgListActivity.class.getSimpleName();
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
    private PageRecycleView mMessageRcSearch;
    /**
     * 全部匹配的适配器
     */
    private SearchMoreMsgAdapter mMessageRcSearchAdapter;

    private RelativeLayout mMessageLayout;
    private RelativeLayout mConversationLayout;
    private ImageView mConversationIcon;
    private TextView mConversationTitle;

    private List<V2TIMMessage> mMessageSearchData = new ArrayList<>();

    private String mKeyWords;
    private String mConversationId;
    private boolean mIsGroup;
    private SearchDataBean mSearchDataBean;
    private int pageIndex = 0;

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

        Intent intent = getIntent();
        if (intent != null) {
            mKeyWords = intent.getStringExtra(TUIKitConstants.SEARCH_KEY_WORDS);
            mSearchDataBean = intent.getParcelableExtra(TUIKitConstants.SEARCH_DATA_BEAN);
            pageIndex = 0;

            if (mSearchDataBean != null) {
                if (!TextUtils.isEmpty(mSearchDataBean.getIconPath())) {
                    GlideEngine.loadImage(mConversationIcon, mSearchDataBean.getIconPath(), null);
                } else {
                    mConversationIcon.setImageResource(R.drawable.default_user_icon);
                }
                mConversationTitle.setText(mSearchDataBean.getTitle());

                mIsGroup = mSearchDataBean.isGroup();
                if (mIsGroup) {
                    mConversationId = "group_" + mSearchDataBean.getGroupID();
                } else {
                    mConversationId = "c2c_" + mSearchDataBean.getUserID();
                }
            }

            initData(mKeyWords);
            mEdtSearch.setText(mKeyWords);
            doChangeColor(mKeyWords);
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
                mKeyWords = editable.toString().trim();
                pageIndex = 0;
                mMessageRcSearch.setNestedScrollingEnabled(true);
                initData(mKeyWords);
                //匹配文字 变色
                doChangeColor(mKeyWords);
            }
        });
        //recyclerview的点击监听
        if (mMessageRcSearchAdapter != null) {
            mMessageRcSearchAdapter.setOnItemClickListener(new SearchMoreMsgAdapter.onItemClickListener() {
                @Override
                public void onClick(View view, int pos) {
                    if (mSearchDataBean == null) {
                        TUIKitLog.e(TAG, "mSearchDataBean == null");
                        return;
                    }
                    List<V2TIMMessage> searchDataBeans = mMessageRcSearchAdapter.getDataSource();
                    if (searchDataBeans != null && pos < searchDataBeans.size()) {
                        V2TIMMessage v2TIMMessage = searchDataBeans.get(pos);
                        ChatInfo chatInfo = new ChatInfo();
                        if (mSearchDataBean.isGroup()) {
                            chatInfo.setType(V2TIMConversation.V2TIM_GROUP);
                            chatInfo.setId(mSearchDataBean.getGroupID());
                            chatInfo.setGroupType(mSearchDataBean.getGroupType());
                        } else {
                            chatInfo.setType(V2TIMConversation.V2TIM_C2C);
                            chatInfo.setId(mSearchDataBean.getUserID());
                        }
                        String chatName = mSearchDataBean.getUserID();
                        if (!TextUtils.isEmpty(mSearchDataBean.getRemark())) {
                            chatName = mSearchDataBean.getRemark();
                        } else if (!TextUtils.isEmpty(mSearchDataBean.getNickname())) {
                            chatName = mSearchDataBean.getNickname();
                        }
                        chatInfo.setChatName(chatName);
                        chatInfo.setLocateTimMessage(v2TIMMessage);
                        Intent intent = new Intent();
                        intent.setAction("com.tencent.action.chat.activity");
                        intent.putExtra(TUIKitConstants.CHAT_INFO, chatInfo);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
                    }
                }
            });
        }

        mConversationLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mSearchDataBean == null) {
                    TUIKitLog.e(TAG, "mSearchDataBean == null");
                    return;
                }
                ChatInfo chatInfo = new ChatInfo();
                if (mSearchDataBean.isGroup()) {
                    chatInfo.setType(V2TIMConversation.V2TIM_GROUP);
                    chatInfo.setId(mSearchDataBean.getGroupID());
                    chatInfo.setGroupType(mSearchDataBean.getGroupType());
                } else {
                    chatInfo.setType(V2TIMConversation.V2TIM_C2C);
                    chatInfo.setId(mSearchDataBean.getUserID());
                }
                String chatName = mSearchDataBean.getUserID();
                if (!TextUtils.isEmpty(mSearchDataBean.getRemark())) {
                    chatName = mSearchDataBean.getRemark();
                } else if (!TextUtils.isEmpty(mSearchDataBean.getNickname())) {
                    chatName = mSearchDataBean.getNickname();
                }
                chatInfo.setChatName(chatName);
                Intent intent = new Intent();
                intent.setAction("com.tencent.action.chat.activity");
                intent.putExtra(TUIKitConstants.CHAT_INFO, chatInfo);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

        mMessageRcSearch.setLoadMoreMessageHandler(new PageRecycleView.OnLoadMoreHandler() {
            @Override
            public void loadMore() {
                final List<String> keywordList = new ArrayList<String>() {{
                    add(mKeyWords);
                }};

                searchMessage(keywordList, mConversationId, ++pageIndex);
            }

            @Override
            public boolean isListEnd(int postion) {
                if (mMessageRcSearchAdapter == null || mMessageRcSearchAdapter.getTotalCount() == 0) {
                    return true;
                }

                int totalCount = mMessageRcSearchAdapter.getTotalCount();
                int totalPage = (totalCount % SearchFuntionUtils.CONVERSATION_MESSAGE_PAGE_SIZE == 0) ? (totalCount / SearchFuntionUtils.CONVERSATION_MESSAGE_PAGE_SIZE) : (totalCount / SearchFuntionUtils.CONVERSATION_MESSAGE_PAGE_SIZE + 1);
                if (pageIndex < totalPage) {
                    return false;
                }

                mMessageRcSearch.setNestedScrollingEnabled(false);
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

    private void searchMessage(final List<String> keywordList, final String conversationID, int index) {
        //search conversation
        TUIKitLog.d(TAG, "searchMessage() index = " + index);
        final V2TIMMessageSearchParam v2TIMMessageSearchParam = new V2TIMMessageSearchParam();
        v2TIMMessageSearchParam.setKeywordList(keywordList);
        v2TIMMessageSearchParam.setPageSize(SearchFuntionUtils.CONVERSATION_MESSAGE_PAGE_SIZE);
        v2TIMMessageSearchParam.setPageIndex(index);
        v2TIMMessageSearchParam.setConversationID(conversationID);
        final boolean isGetByPage = index > 0 ? true : false;
        V2TIMManager.getMessageManager().searchLocalMessages(v2TIMMessageSearchParam, new V2TIMValueCallback<V2TIMMessageSearchResult>() {
            @Override
            public void onSuccess(V2TIMMessageSearchResult v2TIMMessageSearchResult) {
                if (!isGetByPage) {
                    mMessageSearchData.clear();
                }
                if (v2TIMMessageSearchResult == null || v2TIMMessageSearchResult.getTotalCount() == 0 ||
                        v2TIMMessageSearchResult.getMessageSearchResultItems() == null ||
                        v2TIMMessageSearchResult.getMessageSearchResultItems().size() == 0) {
                    TUIKitLog.d(TAG, "searchMessages v2TIMMessageSearchResult is null");
                    if (!isGetByPage) {
                        mMessageSearchData.clear();
                        mConversationLayout.setVisibility(View.GONE);
                        mMessageLayout.setVisibility(View.GONE);
                        mMessageRcSearchAdapter.setDataSource(null);
                        mMessageRcSearchAdapter.setTotalCount(0);
                    }
                    return;
                }

                mMessageRcSearchAdapter.setTotalCount(v2TIMMessageSearchResult.getTotalCount());
                List<V2TIMMessage> v2TIMMessages = v2TIMMessageSearchResult.getMessageSearchResultItems().get(0).getMessageList();

                if (!isGetByPage && (v2TIMMessages == null || v2TIMMessages.isEmpty())){
                    TUIKitLog.d(TAG, "searchMessages is null, v2TIMMessages.size() = " + v2TIMMessages.size());
                    mMessageSearchData.clear();
                    mConversationLayout.setVisibility(View.GONE);
                    mMessageLayout.setVisibility(View.GONE);
                    mMessageRcSearchAdapter.setDataSource(null);
                    mMessageRcSearchAdapter.setTotalCount(0);
                    return;
                }

                if (v2TIMMessages != null && !v2TIMMessages.isEmpty()) {
                    mMessageSearchData.addAll(v2TIMMessages);
                    mConversationLayout.setVisibility(View.VISIBLE);
                    mMessageLayout.setVisibility(View.VISIBLE);
                    mMessageRcSearchAdapter.setDataSource(mMessageSearchData);
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "searchMessages code = " + code + ", desc = " + desc);
                if (!isGetByPage) {
                    mMessageSearchData.clear();
                    mConversationLayout.setVisibility(View.GONE);
                    mMessageLayout.setVisibility(View.GONE);
                    mMessageRcSearchAdapter.setDataSource(null);
                    mMessageRcSearchAdapter.setTotalCount(0);
                }
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

        searchMessage(keywordList, mConversationId, pageIndex);
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        mMessageRcSearch = (PageRecycleView) findViewById(R.id.message_rc_search);
        mMessageRcSearch.setLayoutManager(new LinearLayoutManager(this));
        mMessageRcSearch.setNestedScrollingEnabled(true);
        mConversationLayout = (RelativeLayout) findViewById(R.id.conversation_layout);
        mConversationIcon = (ImageView) findViewById(R.id.icon_conversation);
        mConversationTitle = (TextView) findViewById(R.id.conversation_title);
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
