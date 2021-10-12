package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
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
import com.tencent.imsdk.v2.V2TIMValueCallback;


import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
public class GroupManager {
    private static MethodChannel channel;
    public GroupManager(MethodChannel _channel){
        GroupManager.channel = _channel;
    }


    public void createGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String groupType = CommonUtil.getParam(methodCall,result,"groupType");
        String groupName = CommonUtil.getParam(methodCall,result,"groupName");
        String notification = CommonUtil.getParam(methodCall,result,"notification");
        String introduction = CommonUtil.getParam(methodCall,result,"introduction");
        String faceUrl = CommonUtil.getParam(methodCall,result,"faceUrl");


        V2TIMGroupInfo info =  new V2TIMGroupInfo();
        if(groupID!=null){
            info.setGroupID(groupID);
        }
        if(groupType!=null){
            info.setGroupType(groupType);
        }
        if(groupName!=null){
            info.setGroupName(groupName);
        }
        if(notification!=null){
            info.setNotification(notification);
        }
        if(introduction!=null){
            info.setIntroduction(introduction);
        }
        if(faceUrl!=null){
            info.setFaceUrl(faceUrl);
        }
        if(CommonUtil.getParam(methodCall,result,"isAllMuted")!=null){
            boolean isAllMuted = CommonUtil.getParam(methodCall,result,"isAllMuted");
            info.setAllMuted (isAllMuted);
        }
        if(CommonUtil.getParam(methodCall,result,"addOpt")!=null){
            int addOpt = CommonUtil.getParam(methodCall,result,"addOpt");
            info.setGroupAddOpt(addOpt);
        }
        List<V2TIMCreateGroupMemberInfo> memberList = new LinkedList<V2TIMCreateGroupMemberInfo>();
        if(CommonUtil.getParam(methodCall,result,"memberList")!=null ){
            List<HashMap<String,Object>> list = CommonUtil.getParam(methodCall,result,"memberList");
            if(list.size()>0){
                for(int i=0;i<list.size();i++){
                    V2TIMCreateGroupMemberInfo minfo = new V2TIMCreateGroupMemberInfo();

                    int role = (int)list.get(i).get("role");
                    String userID = (String)list.get(i).get("userID");

                    minfo.setRole(role);
                    minfo.setUserID(userID);
                    memberList.add(minfo);
                }
            }
        }


        V2TIMManager.getGroupManager().createGroup(info, memberList, new V2TIMValueCallback<String>() {
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
    public void getJoinedGroupList(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getGroupManager().getJoinedGroupList(new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMGroupInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupInfoToMap(v2TIMGroupInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void getGroupsInfo(MethodCall methodCall, final MethodChannel.Result result){
        List< String > groupIDList = CommonUtil.getParam(methodCall,result,"groupIDList");
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMGroupInfoResults.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupInfoResultToMap(v2TIMGroupInfoResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void setGroupInfo(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String groupType = CommonUtil.getParam(methodCall,result,"groupType");
        String groupName = CommonUtil.getParam(methodCall,result,"groupName");
        String notification = CommonUtil.getParam(methodCall,result,"notification");
        String introduction = CommonUtil.getParam(methodCall,result,"introduction");
        String faceUrl = CommonUtil.getParam(methodCall,result,"faceUrl");
        HashMap<String,String> customInfoString = CommonUtil.getParam(methodCall,result,"customInfo");

        V2TIMGroupInfo info =  new V2TIMGroupInfo();
        if(groupID!=null){
            info.setGroupID(groupID);
        }
        if(groupType!=null){
            info.setGroupType(groupType);
        }
        if(groupName!=null){
            info.setGroupName(groupName);
        }
        if(notification!=null){
            info.setNotification(notification);
        }
        if(introduction!=null){
            info.setIntroduction(introduction);
        }
        if(faceUrl!=null){
            info.setFaceUrl(faceUrl);
        }
        if(CommonUtil.getParam(methodCall,result,"isAllMuted")!=null){
            boolean isAllMuted = CommonUtil.getParam(methodCall,result,"isAllMuted");
            info.setAllMuted (isAllMuted);
        }
        if(CommonUtil.getParam(methodCall,result,"addOpt")!=null){
            int addOpt = CommonUtil.getParam(methodCall,result,"addOpt");
            info.setGroupAddOpt(addOpt);
        }
        if(CommonUtil.getParam(methodCall,result,"customInfo")!=null){
            HashMap<String, byte[]> newCustomHashMap = new HashMap<String, byte[]>();
            if(!customInfoString.isEmpty()){
                for(String key : customInfoString.keySet() ){
                    String value = customInfoString.get(key);
                    newCustomHashMap.put(key,value.getBytes());
                }
                info.setCustomInfo(newCustomHashMap);
            }
        }

        V2TIMManager.getGroupManager().setGroupInfo(info, new V2TIMCallback() {
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
    public void getGroupOnlineMemberCount(MethodCall methodCall, final MethodChannel.Result result) {
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        V2TIMManager.getInstance().getGroupManager().getGroupOnlineMemberCount(groupID, new V2TIMValueCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                CommonUtil.returnSuccess(result,integer);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void setReceiveMessageOpt(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int opt = CommonUtil.getParam(methodCall,result,"opt");
//        V2TIMManager.getGroupManager()
//        V2TIMManager.getGroupManager().setReceiveMessageOpt(groupID, opt, new V2TIMCallback() {
//            @Override
//            public void onError(int i, String s) {
//                CommonUtil.returnError(result,i,s);
//            }
//
//            @Override
//            public void onSuccess() {
//                CommonUtil.returnSuccess(result,null);
//            }
//        });
    }
    public void initGroupAttributes(MethodCall methodCall,final MethodChannel.Result result){
        String groupID  = CommonUtil.getParam(methodCall,result,"groupID");
        HashMap< String, String > attributes = CommonUtil.getParam(methodCall,result,"attributes");
        V2TIMManager.getGroupManager().initGroupAttributes(groupID, attributes, new V2TIMCallback() {
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
    public void setGroupAttributes(MethodCall methodCall,final MethodChannel.Result result){
        String groupID  = CommonUtil.getParam(methodCall,result,"groupID");
        HashMap< String, String > attributes = CommonUtil.getParam(methodCall,result,"attributes");
        V2TIMManager.getGroupManager().setGroupAttributes(groupID, attributes, new V2TIMCallback() {
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
    public void deleteGroupAttributes(MethodCall methodCall,final MethodChannel.Result result){
        String groupID  = CommonUtil.getParam(methodCall,result,"groupID");
        List< String > keys = CommonUtil.getParam(methodCall,result,"keys");
        V2TIMManager.getGroupManager().deleteGroupAttributes(groupID, keys, new V2TIMCallback() {
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
    public void getGroupAttributes(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        List< String > keys = CommonUtil.getParam(methodCall,result,"keys");
        V2TIMManager.getGroupManager().getGroupAttributes(groupID, keys, new V2TIMValueCallback<Map<String, String>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(Map<String, String> stringStringMap) {
                CommonUtil.returnSuccess(result,stringStringMap);
            }
        });
    }
    public void getGroupMemberList(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int filter = CommonUtil.getParam(methodCall,result,"filter");
        String nextSeq = CommonUtil.getParam(methodCall,result,"nextSeq");
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, Long.parseLong(nextSeq) , new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMGroupMemberInfoResultToMap(v2TIMGroupMemberInfoResult));
            }
        });
    }
    public void getGroupMembersInfo(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        List< String > memberList = CommonUtil.getParam(methodCall,result,"memberList");
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupID, memberList, new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMGroupMemberFullInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberFullInfoToMap(v2TIMGroupMemberFullInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void setGroupMemberInfo(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        String nameCard = CommonUtil.getParam(methodCall,result,"nameCard");
        HashMap<String,String> customInfo = CommonUtil.getParam(methodCall,result,"customInfo");
        V2TIMGroupMemberFullInfo info =  new V2TIMGroupMemberFullInfo();
        if(userID!=null){
            info.setUserID(userID);
        }
        if(nameCard!=null){
            info.setNameCard(nameCard);
        }
        if(customInfo!=null){
            HashMap<String,byte[]> customInfoByte = new HashMap<String,byte[]>();
            Iterator<String> iterator = customInfo.keySet().iterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                customInfoByte.put(key,customInfo.get(key).getBytes());
            }
            info.setCustomInfo(customInfoByte);
        }
        V2TIMManager.getGroupManager().setGroupMemberInfo(groupID,info , new V2TIMCallback() {
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
    public void muteGroupMember(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        int seconds = CommonUtil.getParam(methodCall,result,"seconds");
        V2TIMManager.getGroupManager().muteGroupMember(groupID, userID, seconds, new V2TIMCallback() {
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
    public void inviteUserToGroup(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        List< String > userList = CommonUtil.getParam(methodCall,result,"userList");
        V2TIMManager.getGroupManager().inviteUserToGroup(groupID, userList, new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMGroupMemberOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberOperationResultToMap(v2TIMGroupMemberOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void kickGroupMember(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        List< String > memberList = CommonUtil.getParam(methodCall,result,"memberList");
        String reason = CommonUtil.getParam(methodCall,result,"reason");
        V2TIMManager.getGroupManager().kickGroupMember(groupID, memberList, reason, new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMGroupMemberOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMGroupMemberOperationResultToMap(v2TIMGroupMemberOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void setGroupMemberRole(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        int role = CommonUtil.getParam(methodCall,result,"role");
        V2TIMManager.getGroupManager().setGroupMemberRole(groupID, userID, role, new V2TIMCallback() {
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
    public void transferGroupOwner(MethodCall methodCall,final MethodChannel.Result result){
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        V2TIMManager.getGroupManager().transferGroupOwner(groupID, userID, new V2TIMCallback() {
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
    public void getGroupApplicationList(MethodCall methodCall,final MethodChannel.Result result){
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMGroupApplicationResultToMap(v2TIMGroupApplicationResult));
            }
        });
    }
    public void acceptGroupApplication(MethodCall methodCall,final MethodChannel.Result result){
        final String reason = CommonUtil.getParam(methodCall,result,"reason");
        final String groupID= CommonUtil.getParam(methodCall,result,"groupID");
        final String fromUser= CommonUtil.getParam(methodCall,result,"fromUser");
        final String toUser= CommonUtil.getParam(methodCall,result,"toUser");
        final long addTime= CommonUtil.getParam(methodCall,result,"addTime");
        final int type= CommonUtil.getParam(methodCall,result,"type");
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                for (int i=0;i<v2TIMGroupApplicationResult.getGroupApplicationList().size();i++){
                    V2TIMGroupApplication application = v2TIMGroupApplicationResult.getGroupApplicationList().get(i);
                    if(application.getGroupID().equals(groupID) && application.getFromUser().equals(fromUser) && application.getToUser().equals(toUser) && application.getAddTime() ==addTime && application.getType()==type){
                        V2TIMManager.getGroupManager().acceptGroupApplication(application, reason, new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                CommonUtil.returnError(result,i,s);
                            }

                            @Override
                            public void onSuccess() {
                                CommonUtil.returnSuccess(result,null);
                            }
                        });
                        break;
                    }
                }
            }
        });
    }
    public void refuseGroupApplication(MethodCall methodCall,final MethodChannel.Result result){
        final String reason = CommonUtil.getParam(methodCall,result,"reason");
        final String groupID= CommonUtil.getParam(methodCall,result,"groupID");
        final String fromUser= CommonUtil.getParam(methodCall,result,"fromUser");
        final String toUser= CommonUtil.getParam(methodCall,result,"toUser");
        final long addTime= CommonUtil.getParam(methodCall,result,"addTime");
        final int type= CommonUtil.getParam(methodCall,result,"type");
        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                for (int i=0;i<v2TIMGroupApplicationResult.getGroupApplicationList().size();i++){
                    V2TIMGroupApplication application = v2TIMGroupApplicationResult.getGroupApplicationList().get(i);
                    if(application.getGroupID().equals(groupID) && application.getFromUser().equals(fromUser) && application.getToUser().equals(toUser) && application.getAddTime() ==addTime && application.getType()==type){

                        V2TIMManager.getGroupManager().refuseGroupApplication(application, reason, new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                CommonUtil.returnError(result,i,s);
                            }

                            @Override
                            public void onSuccess() {
                                CommonUtil.returnSuccess(result,null);
                            }
                        });
                        break;
                    }

                }
            }
        });
    }
    public void setGroupApplicationRead(MethodCall methodCall,final MethodChannel.Result result){
        V2TIMManager.getGroupManager().setGroupApplicationRead(new V2TIMCallback() {
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

    public void searchGroups(MethodCall methodCall,final MethodChannel.Result result){
        HashMap<String,Object> searchParam = CommonUtil.getParam(methodCall,result,"searchParam");
        V2TIMGroupSearchParam param = new V2TIMGroupSearchParam();
        if(searchParam.get("keywordList")!=null){
            param.setKeywordList((List<String>) searchParam.get("keywordList"));
        }
        if(searchParam.get("isSearchGroupID")!=null){
            param.setSearchGroupID((Boolean) searchParam.get("isSearchGroupID"));
        }
        if(searchParam.get("isSearchGroupName")!=null){
            param.setSearchGroupName((Boolean) searchParam.get("isSearchGroupName"));
        }
        V2TIMManager.getGroupManager().searchGroups(param, new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                LinkedList<HashMap<String,Object>> infoList = new LinkedList<>();
                for(int i = 0;i<v2TIMGroupInfos.size();i++){
                    infoList.add(CommonUtil.convertV2TIMGroupInfoToMap(v2TIMGroupInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,infoList);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void searchGroupMembers(MethodCall methodCall,final MethodChannel.Result result){
        HashMap<String,Object> param = CommonUtil.getParam(methodCall,result,"param");
        V2TIMGroupMemberSearchParam searchParam = new V2TIMGroupMemberSearchParam ();
        if(param.get("keywordList")!=null){
            searchParam.setKeywordList((List<String>) param.get("keywordList"));
        }
        if(param.get("groupIDList")!=null){
            searchParam.setGroupIDList((List<String>) param.get("groupIDList"));
        }
        if(param.get("isSearchMemberUserID")!=null){
            searchParam.setSearchMemberUserID((Boolean) param.get("isSearchMemberUserID"));
        }
        if(param.get("isSearchMemberNickName")!=null){
            searchParam.setSearchMemberNickName((Boolean) param.get("isSearchMemberNickName"));
        }
        if(param.get("isSearchMemberRemark")!=null){
            searchParam.setSearchMemberRemark((Boolean) param.get("isSearchMemberRemark"));
        }
        if(param.get("isSearchMemberNameCard")!=null){
            searchParam.setSearchMemberNameCard((Boolean) param.get("isSearchMemberNameCard"));
        }

        V2TIMManager.getGroupManager().searchGroupMembers(searchParam, new V2TIMValueCallback<HashMap<String, List<V2TIMGroupMemberFullInfo>>>() {
            @Override
            public void onSuccess(HashMap<String, List<V2TIMGroupMemberFullInfo>> stringListHashMap) {
                Iterator it = stringListHashMap.entrySet().iterator();
                HashMap<String,LinkedList<HashMap<String,Object>>> res = new HashMap();
                while (it.hasNext()) {
                    Map.Entry entry =(Map.Entry) it.next();
                    String key = (String) entry.getKey();
                    List<V2TIMGroupMemberFullInfo> value = (List<V2TIMGroupMemberFullInfo>) entry.getValue();
                    LinkedList<HashMap<String,Object>> resItem = new LinkedList<>();
                    for(int i =0;i<value.size();i++){
                        resItem.add(CommonUtil.convertV2TIMGroupMemberFullInfoToMap(value.get(i)));

                    }

                    res.put(key,resItem);
                }
                CommonUtil.returnSuccess(result,res);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }


}
