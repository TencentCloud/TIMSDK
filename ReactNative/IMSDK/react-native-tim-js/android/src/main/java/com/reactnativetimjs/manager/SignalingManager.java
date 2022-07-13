package com.reactnativetimjs.manager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.reactnativetimjs.util.CommonUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

public class SignalingManager {
    private static V2TIMSignalingListener signallistener;

    private static HashMap<String, String> invitedIDMap = new HashMap();
    private static HashMap<String, V2TIMSignalingListener> signalListenerList = new HashMap<>();

    public void addSignalingListener(Promise promise, ReadableMap arguments) {
        signallistener = new V2TIMSignalingListener() {
            @Override
            public void onReceiveNewInvitation(String inviteID, String inviter, String groupID,
                    List<String> inviteeList, String data) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("inviteID", inviteID);
                res.put("inviter", inviter);
                res.put("groupID", groupID);
                res.put("inviteeList", inviteeList);
                res.put("data", data);
                makeSignalingListenerEventData("onReceiveNewInvitation", res);
            }

            @Override
            public void onInviteeAccepted(String inviteID, String invitee, String data) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("inviteID", inviteID);
                res.put("invitee", invitee);
                res.put("data", data);
                makeSignalingListenerEventData("onInviteeAccepted", res);
            }

            @Override
            public void onInviteeRejected(String inviteID, String invitee, String data) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("inviteID", inviteID);
                res.put("invitee", invitee);
                res.put("data", data);
                makeSignalingListenerEventData("onInviteeRejected", res);
            }

            @Override
            public void onInvitationCancelled(String inviteID, String inviter, String data) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("inviteID", inviteID);
                res.put("inviter", inviter);
                res.put("data", data);
                makeSignalingListenerEventData("onInvitationCancelled", res);
            }

            @Override
            public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
                HashMap<String, Object> res = new HashMap<String, Object>();
                res.put("inviteID", inviteID);
                res.put("inviteeList", inviteeList);
                makeSignalingListenerEventData("onInvitationTimeout", res);
            }
        };
        V2TIMManager.getSignalingManager().addSignalingListener(signallistener);
        CommonUtils.returnSuccess(promise, "add signaling listener success");
    }

    public void removeSignalingListener(Promise promise, ReadableMap arguments) {
        V2TIMManager.getSignalingManager().removeSignalingListener(signallistener);
        CommonUtils.returnSuccess(promise, "removeSignalingListener is done");
    }

    private <T> void makeSignalingListenerEventData(String eventType, T data) {
        CommonUtils.emmitEvent("signalingListener", eventType, data);
    }

    public void invite(Promise promise, ReadableMap arguments) {
        String invitee = arguments.getString("invitee");
        String data = arguments.getString("data");
        int timeout = arguments.getInt("timeout");
        boolean onlineUserOnly = arguments.getBoolean("onlineUserOnly");
        V2TIMOfflinePushInfo offlinePushInfo = new V2TIMOfflinePushInfo();
        HashMap<String, Object> offlinePushInfoParams = CommonUtils
                .convertReadableMapToHashMap(arguments.getMap("offlinePushInfo"));
        if (offlinePushInfoParams != null) {
            String title = (String) offlinePushInfoParams.get("title");
            String desc = (String) offlinePushInfoParams.get("desc");
            Boolean disablePush = (Boolean) offlinePushInfoParams.get("disablePush");
            String ext = (String) offlinePushInfoParams.get("ext");
            String iOSSound = (String) offlinePushInfoParams.get("iOSSound");
            Boolean ignoreIOSBadge = (Boolean) offlinePushInfoParams.get("ignoreIOSBadge");
            String androidOPPOChannelID = (String) offlinePushInfoParams.get("androidOPPOChannelID");
            if (title != null) {
                offlinePushInfo.setTitle(title);
            }
            if (desc != null) {
                offlinePushInfo.setDesc(desc);
            }
            if (offlinePushInfoParams.get("disablePush") != null) {
                offlinePushInfo.disablePush(disablePush);
            }
            if (ext != null) {
                offlinePushInfo.setExt(ext.getBytes());
            }
            if (iOSSound != null) {
                offlinePushInfo.setIOSSound(iOSSound);
            }
            if (offlinePushInfoParams.get("ignoreIOSBadge") != null) {
                offlinePushInfo.setIgnoreIOSBadge(ignoreIOSBadge);
            }
            if (androidOPPOChannelID != null) {
                offlinePushInfo.setAndroidOPPOChannelID(androidOPPOChannelID);
            }
        }
        final String current = String.valueOf(System.nanoTime());
        String id = V2TIMManager.getSignalingManager().invite(invitee, data, onlineUserOnly, offlinePushInfo,
                timeout, new V2TIMCallback() {

                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                        invitedIDMap.remove(current);
                    }

                    @Override
                    public void onSuccess() {
                        // Here, the id returned synchronously above is used
                        CommonUtils.returnSuccess(promise, invitedIDMap.get(current));
                        invitedIDMap.remove(current);
                    }
                });

        invitedIDMap.put(current, id);
    }

    public void inviteInGroup(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        List<String> inviteeList = CommonUtils.convertReadableArrayToListString(arguments.getArray("inviteeList"));
        String data = arguments.getString("data");
        int timeout = arguments.getInt("timeout");
        boolean onlineUserOnly = arguments.getBoolean("onlineUserOnly");
        final String current = String.valueOf(System.nanoTime());
        String id = V2TIMManager.getSignalingManager().inviteInGroup(groupID, inviteeList, data, onlineUserOnly,
                timeout, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                        invitedIDMap.remove(current);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtils.returnSuccess(promise, invitedIDMap.get(current));
                        invitedIDMap.remove(current);
                    }
                });
        invitedIDMap.put(current, id);

    }

    public void cancel(Promise promise, ReadableMap arguments) {
        String inviteID = arguments.getString("inviteID");
        String data = arguments.getString("data");
        V2TIMManager.getSignalingManager().cancel(inviteID, data, new V2TIMCallback() {
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

    public void accept(Promise promise, ReadableMap arguments) {
        String inviteID = arguments.getString("inviteID");
        String data = arguments.getString("data");
        V2TIMManager.getSignalingManager().accept(inviteID, data, new V2TIMCallback() {
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

    public void reject(Promise promise, ReadableMap arguments) {
        String inviteID = arguments.getString("inviteID");
        String data = arguments.getString("data");
        V2TIMManager.getSignalingManager().reject(inviteID, data, new V2TIMCallback() {
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

    public void getSignalingInfo(final Promise promise, ReadableMap arguments) {
        String msgID = arguments.getString("msgID");
        List<String> messageIdList = new LinkedList<>();
        messageIdList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(messageIdList,
                new V2TIMValueCallback<List<V2TIMMessage>>() {
                    @Override
                    public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                        if (v2TIMMessages.size() != 1) {
                            CommonUtils.returnError(promise, -1, "message not found");
                        } else {
                            V2TIMSignalingInfo singnalInfo = V2TIMManager.getSignalingManager()
                                    .getSignalingInfo(v2TIMMessages.get(0));
                            if (singnalInfo == null) {
                                CommonUtils.returnSuccess(promise, null);
                                return;
                            }
                            CommonUtils.returnSuccess(promise,
                                    CommonUtils.convertV2TIMSignalingInfoToMap(singnalInfo));
                        }
                    }

                    @Override
                    public void onError(int code, String desc) {
                        CommonUtils.returnError(promise, code, desc);
                    }
                });

    }

    public void addInvitedSignaling(final Promise promise, ReadableMap arguments) {
        HashMap<String, Object> info = CommonUtils.convertReadableMapToHashMap(arguments.getMap("info"));
        V2TIMSignalingInfo param = new V2TIMSignalingInfo();
        if (info.get("inviteID") != null) {
            param.setInviteID((String) info.get("inviteID"));
        }
        if (info.get("groupID") != null) {
            param.setGroupID((String) info.get("groupID"));
        }
        if (info.get("inviter") != null) {
            param.setInviter((String) info.get("inviter"));
        }
        if (info.get("inviteeList") != null) {
            param.setInviteeList((List<String>) info.get("inviteeList"));
        }
        if (info.get("data") != null) {
            param.setData((String) info.get("data"));
        }
        if (info.get("timeout") != null) {
            param.setTimeout((Integer) info.get("timeout"));
        }
        if (info.get("actionType") != null) {
            param.setActionType((Integer) info.get("actionType"));
        }
        if (info.get("businessID") != null) {
            param.setBusinessID((Integer) info.get("businessID"));
        }
        V2TIMManager.getSignalingManager().addInvitedSignaling(param, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }
}
