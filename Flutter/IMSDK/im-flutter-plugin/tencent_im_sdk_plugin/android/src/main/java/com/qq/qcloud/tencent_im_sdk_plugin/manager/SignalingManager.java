package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
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

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SignalingManager {
    private static MethodChannel channel;
    private static HashMap<String,String> invitedIDMap = new HashMap();
    private  static HashMap<String, V2TIMSignalingListener> signalListenerList = new HashMap<>();
    public SignalingManager(MethodChannel _channel){
        SignalingManager.channel = _channel;
    }

    public void addSignalingListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        final V2TIMSignalingListener signallistener = new V2TIMSignalingListener() {
            @Override
            public void onReceiveNewInvitation(String inviteID, String inviter, String groupID, List<String> inviteeList, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviter",inviter);
                res.put("groupID",groupID);
                res.put("inviteeList",inviteeList);
                res.put("data",data);
                makeSignalingListenerEventData("onReceiveNewInvitation",res,listenerUuid);
            }

            @Override
            public void onInviteeAccepted(String inviteID, String invitee, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("invitee",invitee);
                res.put("data",data);
                makeSignalingListenerEventData("onInviteeAccepted",res,listenerUuid);
            }

            @Override
            public void onInviteeRejected(String inviteID, String invitee, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("invitee",invitee);
                res.put("data",data);
                makeSignalingListenerEventData("onInviteeRejected",res,listenerUuid);
            }

            @Override
            public void onInvitationCancelled(String inviteID, String inviter, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviter",inviter);
                res.put("data",data);
                makeSignalingListenerEventData("onInvitationCancelled",res,listenerUuid);
            }

            @Override
            public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviteeList",inviteeList);
                makeSignalingListenerEventData("onInvitationTimeout",res,listenerUuid);
            }
        };
        signalListenerList.put(listenerUuid, signallistener);
        V2TIMManager.getSignalingManager().addSignalingListener(signallistener);
        result.success("add signaling listener success");
    }
    public void removeSignalingListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        if(listenerUuid != ""){
            final V2TIMSignalingListener listener = signalListenerList.get(listenerUuid);
            V2TIMManager.getSignalingManager().removeSignalingListener(listener);
            signalListenerList.remove(listenerUuid);
            result.success("removeSignalingListener is done");
        }else{
            for(V2TIMSignalingListener listener :signalListenerList.values()) {
                V2TIMManager.getSignalingManager().removeSignalingListener(listener);
            }
            signalListenerList.clear();
            result.success("all signaling listener is removed");
        }
    }

    private <T> void  makeSignalingListenerEventData(String type,T data, String listenerUuid){
        CommonUtil.emitEvent(SignalingManager.channel,"signalingListener",type,data, listenerUuid);
    }
    public void invite(MethodCall methodCall, final MethodChannel.Result result){
        String invitee = CommonUtil.getParam(methodCall,result,"invitee");
        String data = CommonUtil.getParam(methodCall,result,"data");
        int timeout = CommonUtil.getParam(methodCall,result,"timeout");
        boolean onlineUserOnly = CommonUtil.getParam(methodCall,result,"onlineUserOnly");
        V2TIMOfflinePushInfo offlinePushInfo = new V2TIMOfflinePushInfo();
        HashMap<String,Object> offlinePushInfoParams = CommonUtil.getParam(methodCall,result,"offlinePushInfo");
        if(CommonUtil.getParam(methodCall,result,"offlinePushInfo")!=null){
            String title = (String) offlinePushInfoParams.get("title");
            String desc = (String) offlinePushInfoParams.get("desc");
            Boolean disablePush = (Boolean) offlinePushInfoParams.get("disablePush");
            String ext = (String) offlinePushInfoParams.get("ext");
            String iOSSound = (String) offlinePushInfoParams.get("iOSSound");
            Boolean ignoreIOSBadge = (Boolean) offlinePushInfoParams.get("ignoreIOSBadge");
            String androidOPPOChannelID = (String) offlinePushInfoParams.get("androidOPPOChannelID");
            if(title!=null){
                offlinePushInfo.setTitle(title);
            }
            if(desc!=null){
                offlinePushInfo.setDesc(desc);
            }
            if(offlinePushInfoParams.get("disablePush")!=null){
                offlinePushInfo.disablePush(disablePush);
            }
            if(ext!=null){
                offlinePushInfo.setExt(ext.getBytes());
            }
            if (iOSSound!=null){
                offlinePushInfo.setIOSSound(iOSSound);
            }
            if(offlinePushInfoParams.get("ignoreIOSBadge")!=null){
                offlinePushInfo.setIgnoreIOSBadge(ignoreIOSBadge);
            }
            if(androidOPPOChannelID!=null){
                offlinePushInfo.setAndroidOPPOChannelID(androidOPPOChannelID);
            }
        }
       final String current = String.valueOf(System.nanoTime());
        String id = V2TIMManager.getSignalingManager().invite(invitee,data,onlineUserOnly,offlinePushInfo,timeout,new V2TIMCallback(){

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
                invitedIDMap.remove(current);
            }

            @Override
            public void onSuccess() {
                // 这里使用上面同步返回的id
                CommonUtil.returnSuccess(result,invitedIDMap.get(current));
                invitedIDMap.remove(current);
            }
        });

        invitedIDMap.put(current,id);

    }
    public void inviteInGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        List<String> inviteeList = CommonUtil.getParam(methodCall,result,"inviteeList");
        String data = CommonUtil.getParam(methodCall,result,"data");
        int timeout = CommonUtil.getParam(methodCall,result,"timeout");
        boolean onlineUserOnly = CommonUtil.getParam(methodCall,result,"onlineUserOnly");
        final String current = String.valueOf(System.nanoTime());
        String id = V2TIMManager.getSignalingManager().inviteInGroup(groupID,inviteeList,data ,onlineUserOnly,timeout,new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
                invitedIDMap.remove(current);
            }

            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,invitedIDMap.get(current));
                invitedIDMap.remove(current);
            }
        });
        invitedIDMap.put(current,id);

    }
    public void cancel(MethodCall methodCall, final MethodChannel.Result result){
        String inviteID = CommonUtil.getParam(methodCall,result,"inviteID");
        String data = CommonUtil.getParam(methodCall,result,"data");
        V2TIMManager.getSignalingManager().cancel(inviteID,data ,new V2TIMCallback() {
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
    public void accept(MethodCall methodCall, final MethodChannel.Result result){
        String inviteID = CommonUtil.getParam(methodCall,result,"inviteID");
        String data = CommonUtil.getParam(methodCall,result,"data");
        V2TIMManager.getSignalingManager().accept(inviteID,data ,new V2TIMCallback() {
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
    public void reject(MethodCall methodCall, final MethodChannel.Result result){
        String inviteID = CommonUtil.getParam(methodCall,result,"inviteID");
        String data = CommonUtil.getParam(methodCall,result,"data");
        V2TIMManager.getSignalingManager().reject(inviteID,data ,new V2TIMCallback() {
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
    public void getSignalingInfo(MethodCall methodCall, final MethodChannel.Result result){
        String msgID = CommonUtil.getParam(methodCall,result,"msgID");
        List<String> messageIdList = new LinkedList<>();
        messageIdList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(messageIdList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if(v2TIMMessages.size()!=1){
                    CommonUtil.returnError(result,-1,"message not found");
                }else{
                    V2TIMSignalingInfo singnalInfo = V2TIMManager.getSignalingManager().getSignalingInfo(v2TIMMessages.get(0));
                    if(singnalInfo == null) {
                        CommonUtil.returnSuccess(result, null);
                        return;
                    }
                    CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMSignalingInfoToMap(singnalInfo));
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }
    public void addInvitedSignaling(MethodCall methodCall, final MethodChannel.Result result){
        HashMap<String,Object> info = CommonUtil.getParam(methodCall,result,"info");
        V2TIMSignalingInfo param = new V2TIMSignalingInfo();
        if(info.get("inviteID")!=null){
            param.setInviteID((String) info.get("inviteID"));
        }
        if(info.get("groupID")!=null){
            param.setGroupID((String) info.get("groupID"));
        }
        if(info.get("inviter")!=null){
            param.setInviter((String) info.get("inviter"));
        }
        if(info.get("inviteeList")!=null){
            param.setInviteeList((List<String>) info.get("inviteeList"));
        }
        if(info.get("data")!=null){
            param.setData((String) info.get("data"));
        }
        if(info.get("timeout")!=null){
            param.setTimeout((Integer) info.get("timeout"));
        }
        if(info.get("actionType")!=null){
            param.setActionType((Integer) info.get("actionType"));
        }
        if(info.get("businessID")!=null){
            param.setBusinessID((Integer) info.get("businessID"));
        }
        V2TIMManager.getSignalingManager().addInvitedSignaling(param, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
}
