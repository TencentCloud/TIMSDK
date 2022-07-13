package com.reactnativetimjs.manager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.reactnativetimjs.util.CommonUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMCreateGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupApplicationResult;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberSearchParam;
import com.tencent.imsdk.v2.V2TIMGroupSearchParam;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessageSearchParam;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMTopicInfoResult;
import com.tencent.imsdk.v2.V2TIMTopicOperationResult;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class GroupManager {

    public void createGroup(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String groupType = arguments.getString("groupType");
        String groupName = arguments.getString("groupName");
        String notification = arguments.getString("notification");
        String introduction = arguments.getString("introduction");
        String faceUrl = arguments.getString("faceUrl");
        boolean isAllMuted = arguments.getBoolean("isAllMuted");
        int addOpt = arguments.getInt("addOpt");
        boolean isSupportTopic = arguments.getBoolean("isSupportTopic");

        V2TIMGroupInfo info = new V2TIMGroupInfo();
        if (groupID != null) {
            info.setGroupID(groupID);
        }
        if (groupType != null) {
            info.setGroupType(groupType);
        }
        if (groupName != null) {
            info.setGroupName(groupName);
        }
        if (notification != null) {
            info.setNotification(notification);
        }
        if (introduction != null) {
            info.setIntroduction(introduction);
        }
        if (faceUrl != null) {
            info.setFaceUrl(faceUrl);
        }
        // if (isAllMuted != null) {
        info.setAllMuted(isAllMuted);
        // }
        // if (addOpt != null) {
        info.setGroupAddOpt(addOpt);
        // }
        // if (isSupportTopic != null) {
        info.setSupportTopic(isSupportTopic);
        // }
        List<V2TIMCreateGroupMemberInfo> memberList = new LinkedList<V2TIMCreateGroupMemberInfo>();
        if (arguments.getArray("memberList") != null) {
            List<HashMap<String, Object>> list = CommonUtils
                    .convertReadableArrayToListHashMap(arguments.getArray("memberList"));
            if (list.size() > 0) {
                for (int i = 0; i < list.size(); i++) {
                    V2TIMCreateGroupMemberInfo minfo = new V2TIMCreateGroupMemberInfo();

                    int role = (int) list.get(i).get("role");
                    String userID = (String) list.get(i).get("userID");

                    minfo.setRole(role);
                    minfo.setUserID(userID);
                    memberList.add(minfo);
                }
            }
        }

        V2TIMManager.getGroupManager().createGroup(info, memberList, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(String s) {
                CommonUtils.returnSuccess(promise, s);
            }
        });
    }

    public void getJoinedGroupList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getGroupManager().getJoinedGroupList(new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMGroupInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupInfoToMap(v2TIMGroupInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }
        });
    }

    public void getGroupsInfo(Promise promise, ReadableMap arguments) {
        List<String> groupIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("groupIDList"));
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMGroupInfoResults.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupInfoResultToMap(v2TIMGroupInfoResults.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }
        });
    }

    public void setGroupInfo(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String groupType = arguments.getString("groupType");
        String groupName = arguments.getString("groupName");
        String notification = arguments.getString("notification");
        String introduction = arguments.getString("introduction");
        String faceUrl = arguments.getString("faceUrl");
        boolean isAllMuted = arguments.getBoolean("isAllMuted");
        int addOpt = arguments.getInt("addOpt");
        boolean isSupportTopic = arguments.getBoolean("isSupportTopic");

        HashMap<String, String> customInfoString = CommonUtils
                .convertReadableMapToHashMap(arguments.getMap("customInfo"));

        V2TIMGroupInfo info = new V2TIMGroupInfo();
        if (groupID != null) {
            info.setGroupID(groupID);
        }
        if (groupType != null) {
            info.setGroupType(groupType);
        }
        if (groupName != null) {
            info.setGroupName(groupName);
        }
        if (notification != null) {
            info.setNotification(notification);
        }
        if (introduction != null) {
            info.setIntroduction(introduction);
        }
        if (faceUrl != null) {
            info.setFaceUrl(faceUrl);
        }
        // if (isAllMuted != null) {
        info.setAllMuted(isAllMuted);
        // }
        // if (addOpt != null) {
        info.setGroupAddOpt(addOpt);
        // }
        // if (isSupportTopic != null) {
        info.setSupportTopic(isSupportTopic);
        // }
        if (customInfoString != null) {
            HashMap<String, byte[]> newCustomHashMap = new HashMap<String, byte[]>();
            if (!customInfoString.isEmpty()) {
                for (String key : customInfoString.keySet()) {
                    String value = customInfoString.get(key);
                    newCustomHashMap.put(key, value.getBytes());
                }
                info.setCustomInfo(newCustomHashMap);
            }
        }

        V2TIMManager.getGroupManager().setGroupInfo(info, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void getJoinedCommunityList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getGroupManager().getJoinedCommunityList(new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMGroupInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupInfoToMap(v2TIMGroupInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void createTopicInCommunity(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        Map<String, Object> topicInfo = CommonUtils.convertReadableMapToHashMap(arguments.getMap("topicInfo"));
        V2TIMTopicInfo info = new V2TIMTopicInfo();
        if (topicInfo.get("topicID") != null) {
            info.setTopicID((String) topicInfo.get("topicID"));
        }
        if (topicInfo.get("topicName") != null) {
            info.setTopicName((String) topicInfo.get("topicName"));
        }
        if (topicInfo.get("topicFaceUrl") != null) {
            info.setTopicFaceUrl((String) topicInfo.get("topicFaceUrl"));
        }
        if (topicInfo.get("notification") != null) {
            info.setNotification((String) topicInfo.get("notification"));
        }
        if (topicInfo.get("isAllMute") != null) {
            info.setAllMute((Boolean) topicInfo.get("isAllMute"));
        }

        if (topicInfo.get("customString") != null) {
            info.setCustomString((String) topicInfo.get("customString"));
        }

        if (topicInfo.get("draftText") != null) {
            info.setDraft((String) topicInfo.get("draftText"));
        }
        if (topicInfo.get("introduction") != null) {
            info.setIntroduction((String) topicInfo.get("introduction"));
        }

        V2TIMManager.getGroupManager().createTopicInCommunity(groupID, info, new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                CommonUtils.returnSuccess(promise, s);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });

    }

    public void deleteTopicFromCommunity(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> topicIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("topicIDList"));
        V2TIMManager.getGroupManager().deleteTopicFromCommunity(groupID, topicIDList,
                new V2TIMValueCallback<List<V2TIMTopicOperationResult>>() {
                    @Override
                    public void onSuccess(List<V2TIMTopicOperationResult> v2TIMTopicOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMTopicOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMTopicOperationResultToMap(v2TIMTopicOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }

                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }
                });
    }

    public void setTopicInfo(Promise promise, ReadableMap arguments) {
        Map<String, Object> topicInfo = CommonUtils.convertReadableMapToHashMap(arguments.getMap("topicInfo"));
        V2TIMTopicInfo info = new V2TIMTopicInfo();
        if (topicInfo.get("topicID") != null) {
            info.setTopicID((String) topicInfo.get("topicID"));
        }
        if (topicInfo.get("topicName") != null) {
            info.setTopicName((String) topicInfo.get("topicName"));
        }
        if (topicInfo.get("topicFaceUrl") != null) {
            info.setTopicFaceUrl((String) topicInfo.get("topicFaceUrl"));
        }
        if (topicInfo.get("notification") != null) {
            info.setNotification((String) topicInfo.get("notification"));
        }
        if (topicInfo.get("isAllMute") != null) {
            info.setAllMute((Boolean) topicInfo.get("isAllMute"));
        }

        if (topicInfo.get("customString") != null) {
            info.setCustomString((String) topicInfo.get("customString"));
        }

        if (topicInfo.get("draftText") != null) {
            info.setDraft((String) topicInfo.get("draftText"));
        }
        if (topicInfo.get("introduction") != null) {
            info.setIntroduction((String) topicInfo.get("introduction"));
        }
        V2TIMManager.getGroupManager().setTopicInfo(info, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void getTopicInfoList(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> topicIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("topicIDList"));
        V2TIMManager.getGroupManager().getTopicInfoList(groupID, topicIDList,
                new V2TIMValueCallback<List<V2TIMTopicInfoResult>>() {
                    @Override
                    public void onSuccess(List<V2TIMTopicInfoResult> v2TIMTopicInfoResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMTopicInfoResults.size(); i++) {
                            list.add(CommonUtils.convertV2TIMTopicInfoResultToMap(v2TIMTopicInfoResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }

                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }
                });
    }

    public void getGroupOnlineMemberCount(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        V2TIMManager.getInstance().getGroupManager().getGroupOnlineMemberCount(groupID,
                new V2TIMValueCallback<Integer>() {
                    @Override
                    public void onSuccess(Integer integer) {
                        CommonUtils.returnSuccess(promise, integer);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }
                });
    }

    public void initGroupAttributes(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        HashMap<String, String> attributes = CommonUtils.convertReadableMapToHashMap(arguments.getMap("attributes"));
        V2TIMManager.getGroupManager().initGroupAttributes(groupID, attributes, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void setGroupAttributes(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        HashMap<String, String> attributes = CommonUtils.convertReadableMapToHashMap(arguments.getMap("attributes"));
        V2TIMManager.getGroupManager().setGroupAttributes(groupID, attributes, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void deleteGroupAttributes(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> keys = CommonUtils.convertReadableArrayToListString(arguments.getArray("keys"));
        V2TIMManager.getGroupManager().deleteGroupAttributes(groupID, keys, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void getGroupAttributes(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> keys = CommonUtils.convertReadableArrayToListString(arguments.getArray("keys"));
        V2TIMManager.getGroupManager().getGroupAttributes(groupID, keys, new V2TIMValueCallback<Map<String, String>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(Map<String, String> stringStringMap) {
                CommonUtils.returnSuccess(promise, stringStringMap);
            }
        });
    }

    public void getGroupMemberList(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        int filter = arguments.getInt("filter");
        String nextSeq = arguments.getString("nextSeq");
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, Long.parseLong(nextSeq),
                new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                        CommonUtils.returnSuccess(promise,
                                CommonUtils.convertV2TIMGroupMemberInfoResultToMap(v2TIMGroupMemberInfoResult));
                    }
                });
    }

    public void getGroupMembersInfo(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> memberList = CommonUtils.convertReadableArrayToListString(arguments.getArray("memberList"));
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupID, memberList,
                new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMGroupMemberFullInfos.size(); i++) {
                            list.add(
                                    CommonUtils.convertV2TIMGroupMemberFullInfoToMap(v2TIMGroupMemberFullInfos.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void setGroupMemberInfo(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String userID = arguments.getString("userID");
        String nameCard = arguments.getString("nameCard");
        HashMap<String, String> customInfo = CommonUtils.convertReadableMapToHashMap(arguments.getMap("customInfo"));
        V2TIMGroupMemberFullInfo info = new V2TIMGroupMemberFullInfo();
        if (userID != null) {
            info.setUserID(userID);
        }
        if (nameCard != null) {
            info.setNameCard(nameCard);
        }
        if (customInfo != null) {
            HashMap<String, byte[]> customInfoByte = new HashMap<String, byte[]>();
            Iterator<String> iterator = customInfo.keySet().iterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                customInfoByte.put(key, customInfo.get(key).getBytes());
            }
            info.setCustomInfo(customInfoByte);
        }
        V2TIMManager.getGroupManager().setGroupMemberInfo(groupID, info, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void muteGroupMember(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String userID = arguments.getString("userID");
        int seconds = arguments.getInt("seconds");
        V2TIMManager.getGroupManager().muteGroupMember(groupID, userID, seconds, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void inviteUserToGroup(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> userList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userList"));
        V2TIMManager.getGroupManager().inviteUserToGroup(groupID, userList,
                new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                            list.add(CommonUtils.convertV2TIMGroupMemberOperationResultToMap(
                                    v2TIMGroupMemberOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void kickGroupMember(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String reason = arguments.getString("reason");
        List<String> memberList = CommonUtils.convertReadableArrayToListString(arguments.getArray("memberList"));
        V2TIMManager.getGroupManager().kickGroupMember(groupID, memberList, reason,
                new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                            list.add(CommonUtils.convertV2TIMGroupMemberOperationResultToMap(
                                    v2TIMGroupMemberOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void setGroupMemberRole(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String userID = arguments.getString("userID");
        int role = arguments.getInt("role");
        V2TIMManager.getGroupManager().setGroupMemberRole(groupID, userID, role, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void transferGroupOwner(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String userID = arguments.getString("userID");
        V2TIMManager.getGroupManager().transferGroupOwner(groupID, userID, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void getGroupApplicationList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                CommonUtils.returnSuccess(promise,
                        CommonUtils.convertV2TIMGroupApplicationResultToMap(v2TIMGroupApplicationResult));
            }
        });
    }

    public void acceptGroupApplication(Promise promise, ReadableMap arguments) {
        final String reason = arguments.getString("reason");
        final String groupID = arguments.getString("groupID");
        final String fromUser = arguments.getString("fromUser");
        final String toUser = arguments.getString("toUser");
        final long addTime = arguments.getInt("addTime");
        final int type = arguments.getInt("type");
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                for (int i = 0; i < v2TIMGroupApplicationResult.getGroupApplicationList().size(); i++) {
                    V2TIMGroupApplication application = v2TIMGroupApplicationResult.getGroupApplicationList().get(i);
                    if (application.getGroupID().equals(groupID) && application.getFromUser().equals(fromUser)
                            && application.getToUser().equals(toUser) && application.getAddTime() == addTime
                            && application.getType() == type) {
                        V2TIMManager.getGroupManager().acceptGroupApplication(application, reason, new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                CommonUtils.returnError(promise, i, s);
                            }

                            @Override
                            public void onSuccess() {
                                CommonUtils.returnSuccess(promise, null);
                            }
                        });
                        break;
                    }
                }
            }
        });
    }

    public void refuseGroupApplication(Promise promise, ReadableMap arguments) {
        final String reason = arguments.getString("reason");
        final String groupID = arguments.getString("groupID");
        final String fromUser = arguments.getString("fromUser");
        final String toUser = arguments.getString("toUser");
        final long addTime = arguments.getInt("addTime");
        final int type = arguments.getInt("type");
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                for (int i = 0; i < v2TIMGroupApplicationResult.getGroupApplicationList().size(); i++) {
                    V2TIMGroupApplication application = v2TIMGroupApplicationResult.getGroupApplicationList().get(i);
                    if (application.getGroupID().equals(groupID) && application.getFromUser().equals(fromUser)
                            && application.getToUser().equals(toUser) && application.getAddTime() == addTime
                            && application.getType() == type) {

                        V2TIMManager.getGroupManager().refuseGroupApplication(application, reason, new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                CommonUtils.returnError(promise, i, s);
                            }

                            @Override
                            public void onSuccess() {
                                CommonUtils.returnSuccess(promise, null);
                            }
                        });
                        break;
                    }

                }
            }
        });
    }

    public void setGroupApplicationRead(Promise promise, ReadableMap arguments) {
        V2TIMManager.getGroupManager().setGroupApplicationRead(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void searchGroups(Promise promise, ReadableMap arguments) {
        HashMap<String, Object> searchParam = CommonUtils.convertReadableMapToHashMap(arguments.getMap("searchParam"));
        V2TIMGroupSearchParam param = new V2TIMGroupSearchParam();
        if (searchParam.get("keywordList") != null) {
            param.setKeywordList((List<String>) searchParam.get("keywordList"));
        }
        if (searchParam.get("isSearchGroupID") != null) {
            param.setSearchGroupID((Boolean) searchParam.get("isSearchGroupID"));
        }
        if (searchParam.get("isSearchGroupName") != null) {
            param.setSearchGroupName((Boolean) searchParam.get("isSearchGroupName"));
        }
        V2TIMManager.getGroupManager().searchGroups(param, new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                LinkedList<HashMap<String, Object>> infoList = new LinkedList<>();
                for (int i = 0; i < v2TIMGroupInfos.size(); i++) {
                    infoList.add(CommonUtils.convertV2TIMGroupInfoToMap(v2TIMGroupInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, infoList);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void searchGroupMembers(Promise promise, ReadableMap arguments) {
        HashMap<String, Object> param = CommonUtils.convertReadableMapToHashMap(arguments.getMap("param"));
        V2TIMGroupMemberSearchParam searchParam = new V2TIMGroupMemberSearchParam();
        if (param.get("keywordList") != null) {
            searchParam.setKeywordList((List<String>) param.get("keywordList"));
        }
        if (param.get("groupIDList") != null) {
            searchParam.setGroupIDList((List<String>) param.get("groupIDList"));
        }
        if (param.get("isSearchMemberUserID") != null) {
            searchParam.setSearchMemberUserID((Boolean) param.get("isSearchMemberUserID"));
        }
        if (param.get("isSearchMemberNickName") != null) {
            searchParam.setSearchMemberNickName((Boolean) param.get("isSearchMemberNickName"));
        }
        if (param.get("isSearchMemberRemark") != null) {
            searchParam.setSearchMemberRemark((Boolean) param.get("isSearchMemberRemark"));
        }
        if (param.get("isSearchMemberNameCard") != null) {
            searchParam.setSearchMemberNameCard((Boolean) param.get("isSearchMemberNameCard"));
        }

        V2TIMManager.getGroupManager().searchGroupMembers(searchParam,
                new V2TIMValueCallback<HashMap<String, List<V2TIMGroupMemberFullInfo>>>() {
                    @Override
                    public void onSuccess(HashMap<String, List<V2TIMGroupMemberFullInfo>> stringListHashMap) {
                        Iterator it = stringListHashMap.entrySet().iterator();
                        HashMap<String, LinkedList<HashMap<String, Object>>> res = new HashMap();
                        while (it.hasNext()) {
                            Map.Entry entry = (Map.Entry) it.next();
                            String key = (String) entry.getKey();
                            List<V2TIMGroupMemberFullInfo> value = (List<V2TIMGroupMemberFullInfo>) entry.getValue();
                            LinkedList<HashMap<String, Object>> resItem = new LinkedList<>();
                            for (int i = 0; i < value.size(); i++) {
                                resItem.add(CommonUtils.convertV2TIMGroupMemberFullInfoToMap(value.get(i)));

                            }

                            res.put(key, resItem);
                        }
                        CommonUtils.returnSuccess(promise, res);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }
                });
    }

}
