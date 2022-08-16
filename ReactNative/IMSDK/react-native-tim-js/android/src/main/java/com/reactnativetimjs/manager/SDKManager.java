package com.reactnativetimjs.manager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import com.reactnativetimjs.util.CommonUtils;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import android.content.Context;

public class SDKManager {
    public static Context context;
    private static V2TIMSimpleMsgListener simpleMsgListener;
    private static V2TIMGroupListener groupListener;

    public SDKManager(Context context) {
        SDKManager.context = context;
    }

    public void initSDK(Promise promise, ReadableMap arguments) {
        int sdkAppID = arguments.getInt("sdkAppID");
        int logLevel = arguments.getInt("logLevel");
        V2TIMSDKConfig config = new V2TIMSDKConfig();
        config.setLogLevel(logLevel);

        V2TIMManager.getInstance().callExperimentalAPI("setUIPlatform", "rn", null);
        Boolean res = V2TIMManager.getInstance().initSDK(context, sdkAppID, config, new V2TIMSDKListener() {
            public void onConnecting() {
                makeEventData("onConnecting", null);
            }

            public void onConnectSuccess() {
                makeEventData("onConnectSuccess", null);
            }

            public void onConnectFailed(int code, String error) {
                HashMap<String, Object> err = new HashMap<String, Object>();
                err.put("code", code);
                err.put("desc", error);
                makeEventData("onConnectFailed", new JSONObject(err));
            }

            public void onKickedOffline() {
                makeEventData("onKickedOffline", null);
            }

            public void onUserSigExpired() {
                makeEventData("onUserSigExpired", null);
            }

            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                HashMap<String, Object> userInfoMap = CommonUtils.convertV2TIMUserFullInfoToMap(info);
                makeEventData("onSelfInfoUpdated", new JSONObject(userInfoMap));
            }

            public void onUserStatusChanged(List<V2TIMUserStatus> statusList) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < statusList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMUserStatusToMap(statusList.get(i)));
                }
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("statusList", list);
                makeEventData("onUserStatusChanged", data);
            }
        });
        CommonUtils.returnSuccess(promise, res);
    }

    public void login(Promise promise, ReadableMap arguments) {
        String userID = arguments.getString("userID");
        String userSig = arguments.getString("userSig");
        V2TIMManager.getInstance().login(userID, userSig, new V2TIMCallback() {
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }

            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void unInitSDK(Promise promise, ReadableMap arguments) {
        V2TIMManager.getInstance().unInitSDK();
        CommonUtils.returnSuccess(promise, null);
    }

    public void getVersion(Promise promise, ReadableMap arguments) {
        CommonUtils.returnSuccess(promise, V2TIMManager.getInstance().getVersion());
    }

    public void getServerTime(Promise promise, ReadableMap arguments) {
        CommonUtils.returnSuccess(promise, V2TIMManager.getInstance().getServerTime());
    }

    public void logout(Promise promise, ReadableMap arguments) {
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void getLoginUser(Promise promise, ReadableMap arguments) {
        String user = V2TIMManager.getInstance().getLoginUser();
        CommonUtils.returnSuccess(promise, user);
    }

    public void getLoginStatus(Promise promise, ReadableMap arguments) {
        int loginStatus = V2TIMManager.getInstance().getLoginStatus();
        CommonUtils.returnSuccess(promise, loginStatus);
    }

    public void sendC2CTextMessage(Promise promise, ReadableMap arguments) {
        String text = arguments.getString("text");
        String userID = arguments.getString("userID");

        String mesage = V2TIMManager.getInstance().sendC2CTextMessage(text, userID,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                    }
                });
    }

    public void sendC2CCustomMessage(Promise promise, ReadableMap arguments) {
        String customData = arguments.getString("customData");
        String userID = arguments.getString("userID");
        byte[] customDataBytes = customData.getBytes();
        V2TIMManager.getInstance().sendC2CCustomMessage(customDataBytes, userID,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                    }
                });
    }

    public void sendGroupTextMessage(Promise promise, ReadableMap arguments) {
        String text = arguments.getString("text");
        String groupID = arguments.getString("groupID");
        int priority = arguments.getInt("priority");
        V2TIMManager.getInstance().sendGroupTextMessage(text, groupID, priority,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                    }
                });
    }

    public void sendGroupCustomMessage(Promise promise, ReadableMap arguments) {
        String customData = arguments.getString("customData");
        String groupID = arguments.getString("groupID");
        int priority = arguments.getInt("priority");
        V2TIMManager.getInstance().sendGroupCustomMessage(customData.getBytes(), groupID, priority,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                    }
                });
    }

    public void createGroup(Promise promise, ReadableMap arguments) {

        String groupType = arguments.getString("groupType");
        String groupID = arguments.getString("groupID");
        String groupName = arguments.getString("groupName");
        V2TIMManager.getInstance().createGroup(groupType, groupID, groupName, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }

            @Override
            public void onSuccess(String s) {
                CommonUtils.returnSuccess(promise, s);
            }
        });
    }

    public void joinGroup(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        String message = arguments.getString("message");
        V2TIMManager.getInstance().joinGroup(groupID, message, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void quitGroup(Promise promise, ReadableMap arguments) {
        // 群ID
        String groupID = arguments.getString("groupID");
        V2TIMManager.getInstance().quitGroup(groupID, new V2TIMCallback() {
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

    public void dismissGroup(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        V2TIMManager.getInstance().dismissGroup(groupID, new V2TIMCallback() {
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

    public void getUsersInfo(Promise promise, ReadableMap arguments) {

        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getInstance().getUsersInfo(userIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMUserFullInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMUserFullInfoToMap(v2TIMUserFullInfos.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }
        });

    }

    public void setSelfInfo(Promise promise, ReadableMap arguments) {
        String nickName = CommonUtils.safeGetString(arguments, "nickName");
        String faceUrl = CommonUtils.safeGetString(arguments, "faceUrl");
        String selfSignature = CommonUtils.safeGetString(arguments, "selfSignature");
        Integer gender = CommonUtils.safeGetInt(arguments, "gender");
        Integer allowType = CommonUtils.safeGetInt(arguments, "allowType");
        Integer birthday = CommonUtils.safeGetInt(arguments, "birthday");
        Integer level = CommonUtils.safeGetInt(arguments, "level");
        Integer role = CommonUtils.safeGetInt(arguments, "role");
        HashMap<String, String> customInfoString = CommonUtils
                .convertReadableMapToHashMap(CommonUtils.safeGetMap(arguments, "customInfo"));

        V2TIMUserFullInfo userFullInfo = new V2TIMUserFullInfo();

        if (nickName != null) {
            userFullInfo.setNickname(nickName);
        }
        if (faceUrl != null) {
            userFullInfo.setFaceUrl(faceUrl);
        }
        if (selfSignature != null) {
            userFullInfo.setSelfSignature(selfSignature);
        }
        if (gender != null) {
            userFullInfo.setGender(gender);
        }
        if (birthday != null) {
            userFullInfo.setBirthday(birthday);
        }
        if (allowType != null) {
            userFullInfo.setAllowType(allowType);
        }
        if (level != null) {
            userFullInfo.setLevel(level);
        }
        if (role != null) {
            userFullInfo.setRole(role);
        }
        if (!customInfoString.isEmpty()) {
            HashMap<String, byte[]> newCustomHashMap = new HashMap<String, byte[]>();
            for (String key : customInfoString.keySet()) {
                String value = customInfoString.get(key);
                newCustomHashMap.put(key, value.getBytes());
            }
            userFullInfo.setCustomInfo(newCustomHashMap);
        }
        V2TIMManager.getInstance().setSelfInfo(userFullInfo, new V2TIMCallback() {
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

    public void callExperimentalAPI(Promise promise, ReadableMap arguments) {
        String api = arguments.getString("api");
        Object param = arguments.getDynamic("param");
        V2TIMManager.getInstance().callExperimentalAPI(api, param, new V2TIMValueCallback<Object>() {

            @Override
            public void onSuccess(Object o) {
                CommonUtils.returnSuccess(promise, o);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void addSimpleMsgListener(Promise promise, ReadableMap arguments) {
        simpleMsgListener = new V2TIMSimpleMsgListener() {
            public void onRecvC2CTextMessage(String msgID, V2TIMUserInfo sender, String text) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("msgID", msgID);
                res.put("sender", CommonUtils.convertV2TIMUserInfotoMap(sender));
                res.put("text", text);
                makeaddSimpleMsgListenerEventData("onRecvC2CTextMessage", res);
            }

            public void onRecvC2CCustomMessage(String msgID, V2TIMUserInfo sender, byte[] customData) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("msgID", msgID);
                res.put("sender", CommonUtils.convertV2TIMUserInfotoMap(sender));
                res.put("customData", customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvC2CCustomMessage", res);
            }

            public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("msgID", msgID);
                res.put("groupID", groupID);
                res.put("sender", CommonUtils.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("text", text);
                makeaddSimpleMsgListenerEventData("onRecvGroupTextMessage", res);
            }

            public void onRecvGroupCustomMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender,
                    byte[] customData) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("msgID", msgID);
                res.put("groupID", groupID);
                res.put("sender", CommonUtils.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("customData", customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvGroupCustomMessage", res);
            }
        };
        V2TIMManager.getInstance().addSimpleMsgListener(simpleMsgListener);
        CommonUtils.returnSuccess(promise, "add simple msg listener success");
    }

    public void removeSimpleMsgListener(Promise promise, ReadableMap arguments) {
        V2TIMManager.getInstance().removeSimpleMsgListener(simpleMsgListener);
        CommonUtils.returnSuccess(promise, "simple msg listener was removed");
    }

    public void addGroupListener(Promise promise, ReadableMap arguments) {
        groupListener = new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < memberList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList", list);
                makeaddGroupListenerEventData("onMemberEnter", data);
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("member", CommonUtils.convertV2TIMGroupMemberInfoToMap(member));
                makeaddGroupListenerEventData("onMemberLeave", data);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser,
                    List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < memberList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList", list);
                makeaddGroupListenerEventData("onMemberInvited", data);
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser,
                    List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < memberList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList", list);
                makeaddGroupListenerEventData("onMemberKicked", data);
            }

            @Override
            public void onMemberInfoChanged(String groupID,
                    List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMGroupMemberChangeInfoList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberChangeInfoToMap(v2TIMGroupMemberChangeInfoList.get(i)));
                }
                data.put("groupMemberChangeInfoList", list);
                makeaddGroupListenerEventData("onMemberInfoChanged", data);
            }

            @Override
            public void onGroupCreated(String groupID) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                makeaddGroupListenerEventData("onGroupCreated", data);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupDismissed", data);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupRecycled", data);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < changeInfos.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupChangeInfoToMap(changeInfos.get(i)));
                }
                data.put("groupChangeInfoList", list);
                makeaddGroupListenerEventData("onGroupInfoChanged", data);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("member", CommonUtils.convertV2TIMGroupMemberInfoToMap(member));
                data.put("opReason", opReason);
                makeaddGroupListenerEventData("onReceiveJoinApplication", data);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin,
                    String opReason) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                data.put("isAgreeJoin", isAgreeJoin);
                data.put("opReason", opReason);
                makeaddGroupListenerEventData("onApplicationProcessed", data);
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser,
                    List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < memberList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList", list);
                makeaddGroupListenerEventData("onGrantAdministrator", data);
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser,
                    List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("opUser", CommonUtils.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < memberList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList", list);
                makeaddGroupListenerEventData("onRevokeAdministrator", data);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);

                makeaddGroupListenerEventData("onQuitFromGroup", data);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("customData", customData == null ? "" : new String(customData));
                makeaddGroupListenerEventData("onReceiveRESTCustomData", data);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                HashMap<String, Object> data = new HashMap<String, Object>();
                data.put("groupID", groupID);
                data.put("groupAttributeMap", groupAttributeMap);
                makeaddGroupListenerEventData("onGroupAttributeChanged", data);
            }
        };
        V2TIMManager.getInstance().addGroupListener(groupListener);
        CommonUtils.returnSuccess(promise, "add group listener success");
    }

    public void getUserStatus(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getInstance().getUserStatus(userIDList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                for (int i = 0; i < v2TIMUserStatuses.size(); i++) {
                    list.add(CommonUtils.convertV2TIMUserStatusToMap(v2TIMUserStatuses.get(i)));
                }
                CommonUtils.returnSuccess(promise, list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void setSelfStatus(Promise promise, ReadableMap arguments) {
        String status = arguments.getString("status");
        V2TIMUserStatus customStatus = new V2TIMUserStatus();
        customStatus.setCustomStatus(status);
        V2TIMManager.getInstance().setSelfStatus(customStatus, new V2TIMCallback() {
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

    public void removeGroupListener(Promise promise, ReadableMap arguments) {
        V2TIMManager.getInstance().removeGroupListener(groupListener);
        CommonUtils.returnSuccess(promise, "removeGroupListener was removed");
    }

    private <T> void makeEventData(String eventType, T data) {
        CommonUtils.emmitEvent("sdkListener", eventType, data);
    }

    private <T> void makeaddSimpleMsgListenerEventData(String eventType, T data) {
        CommonUtils.emmitEvent("simpleMsgListener", eventType, data);
    }

    private <T> void makeaddGroupListenerEventData(String eventType, T data) {
        CommonUtils.emmitEvent("groupListener", eventType, data);
    }
}
