package com.tencent.qcloud.tuikit.tuicommunity.model;

import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.COMMUNITY_CUSTOM_INFO_COVER_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.TOPIC_CUSTOM_STRING_TOPIC_CATEGORY_KEY;
import static com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants.TOPIC_CUSTOM_STRING_TOPIC_TYPE_KEY;

import android.text.TextUtils;
import android.util.Pair;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMTopicInfoResult;
import com.tencent.imsdk.v2.V2TIMTopicOperationResult;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityParser;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CommunityProvider {
    public static final String TAG = CommunityProvider.class.getSimpleName();

    public void getJoinedCommunityList(IUIKitCallback<List<CommunityBean>> callback) {
        V2TIMManager.getGroupManager().getJoinedCommunityList(new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                List<CommunityBean> communityBeans = CommunityParser.parseCommunityGroup(v2TIMGroupInfos);
                CommunityUtil.callbackOnSuccess(callback, communityBeans);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getCommunityBean(String groupID, IUIKitCallback<CommunityBean> callback) {
        if (!CommunityUtil.isCommunityGroup(groupID)) {
            CommunityUtil.callbackOnError(callback, -1, "this groupType is not community");
            return;
        }
        List<String> groupIDs = new ArrayList<>();
        groupIDs.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDs, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                V2TIMGroupInfoResult result = v2TIMGroupInfoResults.get(0);
                if (result.getResultCode() == 0) {
                    V2TIMGroupInfo groupInfo = result.getGroupInfo();
                    if (groupInfo.isSupportTopic()) {
                        CommunityBean communityBean = CommunityParser.parseCommunityGroup(groupInfo);
                        CommunityUtil.callbackOnSuccess(callback, communityBean);
                    } else {
                        CommunityUtil.callbackOnError(callback, -1, "not support topic");
                    }
                } else {
                    CommunityUtil.callbackOnError(callback, result.getResultCode(), result.getResultMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void createCommunityGroup(CommunityBean communityBean, IUIKitCallback<String> callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupType(V2TIMManager.GROUP_TYPE_COMMUNITY);
        if (!TextUtils.isEmpty(communityBean.getCommunityName())) {
            v2TIMGroupInfo.setGroupName(communityBean.getCommunityName());
        }
        if (!TextUtils.isEmpty(communityBean.getGroupFaceUrl())) {
            v2TIMGroupInfo.setFaceUrl(communityBean.getGroupFaceUrl());
        }
        if (!TextUtils.isEmpty(communityBean.getIntroduction())) {
            v2TIMGroupInfo.setIntroduction(communityBean.getIntroduction());
        }

        Map<String, byte[]> map = new HashMap<>();
        if (!TextUtils.isEmpty(communityBean.getCoverUrl())) {
            map.put(COMMUNITY_CUSTOM_INFO_COVER_KEY, communityBean.getCoverUrl().getBytes());
        }

        Gson gson = new Gson();
        map.put(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY, gson.toJson(communityBean.getTopicCategories()).getBytes());
        v2TIMGroupInfo.setCustomInfo(map);

        v2TIMGroupInfo.setSupportTopic(true);
        V2TIMManager.getGroupManager().createGroup(v2TIMGroupInfo, null, new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                CommunityUtil.callbackOnSuccess(callback, s);
            }

            @Override
            public void onError(int i, String s) {
                CommunityUtil.callbackOnError(callback, i, s);
            }
        });
    }

    public void createTopic(String groupID, TopicBean topicBean, IUIKitCallback<String> callback) {
        V2TIMTopicInfo v2TIMTopicInfo = new V2TIMTopicInfo();
        v2TIMTopicInfo.setTopicName(topicBean.getTopicName());
        v2TIMTopicInfo.setTopicFaceUrl(topicBean.getFaceUrl());
        v2TIMTopicInfo.setAllMute(topicBean.isAllMute());
        Map<String, Object> map = new HashMap<>();
        map.put(TOPIC_CUSTOM_STRING_TOPIC_CATEGORY_KEY, topicBean.getCategory());
        map.put(TOPIC_CUSTOM_STRING_TOPIC_TYPE_KEY, topicBean.getType());
        Gson gson = new Gson();
        v2TIMTopicInfo.setCustomString(gson.toJson(map));

        V2TIMManager.getGroupManager().createTopicInCommunity(groupID, v2TIMTopicInfo, new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                CommunityUtil.callbackOnSuccess(callback, s);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyTopicCategory(TopicBean topicBean, String category, IUIKitCallback<Void> callback) {
        V2TIMTopicInfo v2TIMTopicInfo = topicBean.getV2TIMTopicInfo();
        Gson gson = new Gson();
        Map<String, Object> map = gson.fromJson(v2TIMTopicInfo.getCustomString(), Map.class);
        if (map == null) {
            map = new HashMap<>();
        }
        map.put(TOPIC_CUSTOM_STRING_TOPIC_CATEGORY_KEY, category);
        map.put(TOPIC_CUSTOM_STRING_TOPIC_TYPE_KEY, topicBean.getType());
        v2TIMTopicInfo.setCustomString(gson.toJson(map));
        V2TIMManager.getGroupManager().setTopicInfo(v2TIMTopicInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getTopicList(String groupID, List<String> topicIDList, IUIKitCallback<List<TopicBean>> callback) {
        V2TIMManager.getGroupManager().getTopicInfoList(groupID, topicIDList, new V2TIMValueCallback<List<V2TIMTopicInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicInfoResult> v2TIMTopicInfoResults) {
                List<V2TIMTopicInfo> timGroupInfoList = new ArrayList<>();
                for (V2TIMTopicInfoResult result : v2TIMTopicInfoResults) {
                    timGroupInfoList.add(result.getTopicInfo());
                }
                List<TopicBean> topicBeanList = CommunityParser.parseTopicBeanList(timGroupInfoList);
                CommunityUtil.callbackOnSuccess(callback, topicBeanList);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getSelfFaceUrl(IUIKitCallback<String> callback) {
        List<String> userIDList = new ArrayList<>();
        userIDList.add(V2TIMManager.getInstance().getLoginUser());
        V2TIMManager.getInstance().getUsersInfo(userIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                V2TIMUserFullInfo info = v2TIMUserFullInfos.get(0);
                CommunityUtil.callbackOnSuccess(callback, info.getFaceUrl());
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getGroupNameCard(String groupID, IUIKitCallback<String> callback) {
        List<String> userIDList = new ArrayList<>();
        userIDList.add(V2TIMManager.getInstance().getLoginUser());
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupID, userIDList, new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                CommunityUtil.callbackOnSuccess(callback, v2TIMGroupMemberFullInfos.get(0).getNameCard());
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyTopicName(String topicID, String name, IUIKitCallback<Void> callback) {
        V2TIMTopicInfo v2TIMTopicInfo = new V2TIMTopicInfo();
        v2TIMTopicInfo.setTopicID(topicID);
        v2TIMTopicInfo.setTopicName(name);
        V2TIMManager.getGroupManager().setTopicInfo(v2TIMTopicInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void deleteTopic(String groupID, String topicID, IUIKitCallback<Void> callback) {
        List<String> topicList = new ArrayList<>();
        topicList.add(topicID);
        V2TIMManager.getGroupManager().deleteTopicFromCommunity(groupID, topicList, new V2TIMValueCallback<List<V2TIMTopicOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicOperationResult> v2TIMTopicOperationResults) {
                V2TIMTopicOperationResult result = v2TIMTopicOperationResults.get(0);
                if (result.getErrorCode() == 0) {
                    CommunityUtil.callbackOnSuccess(callback, null);
                    TUICore.notifyEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_DELETE_TOPIC, null);
                } else {
                    CommunityUtil.callbackOnError(callback, result.getErrorCode(), result.getErrorMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void deleteTopicCategory(TopicBean topicBean, IUIKitCallback<Void> callback) {
        modifyTopicCategory(topicBean, "", callback);
    }

    public void loadCommunityMembers(String groupID, int filter, long nextSeq, final IUIKitCallback<Pair<List<CommunityMemberBean>, Long>> callBack) {
        if (filter != V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL && filter != V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_OWNER
            && filter != V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ADMIN && filter != V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON) {
            filter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL;
        }
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, nextSeq, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                TUICommunityLog.e(TAG, "loadCommunityMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                CommunityUtil.callbackOnError(callBack, code, desc);
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<CommunityMemberBean> members = CommunityParser.parseCommunityMemberBeanList(v2TIMGroupMemberInfoResult.getMemberInfoList());
                CommunityUtil.callbackOnSuccess(callBack, new Pair<>(members, v2TIMGroupMemberInfoResult.getNextSeq()));
            }
        });
    }

    public void joinCommunity(String groupID, String message, IUIKitCallback<Void> callback) {
        V2TIMManager.getInstance().joinGroup(groupID, message, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
                TUICore.notifyEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_ADD_COMMUNITY, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void createCategory(String groupID, String category, IUIKitCallback<Void> callback) {
        if (TextUtils.isEmpty(category)) {
            CommunityUtil.callbackOnError(callback, -1, "category is empty");
            return;
        }
        List<String> groupIDs = new ArrayList<>();
        groupIDs.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDs, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults.get(0).getResultCode() == 0) {
                    V2TIMGroupInfo groupInfo = v2TIMGroupInfoResults.get(0).getGroupInfo();
                    Map<String, byte[]> customMap = groupInfo.getCustomInfo();
                    if (customMap == null) {
                        customMap = new HashMap<>();
                    }
                    byte[] categoriesByteArray;
                    Gson gson = new Gson();
                    if (customMap.containsKey(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY)) {
                        categoriesByteArray = customMap.get(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY);
                        try {
                            List<String> categoryList = gson.fromJson(new String(categoriesByteArray), List.class);
                            if (categoryList == null) {
                                categoryList = new ArrayList<>();
                            }
                            categoryList.add(category);
                            categoriesByteArray = gson.toJson(categoryList).getBytes();
                        } catch (JsonParseException parseException) {
                            CommunityUtil.callbackOnError(callback, -1, parseException.getMessage());
                            return;
                        }
                    } else {
                        List<String> categoryList = new ArrayList<>();
                        categoryList.add(category);
                        categoriesByteArray = gson.toJson(categoryList).getBytes();
                    }
                    customMap.put(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY, categoriesByteArray);
                    V2TIMGroupInfo modifyInfo = groupInfo;
                    groupInfo.setCustomInfo(customMap);
                    V2TIMManager.getGroupManager().setGroupInfo(modifyInfo, new V2TIMCallback() {
                        @Override
                        public void onSuccess() {
                            CommunityUtil.callbackOnSuccess(callback, null);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            CommunityUtil.callbackOnError(callback, code, desc);
                        }
                    });
                } else {
                    CommunityUtil.callbackOnError(callback, v2TIMGroupInfoResults.get(0).getResultCode(), v2TIMGroupInfoResults.get(0).getResultMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void deleteCategory(String groupID, String category, IUIKitCallback<Void> callback) {
        if (TextUtils.isEmpty(category)) {
            CommunityUtil.callbackOnError(callback, -1, "category is empty");
            return;
        }
        List<String> groupIDs = new ArrayList<>();
        groupIDs.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDs, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults.get(0).getResultCode() == 0) {
                    V2TIMGroupInfo groupInfo = v2TIMGroupInfoResults.get(0).getGroupInfo();
                    Map<String, byte[]> customMap = groupInfo.getCustomInfo();
                    if (customMap == null) {
                        CommunityUtil.callbackOnSuccess(callback, null);
                        return;
                    }
                    byte[] categoriesByteArray;
                    Gson gson = new Gson();
                    if (customMap.containsKey(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY)) {
                        categoriesByteArray = customMap.get(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY);
                        try {
                            List<String> categoryList = gson.fromJson(new String(categoriesByteArray), List.class);
                            if (categoryList == null) {
                                CommunityUtil.callbackOnSuccess(callback, null);
                                return;
                            }
                            categoryList.remove(category);
                            categoriesByteArray = gson.toJson(categoryList).getBytes();
                            customMap.put(COMMUNITY_CUSTOM_INFO_TOPIC_CATEGORY_KEY, categoriesByteArray);
                            V2TIMGroupInfo modifyInfo = groupInfo;
                            groupInfo.setCustomInfo(customMap);
                            V2TIMManager.getGroupManager().setGroupInfo(modifyInfo, new V2TIMCallback() {
                                @Override
                                public void onSuccess() {
                                    CommunityUtil.callbackOnSuccess(callback, null);
                                }

                                @Override
                                public void onError(int code, String desc) {
                                    CommunityUtil.callbackOnError(callback, code, desc);
                                }
                            });
                        } catch (JsonParseException parseException) {
                            CommunityUtil.callbackOnError(callback, -1, parseException.getMessage());
                        }
                    } else {
                        CommunityUtil.callbackOnSuccess(callback, null);
                    }
                } else {
                    CommunityUtil.callbackOnError(callback, v2TIMGroupInfoResults.get(0).getResultCode(), v2TIMGroupInfoResults.get(0).getResultMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void quitCommunity(String groupID, IUIKitCallback<Void> callback) {
        V2TIMManager.getInstance().quitGroup(groupID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void disbandCommunity(String groupID, IUIKitCallback<Void> callback) {
        V2TIMManager.getInstance().dismissGroup(groupID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
                TUICore.notifyEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_DISBAND_COMMUNITY, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void removeGroupMembers(String groupId, List<String> members, final IUIKitCallback<List<String>> callBack) {
        if (members == null || members.size() == 0) {
            return;
        }

        V2TIMManager.getGroupManager().kickGroupMember(groupId, members, "", new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUICommunityLog.e(TAG, "removeGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                CommunityUtil.callbackOnError(callBack, code, ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                List<String> dels = new ArrayList<>();
                for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                    V2TIMGroupMemberOperationResult res = v2TIMGroupMemberOperationResults.get(i);
                    if (res.getResult() == V2TIMGroupMemberOperationResult.OPERATION_RESULT_SUCC) {
                        dels.add(res.getMemberID());
                    }
                }
                CommunityUtil.callbackOnSuccess(callBack, dels);
            }
        });
    }

    public void inviteGroupMembers(String groupID, List<String> addMembers, final IUIKitCallback<List<String>> callBack) {
        if (addMembers == null || addMembers.size() == 0) {
            return;
        }

        V2TIMManager.getGroupManager().inviteUserToGroup(groupID, addMembers, new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUICommunityLog.e(TAG, "addGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                CommunityUtil.callbackOnError(callBack, code, ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                final List<String> adds = new ArrayList<>();
                if (v2TIMGroupMemberOperationResults.size() > 0) {
                    for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                        V2TIMGroupMemberOperationResult res = v2TIMGroupMemberOperationResults.get(i);
                        if (res.getResult() == V2TIMGroupMemberOperationResult.OPERATION_RESULT_PENDING) {
                            continue;
                        }
                        if (res.getResult() > 0) {
                            adds.add(res.getMemberID());
                        }
                    }
                }
                CommunityUtil.callbackOnSuccess(callBack, adds);
            }
        });
    }

    public void modifyCommunityAvatar(String groupID, String groupFaceUrl, IUIKitCallback<Void> callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupID(groupID);
        v2TIMGroupInfo.setFaceUrl(groupFaceUrl);
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyCommunityCover(String groupID, String groupCoverUrl, IUIKitCallback<Void> callback) {
        List<String> groupIDs = new ArrayList<>();
        groupIDs.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDs, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                V2TIMGroupInfoResult result = v2TIMGroupInfoResults.get(0);
                if (result.getResultCode() == 0) {
                    V2TIMGroupInfo v2TIMGroupInfo = result.getGroupInfo();
                    Map<String, byte[]> map = new HashMap<>();
                    if (!TextUtils.isEmpty(groupCoverUrl)) {
                        map.put(COMMUNITY_CUSTOM_INFO_COVER_KEY, groupCoverUrl.getBytes());
                    }
                    if (!map.isEmpty()) {
                        v2TIMGroupInfo.setCustomInfo(map);
                    }
                    V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
                        @Override
                        public void onSuccess() {
                            CommunityUtil.callbackOnSuccess(callback, null);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            CommunityUtil.callbackOnError(callback, code, desc);
                        }
                    });
                } else {
                    CommunityUtil.callbackOnError(callback, result.getResultCode(), result.getResultMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void transferGroupOwner(String groupID, String newOwnerID, IUIKitCallback<Void> callback) {
        V2TIMManager.getGroupManager().transferGroupOwner(groupID, newOwnerID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyCommunityName(String groupID, String name, IUIKitCallback<Void> callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setGroupName(name);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyCommunityIntroduction(String groupID, String introduction, IUIKitCallback<Void> callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setIntroduction(introduction);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }

    public void modifyCommunitySelfNameCard(String groupID, String nameCard, IUIKitCallback<Void> callback) {
        V2TIMGroupMemberFullInfo v2TIMGroupMemberInfo = new V2TIMGroupMemberFullInfo();
        v2TIMGroupMemberInfo.setUserID(TUILogin.getLoginUser());
        v2TIMGroupMemberInfo.setNameCard(nameCard);
        V2TIMManager.getGroupManager().setGroupMemberInfo(groupID, v2TIMGroupMemberInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommunityUtil.callbackOnError(callback, code, desc);
            }
        });
    }
}
