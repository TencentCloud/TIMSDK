package com.tencent.qcloud.tuikit.tuisearch.classicui.page;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.classicui.util.ClassicSearchUtils;
import com.tencent.qcloud.tuikit.tuisearch.classicui.widget.PageRecycleView;
import com.tencent.qcloud.tuikit.tuisearch.classicui.widget.SearchResultAdapter;
import com.tencent.qcloud.tuikit.tuisearch.presenter.SearchMainPresenter;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import java.util.ArrayList;
import java.util.List;

public class SearchMainActivity extends BaseLightActivity {
    private static final String TAG = SearchMainActivity.class.getSimpleName();

    private EditText mEdtSearch;

    private ImageView mImgvDelete;
    private TextView mCancleView;

    private RecyclerView mFriendRcSearch;
    private RecyclerView mGroupRcSearch;
    private PageRecycleView mConversationRcSearch;

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
        setListener();
    }

    public void initPresenter() {
        presenter = new SearchMainPresenter();
        presenter.setGroupAdapter(mGroupRcSearchAdapter);
        presenter.setContactAdapter(mContactRcSearchAdapter);
        presenter.setConversationAdapter(mConversationRcSearchAdapter);
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
                initData(editable.toString().trim());
                doChangeColor(editable.toString().trim());
            }
        });

        if (mContactRcSearchAdapter != null) {
            mContactRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.OnItemClickListener() {
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
                        ClassicSearchUtils.startChatActivity(chatInfo);
                    }
                }
            });
        }
        if (mGroupRcSearchAdapter != null) {
            mGroupRcSearchAdapter.setOnItemClickListener(new SearchResultAdapter.OnItemClickListener() {
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
                        ClassicSearchUtils.startChatActivity(chatInfo);
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
                        Intent intent = new Intent(getApplicationContext(), SearchMoreMsgListActivity.class);
                        intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                        intent.putExtra(TUISearchConstants.SEARCH_DATA_BEAN, searchDataBean);
                        startActivity(intent);
                    }
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

        mCancleView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });

        mMoreContactLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mContactRcSearchAdapter == null) {
                    return;
                }
                List<SearchDataBean> searchDataBeans = mContactRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4) {
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, TUISearchConstants.CONTACT_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
            }
        });

        mMoreGroupLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mGroupRcSearchAdapter == null) {
                    return;
                }
                List<SearchDataBean> searchDataBeans = mGroupRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4) {
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, TUISearchConstants.GROUP_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
            }
        });

        mMoreConversationLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mConversationRcSearchAdapter == null) {
                    return;
                }
                List<SearchDataBean> searchDataBeans = mConversationRcSearchAdapter.getDataSource();
                if (searchDataBeans == null || searchDataBeans.size() < 4) {
                    return;
                }
                Intent intent = new Intent(getApplicationContext(), SearchMoreListActivity.class);
                intent.putExtra(TUISearchConstants.SEARCH_LIST_TYPE, TUISearchConstants.CONVERSATION_TYPE);
                intent.putExtra(TUISearchConstants.SEARCH_KEY_WORDS, mEdtSearch.getText().toString().trim());
                startActivity(intent);
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

    private void initData(final String keyWords) {
        if (keyWords == null || TextUtils.isEmpty(keyWords)) {
            mContactLayout.setVisibility(View.GONE);
            mGroupLayout.setVisibility(View.GONE);
            mConversationLayout.setVisibility(View.GONE);
            return;
        }

        final List<String> keywordList = new ArrayList<String>() {
            { add(keyWords); }
        };

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
                if (code == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                }
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
                if (code == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                }
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
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                }
                mConversationLayout.setVisibility(View.GONE);
                mMoreConversationLayout.setVisibility(View.GONE);
            }
        });
    }

    private void showNotSupportDialog() {
        String string = getResources().getString(R.string.search_im_flagship_edition_update_tip, getString(R.string.search));
        String buyingGuidelines = getResources().getString(R.string.search_buying_guidelines);
        int buyingGuidelinesIndex = string.lastIndexOf(buyingGuidelines);
        final int foregroundColor =
            getResources().getColor(TUIThemeManager.getAttrResId(SearchMainActivity.this, com.tencent.qcloud.tuicore.R.attr.core_primary_color));
        SpannableString spannedString = new SpannableString(string);
        ForegroundColorSpan colorSpan2 = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan2 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC);
                } else {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC_EN);
                }
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        TUIKitDialog.TUIIMUpdateDialog.getInstance()
            .createDialog(this)
            .setShowOnlyDebug(true)
            .setMovementMethod(LinkMovementMethod.getInstance())
            .setHighlightColor(Color.TRANSPARENT)
            .setCancelable(true)
            .setCancelOutside(true)
            .setTitle(spannedString)
            .setDialogWidth(0.75f)
            .setDialogFeatureName(TUIConstants.BuyingFeature.BUYING_FEATURE_SEARCH)
            .setPositiveButton(getString(R.string.search_no_more_reminders),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().setNeverShow(true);
                    }
                })
            .setNegativeButton(getString(R.string.search_i_know),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                    }
                })
            .show();
    }

    private void openWebUrl(String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    private void initView() {
        mEdtSearch = (EditText) findViewById(R.id.edt_search);
        mImgvDelete = (ImageView) findViewById(R.id.imgv_delete);
        mFriendRcSearch = (RecyclerView) findViewById(R.id.friend_rc_search);
        mGroupRcSearch = (RecyclerView) findViewById(R.id.group_rc_search);
        mConversationRcSearch = (PageRecycleView) findViewById(R.id.conversation_rc_search);
        mCancleView = (TextView) findViewById(R.id.cancel_button);
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
