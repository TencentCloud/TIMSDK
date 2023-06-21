package com.tencent.qcloud.tuikit.tuisearch.presenter;

import android.text.TextUtils;
import android.util.Pair;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchMessageBean;
import com.tencent.qcloud.tuikit.tuisearch.bean.TUISearchGroupParam;
import com.tencent.qcloud.tuikit.tuisearch.bean.TUISearchGroupResult;
import com.tencent.qcloud.tuikit.tuisearch.interfaces.ISearchResultAdapter;
import com.tencent.qcloud.tuikit.tuisearch.model.SearchDataProvider;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SearchMainPresenter {
    private static final String TAG = SearchMainPresenter.class.getSimpleName();

    private final SearchDataProvider groupProvider;
    private final SearchDataProvider contactProvider;
    private final SearchDataProvider conversationProvider;

    private ISearchResultAdapter contactAdapter;

    private ISearchResultAdapter groupAdapter;

    private ISearchResultAdapter conversationAdapter;

    private final Set<String> conversationSearchIdSet = new HashSet<>();
    private final List<SearchDataBean> conversationSearchDataBeans = new ArrayList<>();
    private final Map<String, SearchMessageBean> msgCountInConversationMap = new HashMap<>();

    public SearchMainPresenter() {
        groupProvider = new SearchDataProvider();
        contactProvider = new SearchDataProvider();
        conversationProvider = new SearchDataProvider();
    }

    public void setContactAdapter(ISearchResultAdapter contactAdapter) {
        this.contactAdapter = contactAdapter;
    }

    public void setGroupAdapter(ISearchResultAdapter groupAdapter) {
        this.groupAdapter = groupAdapter;
    }

    public void setConversationAdapter(ISearchResultAdapter conversationAdapter) {
        this.conversationAdapter = conversationAdapter;
    }

    public void searchContact(final List<String> keywordList, final IUIKitCallback<List<SearchDataBean>> callback) {
        if (keywordList == null || keywordList.size() == 0 || contactAdapter == null) {
            TUISearchLog.e(TAG, "param is null");
            return;
        }

        final List<SearchDataBean> contactSearchDataList = new ArrayList<>();
        // search contact
        contactProvider.searchContact(keywordList, new IUIKitCallback<List<SearchDataBean>>() {
            @Override
            public void onSuccess(List<SearchDataBean> searchDataBeanList) {
                if (searchDataBeanList == null || searchDataBeanList.isEmpty()) {
                    contactSearchDataList.clear();
                    TUISearchLog.d(TAG, "searchFriends is null, mContactSearchData.size() = " + contactSearchDataList.size());
                    contactAdapter.onDataSourceChanged(null, TUISearchConstants.CONTACT_TYPE);
                    if (callback != null) {
                        callback.onSuccess(contactSearchDataList);
                    }
                    return;
                }

                for (int i = 0; i < searchDataBeanList.size(); i++) {
                    SearchDataBean searchDataBean = searchDataBeanList.get(i);
                    SearchDataBean dataBean = new SearchDataBean();
                    dataBean.setIconPath(searchDataBean.getIconPath());
                    dataBean.setTitle(searchDataBean.getUserID());
                    dataBean.setSubTitleLabel(ServiceInitializer.getAppContext().getString(R.string.nick_name));
                    if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
                        dataBean.setSubTitle(searchDataBean.getRemark());
                    } else if (!TextUtils.isEmpty(searchDataBean.getNickName())) {
                        dataBean.setSubTitle(searchDataBean.getNickName());
                    } else if (!TextUtils.isEmpty(searchDataBean.getUserID())) {
                        dataBean.setSubTitle(searchDataBean.getUserID());
                    }
                    dataBean.setType(TUISearchConstants.CONTACT_TYPE);

                    dataBean.setUserID(searchDataBean.getUserID());
                    dataBean.setNickName(searchDataBean.getNickName());
                    dataBean.setRemark(searchDataBean.getRemark());
                    contactSearchDataList.add(dataBean);
                }

                contactAdapter.onDataSourceChanged(contactSearchDataList, TUISearchConstants.CONTACT_TYPE);
                if (callback != null) {
                    callback.onSuccess(contactSearchDataList);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUISearchLog.e(TAG, "code = " + errCode + ", desc = " + errMsg);
                if (callback != null) {
                    callback.onSuccess(contactSearchDataList);
                }
            }
        });
    }

    public void searchGroup(final List<String> keywordList, final IUIKitCallback<List<SearchDataBean>> callback) {
        if (keywordList == null || keywordList.size() == 0 || groupAdapter == null) {
            TUISearchLog.e(TAG, "param is null");
            return;
        }

        final List<SearchDataBean> groupSearchDataList = new ArrayList<>();

        TUISearchGroupParam searchParam = new TUISearchGroupParam();
        searchParam.setKeywordList(keywordList);
        searchParam.setSearchGroupID(true);
        searchParam.setSearchGroupName(true);

        searchParam.setSearchMemberUserID(true);
        searchParam.setSearchMemberNickName(true);
        searchParam.setSearchMemberNameCard(true);
        searchParam.setSearchMemberRemark(true);

        groupProvider.searchGroups(searchParam, new IUIKitCallback<List<TUISearchGroupResult>>() {
            @Override
            public void onSuccess(List<TUISearchGroupResult> tuiSearchGroupResults) {
                groupSearchDataList.clear();
                if (tuiSearchGroupResults == null || tuiSearchGroupResults.isEmpty()) {
                    TUISearchLog.d(TAG, "searchGroups is null, tuiSearchGroupResults.size() = " + tuiSearchGroupResults.size());
                    groupAdapter.onDataSourceChanged(null, TUISearchConstants.GROUP_TYPE);

                    if (callback != null) {
                        callback.onSuccess(groupSearchDataList);
                    }
                    return;
                }

                TUISearchLog.d(TAG, "tuiSearchGroupResults.size() = " + tuiSearchGroupResults.size());

                for (int i = 0; i < tuiSearchGroupResults.size(); i++) {
                    TUISearchGroupResult searchGroupResult = tuiSearchGroupResults.get(i);
                    SearchDataBean dataBean = new SearchDataBean();
                    GroupInfo groupInfo = searchGroupResult.getGroupInfo();
                    String groupId = groupInfo.getId();
                    dataBean.setGroupID(groupId);
                    dataBean.setGroup(true);
                    dataBean.setGroupName(groupInfo.getGroupName());
                    dataBean.setGroupType(groupInfo.getGroupType());
                    dataBean.setRemark(groupInfo.getGroupName());
                    dataBean.setIconPath(groupInfo.getFaceUrl());
                    if (searchGroupResult.getMatchField() == TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_ID) {
                        dataBean.setTitle(groupInfo.getGroupName());
                        dataBean.setSubTitleLabel(ServiceInitializer.getAppContext().getString(R.string.include_group_id));
                        dataBean.setSubTitle(groupId);
                    } else if (searchGroupResult.getMatchField() == TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NAME) {
                        dataBean.setTitle(groupInfo.getGroupName());
                    } else {
                        dataBean.setTitle(groupInfo.getGroupName());
                        if (searchGroupResult.getMatchMembers() != null && !searchGroupResult.getMatchMembers().isEmpty()) {
                            TUISearchGroupResult.TUISearchGroupMemberMatchResult searchGroupMemberMatchResult = searchGroupResult.getMatchMembers().get(0);
                            if (searchGroupMemberMatchResult.getMemberMatchField()
                                != TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NONE) {
                                dataBean.setSubTitleLabel(ServiceInitializer.getAppContext().getString(R.string.include_group_member));
                                dataBean.setSubTitle(searchGroupMemberMatchResult.getMemberMatchValue());
                            } else {
                                dataBean.setSubTitle("");
                            }
                        }
                    }
                    dataBean.setType(TUISearchConstants.GROUP_TYPE);
                    groupSearchDataList.add(dataBean);
                }

                groupAdapter.onDataSourceChanged(groupSearchDataList, TUISearchConstants.GROUP_TYPE);

                if (callback != null) {
                    callback.onSuccess(groupSearchDataList);
                }
            }

            @Override
            public void onError(String module, int code, String desc) {
                groupAdapter.onDataSourceChanged(groupSearchDataList, TUISearchConstants.GROUP_TYPE);
                if (callback != null) {
                    callback.onSuccess(groupSearchDataList);
                }
            }
        });
    }

    public void searchConversation(final List<String> keywordList, int pageIndex, IUIKitCallback<List<SearchDataBean>> callback) {
        if (keywordList == null || keywordList.size() <= 0 || conversationAdapter == null) {
            return;
        }
        conversationProvider.searchMessages(keywordList, null, pageIndex, new IUIKitCallback<Pair<Integer, List<SearchMessageBean>>>() {
            @Override
            public void onSuccess(Pair<Integer, List<SearchMessageBean>> data) {
                List<SearchMessageBean> searchMessageBeanList = data.second;
                int totalCount = data.first;
                if (pageIndex == 0) {
                    conversationSearchIdSet.clear();
                    conversationSearchDataBeans.clear();
                    msgCountInConversationMap.clear();
                    if (totalCount == 0) {
                        conversationAdapter.onDataSourceChanged(conversationSearchDataBeans, TUISearchConstants.CONVERSATION_TYPE);
                        TUISearchUtils.callbackOnError(callback, -1, "search conversation , total count is 0");
                        return;
                    }
                }
                conversationAdapter.onTotalCountChanged(totalCount);

                List<String> conversationIdList = new ArrayList<>();
                for (SearchMessageBean searchMessageBean : searchMessageBeanList) {
                    if (conversationSearchIdSet.contains(searchMessageBean.getConversationId())) {
                        continue;
                    }
                    conversationIdList.add(searchMessageBean.getConversationId());
                    msgCountInConversationMap.put(searchMessageBean.getConversationId(), searchMessageBean);
                }

                if (conversationIdList.isEmpty()) {
                    TUISearchUtils.callbackOnSuccess(callback, conversationSearchDataBeans);
                    return;
                }

                conversationProvider.getConversationList(conversationIdList, new IUIKitCallback<List<ConversationInfo>>() {
                    @Override
                    public void onSuccess(List<ConversationInfo> conversationInfoList) {
                        for (ConversationInfo conversationInfo : conversationInfoList) {
                            SearchDataBean searchDataBean = new SearchDataBean();
                            searchDataBean.setConversationID(conversationInfo.getConversationId());
                            searchDataBean.setUserID(conversationInfo.getId());
                            searchDataBean.setGroupID(conversationInfo.getId());
                            searchDataBean.setGroup(conversationInfo.isGroup());
                            searchDataBean.setGroupType(conversationInfo.getGroupType());
                            searchDataBean.setIconPath(conversationInfo.getIconPath());
                            searchDataBean.setTitle(conversationInfo.getTitle());
                            conversationSearchDataBeans.add(searchDataBean);
                            conversationSearchIdSet.add(searchDataBean.getConversationID());
                        }

                        TUISearchLog.i(TAG, "searchDataBeans.size() = " + conversationSearchDataBeans.size());
                        TUISearchLog.i(TAG, "mMsgsInConversationMap.size() = " + msgCountInConversationMap.size());
                        if (conversationSearchDataBeans.size() > 0) {
                            for (int i = 0; i < conversationSearchDataBeans.size(); i++) {
                                SearchMessageBean searchMessageBean = msgCountInConversationMap.get(conversationSearchDataBeans.get(i).getConversationID());
                                if (searchMessageBean != null) {
                                    int count = searchMessageBean.getMessageCount();
                                    if (count == 1) {
                                        conversationSearchDataBeans.get(i).setSubTitle(
                                            conversationProvider.getMessageText(searchMessageBean.getMessageInfoList().get(0)));
                                        conversationSearchDataBeans.get(i).setSubTextMatch(1);
                                    } else if (count > 1) {
                                        conversationSearchDataBeans.get(i).setSubTitle(
                                            count + ServiceInitializer.getAppContext().getString(R.string.chat_records));
                                        conversationSearchDataBeans.get(i).setSubTextMatch(0);
                                    }
                                }
                            }
                        }
                        conversationAdapter.onDataSourceChanged(conversationSearchDataBeans, TUISearchConstants.CONVERSATION_TYPE);
                        TUISearchUtils.callbackOnSuccess(callback, conversationSearchDataBeans);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        conversationAdapter.onDataSourceChanged(conversationSearchDataBeans, TUISearchConstants.CONVERSATION_TYPE);
                        TUISearchUtils.callbackOnError(callback, module, errCode, errMsg);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                conversationAdapter.onDataSourceChanged(conversationSearchDataBeans, TUISearchConstants.CONVERSATION_TYPE);
                conversationAdapter.onTotalCountChanged(conversationSearchDataBeans.size());
                TUISearchUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }
}
