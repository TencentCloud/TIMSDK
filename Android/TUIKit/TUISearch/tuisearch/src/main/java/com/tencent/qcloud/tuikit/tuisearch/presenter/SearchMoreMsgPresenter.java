package com.tencent.qcloud.tuikit.tuisearch.presenter;

import android.text.TextUtils;
import android.util.Pair;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchMessageBean;
import com.tencent.qcloud.tuikit.tuisearch.interfaces.ISearchMoreMsgAdapter;
import com.tencent.qcloud.tuikit.tuisearch.model.SearchDataProvider;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;
import java.util.ArrayList;
import java.util.List;

public class SearchMoreMsgPresenter {
    private static final String TAG = SearchMoreMsgPresenter.class.getSimpleName();

    private final SearchDataProvider provider;

    private ISearchMoreMsgAdapter adapter;

    private final List<SearchDataBean> searchDataBeanList = new ArrayList<>();

    public SearchMoreMsgPresenter() {
        provider = new SearchDataProvider();
    }

    public void setAdapter(ISearchMoreMsgAdapter adapter) {
        this.adapter = adapter;
    }

    private boolean isLoad = false;

    public void searchMessage(List<String> keywordList, String conversationId, int pageIndex, IUIKitCallback<List<SearchDataBean>> callback) {
        if (isLoad) {
            return;
        }
        TUISearchLog.d(TAG, "searchMessage() index = " + pageIndex);

        final boolean isGetByPage = pageIndex > 0;

        isLoad = true;

        provider.searchMessages(keywordList, conversationId, pageIndex, new IUIKitCallback<Pair<Integer, List<SearchMessageBean>>>() {
            @Override
            public void onSuccess(Pair<Integer, List<SearchMessageBean>> data) {
                List<SearchMessageBean> searchMessageBeanList = data.second;
                int totalCount = data.first;
                if (!isGetByPage) {
                    searchDataBeanList.clear();
                }
                if (searchMessageBeanList.size() == 0) {
                    TUISearchLog.i(TAG, "searchMessages searchMessageBeanList is empty");
                    if (!isGetByPage) {
                        adapter.onDataSourceChanged(searchDataBeanList);
                        adapter.onTotalCountChanged(totalCount);
                    }
                    TUISearchUtils.callbackOnSuccess(callback, searchDataBeanList);
                    isLoad = false;
                    return;
                }

                adapter.onTotalCountChanged(searchMessageBeanList.size());
                List<MessageInfo> messageInfoList = searchMessageBeanList.get(0).getMessageInfoList();

                if (!isGetByPage && (messageInfoList == null || messageInfoList.isEmpty())) {
                    TUISearchLog.i(TAG, "searchMessages is null, messageInfoList.size() = " + messageInfoList.size());
                    adapter.onDataSourceChanged(searchDataBeanList);
                    adapter.onTotalCountChanged(totalCount);
                    TUISearchUtils.callbackOnSuccess(callback, searchDataBeanList);
                    isLoad = false;

                    return;
                }

                if (messageInfoList != null && !messageInfoList.isEmpty()) {
                    for (MessageInfo message : messageInfoList) {
                        SearchDataBean searchDataBean = new SearchDataBean();
                        String title = "";
                        if (!TextUtils.isEmpty(message.getFriendRemark())) {
                            title = message.getFriendRemark();
                        } else if (!TextUtils.isEmpty(message.getNameCard())) {
                            title = message.getNameCard();
                        } else if (!TextUtils.isEmpty(message.getNickName())) {
                            title = message.getNickName();
                        } else {
                            title = message.isGroup() ? message.getGroupId() : message.getUserId();
                        }
                        String subTitle = provider.getMessageText(message);
                        String path = message.getFaceUrl();

                        searchDataBean.setTitle(title);
                        searchDataBean.setSubTitle(subTitle);
                        searchDataBean.setIconPath(path);
                        searchDataBean.setUserID(message.getUserId());
                        searchDataBean.setGroupID(message.getGroupId());
                        searchDataBean.setGroup(message.isGroup());
                        searchDataBean.setIconPath(message.getFaceUrl());
                        searchDataBean.setLocateTimMessage(message.getTimMessage());

                        searchDataBeanList.add(searchDataBean);
                    }

                    TUISearchUtils.callbackOnSuccess(callback, searchDataBeanList);
                    adapter.onDataSourceChanged(searchDataBeanList);
                    adapter.onTotalCountChanged(totalCount);
                }
                isLoad = false;
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUISearchLog.e(TAG, "searchMessages code = " + errCode + ", desc = " + errMsg);
                if (!isGetByPage) {
                    searchDataBeanList.clear();
                    adapter.onDataSourceChanged(null);
                    adapter.onTotalCountChanged(0);
                }
                TUISearchUtils.callbackOnError(callback, module, errCode, errMsg);
                isLoad = false;
            }
        });
    }

    public ChatInfo generateChatInfo(SearchDataBean searchDataBean) {
        return provider.generateChatInfo(searchDataBean);
    }
}
