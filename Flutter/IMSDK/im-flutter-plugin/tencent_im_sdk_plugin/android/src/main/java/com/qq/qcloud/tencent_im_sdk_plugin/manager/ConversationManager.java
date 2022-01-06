package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ConversationManager {
    private static MethodChannel channel;
    public ConversationManager(MethodChannel _channel){
        ConversationManager.channel = _channel;
    }

    public  void setConversationListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = methodCall.argument("listenerUuid");
        V2TIMManager.getConversationManager().setConversationListener(new V2TIMConversationListener() {
            @Override
            public void onSyncServerStart() {
                makeConversationListenerEventData("onSyncServerStart",null, listenerUuid);
            }

            @Override
            public void onSyncServerFinish() {
                makeConversationListenerEventData("onSyncServerFinish",null, listenerUuid);
            }

            @Override
            public void onSyncServerFailed() {
                makeConversationListenerEventData("onSyncServerFailed",null, listenerUuid);
            }

            @Override
            public void onNewConversation(List<V2TIMConversation> conversationList) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                makeConversationListenerEventData("onNewConversation",list, listenerUuid);
            }

            @Override
            public void onConversationChanged(List<V2TIMConversation> conversationList) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                makeConversationListenerEventData("onConversationChanged",list, listenerUuid);
            }
            @Override
            public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                makeConversationListenerEventData("onTotalUnreadMessageCountChanged",totalUnreadCount, listenerUuid);
            }
        });
        result.success("add conversation listener success");
    }
    public  void  getConversation(MethodCall methodCall,final  MethodChannel.Result result){
        String conversationID = CommonUtil.getParam(methodCall,result,"conversationID");
        V2TIMManager.getConversationManager().getConversation(conversationID, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationToMap(v2TIMConversation));
            }
        });
    }
    private <T> void  makeConversationListenerEventData(String type,T data, String listenerUuid){
        CommonUtil.emitEvent(ConversationManager.channel,"conversationListener",type,data, listenerUuid);
    }
    public void getConversationList(MethodCall methodCall, final MethodChannel.Result result){
        String nextSeq = CommonUtil.getParam(methodCall,result,"nextSeq");
        int count = CommonUtil.getParam(methodCall,result,"count");
        V2TIMManager.getConversationManager().getConversationList(Long.parseLong(nextSeq), count, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationResultToMap(v2TIMConversationResult));
            }
        });
    }
    public void getConversationListByConversaionIds(MethodCall methodCall, final MethodChannel.Result result){
      List<String>  conversationIDList = CommonUtil.getParam(methodCall,result,"conversationIDList");
      V2TIMManager.getConversationManager().getConversationList(conversationIDList, new V2TIMValueCallback<List<V2TIMConversation>>() {
          @Override
          public void onSuccess(List<V2TIMConversation> v2TIMConversations) {
              LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
              for(int i = 0;i<v2TIMConversations.size();i++){
                  list.add(CommonUtil.convertV2TIMConversationToMap(v2TIMConversations.get(i)));
              }
              CommonUtil.returnSuccess(result,list);
          }

          @Override
          public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
          }
      });
    }
    public void pinConversation(MethodCall methodCall, final MethodChannel.Result result){
        String conversationID = CommonUtil.getParam(methodCall,result,"conversationID");
       boolean isPinned = CommonUtil.getParam(methodCall,result,"isPinned");
       V2TIMManager.getConversationManager().pinConversation(conversationID, isPinned, new V2TIMCallback() {
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
    public void getTotalUnreadMessageCount(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
            @Override
            public void onSuccess(Long aLong) {
                CommonUtil.returnSuccess(result,aLong);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversation(MethodCall methodCall, final MethodChannel.Result result) {
        // 会话ID
        String conversationID = CommonUtil.getParam(methodCall, result, "conversationID");
        V2TIMManager.getConversationManager().deleteConversation(conversationID, new V2TIMCallback() {
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
    public void setConversationDraft(MethodCall methodCall, final MethodChannel.Result result) {
        // 会话ID
        String conversationID = CommonUtil.getParam(methodCall, result, "conversationID");
        String draftText = CommonUtil.getParam(methodCall, result, "draftText");
        if(draftText==""){
            draftText = null;
        }
        V2TIMManager.getConversationManager().setConversationDraft(conversationID,draftText, new V2TIMCallback() {
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
}
