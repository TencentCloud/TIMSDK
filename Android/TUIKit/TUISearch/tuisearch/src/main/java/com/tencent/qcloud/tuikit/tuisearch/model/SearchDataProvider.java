package com.tencent.qcloud.tuikit.tuisearch.model;

import android.text.SpannableString;
import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendSearchParam;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberSearchParam;
import com.tencent.imsdk.v2.V2TIMGroupSearchParam;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageSearchParam;
import com.tencent.imsdk.v2.V2TIMMessageSearchResult;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBeanUtil;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchMessageBean;
import com.tencent.qcloud.tuikit.tuisearch.bean.TUISearchGroupParam;
import com.tencent.qcloud.tuikit.tuisearch.bean.TUISearchGroupResult;
import com.tencent.qcloud.tuikit.tuisearch.util.ConversationUtils;
import com.tencent.qcloud.tuikit.tuisearch.util.GroupInfoUtils;
import com.tencent.qcloud.tuikit.tuisearch.util.MessageInfoUtil;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SearchDataProvider {
    private static final String TAG = SearchDataProvider.class.getSimpleName();

    public static final int CONVERSATION_MESSAGE_PAGE_SIZE = 10;

    public boolean groupInfoFinish = false;
    public boolean groupMemberFullInfofinish = false;

    /**
     * 群搜索
     * @param searchParam 搜索参数
     * 
     * @note 
     * - 搜索时支持匹配群信息，支持匹配群ID、群名称，详见 @TUISearchGroupMatchField
     * - 搜索时支持匹配群成员信息，支持匹配成员ID、匹配成员昵称、匹配成员备注、匹配成员名片，详见 @TUISearchGroupMemberMatchField
     * 
     * 
     * group search
     * @param searchParam
     * 
     * @note 
     * - Support matching group information when searching, support matching group ID and group name, see @TUISearchGroupMatchField for details.
     * - Support matching group member information when searching, support matching member ID, matching member nickname, matching member note, matching member business card, see @TUISearchGroupMemberMatchField for details
     */
    public void searchGroups(final TUISearchGroupParam searchParam, final IUIKitCallback<List<TUISearchGroupResult>> callback) {
        if (searchParam == null || searchParam.getKeywordList().size() == 0) {
            TUISearchLog.e(TAG, "searchParam is null");
            return;
        }

        final List<V2TIMGroupInfo> groupInfos = new ArrayList<>();
        final HashMap<String, List<V2TIMGroupMemberFullInfo>> groupMemberFullInfos = new HashMap<String, List<V2TIMGroupMemberFullInfo>>();

        //search group
        V2TIMGroupSearchParam groupSearchParam = new V2TIMGroupSearchParam();
        groupSearchParam.setKeywordList(searchParam.getKeywordList());
        groupSearchParam.setSearchGroupID(searchParam.isSearchGroupID());
        groupSearchParam.setSearchGroupName(searchParam.isSearchGroupName());
        V2TIMManager.getGroupManager().searchGroups(groupSearchParam, new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                TUISearchLog.d(TAG, "v2TIMGroupInfos.size() = " + v2TIMGroupInfos.size());
                for (V2TIMGroupInfo v2TIMGroupInfo : v2TIMGroupInfos) {
                    groupInfos.add(v2TIMGroupInfo);
                }

                groupInfoFinish = true;
                mergeGroupAndGroupMemberResult(searchParam.getKeywordList(), groupInfos, groupMemberFullInfos, callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                groupInfoFinish = true;
                mergeGroupAndGroupMemberResult(searchParam.getKeywordList(), groupInfos, groupMemberFullInfos, callback);
            }
        });

        //search group member
        V2TIMGroupMemberSearchParam groupMemberSearchParam = new V2TIMGroupMemberSearchParam();
        groupMemberSearchParam.setKeywordList(searchParam.getKeywordList());
        groupMemberSearchParam.setSearchMemberUserID(searchParam.isSearchMemberUserID());
        groupMemberSearchParam.setSearchMemberNickName(searchParam.isSearchMemberNickName());
        groupMemberSearchParam.setSearchMemberNameCard(searchParam.isSearchMemberNameCard());
        groupMemberSearchParam.setSearchMemberRemark(searchParam.isSearchMemberRemark());
        V2TIMManager.getGroupManager().searchGroupMembers(groupMemberSearchParam, new V2TIMValueCallback<HashMap<String, List<V2TIMGroupMemberFullInfo>>>() {
            @Override
            public void onSuccess(HashMap<String, List<V2TIMGroupMemberFullInfo>> v2TIMGroupMemberInfoMap) {
                if (v2TIMGroupMemberInfoMap == null || v2TIMGroupMemberInfoMap.isEmpty()) {
                    groupMemberFullInfos.clear();
                    groupMemberFullInfofinish = true;
                    mergeGroupAndGroupMemberResult(searchParam.getKeywordList(), groupInfos, groupMemberFullInfos, callback);
                    return;
                }

                TUISearchLog.d(TAG, "v2TIMGroupMemberInfoMap.size() = " + v2TIMGroupMemberInfoMap.size());
                for (Map.Entry<String, List<V2TIMGroupMemberFullInfo>> entry : v2TIMGroupMemberInfoMap.entrySet()) {
                    groupMemberFullInfos.put(entry.getKey(), entry.getValue());
                }

                groupMemberFullInfofinish = true;
                mergeGroupAndGroupMemberResult(searchParam.getKeywordList(), groupInfos, groupMemberFullInfos, callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                groupMemberFullInfofinish = true;
                mergeGroupAndGroupMemberResult(searchParam.getKeywordList(), groupInfos, groupMemberFullInfos, callback);
            }
        });
    }

    public void searchContact(List<String> keywordList, IUIKitCallback<List<SearchDataBean>> callBack) {
        V2TIMFriendSearchParam searchParam = new V2TIMFriendSearchParam();
        searchParam.setKeywordList(keywordList);
        searchParam.setSearchUserID(true);
        searchParam.setSearchNickName(true);
        searchParam.setSearchRemark(true);
        V2TIMManager.getFriendshipManager().searchFriends(searchParam, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                List<SearchDataBean> searchDataBeanList = SearchDataBeanUtil.convertFriendInfos2SearchDataBeans(v2TIMFriendInfoResults);
                TUISearchUtils.callbackOnSuccess(callBack, searchDataBeanList);
            }

            @Override
            public void onError(int code, String desc) {
                TUISearchUtils.callbackOnError(callBack, TAG, code, desc);
            }
        });
    }

    public void searchMessages(final List<String> keywordList, String conversationId, int index, IUIKitCallback<Pair<Integer,List<SearchMessageBean>>> callBack) {
        final V2TIMMessageSearchParam v2TIMMessageSearchParam = new V2TIMMessageSearchParam();
        v2TIMMessageSearchParam.setKeywordList(keywordList);
        v2TIMMessageSearchParam.setPageSize(CONVERSATION_MESSAGE_PAGE_SIZE);
        v2TIMMessageSearchParam.setPageIndex(index);
        if (!TextUtils.isEmpty(conversationId)) {
            v2TIMMessageSearchParam.setConversationID(conversationId);
        }
        V2TIMManager.getMessageManager().searchLocalMessages(v2TIMMessageSearchParam, new V2TIMValueCallback<V2TIMMessageSearchResult>() {
            @Override
            public void onSuccess(V2TIMMessageSearchResult v2TIMMessageSearchResult) {
                List<SearchMessageBean> searchMessageBeanList =
                        SearchDataBeanUtil.convertSearchResultItems2SearchMessageBeans(v2TIMMessageSearchResult.getMessageSearchResultItems());
                TUISearchUtils.callbackOnSuccess(callBack, new Pair<>(v2TIMMessageSearchResult.getTotalCount(), searchMessageBeanList));

            }

            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "searchMessages code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                TUISearchUtils.callbackOnError(callBack, TAG, code, desc);

            }
        });
    }

    public void getConversationList(List<String> conversationIdList, IUIKitCallback<List<ConversationInfo>> callBack) {
        V2TIMManager.getConversationManager().getConversationList(conversationIdList, new V2TIMValueCallback<List<V2TIMConversation>>() {
            @Override
            public void onSuccess(List<V2TIMConversation> v2TIMConversationList) {
                List<ConversationInfo> conversationInfoList = ConversationUtils.convertV2TIMConversationList(v2TIMConversationList);
                TUISearchUtils.callbackOnSuccess(callBack, conversationInfoList);

            }

            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "getConversation code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                TUISearchUtils.callbackOnError(callBack, code, desc);
            }
        });
    }

    public String getMessageText(MessageInfo messageInfo) {
        String text = "";
        if (messageInfo != null && messageInfo.getTimMessage().getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            text = (String) messageInfo.getExtra();
        }
        return text;
    }

    private static boolean matcherSearchText(String text, List<String> keywordList) {
        if (text == null || TextUtils.isEmpty(text) || keywordList == null || keywordList.size() == 0) {
            return false;
        }

        String keyword = keywordList.get(0);
        //return text.toLowerCase().contains(keyword.toLowerCase());
        SpannableString spannableString = new SpannableString(text);
        Pattern pattern = Pattern.compile(Pattern.quote(keyword), Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(spannableString);
        while (matcher.find()) {
            return true;
        }

        return false;
    }

    private void mergeGroupAndGroupMemberResult(List<String> keywordList, List<V2TIMGroupInfo> groupInfos, HashMap<String, List<V2TIMGroupMemberFullInfo>> groupMemberFullInfos,
                                                final IUIKitCallback<List<TUISearchGroupResult>> callback) {
        if (!groupInfoFinish || !groupMemberFullInfofinish) {
            return;
        }
        groupInfoFinish = false;
        groupMemberFullInfofinish = false;

        if ((groupInfos == null || groupInfos.size() == 0) && (groupMemberFullInfos == null || groupMemberFullInfos.size() == 0)) {
            if (callback != null) {
                callback.onSuccess(new ArrayList<TUISearchGroupResult>());
            }
            return;
        }

        final List<TUISearchGroupResult> searchGroupResults = new ArrayList<>();

        TUISearchLog.d(TAG, "mergeGroupAndGroupMemberResult groupInfos.size() =" + groupInfos.size() + "groupMemberFullInfos.size() = " + groupMemberFullInfos.size());
        //GroupInfo
        if (groupInfos != null && groupInfos.size() != 0) {
            for (V2TIMGroupInfo v2TIMGroupInfo : groupInfos) {
                // 组装匹配到的群信息数据
                // Assemble the matched group information data
                TUISearchGroupResult searchGroupResult = new TUISearchGroupResult();
                GroupInfo groupInfo = GroupInfoUtils.convertTimGroupInfo2GroupInfo(v2TIMGroupInfo);
                searchGroupResult.setGroupInfo(groupInfo);
                if (matcherSearchText(v2TIMGroupInfo.getGroupName(), keywordList)) {
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NAME);
                    searchGroupResult.setMatchValue(v2TIMGroupInfo.getGroupName());
                } else if (matcherSearchText(v2TIMGroupInfo.getGroupID(), keywordList)) {
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_ID);
                    searchGroupResult.setMatchValue(v2TIMGroupInfo.getGroupID());
                } else {
                    TUISearchLog.d(TAG, "groupInfos have not matched, group id is " + v2TIMGroupInfo.getGroupID());
                    searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE);
                    searchGroupResult.setMatchValue("");
                }
                searchGroupResults.add(searchGroupResult);

                // 移除groupMemberFullInfos中匹配到群信息的数据
                // Remove data matching group information in groupMemberFullInfos
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

        TUISearchLog.d(TAG, "mergeGroupAndGroupMemberResult remove repeat, groupMemberFullInfos.size() = " + groupMemberFullInfos.size());
        //GroupMemberFullInfo
        List<String> groupIDList = new ArrayList<>();// 用来请求 groupInfo 数据 // Used to request groupInfo data
        // 暂存匹配到的群成员数据，缺少 groupInfo 信息 // Temporarily store the matched group member data, but the groupInfo information is missing
        final HashMap<String, TUISearchGroupResult> searchGroupMemberResults = new HashMap<>();
        for (Map.Entry<String, List<V2TIMGroupMemberFullInfo>> entry : groupMemberFullInfos.entrySet()) {
            String groupId = entry.getKey();
            groupIDList.add(groupId);

            // 遍历剩余的匹配到的 groupMemberFullInfos，填充result数据
            // Traverse the remaining matched groupMemberFullInfos and fill in the result data
            TUISearchGroupResult searchGroupResult = new TUISearchGroupResult();
            searchGroupResult.setMatchField(TUISearchGroupParam.TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE);
            searchGroupResult.setMatchValue("");

            // 群成员数据填充
            // fill group member data
            List<TUISearchGroupResult.TUISearchGroupMemberMatchResult> matchMembers = new ArrayList<>();
            for (V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo : entry.getValue()) {
                TUISearchGroupResult.TUISearchGroupMemberMatchResult searchGroupMemberMatchResult = new TUISearchGroupResult.TUISearchGroupMemberMatchResult();
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
                    TUISearchLog.d(TAG, "groupMemberFullInfos have not matched, user id is " + v2TIMGroupMemberFullInfo.getUserID());
                    searchGroupMemberMatchResult.setMemberMatchField(TUISearchGroupParam.TUISearchGroupMemberMatchField.SEARCH_FIELD_MEMBER_NONE);
                    searchGroupMemberMatchResult.setMemberMatchValue("");
                }
                matchMembers.add(searchGroupMemberMatchResult);
            }

            searchGroupResult.setMatchMembers(matchMembers);
            // 群成员数据暂存 searchGroupMemberResults 中，缺少 groupInfo 信息
            // In the temporary storage of group member data searchGroupMemberResults, the groupInfo information is missing
            searchGroupMemberResults.put(groupId, searchGroupResult);
        }
        TUISearchLog.d(TAG, "mergeGroupAndGroupMemberResult searchGroupMemberResults.size() = " + searchGroupMemberResults.size());

        V2TIMManager.getGroupManager().getGroupsInfo(groupIDList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "getGroupsInfo failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                if (callback != null) {
                    callback.onSuccess(searchGroupResults);
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults != null && v2TIMGroupInfoResults.size() > 0) {
                    for (V2TIMGroupInfoResult v2TIMGroupInfoResult : v2TIMGroupInfoResults) {
                        TUISearchGroupResult searchGroupResult = searchGroupMemberResults.get(v2TIMGroupInfoResult.getGroupInfo().getGroupID());
                        if (searchGroupResult != null) {
                            searchGroupResult.setGroupInfo(GroupInfoUtils.convertTimGroupInfo2GroupInfo(v2TIMGroupInfoResult.getGroupInfo()));
                            searchGroupResults.add(searchGroupResult);
                        } else {
                            TUISearchLog.e(TAG, "getGroupsInfo not searchGroupMemberResults.get(v2TIMGroupInfoResult.getGroupInfo().getGroupID(): " + v2TIMGroupInfoResult.getGroupInfo().getGroupID());
                        }
                    }

                    TUISearchLog.d(TAG, "mergeGroupAndGroupMemberResult callback.onSuccess searchGroupResults.size() = " + searchGroupResults.size());
                    if (callback != null) {
                        callback.onSuccess(searchGroupResults);
                    }
                }
            }
        });
    }

    public ChatInfo generateChatInfo(SearchDataBean searchDataBean) {
        ChatInfo chatInfo = new ChatInfo();
        if (searchDataBean.isGroup()) {
            chatInfo.setType(V2TIMConversation.V2TIM_GROUP);
            chatInfo.setId(searchDataBean.getGroupID());
            chatInfo.setGroupType(searchDataBean.getGroupType());
        } else {
            chatInfo.setType(V2TIMConversation.V2TIM_C2C);
            chatInfo.setId(searchDataBean.getUserID());
        }
        String chatName = searchDataBean.getUserID();
        if (!TextUtils.isEmpty(searchDataBean.getRemark())) {
            chatName = searchDataBean.getRemark();
        } else if (!TextUtils.isEmpty(searchDataBean.getNickName())) {
            chatName = searchDataBean.getNickName();
        }
        chatInfo.setChatName(chatName);
        chatInfo.setLocateMessage(MessageInfoUtil.convertTIMMessage2MessageInfo(searchDataBean.getLocateTimMessage()));
        chatInfo.getLocateMessage().setFaceUrl(searchDataBean.getIconPath());
        return chatInfo;
    }
}