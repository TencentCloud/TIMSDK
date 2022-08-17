package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ConversationManager {
    private static MethodChannel channel;
    private static  HashMap<String, V2TIMConversationListener> conversationListenerList= new HashMap();
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
            @Override
            public void onConversationGroupCreated(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationGroupCreated",data, listenerUuid);
            }

            @Override
            public void onConversationGroupDeleted(String groupName) {
                makeConversationListenerEventData("onConversationGroupDeleted",groupName, listenerUuid);
            }

            @Override
            public void onConversationGroupNameChanged(String oldName, String newName) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("oldName",oldName);
                data.put("newName",newName);
                makeConversationListenerEventData("onConversationGroupNameChanged",data, listenerUuid);
            }

            @Override
            public void onConversationsAddedToGroup(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationsAddedToGroup",data, listenerUuid);
            }

            @Override
            public void onConversationsDeletedFromGroup(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationsDeletedFromGroup",data, listenerUuid);
            }
        });
        result.success("add conversation listener success");
    }
    public void removeConversationListener(MethodCall call,final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(call,result,"listenerUuid");
        if (listenerUuid != "") {
            final V2TIMConversationListener listener = conversationListenerList.get(listenerUuid);
            V2TIMManager.getConversationManager().removeConversationListener(listener);
            conversationListenerList.remove(listenerUuid);
            result.success("removeConversationListener is done");
        } else {
            for (V2TIMConversationListener listener : conversationListenerList.values()) {
                V2TIMManager.getConversationManager().removeConversationListener(listener);
            }
            conversationListenerList.clear();
            result.success("all conversation listener message is removed");
        }
    }

    public void  addConversationListener(MethodCall call,final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(call,result,"listenerUuid");
        final V2TIMConversationListener conversationLister = new V2TIMConversationListener() {
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

            @Override
            public void onConversationGroupCreated(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationGroupCreated",data, listenerUuid);
            }

            @Override
            public void onConversationGroupDeleted(String groupName) {
                makeConversationListenerEventData("onConversationGroupDeleted",groupName, listenerUuid);
            }

            @Override
            public void onConversationGroupNameChanged(String oldName, String newName) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("oldName",oldName);
                data.put("newName",newName);
                makeConversationListenerEventData("onConversationGroupNameChanged",data, listenerUuid);
            }

            @Override
            public void onConversationsAddedToGroup(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationsAddedToGroup",data, listenerUuid);
            }

            @Override
            public void onConversationsDeletedFromGroup(String groupName, List<V2TIMConversation> conversationList) {
                HashMap<String,Object> data = new HashMap<>();
                data.put("groupName",groupName);
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<conversationList.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
                }
                data.put("conversationList",list);
                makeConversationListenerEventData("onConversationsDeletedFromGroup",data, listenerUuid);
            }
        };
        conversationListenerList.put(listenerUuid, conversationLister);
        V2TIMManager.getConversationManager().addConversationListener(conversationLister);
        result.success("addConversationListener success");
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
        // session id
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
        // session id
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
    public void setConversationCustomData(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String customData = CommonUtil.getParam(methodCall, result, "customData");
        V2TIMManager.getConversationManager().setConversationCustomData(conversationIDList, customData, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void getConversationListByFilter(MethodCall methodCall, final MethodChannel.Result result) {
        final Map<String,Object> filter = CommonUtil.getParam(methodCall,result,"filter");
        final V2TIMConversationListFilter filterNative = new V2TIMConversationListFilter();
        if(filter.get("conversationType")!=null){
            filterNative.setConversationType((Integer) filter.get("conversationType"));
        }
        if(filter.get("nextSeq")!=null){
            filterNative.setNextSeq( Long.parseLong(filter.get("nextSeq").toString()) );
        }
        if(filter.get("count")!=null){
            filterNative.setCount((Integer) filter.get("count"));
        }
        if(filter.get("markType")!=null){
            filterNative.setMarkType(0x1l << (int)filter.get("markType"));
        }if(filter.get("groupName")!=null){
            filterNative.setGroupName((String) filter.get("groupName"));
        }
        V2TIMManager.getConversationManager().getConversationListByFilter(filterNative, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationResultToMap(v2TIMConversationResult));
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });

    }
    public void markConversation(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        Boolean enableMark = CommonUtil.getParam(methodCall, result, "enableMark");
        int markType = CommonUtil.getParam(methodCall, result, "markType");
        long longMarkType = 0x1l << markType;
        V2TIMManager.getConversationManager().markConversation(conversationIDList, longMarkType, enableMark, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });

    }
    public void createConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().createConversationGroup(groupName, conversationIDList, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void getConversationGroupList(MethodCall methodCall, final MethodChannel.Result result) {
        V2TIMManager.getConversationManager().getConversationGroupList(new V2TIMValueCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> strings) {
                List<String>  list = new LinkedList();
                for(int i = 0;i < strings.size();i++){
                    list.add(strings.get(i));
                }
                System.out.println(list);
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().deleteConversationGroup(groupName, new V2TIMCallback() {
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
    public void renameConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        String oldName = CommonUtil.getParam(methodCall, result, "oldName");
        String newName = CommonUtil.getParam(methodCall, result, "newName");
        V2TIMManager.getConversationManager().renameConversationGroup(oldName, newName, new V2TIMCallback() {
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
    public void addConversationsToGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().addConversationsToGroup(groupName,conversationIDList , new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversationsFromGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().deleteConversationsFromGroup( groupName,conversationIDList , new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }



}
