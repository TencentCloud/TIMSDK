package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSignalingListener;

import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SignalingManager {
    private static MethodChannel channel;
    private static V2TIMSignalingListener signallistener;
    private static HashMap<String,String> invitedIDMap = new HashMap();
    public SignalingManager(MethodChannel _channel){
        SignalingManager.channel = _channel;
    }

    public void addSignalingListener(MethodCall methodCall, final MethodChannel.Result result){
        signallistener = new V2TIMSignalingListener() {
            @Override
            public void onReceiveNewInvitation(String inviteID, String inviter, String groupID, List<String> inviteeList, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviter",inviter);
                res.put("groupID",groupID);
                res.put("inviteeList",inviteeList);
                res.put("data",data);
                makeSignalingListenerEventData("onReceiveNewInvitation",res);
            }

            @Override
            public void onInviteeAccepted(String inviteID, String invitee, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("invitee",invitee);
                res.put("data",data);
                makeSignalingListenerEventData("onInviteeAccepted",res);
            }

            @Override
            public void onInviteeRejected(String inviteID, String invitee, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("invitee",invitee);
                res.put("data",data);
                makeSignalingListenerEventData("onInviteeRejected",res);
            }

            @Override
            public void onInvitationCancelled(String inviteID, String inviter, String data) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviter",inviter);
                res.put("data",data);
                makeSignalingListenerEventData("onInvitationCancelled",res);
            }

            @Override
            public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
                HashMap<String,Object> res = new HashMap<String,Object>();
                res.put("inviteID",inviteID);
                res.put("inviteeList",inviteeList);
                makeSignalingListenerEventData("onInvitationTimeout",res);
            }
        };
        V2TIMManager.getSignalingManager().addSignalingListener(signallistener);
    }
    public void removeSignalingListener(MethodCall methodCall, final MethodChannel.Result result){
        if(signallistener==null){
            result.error("-1","no listener",null);
        }else{
            V2TIMManager.getSignalingManager().removeSignalingListener(signallistener);
            result.success(null);
        }
    }

    private <T> void  makeSignalingListenerEventData(String type,T data){
        CommonUtil.emitEvent(SignalingManager.channel,"signalingListener",type,data);
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
            if(offlinePushInfoParams.get("disable")!=null){
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
        V2TIMManager.getSignalingManager().getSignalingInfo(new V2TIMMessage());
    }
    public void addInvitedSignaling(MethodCall methodCall, final MethodChannel.Result result){
        //这个方法可能被删掉了
    }
}
