package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import android.content.Context;
import android.util.Log;

import com.qq.qcloud.tencent_im_sdk_plugin.util.AbCallback;
import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
import com.tencent.imsdk.common.IMLog;
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
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TimManager {

    public static String TAG = "tencent_im_sdk_plugin";
    private static MethodChannel channel;
    private static HashMap<String, V2TIMSimpleMsgListener> simpleMsgListenerMap = new HashMap<>();
    private static HashMap<String, V2TIMGroupListener> groupListenerMap = new HashMap<>();
    private static HashMap<String, V2TIMSDKListener> initListenerMap = new HashMap<>();
    public static Context context;
    public TimManager(MethodChannel _channel, Context context){
        TimManager.channel = _channel;
        TimManager.context = context;
    }
    public void addSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        final V2TIMSimpleMsgListener listener = new V2TIMSimpleMsgListener(){
            public void onRecvC2CTextMessage (String msgID, V2TIMUserInfo sender, String text){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
                res.put("text",text);
                makeaddSimpleMsgListenerEventData("onRecvC2CTextMessage",res, listenerUuid);
            }

            public void onRecvC2CCustomMessage (String msgID, V2TIMUserInfo sender, byte[] customData){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
                res.put("customData",customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvC2CCustomMessage",res, listenerUuid);
            }

            public void onRecvGroupTextMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, String text){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("groupID",groupID);
                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("text",text);
                makeaddSimpleMsgListenerEventData("onRecvGroupTextMessage",res, listenerUuid);
            }

            public void onRecvGroupCustomMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("groupID",groupID);
                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("customData",customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvGroupCustomMessage",res, listenerUuid);
            }
        };
        simpleMsgListenerMap.put(listenerUuid, listener);
        V2TIMManager.getInstance().addSimpleMsgListener(listener);
        result.success("add simple msg listener success");
    }

    public void getUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().getUserStatus(userIDList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMUserStatuses.size();i++){
                    list.add(CommonUtil.convertV2TIMUserStatusToMap(v2TIMUserStatuses.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void setSelfStatus(MethodCall methodCall, final MethodChannel.Result result){
        String status = methodCall.argument("status");
        V2TIMUserStatus customStatus = new V2TIMUserStatus();
        customStatus.setCustomStatus(status);
        V2TIMManager.getInstance().setSelfStatus(customStatus, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void removeSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        if (listenerUuid != "") {
            final V2TIMSimpleMsgListener listener = simpleMsgListenerMap.get(listenerUuid);
            V2TIMManager.getInstance().removeSimpleMsgListener(listener);
            simpleMsgListenerMap.remove(listenerUuid);
            result.success("removeSimpleMsgListener is done");
        } else {
            for (V2TIMSimpleMsgListener listener : simpleMsgListenerMap.values()) {
                V2TIMManager.getInstance().removeSimpleMsgListener(listener);
            }
            simpleMsgListenerMap.clear();
            result.success("all simple msg listener is removed");
        }
    }
    public void removeGroupListener(MethodCall methodCall, MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        if (listenerUuid != "") {
            final V2TIMGroupListener listener = groupListenerMap.get(listenerUuid);
            V2TIMManager.getInstance().removeGroupListener(listener);
            groupListenerMap.remove(listenerUuid);
            result.success("removeGroupListener is done");
        } else {
            for (V2TIMGroupListener listener : groupListenerMap.values()) {
                V2TIMManager.getInstance().removeGroupListener(listener);
            }
            groupListenerMap.clear();
            result.success("all groupListener is removed");
        }
    }
    public void initSDK(final MethodCall methodCall, final MethodChannel.Result result) {
        int sdkAppID =  methodCall.argument("sdkAppID");
        int logLevel =  methodCall.argument("logLevel");
        String uiPlatform =  methodCall.argument("uiPlatform");
        final String listenerUuid = methodCall.argument("listenerUuid");

        // Global configuration
        
//        V2TIMManager.getInstance().callExperimentalAPI("setTestEnvironment", true, null);
        V2TIMManager.getInstance().callExperimentalAPI("setUIPlatform",uiPlatform, null);
        // The main thread initializes the SDK
//        if (SessionWrapper.isMainProcess(context)) {

        V2TIMSDKConfig config = new V2TIMSDKConfig();
        config.setLogLevel(logLevel);
        V2TIMSDKListener initListener = new V2TIMSDKListener(){
            public void onConnecting() {
                makeEventData("onConnecting",null, listenerUuid);
            }

            public void onConnectSuccess() {
                makeEventData("onConnectSuccess",null, listenerUuid);
            }

            public void onConnectFailed(int code, String error) {
                HashMap<String,Object> err = new HashMap<String,Object>();
                err.put("code",code);
                err.put("desc",error);
                makeEventData("onConnectFailed",err, listenerUuid);
            }

            public void onKickedOffline() {
                makeEventData("onKickedOffline",null, listenerUuid);
            }

            public void onUserSigExpired() {
                makeEventData("onUserSigExpired",null, listenerUuid);
            }

            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                makeEventData("onSelfInfoUpdated",CommonUtil.convertV2TIMUserFullInfoToMap(info), listenerUuid);
            }
            public void onUserStatusChanged(List<V2TIMUserStatus> statusList){
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<statusList.size();i++){
                    list.add(CommonUtil.convertV2TIMUserStatusToMap(statusList.get(i)));
                }
                Map<String,Object> data = new HashMap<String,Object>();
                data.put("statusList",list);
                makeEventData("onUserStatusChanged",data, listenerUuid);
            }
        };
        Boolean res = false;
        try{
            res = V2TIMManager.getInstance().initSDK(context,sdkAppID,config);
        }catch (Exception e){

        };
        V2TIMManager.getInstance().addIMSDKListener(initListener);
//            Boolean res =  V2TIMManager.getInstance().initSDK(context, sdkAppID, config, initListener);
        initListenerMap.put(listenerUuid,initListener);
        CommonUtil.returnSuccess(result,res);
//        }

    }
    private <T> void  makeEventData(String type,T data, String listenerUuid){
        CommonUtil.emitEvent(TimManager.channel,"initSDKListener",type,data, listenerUuid);
    }
    private <T> void  makeaddSimpleMsgListenerEventData(String type,T data, String listenerID){
        CommonUtil.emitEvent(TimManager.channel,"simpleMsgListener",type,data,listenerID);
    }
    private <T> void  makeaddGroupListenerEventData(String type,T data, String listenerUuid){
        CommonUtil.emitEvent(TimManager.channel,"groupListener",type,data, listenerUuid);
    }
    public void unInitSDK(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getInstance().unInitSDK();
        CommonUtil.returnSuccess(result,null);
    }
    public void login(final MethodCall methodCall, final MethodChannel.Result result) {

        String userID = CommonUtil.getParam(methodCall, result, "userID");
        String userSig = CommonUtil.getParam(methodCall, result, "userSig");
        // login operation
        V2TIMManager.getInstance().login(userID, userSig, new V2TIMCallback(){
            public void onError (int code, String desc){
                CommonUtil.returnError(result,code,desc);
            }
            public void onSuccess (){
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    // 安卓仅仅保证不报错
    public void setAPNSListener(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,"add setAPNSListener success");
    }
    public void getVersion(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,V2TIMManager.getInstance().getVersion());
    }
    public void getServerTime(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,V2TIMManager.getInstance().getServerTime());

    }

    public void logout(MethodCall methodCall, final MethodChannel.Result result) {
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    public void getLoginUser(MethodCall methodCall, final MethodChannel.Result result) {
        String user = V2TIMManager.getInstance().getLoginUser();
        CommonUtil.returnSuccess(result,user);

    }
    public void getLoginStatus(MethodCall methodCall, final MethodChannel.Result result) {
        int user = V2TIMManager.getInstance().getLoginStatus();
        CommonUtil.returnSuccess(result,user);
    }
    public void sendC2CTextMessage(MethodCall methodCall, final MethodChannel.Result result) {
        String text = this.getParam(methodCall, result, "text");
        String userID = this.getParam(methodCall, result, "userID");

        String mesage = V2TIMManager.getInstance().sendC2CTextMessage(text, userID, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {

                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendC2CCustomMessage(MethodCall methodCall, final MethodChannel.Result result) {
        String customData = this.getParam(methodCall, result, "customData");
        String userID = this.getParam(methodCall, result, "userID");
        byte[] customDataBytes = customData.getBytes();
        V2TIMManager.getInstance().sendC2CCustomMessage(customDataBytes, userID, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendGroupTextMessage(MethodCall methodCall, final MethodChannel.Result result){
        String text = CommonUtil.getParam(methodCall,result,"text");
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int priority = CommonUtil.getParam(methodCall,result,"priority");
        V2TIMManager.getInstance().sendGroupTextMessage(text, groupID, priority, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendGroupCustomMessage(MethodCall methodCall, final MethodChannel.Result result){
        String customData = CommonUtil.getParam(methodCall,result,"customData");
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int priority = CommonUtil.getParam(methodCall,result,"priority");
        V2TIMManager.getInstance().sendGroupCustomMessage(customData.getBytes(), groupID, priority, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void addGroupListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        V2TIMGroupListener groupListener =  new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberEnter",data,listenerUuid);
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                makeaddGroupListenerEventData("onMemberLeave",data,listenerUuid);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberInvited",data,listenerUuid);
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberKicked",data,listenerUuid);
            }

            @Override
            public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMGroupMemberChangeInfoList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberChangeInfoToMap(v2TIMGroupMemberChangeInfoList.get(i)));
                }
                data.put("groupMemberChangeInfoList",list);
                makeaddGroupListenerEventData("onMemberInfoChanged",data,listenerUuid);
            }

            @Override
            public void onGroupCreated(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                makeaddGroupListenerEventData("onGroupCreated",data,listenerUuid);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupDismissed",data,listenerUuid);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupRecycled",data,listenerUuid);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<changeInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupChangeInfoToMap(changeInfos.get(i)));
                }
                data.put("groupChangeInfoList",list);
                makeaddGroupListenerEventData("onGroupInfoChanged",data,listenerUuid);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onReceiveJoinApplication",data,listenerUuid);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                data.put("isAgreeJoin",isAgreeJoin);
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onApplicationProcessed",data,listenerUuid);
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onGrantAdministrator",data,listenerUuid);
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onRevokeAdministrator",data,listenerUuid);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);

                makeaddGroupListenerEventData("onQuitFromGroup",data,listenerUuid);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("customData",customData == null ? "" : new String(customData));
                makeaddGroupListenerEventData("onReceiveRESTCustomData",data,listenerUuid);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("groupAttributeMap",groupAttributeMap);
                makeaddGroupListenerEventData("onGroupAttributeChanged",data,listenerUuid);
            }

            @Override
            public void onTopicCreated(String groupID, String topicID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicID",topicID);
                makeaddGroupListenerEventData("onTopicCreated",data,listenerUuid);
            }

            @Override
            public void onTopicDeleted(String groupID, List<String> topicIDList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicIDList",topicIDList);
                makeaddGroupListenerEventData("onTopicDeleted",data,listenerUuid);
            }

            @Override
            public void onTopicInfoChanged(String groupID, V2TIMTopicInfo topicInfo) {
                System.out.println("1231231231231231231212312");
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicInfo",CommonUtil.convertV2TIMTopicInfoToMap(topicInfo));
                makeaddGroupListenerEventData("onTopicInfoChanged",data,listenerUuid);
            }
        };
        groupListenerMap.put(listenerUuid, groupListener);
        V2TIMManager.getInstance().addGroupListener(groupListener);
        result.success("add group listener success");
    }
    public void setGroupListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        V2TIMManager.getInstance().setGroupListener(new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberEnter",data,listenerUuid);

            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                makeaddGroupListenerEventData("onMemberLeave",data,listenerUuid);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberInvited",data,listenerUuid);
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onMemberKicked",data,listenerUuid);
            }

            @Override
            public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMGroupMemberChangeInfoList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberChangeInfoToMap(v2TIMGroupMemberChangeInfoList.get(i)));
                }
                data.put("groupMemberChangeInfoList",list);
                makeaddGroupListenerEventData("onMemberInfoChanged",data,listenerUuid);
            }

            @Override
            public void onGroupCreated(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                makeaddGroupListenerEventData("onGroupCreated",data,listenerUuid);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupDismissed",data,listenerUuid);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupRecycled",data,listenerUuid);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<changeInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupChangeInfoToMap(changeInfos.get(i)));
                }
                data.put("groupChangeInfoList",list);
                makeaddGroupListenerEventData("onGroupInfoChanged",data,listenerUuid);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onReceiveJoinApplication",data,listenerUuid);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                data.put("isAgreeJoin",isAgreeJoin);
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onApplicationProcessed",data,listenerUuid);
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onGrantAdministrator",data,listenerUuid);
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<memberList.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
                }
                data.put("memberList",list);
                makeaddGroupListenerEventData("onRevokeAdministrator",data,listenerUuid);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);

                makeaddGroupListenerEventData("onQuitFromGroup",data,listenerUuid);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("customData",customData == null ? "" : new String(customData));
                makeaddGroupListenerEventData("onReceiveRESTCustomData",data,listenerUuid);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("groupAttributeMap",groupAttributeMap);
                makeaddGroupListenerEventData("onGroupAttributeChanged",data,listenerUuid);
            }
            @Override
            public void onTopicCreated(String groupID, String topicID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicID",topicID);
                makeaddGroupListenerEventData("onTopicCreated",data,listenerUuid);
            }

            @Override
            public void onTopicDeleted(String groupID, List<String> topicIDList) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicIDList",topicIDList);
                makeaddGroupListenerEventData("onTopicDeleted",data,listenerUuid);
            }

            @Override
            public void onTopicInfoChanged(String groupID, V2TIMTopicInfo topicInfo) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("topicInfo",CommonUtil.convertV2TIMTopicInfoToMap(topicInfo));
                makeaddGroupListenerEventData("onTopicInfoChanged",data,listenerUuid);
            }
        });
        result.success("set group listener success");
    }
    public void createGroup(final MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                String groupType = methodCall.argument("groupType");
                String groupID = methodCall.argument("groupID");
                String groupName = methodCall.argument("groupName");
                V2TIMManager.getInstance().createGroup(groupType, groupID, groupName, new V2TIMValueCallback<String>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }
                    @Override
                    public void onSuccess(String s) {
                        CommonUtil.returnSuccess(result,s);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }
    public void joinGroup(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                String groupID = methodCall.argument("groupID");
                String message = methodCall.argument("message");
                V2TIMManager.getInstance().joinGroup(groupID, message, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });


    }
    public void quitGroup(final MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                // 群ID
                String groupID = methodCall.argument("groupID");

                V2TIMManager.getInstance().quitGroup(groupID, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void dismissGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID = this.getParam(methodCall,result,"groupID");
        V2TIMManager.getInstance().dismissGroup(groupID, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    public void getUsersInfo(final MethodCall methodCall, final MethodChannel.Result result){

        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().getUsersInfo(userIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMUserFullInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMUserFullInfoToMap(v2TIMUserFullInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });

    }
    public void setSelfInfo(final MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                String nickName = methodCall.argument("nickName");
                String faceUrl = methodCall.argument("faceUrl");
                String selfSignature = methodCall.argument("selfSignature");
                Integer gender = methodCall.argument("gender");
                Integer allowType = methodCall.argument("allowType");
                Integer birthday = methodCall.argument("birthday");
                Integer level = methodCall.argument("level");
                Integer role = methodCall.argument("role");
                HashMap<String,String> customInfoString = methodCall.argument("customInfo");

                V2TIMUserFullInfo userFullInfo = new V2TIMUserFullInfo();

                if(nickName!=null){
                    userFullInfo.setNickname(nickName);
                }
                if(faceUrl!=null){
                    userFullInfo.setFaceUrl(faceUrl);
                }
                if(selfSignature!=null){
                    userFullInfo.setSelfSignature(selfSignature);
                }
                if(gender!=null){
                    userFullInfo.setGender(gender);
                }
                if(birthday!=null){
                    userFullInfo.setBirthday(birthday);
                }
                if(allowType!=null){
                    userFullInfo.setAllowType(allowType);
                }
                if(level!=null){
                    userFullInfo.setLevel(level);
                }
                if(role!=null){
                    userFullInfo.setRole(role);
                }
                if(CommonUtil.getParam(methodCall,result,"customInfo")!=null){
                    HashMap<String, byte[]> newCustomHashMap = new HashMap<String, byte[]>();
                    if(!customInfoString.isEmpty()){
                        for(String key : customInfoString.keySet() ){
                            String value = customInfoString.get(key);
                            newCustomHashMap.put(key,value.getBytes());
                        }
                        userFullInfo.setCustomInfo(newCustomHashMap);
                    }
                }
                V2TIMManager.getInstance().setSelfInfo(userFullInfo, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }
    public void callExperimentalAPI(MethodCall methodCall, final MethodChannel.Result result){
        String api = methodCall.argument("api");
        Object param = methodCall.argument("param");
        V2TIMManager.getInstance().callExperimentalAPI(api, param, new V2TIMValueCallback<Object>() {

            @Override
            public void onSuccess(Object o) {
                CommonUtil.returnSuccess(result,o);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void checkAbility(MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                CommonUtil.returnSuccess(result,1);
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void subscribeUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().subscribeUserStatus(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void unsubscribeUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().unsubscribeUserStatus(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    private <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
        T par = methodCall.argument(param);
        if (par == null) {
            Log.w(TAG, "init: Cannot find parameter `" + param + "` or `" + param + "` is null!");
            throw new RuntimeException("Cannot find parameter `" + param + "` or `" + param + "` is null!");
        }
        return par;
    }
}
