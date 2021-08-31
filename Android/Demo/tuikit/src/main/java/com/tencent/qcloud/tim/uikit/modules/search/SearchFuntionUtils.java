package com.tencent.qcloud.tim.uikit.modules.search;

import android.text.SpannableString;
import android.text.TextUtils;
import android.view.View;
import android.widget.RelativeLayout;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendSearchParam;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageTyping;
import com.tencent.qcloud.tim.uikit.modules.search.groupinterface.TUISearchGroupDataProvider;
import com.tencent.qcloud.tim.uikit.modules.search.groupinterface.TUISearchGroupParam;
import com.tencent.qcloud.tim.uikit.modules.search.groupinterface.TUISearchGroupResult;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchDataBean;
import com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter.CONTACT_TYPE;
import static com.tencent.qcloud.tim.uikit.modules.search.model.SearchResultAdapter.GROUP_TYPE;

public class SearchFuntionUtils {
    private static final String TAG = SearchFuntionUtils.class.getSimpleName();

    public static final String CONVERSATION_C2C_PREFIX = "c2c_";
    public static final String CONVERSATION_GROUP_PREFIX = "group_";

    public static final int CONVERSATION_MESSAGE_PAGE_SIZE = 10;

    public static boolean groupInfoFinish = false;
    public static boolean groupMemberFullInfofinish = false;

    public static void SearchContact(final List<String> keywordList, final SearchResultAdapter adapter, final RelativeLayout listLayout, final RelativeLayout moreLayout, final boolean isShowAll, final V2TIMValueCallback<List<SearchDataBean>> callback) {
        if (keywordList == null || keywordList.size() == 0 || adapter == null) {
            TUIKitLog.e(TAG, "param is null");
            return;
        }

        final List<SearchDataBean> mContactSearchData = new ArrayList<>();
        //search contact
        V2TIMFriendSearchParam searchParam = new V2TIMFriendSearchParam();
        searchParam.setKeywordList(keywordList);
        searchParam.setSearchUserID(true);
        searchParam.setSearchNickName(true);
        searchParam.setSearchRemark(true);
        V2TIMManager.getFriendshipManager().searchFriends(searchParam, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendResultInfos) {
                mContactSearchData.clear();
                if (v2TIMFriendResultInfos == null || v2TIMFriendResultInfos.isEmpty()) {
                    TUIKitLog.d(TAG, "searchFriends is null, mContactSearchData.size() = " + mContactSearchData.size());
                    adapter.setDataSource(null, CONTACT_TYPE);
                    listLayout.setVisibility(View.GONE);
                    if (callback != null) {
                        callback.onSuccess(mContactSearchData);
                    }
                    return;
                }

                TUIKitLog.d(TAG, "v2TIMFriendResultInfos.size() = " + v2TIMFriendResultInfos.size());

                if (v2TIMFriendResultInfos != null) {
                    if (v2TIMFriendResultInfos.size() == 0) {
                        listLayout.setVisibility(View.GONE);
                        adapter.setDataSource(null, CONTACT_TYPE);
                        if (callback != null) {
                            callback.onSuccess(mContactSearchData);
                        }
                        return;
                    }

                    if (v2TIMFriendResultInfos.size() > 0) {
                        listLayout.setVisibility(View.VISIBLE);
                        if (!isShowAll) {
                            if (v2TIMFriendResultInfos.size() > 3) {
                                moreLayout.setVisibility(View.VISIBLE);
                            } else {
                                moreLayout.setVisibility(View.GONE);
                            }
                        }
                    }

                    //List<SearchDataBean> dataBeans = new ArrayList<>();
                    for (int i = 0; i < v2TIMFriendResultInfos.size(); i++) {
                        V2TIMFriendInfo v2TIMFriendInfo = v2TIMFriendResultInfos.get(i).getFriendInfo();
                        SearchDataBean dataBean = new SearchDataBean();
                        dataBean.setIconPath(v2TIMFriendInfo.getUserProfile().getFaceUrl());
                        dataBean.setTitle(v2TIMFriendInfo.getUserProfile().getUserID());
                        if (!TextUtils.isEmpty(v2TIMFriendInfo.getFriendRemark())) {
                            dataBean.setSubTitle(TUIKit.getAppContext().getString(R.string.nick_name) + v2TIMFriendInfo.getFriendRemark());
                        } else if (!TextUtils.isEmpty(v2TIMFriendInfo.getUserProfile().getNickName())) {
                            dataBean.setSubTitle(TUIKit.getAppContext().getString(R.string.nick_name) + v2TIMFriendInfo.getUserProfile().getNickName());
                        } else if (!TextUtils.isEmpty(v2TIMFriendInfo.getUserID())) {
                            dataBean.setSubTitle(TUIKit.getAppContext().getString(R.string.nick_name) + v2TIMFriendInfo.getUserID());
                        }
                        dataBean.setType(CONTACT_TYPE);

                        dataBean.setUserID(v2TIMFriendInfo.getUserProfile().getUserID());
                        dataBean.setNickname(v2TIMFriendInfo.getUserProfile().getNickName());
                        dataBean.setRemark(v2TIMFriendInfo.getFriendRemark());
                        mContactSearchData.add(dataBean);
                    }

                    adapter.setDataSource(mContactSearchData, CONTACT_TYPE);
                    adapter.setIsShowAll(isShowAll);
                    if (callback != null) {
                        callback.onSuccess(mContactSearchData);
                    }
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "code = " + code + ", desc = " + desc);
                if (callback != null) {
                    callback.onSuccess(mContactSearchData);
                }
            }
        });
    }

    public static void SearchGroup(final List<String> keywordList, final SearchResultAdapter adapter, final RelativeLayout listLayout, final RelativeLayout moreLayout, final boolean isShowAll, final V2TIMValueCallback<List<SearchDataBean>> callback) {
        if (keywordList == null || keywordList.size() == 0 || adapter == null) {
            TUIKitLog.e(TAG, "param is null");
            return;
        }

        final List<SearchDataBean> mGroupSearchData = new ArrayList<>();
        final List<TUISearchGroupResult> searchGroupResults = new ArrayList<>();
        List<Integer> searchMatchFieldList = new ArrayList<Integer>() {{
            add(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_ID);
            add(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NAME);
        }};
        List<Integer> searchMemberMatchFieldList = new ArrayList<Integer>() {{
            add(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_USER_ID);
            add(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NICK_NAME);
            add(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NAME_CARD);
            add(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_REMARK);
        }};
        TUISearchGroupParam searchParam = new TUISearchGroupParam();
        searchParam.setKeywordList(keywordList);
        searchParam.setSearchGroupID(true);
        searchParam.setSearchGroupName(true);

        searchParam.setSearchMemberUserID(true);
        searchParam.setSearchMemberNickName(true);
        searchParam.setSearchMemberNameCard(true);
        searchParam.setSearchMemberRemark(true);
        TUISearchGroupDataProvider.searchGroups(searchParam, new V2TIMValueCallback<List<TUISearchGroupResult>>() {

            @Override
            public void onSuccess(List<TUISearchGroupResult> tuiSearchGroupResults) {
                mGroupSearchData.clear();
                if (tuiSearchGroupResults == null || tuiSearchGroupResults.isEmpty()) {
                    TUIKitLog.d(TAG, "searchGroups is null, tuiSearchGroupResults.size() = " + tuiSearchGroupResults.size());
                    adapter.setDataSource(null, GROUP_TYPE);
                    listLayout.setVisibility(View.GONE);
                    moreLayout.setVisibility(View.GONE);
                    if (callback != null) {
                        callback.onSuccess(mGroupSearchData);
                    }
                    return;
                }

                TUIKitLog.d(TAG, "tuiSearchGroupResults.size() = " + tuiSearchGroupResults.size());

                if (tuiSearchGroupResults.size() > 0) {
                    listLayout.setVisibility(View.VISIBLE);
                    if (!isShowAll) {
                        if (tuiSearchGroupResults.size() > 3) {
                            moreLayout.setVisibility(View.VISIBLE);
                        } else {
                            moreLayout.setVisibility(View.GONE);
                        }
                    }
                }

                for (int i = 0; i < tuiSearchGroupResults.size(); i++) {
                    TUISearchGroupResult searchGroupResult = tuiSearchGroupResults.get(i);
                    SearchDataBean dataBean = new SearchDataBean();
                    V2TIMGroupInfo groupInfo = searchGroupResult.getGroupInfo();
                    String groupId = groupInfo.getGroupID();
                    dataBean.setGroupID(groupId);
                    dataBean.setGroupName(groupInfo.getGroupName());
                    dataBean.setGroupType(groupInfo.getGroupType());
                    dataBean.setRemark(groupInfo.getGroupName());
                    dataBean.setIconPath(groupInfo.getFaceUrl());
                    if (searchGroupResult.getMatchField() == TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_ID) {
                        dataBean.setTitle(groupInfo.getGroupName());
                        dataBean.setSubTitle(TUIKit.getAppContext().getString(R.string.include_group_id) + groupId);
                    } else if (searchGroupResult.getMatchField() == TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NAME) {
                        dataBean.setTitle(groupInfo.getGroupName());
                    } else {
                        dataBean.setTitle(groupInfo.getGroupName());
                        if (searchGroupResult.getMatchMembers() != null && !searchGroupResult.getMatchMembers().isEmpty()) {
                            TUISearchGroupResult.TUISearchGroupMemberMatchResult searchGroupMemberMatchResult = searchGroupResult.getMatchMembers().get(0);
                            if (searchGroupMemberMatchResult.getMemberMatchField() != TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NONE) {
                                dataBean.setSubTitle(TUIKit.getAppContext().getString(R.string.include_group_member) + searchGroupMemberMatchResult.getMemberMatchValue());
                            } else {
                                dataBean.setSubTitle("");
                            }
                        }
                    }
                    dataBean.setType(GROUP_TYPE);
                    mGroupSearchData.add(dataBean);
                }

                adapter.setDataSource(mGroupSearchData, GROUP_TYPE);
                adapter.setIsShowAll(isShowAll);

                if (callback != null) {
                    callback.onSuccess(mGroupSearchData);
                }
            }

            @Override
            public void onError(int code, String desc) {
                adapter.setDataSource(mGroupSearchData, GROUP_TYPE);
                adapter.setIsShowAll(isShowAll);
                if (callback != null) {
                    callback.onSuccess(mGroupSearchData);
                }
            }
        });
    }

    private static boolean isTyping(byte[] data) {
        try {
            String str = new String(data, "UTF-8");
            MessageTyping typing = new Gson().fromJson(str, MessageTyping.class);
            if (typing != null
                    && typing.userAction == MessageTyping.TYPE_TYPING
                    && TextUtils.equals(typing.actionParam, MessageTyping.EDIT_START)) {
                return true;
            }
            return false;
        } catch (Exception e) {
            TUIKitLog.e(TAG, "parse json error");
        }
        return false;
    }

    public static String getMessageText(V2TIMMessage timMessage) {
        if (timMessage == null) {
            return "";
        }
        String text = "";
        MessageInfo messageInfo = MessageInfoUtil.createMessageInfo(timMessage);
        if (messageInfo != null && timMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            text = (String) messageInfo.getExtra();
        }
        return text;
    }

    private static boolean matcherSearchText(String text, List<String> keywordList) {
        if (text == null || TextUtils.isEmpty(text) || keywordList == null || keywordList.size() == 0) {
            return false;
        }

        //目前只是单字段搜索
        String keyword = keywordList.get(0);
        //return text.toLowerCase().contains(keyword.toLowerCase());
        SpannableString spannableString = new SpannableString(text);
        //条件 keyword
        Pattern pattern = Pattern.compile(Pattern.quote(keyword), Pattern.CASE_INSENSITIVE);
        //匹配
        Matcher matcher = pattern.matcher(spannableString);
        while (matcher.find()) {
            return true;
        }

        return false;
    }

    public static void mergeGroupAndGroupMemberResult(List<String> keywordList, List<V2TIMGroupInfo> groupInfos, HashMap<String, List<V2TIMGroupMemberFullInfo>> groupMemberFullInfos,
                                                final V2TIMValueCallback<List<TUISearchGroupResult>> callback) {
        if (!groupInfoFinish || !groupMemberFullInfofinish) {
            return;
        }
        groupInfoFinish = false;
        groupMemberFullInfofinish = false;

        if ((groupInfos == null || groupInfos.size() == 0) && (groupMemberFullInfos == null || groupMemberFullInfos.size() == 0)) {
            if (callback != null) {
                callback.onSuccess(new ArrayList<TUISearchGroupResult> ());
            }
            return;
        }

        final List<TUISearchGroupResult> searchGroupResults = new ArrayList<>();

        TUIKitLog.d(TAG, "mergeGroupAndGroupMemberResult groupInfos.size() =" + groupInfos.size() + "groupMemberFullInfos.size() = " + groupMemberFullInfos.size());
        //GroupInfo
        if (groupInfos != null && groupInfos.size() != 0) {
            for (V2TIMGroupInfo v2TIMGroupInfo : groupInfos) {
                //组装匹配到的群信息数据
                TUISearchGroupResult searchGroupResult = new TUISearchGroupResult();
                searchGroupResult.setGroupInfo(v2TIMGroupInfo);
                // 优先匹配群名称，其次群 ID
                if (matcherSearchText(v2TIMGroupInfo.getGroupName(), keywordList)) {
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NAME);
                    searchGroupResult.setMatchValue(v2TIMGroupInfo.getGroupName());
                } else if (matcherSearchText(v2TIMGroupInfo.getGroupID(), keywordList)) {
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_ID);
                    searchGroupResult.setMatchValue(v2TIMGroupInfo.getGroupID());
                } else {
                    TUIKitLog.d(TAG, "groupInfos have not matched, group id is " + v2TIMGroupInfo.getGroupID());
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE);
                    searchGroupResult.setMatchValue("");
                }
                searchGroupResults.add(searchGroupResult);

                //移除groupMemberFullInfos中匹配到群信息的数据
                Iterator iterator = groupMemberFullInfos.keySet().iterator();
                while (iterator.hasNext()) {
                    String key = (String) iterator.next();
                    if (v2TIMGroupInfo.getGroupID().equals(key)) {
                        iterator.remove();
                        //groupMemberFullInfos.remove(key);
                    }
                }
            }
        }

        TUIKitLog.d(TAG, "mergeGroupAndGroupMemberResult remove repeat, groupMemberFullInfos.size() = " + groupMemberFullInfos.size());
        //GroupMemberFullInfo
        List<String> groupIDList = new ArrayList<>();//用来请求 groupInfo 数据
        final HashMap<String, TUISearchGroupResult> searchGroupMemberResults = new HashMap<>();//暂存匹配到的群成员数据，缺少 groupInfo 信息
        for (Map.Entry<String, List<V2TIMGroupMemberFullInfo>> entry : groupMemberFullInfos.entrySet()) {
            String groupId = entry.getKey();
            groupIDList.add(groupId);

            //遍历剩余的匹配到的 groupMemberFullInfos，填充result数据
            TUISearchGroupResult searchGroupResult = new TUISearchGroupResult();
            searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE);
            searchGroupResult.setMatchValue("");

            //群成员数据填充
            List<TUISearchGroupResult.TUISearchGroupMemberMatchResult> matchMembers = new ArrayList<>();
            for (V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo : entry.getValue()) {
                TUISearchGroupResult.TUISearchGroupMemberMatchResult searchGroupMemberMatchResult = new TUISearchGroupResult.TUISearchGroupMemberMatchResult();
                searchGroupMemberMatchResult.setMemberInfo(v2TIMGroupMemberFullInfo);
                // 优先级：群名片>好友备注>昵称>userID
                if (matcherSearchText(v2TIMGroupMemberFullInfo.getNameCard(), keywordList)) {
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NAME_CARD);
                    searchGroupMemberMatchResult.setMemberMatchValue(v2TIMGroupMemberFullInfo.getNameCard());
                } else if (matcherSearchText(v2TIMGroupMemberFullInfo.getFriendRemark(), keywordList)) {
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_REMARK);
                    searchGroupMemberMatchResult.setMemberMatchValue(v2TIMGroupMemberFullInfo.getFriendRemark());
                } else if (matcherSearchText(v2TIMGroupMemberFullInfo.getNickName(), keywordList)) {
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NICK_NAME);
                    searchGroupMemberMatchResult.setMemberMatchValue(v2TIMGroupMemberFullInfo.getNickName());
                } else if (matcherSearchText(v2TIMGroupMemberFullInfo.getUserID(), keywordList)) {
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_USER_ID);
                    searchGroupMemberMatchResult.setMemberMatchValue(v2TIMGroupMemberFullInfo.getUserID());
                } else {
                    TUIKitLog.d(TAG, "groupMemberFullInfos have not matched, user id is " + v2TIMGroupMemberFullInfo.getUserID());
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NONE);
                    searchGroupMemberMatchResult.setMemberMatchValue("");
                    searchGroupMemberMatchResult.setMemberInfo(v2TIMGroupMemberFullInfo);
                }
                matchMembers.add(searchGroupMemberMatchResult);
            }

            searchGroupResult.setMatchMembers(matchMembers);
            //群成员数据暂存 searchGroupMemberResults 中，缺少 groupInfo 信息
            searchGroupMemberResults.put(groupId, searchGroupResult);
        }
        TUIKitLog.d(TAG, "mergeGroupAndGroupMemberResult searchGroupMemberResults.size() = " + searchGroupMemberResults.size());

        V2TIMManager.getGroupManager().getGroupsInfo(groupIDList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "getGroupsInfo failed, code: " + code + "|desc: " + desc);
                if (callback != null) {
                    callback.onSuccess(searchGroupResults);
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults != null && v2TIMGroupInfoResults.size() > 0) {
                    for (V2TIMGroupInfoResult v2TIMGroupInfoResult : v2TIMGroupInfoResults) {
                        TUISearchGroupResult searchGroupResult  = searchGroupMemberResults.get(v2TIMGroupInfoResult.getGroupInfo().getGroupID());
                        if (searchGroupResult != null) {
                            searchGroupResult.setGroupInfo(v2TIMGroupInfoResult.getGroupInfo());
                            searchGroupResults.add(searchGroupResult);
                        } else {
                            TUIKitLog.e(TAG, "getGroupsInfo not searchGroupMemberResults.get(v2TIMGroupInfoResult.getGroupInfo().getGroupID(): " + v2TIMGroupInfoResult.getGroupInfo().getGroupID());
                        }
                    }

                    TUIKitLog.d(TAG, "mergeGroupAndGroupMemberResult callback.onSuccess searchGroupResults.size() = " + searchGroupResults.size());
                    if (callback != null) {
                        callback.onSuccess(searchGroupResults);
                    }
                }
            }
        });
    }
}
