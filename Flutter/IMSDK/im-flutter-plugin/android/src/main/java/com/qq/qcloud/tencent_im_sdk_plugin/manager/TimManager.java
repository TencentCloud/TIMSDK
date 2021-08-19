package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import android.content.Context;
import android.util.Log;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
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
    private static V2TIMSimpleMsgListener simpleMsgListener;//只允许注册一次listener
    public static Context context;
    public TimManager(MethodChannel _channel, Context context){
        TimManager.channel = _channel;
        TimManager.context = context;
    }
    public  void addSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){
        simpleMsgListener = new V2TIMSimpleMsgListener(){
            public void onRecvC2CTextMessage (String msgID, V2TIMUserInfo sender, String text){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
                res.put("text",text);
                makeaddSimpleMsgListenerEventData("onRecvC2CTextMessage",res);
            }

            public void onRecvC2CCustomMessage (String msgID, V2TIMUserInfo sender, byte[] customData){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
                res.put("customData",customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvC2CCustomMessage",res);
            }

            public void onRecvGroupTextMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, String text){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("groupID",groupID);
                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("text",text);
                makeaddSimpleMsgListenerEventData("onRecvGroupTextMessage",res);
            }

            public void onRecvGroupCustomMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData){
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("msgID",msgID);
                res.put("groupID",groupID);
                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
                res.put("customData",customData == null ? "" : new String(customData));
                makeaddSimpleMsgListenerEventData("onRecvGroupCustomMessage",res);
            }
        };
        V2TIMManager.getInstance().addSimpleMsgListener(simpleMsgListener);
    }
    public void removeSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){
        if(simpleMsgListener==null){
            result.error("-1","no listener",null);
        }else{
            V2TIMManager.getInstance().removeSimpleMsgListener(simpleMsgListener);
            result.success(null);
        }
    }
    public void initSDK(MethodCall methodCall, MethodChannel.Result result) {

        int sdkAppID =  methodCall.argument("sdkAppID");
        int logLevel =  methodCall.argument("logLevel");



        // 主线程才初始化SDK
//        if (SessionWrapper.isMainProcess(context)) {

            V2TIMSDKConfig config = new V2TIMSDKConfig();
            config.setLogLevel(logLevel);
            Boolean res =  V2TIMManager.getInstance().initSDK(context, sdkAppID, config, new V2TIMSDKListener(){
                public void onConnecting() {
                    makeEventData("onConnecting",null);
                }

                public void onConnectSuccess() {
                    makeEventData("onConnectSuccess",null);
                }

                public void onConnectFailed(int code, String error) {
                    HashMap<String,Object> err = new HashMap<String,Object>();
                    err.put("code",code);
                    err.put("desc",error);
                    makeEventData("onConnectFailed",err);
                }

                public void onKickedOffline() {
                    makeEventData("onKickedOffline",null);
                }

                public void onUserSigExpired() {
                    makeEventData("onUserSigExpired",null);
                }

                public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                    makeEventData("onSelfInfoUpdated",CommonUtil.convertV2TIMUserFullInfoToMap(info));
                }
            });
            CommonUtil.returnSuccess(result,res);
//        }
    }
    private <T> void  makeEventData(String type,T data){
        CommonUtil.emitEvent(TimManager.channel,"initSDKListener",type,data);
    }
    private <T> void  makeaddSimpleMsgListenerEventData(String type,T data){
        CommonUtil.emitEvent(TimManager.channel,"simpleMsgListener",type,data);
    }
    private <T> void  makeaddGroupListenerEventData(String type,T data){
        CommonUtil.emitEvent(TimManager.channel,"groupListener",type,data);
    }
    public void unInitSDK(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getInstance().unInitSDK();
        CommonUtil.returnSuccess(result,null);
    }
    public void login(MethodCall methodCall, final MethodChannel.Result result) {
        String userID = CommonUtil.getParam(methodCall, result, "userID");
        String userSig = CommonUtil.getParam(methodCall, result, "userSig");
        // 登录操作
        V2TIMManager.getInstance().login(userID, userSig, new V2TIMCallback(){
            public void onError (int code, String desc){
                CommonUtil.returnError(result,code,desc);
            }
            public void onSuccess (){
                CommonUtil.returnSuccess(result,null);
            }
        });
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

    public void setGroupListener(MethodCall methodCall, final MethodChannel.Result result){
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
                makeaddGroupListenerEventData("onMemberEnter",data);
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                makeaddGroupListenerEventData("onMemberLeave",data);
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
                makeaddGroupListenerEventData("onMemberInvited",data);
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
                makeaddGroupListenerEventData("onMemberKicked",data);
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
                makeaddGroupListenerEventData("onMemberInfoChanged",data);
            }

            @Override
            public void onGroupCreated(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                makeaddGroupListenerEventData("onGroupCreated",data);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupDismissed",data);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                makeaddGroupListenerEventData("onGroupRecycled",data);
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
                makeaddGroupListenerEventData("onGroupInfoChanged",data);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onReceiveJoinApplication",data);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
                data.put("isAgreeJoin",isAgreeJoin);
                data.put("opReason",opReason);
                makeaddGroupListenerEventData("onApplicationProcessed",data);
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
                makeaddGroupListenerEventData("onGrantAdministrator",data);
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
                makeaddGroupListenerEventData("onRevokeAdministrator",data);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);

                makeaddGroupListenerEventData("onQuitFromGroup",data);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("customData",customData == null ? "" : new String(customData));
                makeaddGroupListenerEventData("onReceiveRESTCustomData",data);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                HashMap<String,Object> data = new HashMap<String,Object>();
                data.put("groupID",groupID);
                data.put("groupAttributeMap",groupAttributeMap);
                makeaddGroupListenerEventData("onGroupAttributeChanged",data);
            }
        });
    }
    public void createGroup(MethodCall methodCall, final MethodChannel.Result result) {

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
    public void joinGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID = this.getParam(methodCall,result,"groupID");
        String message = this.getParam(methodCall,result,"message");
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
    public void quitGroup(MethodCall methodCall, final MethodChannel.Result result) {
        // 群ID
        String groupID = this.getParam(methodCall, result, "groupID");

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
    public void getUsersInfo(MethodCall methodCall, final MethodChannel.Result result){

        List<String> userIDList = this.getParam(methodCall, result, "userIDList");
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
    public void setSelfInfo(MethodCall methodCall, final MethodChannel.Result result) {

        String nickName = methodCall.argument("nickName");
        String faceUrl = methodCall.argument("faceUrl");
        String selfSignature = methodCall.argument("selfSignature");
        Integer gender = methodCall.argument("gender");
        Integer allowType = methodCall.argument("allowType");
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
        if(allowType!=null){
            userFullInfo.setAllowType(allowType);
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
    private <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
        T par = methodCall.argument(param);
        if (par == null) {
            Log.w(TAG, "init: Cannot find parameter `" + param + "` or `" + param + "` is null!");
            throw new RuntimeException("Cannot find parameter `" + param + "` or `" + param + "` is null!");
        }
        return par;
    }
}
