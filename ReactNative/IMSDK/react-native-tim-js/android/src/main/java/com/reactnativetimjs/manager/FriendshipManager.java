package com.reactnativetimjs.manager;

import com.reactnativetimjs.util.CommonUtils;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMFriendAddApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendGroup;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMFriendSearchParam;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberSearchParam;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

public class FriendshipManager {
    private static V2TIMFriendshipListener friendshipListener;

    public void addFriendListener(Promise promise, ReadableMap arguments) {
        friendshipListener = new V2TIMFriendshipListener() {
            @Override
            public void onFriendApplicationListAdded(List<V2TIMFriendApplication> applicationList) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < applicationList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendApplicationToMap(applicationList.get(i)));
                }

                makeFriendListenerEventData("onFriendApplicationListAdded", list);
            }

            @Override
            public void onFriendApplicationListDeleted(List<String> userIDList) {

                makeFriendListenerEventData("onFriendApplicationListDeleted", userIDList);
            }

            @Override
            public void onFriendApplicationListRead() {
                makeFriendListenerEventData("onFriendApplicationListRead", null);
            }

            @Override
            public void onFriendListAdded(List<V2TIMFriendInfo> users) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < users.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendInfoToMap(users.get(i)));
                }
                makeFriendListenerEventData("onFriendListAdded", list);
            }

            @Override
            public void onFriendListDeleted(List<String> userList) {
                makeFriendListenerEventData("onFriendListDeleted", userList);
            }

            @Override
            public void onBlackListAdd(List<V2TIMFriendInfo> infoList) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < infoList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendInfoToMap(infoList.get(i)));
                }
                makeFriendListenerEventData("onBlackListAdd", list);
            }

            @Override
            public void onBlackListDeleted(List<String> userList) {
                makeFriendListenerEventData("onBlackListDeleted", userList);
            }

            @Override
            public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < infoList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendInfoToMap(infoList.get(i)));
                }
                makeFriendListenerEventData("onFriendInfoChanged", list);
            }
        };
        V2TIMManager.getFriendshipManager().addFriendListener(friendshipListener);
        CommonUtils.returnSuccess(promise, "addFriendListener  success");
    }

    public void removeFriendListener(Promise promise, ReadableMap arguments) {
        V2TIMManager.getFriendshipManager().removeFriendListener(friendshipListener);
        CommonUtils.returnSuccess(promise, "removeFriendListener  success");
    }

    private <T> void makeFriendListenerEventData(String eventType, T data) {
        CommonUtils.emmitEvent("friendListener", eventType, data);
    }

    public void getFriendList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMFriendInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendInfoToMap(v2TIMFriendInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }
        });
    }

    public void getFriendsInfo(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().getFriendsInfo(userIDList,
                new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendInfoResults.size(); i++) {
                            list.add(CommonUtils.convertV2TIMFriendInfoResultToMap(v2TIMFriendInfoResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void setFriendInfo(Promise promise, ReadableMap arguments) {
        String userID = arguments.getString("userID");
        String friendRemark = arguments.getString("friendRemark");
        HashMap<String, String> customHashMap = CommonUtils
                .convertReadableMapToHashMap(arguments.getMap("friendCustomInfo"));
        V2TIMFriendInfo info = new V2TIMFriendInfo();
        info.setUserID(userID);
        if (friendRemark != null) {
            info.setFriendRemark(friendRemark);
        }
        if (customHashMap != null) {
            HashMap<String, byte[]> newCustomHashMap = new HashMap<>();
            if (!customHashMap.isEmpty()) {
                for (String key : customHashMap.keySet()) {
                    String value = customHashMap.get(key);
                    newCustomHashMap.put(key, value.getBytes());
                }
                info.setFriendCustomInfo(newCustomHashMap);
            }
        }
        V2TIMManager.getFriendshipManager().setFriendInfo(info, new V2TIMCallback() {
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

    public void addFriend(Promise promise, ReadableMap arguments) {
        String userID = arguments.getString("userID");
        String remark = arguments.getString("remark");
        String friendGroup = arguments.getString("friendGroup");
        String addWording = arguments.getString("addWording");
        String addSource = arguments.getString("addSource");
        int addType = arguments.getInt("addType");
        V2TIMFriendAddApplication info = new V2TIMFriendAddApplication(userID);
        info.setUserID(userID);
        if (remark != null) {
            info.setFriendRemark(remark);
        }
        if (friendGroup != null) {
            info.setFriendGroup(friendGroup);
        }
        if (addWording != null) {
            info.setAddWording(addWording);
        }
        if (addSource != null) {
            info.setAddSource(addSource);
        }
        // if (addType != null) {
        info.setAddType(addType);
        // }
        V2TIMManager.getFriendshipManager().addFriend(info, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                CommonUtils.returnSuccess(promise,
                        CommonUtils.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
            }
        });
    }

    public void deleteFromFriendList(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        int deleteType = arguments.getInt("deleteType");
        V2TIMManager.getFriendshipManager().deleteFromFriendList(userIDList, deleteType,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void checkFriend(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        int checkType = arguments.getInt("checkType");

        V2TIMManager.getFriendshipManager().checkFriend(userIDList, checkType,
                new V2TIMValueCallback<List<V2TIMFriendCheckResult>>() {
                    @Override
                    public void onSuccess(List<V2TIMFriendCheckResult> v2TIMFriendCheckResults) {
                        List<HashMap<String, Object>> ress = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendCheckResults.size(); i++) {
                            ress.add(CommonUtils.convertV2TIMFriendCheckResultToMap(v2TIMFriendCheckResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, ress);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }
                });
    }

    public void getFriendApplicationList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getFriendshipManager()
                .getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                        CommonUtils.returnSuccess(promise,
                                CommonUtils.convertV2TIMFriendApplicationResultToMap(v2TIMFriendApplicationResult));
                    }
                });
    }

    public void acceptFriendApplication(Promise promise, ReadableMap arguments) {
        final int responseType = arguments.getInt("responseType");
        final String userID = arguments.getString("userID");
        final int type = arguments.getInt("type");
        V2TIMManager.getFriendshipManager()
                .getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                        List<V2TIMFriendApplication> list = v2TIMFriendApplicationResult.getFriendApplicationList();
                        V2TIMFriendApplication app = null;
                        System.out.println("当前所有申请:" + list.size() + ",userID:" + userID + ",responseType:"
                                + responseType + ",type:" + type);
                        for (int i = 0; i < list.size(); i++) {
                            System.out.println(list.get(i).getUserID() + "," + list.get(i).getType());
                            if (list.get(i).getUserID().equals(userID) && list.get(i).getType() == type) {
                                app = list.get(i);
                                break;
                            }
                        }
                        if (app == null) {
                            CommonUtils.returnError(promise, -1, "application get error");
                            return;
                        }
                        V2TIMManager.getFriendshipManager().acceptFriendApplication(app, responseType,
                                new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                                    @Override
                                    public void onError(int i, String s) {
                                        CommonUtils.returnError(promise, i, s);
                                    }

                                    @Override
                                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                                        CommonUtils.returnSuccess(promise, CommonUtils
                                                .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
                                    }
                                });
                    }
                });

    }

    public void refuseFriendApplication(Promise promise, ReadableMap arguments) {
        final String userID = arguments.getString("userID");
        final int type = arguments.getInt("type");
        V2TIMManager.getFriendshipManager()
                .getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                        List<V2TIMFriendApplication> list = v2TIMFriendApplicationResult.getFriendApplicationList();
                        V2TIMFriendApplication app = new V2TIMFriendApplication();
                        for (int i = 0; i < list.size(); i++) {
                            if (list.get(i).getUserID().equals(userID) && list.get(i).getType() == type) {
                                app = list.get(i);
                                break;
                            }
                        }
                        V2TIMManager.getFriendshipManager().refuseFriendApplication(app,
                                new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                                    @Override
                                    public void onError(int i, String s) {
                                        CommonUtils.returnError(promise, i, s);
                                    }

                                    @Override
                                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                                        CommonUtils.returnSuccess(promise, CommonUtils
                                                .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
                                    }
                                });
                    }
                });
    }

    public void deleteFriendApplication(Promise promise, ReadableMap arguments) {
        final String userID = arguments.getString("userID");
        final int type = arguments.getInt("type");
        V2TIMManager.getFriendshipManager()
                .getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                        List<V2TIMFriendApplication> list = v2TIMFriendApplicationResult.getFriendApplicationList();
                        V2TIMFriendApplication app;
                        for (int i = 0; i < list.size(); i++) {
                            if (list.get(i).getUserID().equals(userID) && list.get(i).getType() == type) {
                                app = list.get(i);
                                V2TIMManager.getFriendshipManager().deleteFriendApplication(app, new V2TIMCallback() {
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

    public void setFriendApplicationRead(Promise promise, ReadableMap arguments) {
        V2TIMManager.getFriendshipManager().setFriendApplicationRead(new V2TIMCallback() {
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

    public void addToBlackList(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().addToBlackList(userIDList,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void deleteFromBlackList(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().deleteFromBlackList(userIDList,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void getBlackList(Promise promise, ReadableMap arguments) {
        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMFriendInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMFriendInfoToMap(v2TIMFriendInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }
        });
    }

    public void createFriendGroup(Promise promise, ReadableMap arguments) {
        String groupName = arguments.getString("groupName");
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().createFriendGroup(groupName, userIDList,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void getFriendGroups(Promise promise, ReadableMap arguments) {
        List<String> groupNameList = CommonUtils.convertReadableArrayToListString(arguments.getArray("groupNameList"));
        V2TIMManager.getFriendshipManager().getFriendGroups(groupNameList,
                new V2TIMValueCallback<List<V2TIMFriendGroup>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendGroup> v2TIMFriendGroups) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendGroups.size(); i++) {
                            list.add(CommonUtils.convertV2TIMFriendGroupToMap(v2TIMFriendGroups.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void deleteFriendGroup(Promise promise, ReadableMap arguments) {
        List<String> groupNameList = CommonUtils.convertReadableArrayToListString(arguments.getArray("groupNameList"));
        V2TIMManager.getFriendshipManager().deleteFriendGroup(groupNameList, new V2TIMCallback() {
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

    public void renameFriendGroup(Promise promise, ReadableMap arguments) {
        String oldName = arguments.getString("oldName");
        String newName = arguments.getString("newName");
        V2TIMManager.getFriendshipManager().renameFriendGroup(oldName, newName, new V2TIMCallback() {
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

    public void addFriendsToFriendGroup(Promise promise, ReadableMap arguments) {
        String groupName = arguments.getString("groupName");
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().addFriendsToFriendGroup(groupName, userIDList,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void deleteFriendsFromFriendGroup(Promise promise, ReadableMap arguments) {
        String groupName = arguments.getString("groupName");
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getFriendshipManager().deleteFriendsFromFriendGroup(groupName, userIDList,
                new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMFriendOperationResults.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }
                });
    }

    public void searchFriends(Promise promise, ReadableMap arguments) {
        HashMap<String, Object> param = CommonUtils
                .convertReadableMapToHashMap(arguments.getMap("searchParam"));
        V2TIMFriendSearchParam searchParam = new V2TIMFriendSearchParam();
        if (param.get("keywordList") != null) {
            searchParam.setKeywordList((List<String>) param.get("keywordList"));
        }

        if (param.get("isSearchUserID") != null) {
            searchParam.setSearchUserID((Boolean) param.get("isSearchUserID"));
        }
        if (param.get("isSearchNickName") != null) {
            searchParam.setSearchNickName((Boolean) param.get("isSearchNickName"));
        }
        if (param.get("isSearchRemark") != null) {
            searchParam.setSearchRemark((Boolean) param.get("isSearchRemark"));
        }
        V2TIMManager.getFriendshipManager().searchFriends(searchParam,
                new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
                    @Override
                    public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                        LinkedList<HashMap<String, Object>> infoList = new LinkedList<>();
                        for (int i = 0; i < v2TIMFriendInfoResults.size(); i++) {
                            infoList.add(CommonUtils.convertV2TIMFriendInfoResultToMap(v2TIMFriendInfoResults.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, infoList);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }
                });
    }
}
