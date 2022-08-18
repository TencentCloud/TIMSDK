package com.qq.qcloud.tencent_im_sdk_plugin.util;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Nullable;

import com.tencent.imsdk.common.IMLog;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFaceElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendGroup;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupApplicationResult;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMLocationElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMMessageSearchResult;
import com.tencent.imsdk.v2.V2TIMMessageSearchResultItem;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMTopicInfoResult;
import com.tencent.imsdk.v2.V2TIMTopicOperationResult;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.imsdk.v2.V2TIMGroupMessageReadMemberList;


import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Tools
 */
public class CommonUtil {

    public static Context context;

    public static String apiName = "isCommercialAbilityEnabled";
    public static String paramName = "ability";
    public static void checkAbility(final MethodCall methodCall, final AbCallback callback){
        try {
            final List<Integer> param =  methodCall.argument(paramName);
            if(param.size()>0){
                Long ab = new Long(1L << (long) param.get(0));
                for(int i = 1;i<param.size();i++){
                    ab = ab ^ new Long(1L << (long)param.get(i));
                }
                System.out.println(ab);
                V2TIMManager.getInstance().callExperimentalAPI(apiName, ab, new V2TIMValueCallback<Object>() {
                    @Override
                    public void onError(int i, String s) {
                        callback.onAbError(i,s);
                    }
                    @Override
                    public void onSuccess(Object o) {
                        boolean enabled = ((Integer)o > 0 ? true : false);
                        if(!enabled){
                            callback.onAbError(70130,"the configuration to use this plugin was not obtained (" + param.get(0)+")");
                        }else{
                            callback.onAbSuccess();
                        }
                    }
                });
            }else{
                callback.onAbSuccess();
            }
        }catch (Exception e){
            callback.onAbError(-2,e.getMessage());
        }
    };
    /**
     * main thread processor
     */
    private final static Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

    /**
     * General method, get the parameter value, if the parameter is not found, it will be interrupted directly
     *
     * @param methodCall method call object
     * @param result     return object
     * @param param      parameter name
     */
    public static <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
        T par = methodCall.argument(param);
//        if (par == null) {
//            result.error("Missing parameter", "Cannot find parameter `" + param + "` or `" + param + "` is null!", 5);
//            throw new RuntimeException("Cannot find parameter `" + param + "` or `" + param + "` is null!");
//        }
        return par;
    }

    /**
     * Run the main thread and return the result to execute
     *
     * @param result return result object
     * @param param  return parameter
     */
    public static void runMainThreadReturn(final MethodChannel.Result result, final Object param) {
        MAIN_HANDLER.post(new Runnable() {
            @Override
            public void run() {
                result.success(param);
            }
        });
    }
    public static void wirteLog(HashMap<String,Object> map){
        try{
            IMLog.i("tencent_im_sdk_plugin_res",map.toString());
        }catch (Exception e){
            System.out.println("write log fail");
        }
    }
    public static void returnError(final MethodChannel.Result result, int i,String s) {
        HashMap<String,Object> err = new HashMap<String,Object>();
        err.put("code",i);
        err.put("desc",s);
        result.success(err);
        wirteLog(err);
    }
    public static void returnError(final MethodChannel.Result result, int i,String s,HashMap<String,Object> data) {
        HashMap<String,Object> err = new HashMap<String,Object>();
        err.put("code",i);
        err.put("desc",s);
        err.put("data",data);
        result.success(err);
        wirteLog(err);
    }
    public static <T> void returnSuccess(final MethodChannel.Result result,T data) {
        HashMap<String,Object> succ = new HashMap<String,Object>();
        succ.put("code",0);
        succ.put("desc","ok");
        succ.put("data",data);
        result.success(succ);
        wirteLog(succ);
    }
    public static <T> void emitEvent(MethodChannel channel,String method,String type,T data, String listenerUuid){
        HashMap<String,Object> res = new HashMap<String,Object>();
        res.put("type",type);
        res.put("data",data);
        res.put("listenerUuid", listenerUuid);
        channel.invokeMethod(method,res);
        res.put("method", method);
        wirteLog(res);
    }
    public static HashMap<String,Object> convertV2TIMUserFullInfoToMap(V2TIMUserFullInfo info){
        HashMap<String,Object> userInfo = new HashMap<String,Object>();
        userInfo.put("userID",info.getUserID());
        userInfo.put("nickName",info.getNickName());
        userInfo.put("faceUrl",info.getFaceUrl());
        userInfo.put("selfSignature",info.getSelfSignature());
        userInfo.put("gender",info.getGender());
        userInfo.put("allowType",info.getAllowType());
        userInfo.put("birthday",info.getBirthday());
        HashMap<String,byte[]> customInfo = info.getCustomInfo();
        HashMap<String,String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry =(Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[])entry.getValue() ==null ? "": new String((byte[])entry.getValue());
            customInfoTypeString.put(key,value);
        }
        userInfo.put("customInfo",customInfoTypeString);
        userInfo.put("role",info.getRole());
        userInfo.put("level",info.getLevel());
        return userInfo;
    }
    public static HashMap<String,Object> convertV2TIMUserInfotoMap(V2TIMUserInfo userInfo){
        HashMap<String,Object> info = new HashMap<String,Object>();
        info.put("userID",userInfo.getUserID());
        info.put("nickName",userInfo.getNickName());
        info.put("faceUrl",userInfo.getFaceUrl());
        return info;
    }
    public static HashMap<String,Object> convertV2TIMGroupMemberInfoToMap(V2TIMGroupMemberInfo info){
        HashMap<String,Object> ginfo = new HashMap<String,Object>();
        ginfo.put("faceUrl",info.getFaceUrl());
        ginfo.put("friendRemark",info.getFriendRemark());
        ginfo.put("nameCard",info.getNameCard());
        ginfo.put("nickName",info.getNickName());
        ginfo.put("userID",info.getUserID());
        return  ginfo;
    }
    public static HashMap<String,Object> convertV2TIMMessageToMap(V2TIMMessage msg,Object ...progress){
        final HashMap<String,Object> message = new HashMap<String, Object>();
        if(msg == null){
            return  null;
        }
        message.put("elemType",msg.getElemType());
        message.put("msgID",msg.getMsgID());
        message.put("timestamp",msg.getTimestamp());

        if(progress.length == 0){
            message.put("progress",100);
        }else{
            message.put("progress",progress[0]);
        }
        // onProgress listener will return id
        if(progress.length == 2){
            message.put("id",progress[1]);
        }

        message.put("sender",msg.getSender());
        message.put("nickName",msg.getNickName());
        message.put("friendRemark",msg.getFriendRemark());
        message.put("faceUrl",msg.getFaceUrl());
        message.put("nameCard",msg.getNameCard());
        message.put("groupID",msg.getGroupID());
        message.put("userID",msg.getUserID());
        message.put("status",msg.getStatus());
        message.put("localCustomData",msg.getLocalCustomData());
        message.put("localCustomInt",msg.getLocalCustomInt());
        message.put("cloudCustomData",msg.getCloudCustomData());
        message.put("isSelf",msg.isSelf());
        message.put("isRead",msg.isRead());
        message.put("isPeerRead",msg.isPeerRead());
        message.put("priority",msg.getPriority());
        message.put("seq",String.valueOf(msg.getSeq()));
        message.put("groupAtUserList",msg.getGroupAtUserList());
        message.put("random",msg.getRandom());
        message.put("isExcludedFromUnreadCount",msg.isExcludedFromUnreadCount());
        message.put("isExcludedFromLastMessage",msg.isExcludedFromLastMessage());
        message.put("needReadReceipt", true);
        V2TIMOfflinePushInfo info =  msg.getOfflinePushInfo();

        HashMap<String,Object> offlinePushInfo = new HashMap<String, Object>();
        try{
            offlinePushInfo.put("desc",info.getDesc());
            offlinePushInfo.put("title",info.getTitle());
            offlinePushInfo.put("disablePush",info.isDisablePush());
            offlinePushInfo.put("ext",new String(info.getExt()));
        }catch (Exception e){

        }
        message.put("offlinePushInfo",offlinePushInfo);

        int type = msg.getElemType();
        if(type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT){
            V2TIMTextElem element = msg.getTextElem();
            V2TIMElem nextElem = element.getNextElem();
            HashMap<String,Object> textMap = CommonUtil.convertTextMessageElem(element);
            if (nextElem != null) {
                textMap.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("textElem",textMap);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM){
            V2TIMCustomElem elem = msg.getCustomElem();
            V2TIMElem nextElem = elem.getNextElem();
            HashMap<String,Object> customMap = CommonUtil.convertCustomMessageElem(msg.getCustomElem());
            if(elem != null) {
                customMap.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("customElem",customMap);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE){
            V2TIMImageElem imageElem = msg.getImageElem();
            V2TIMElem nextElem = imageElem.getNextElem();
            HashMap<String,Object> img = CommonUtil.convertImageMessageElem(msg.getImageElem());
            if(nextElem != null) {
                img.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("imageElem",img);

        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND){
            final V2TIMSoundElem soundElem = msg.getSoundElem();
            V2TIMElem nextElem = soundElem.getNextElem();
            final HashMap<String,Object> sound = CommonUtil.convertSoundMessageElem(soundElem);
            if(nextElem != null) {
                sound.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("soundElem",sound);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO){
            V2TIMVideoElem videoElem = msg.getVideoElem ();
            V2TIMElem nextElem = videoElem.getNextElem();
            final HashMap<String,Object> video = CommonUtil.convertVideoMessageElem(videoElem);
            if(nextElem != null) {
                video.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("videoElem",video);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_FILE){
            final V2TIMFileElem fileElem = msg.getFileElem();
            V2TIMElem nextElem = fileElem.getNextElem();
            final HashMap<String,Object> file = CommonUtil.convertFileMessageElem(fileElem);
            if(nextElem != null) {
                file.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("fileElem",file);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE){
            V2TIMFaceElem faceElem = msg.getFaceElem();
            V2TIMElem nextElem = faceElem.getNextElem();
            HashMap<String,Object> face = CommonUtil.convertFaceMessageElem(faceElem);
            if(nextElem != null) {
                face.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("faceElem",face);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION){
            V2TIMLocationElem locationElem = msg.getLocationElem();
            V2TIMElem nextElem = locationElem.getNextElem();
            HashMap<String,Object> location = CommonUtil.convertLocationMessageElem(locationElem);
            if(nextElem != null) {
                location.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("locationElem",location);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            V2TIMGroupTipsElem groupTipsElem = msg.getGroupTipsElem();
            V2TIMElem nextElem = groupTipsElem.getNextElem();
            HashMap<String,Object> groupTips = CommonUtil.convertGroupTipsMessageElem(groupTipsElem);
            if(nextElem != null) {
                groupTips.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("groupTipsElem", groupTips);
        }else if(type == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER){
            V2TIMMergerElem mergerElem 	= msg.getMergerElem();
            V2TIMElem nextElem = mergerElem.getNextElem();
            HashMap<String,Object> elem = CommonUtil.convertMergerMessageElem(mergerElem);
            if(elem != null) {
                elem.put("nextElem", CommonUtil.convertMessageElem(nextElem));
            }
            message.put("mergerElem",elem);
        }

        return message;
    }

    public static HashMap<String,Object> convertCustomMessageElem(V2TIMCustomElem elem) {
        HashMap<String,Object> messageElem = new HashMap<String, Object>();
        V2TIMCustomElem rawCustomMessage = (V2TIMCustomElem) elem;
        messageElem.put("data",rawCustomMessage.getData()==null ? "" : new String(rawCustomMessage.getData()));
        messageElem.put("desc",rawCustomMessage.getDescription());
        messageElem.put("extension",rawCustomMessage.getExtension()==null ? "" : new String(rawCustomMessage.getExtension()));

        return messageElem;
    }

    public static  HashMap<String,Object> convertTextMessageElem(V2TIMTextElem elem) {
        HashMap<String,Object> messageElem = new HashMap<String, Object>();
        V2TIMTextElem textElem = (V2TIMTextElem) elem;
        messageElem.put("text",textElem.getText());
        return messageElem;
    }

    public static  HashMap<String,Object> convertImageMessageElem(V2TIMImageElem elem) {
        final HashMap<String,Object> img = new HashMap<String,Object>();
        img.put("path",elem.getPath());
        LinkedList<Object> imgList = new LinkedList<Object>();
        for (int i=0;i<elem.getImageList().size();i++){
            HashMap<String,Object> item = new HashMap<String,Object>();
            V2TIMImageElem.V2TIMImage imgInstance = elem.getImageList().get(i);
            item.put("size",imgInstance.getSize());
            item.put("height",imgInstance.getHeight());
            item.put("type",imgInstance.getType());
            item.put("url",imgInstance.getUrl());
            item.put("UUID",imgInstance.getUUID());
            item.put("width",imgInstance.getWidth());

            try{
                File cacheDir =  context.getExternalCacheDir();
                if(cacheDir.exists()){
                    String path =  cacheDir.getPath()+"/"+imgInstance.getType()+""+imgInstance.getSize()+""+imgInstance.getWidth()+imgInstance.getHeight()+"_"+imgInstance.getUUID();
                    File file = new File(path);
                    if(!file.exists()){
                        imgInstance.downloadImage(path, new V2TIMDownloadCallback() {
                            @Override
                            public void onProgress(V2TIMElem.V2ProgressInfo v2ProgressInfo) {

                            }

                            @Override
                            public void onSuccess() {

                            }

                            @Override
                            public void onError(int i, String s) {

                            }
                        });
                    }else{
                        item.put("localUrl",path);
                    }
                }
            }catch (Exception err){
                System.out.println(err);
            }
            imgList.add(item);
        }
        img.put("imageList",imgList);
        System.out.println(img);
        return  img;
    }

    public static  HashMap<String,Object> convertSoundMessageElem(V2TIMSoundElem soundElem) {
        final HashMap<String,Object> sound = new HashMap<String,Object>();
        sound.put("dataSize",soundElem.getDataSize());
        sound.put("duration",soundElem.getDuration());
        sound.put("path",soundElem.getPath());
        sound.put("UUID",soundElem.getUUID());
        soundElem.getUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                sound.put("url",s);
            }
        });
        try {
            File cacheDir = context.getExternalCacheDir();

            if (cacheDir.exists()) {
                String path = cacheDir.getPath() + "/" + soundElem.getUUID();
                File file = new File(path);
                if(!file.exists()){
                    soundElem.downloadSound(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo v2ProgressInfo) {

                        }

                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onError(int i, String s) {

                        }
                    });
                }else{
                    sound.put("localUrl",path);
                }
            }
        }catch (Exception errr){

        }
        return sound;
    }

    public static  HashMap<String,Object> convertVideoMessageElem(V2TIMVideoElem videoElem) {
        final HashMap<String,Object> video = new HashMap<String,Object>();
        videoElem.getVideoUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                video.put("videoUrl",s);
            }
        });
        videoElem.getSnapshotUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                video.put("snapshotUrl",s);
            }
        });
        video.put("duration",videoElem.getDuration());
        video.put("snapshotHeight",videoElem.getSnapshotHeight());
        video.put("snapshotPath",videoElem.getSnapshotPath());
        video.put("snapshotSize",videoElem.getSnapshotSize());
        video.put("snapshotUUID",videoElem.getSnapshotUUID());
        video.put("snapshotWidth",videoElem.getSnapshotWidth());
        video.put("videoPath",videoElem.getVideoPath());
        video.put("videoSize",videoElem.getVideoSize());
        video.put("UUID",videoElem.getVideoUUID());
        try {
            File cacheDir = context.getExternalCacheDir();

            if (cacheDir.exists()) {
                String path = cacheDir.getPath() + "/" + videoElem.getVideoUUID();
                String snipPath = cacheDir.getPath() + "/" + videoElem.getSnapshotUUID();
                File file = new File(path);
                File snip = new File(snipPath);
                if (!file.exists()) {
                    videoElem.downloadVideo(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo v2ProgressInfo) {

                        }

                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onError(int i, String s) {

                        }
                    });
                }else{
                    video.put("localVideoUrl",path);
                }
                if(!snip.exists()){
                    videoElem.downloadSnapshot(snipPath, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo v2ProgressInfo) {

                        }

                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onError(int i, String s) {

                        }
                    });
                }else{
                    video.put("localSnapshotUrl",snipPath);
                }
            }
        }catch (Exception err){

        }
        return  video;
    }

    public static  HashMap<String,Object> convertFileMessageElem(V2TIMFileElem fileElem) {
        final HashMap<String,Object> file = new HashMap<String,Object>();
        file.put("fileName",fileElem.getFileName());
        file.put("fileSize",fileElem.getFileSize());
        file.put("path",fileElem.getPath());
        file.put("UUID",fileElem.getUUID());
        fileElem.getUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                file.put("url",s);
            }
        });
        try {
            File cacheDir = context.getExternalCacheDir();

            if (cacheDir.exists()) {
                String path = cacheDir.getPath() + "/" + fileElem.getUUID();
                File f = new File(path);
                if(!f.exists()){
                    fileElem.downloadFile(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo v2ProgressInfo) {

                        }

                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onError(int i, String s) {

                        }
                    });
                }else{
                    file.put("localUrl",path);
                }
            }
        }catch (Exception errr){

        }
        return  file;
    }

    public static  HashMap<String,Object> convertFaceMessageElem(V2TIMFaceElem faceElem) {
        HashMap<String,Object> face = new HashMap<String,Object>();
        face.put("data",faceElem.getData() == null ? "" : new String(faceElem.getData()));
        face.put("index",faceElem.getIndex());
        return face;
    }

    public static  HashMap<String,Object> convertLocationMessageElem(V2TIMLocationElem locationElem) {
        HashMap<String,Object> location = new HashMap<String,Object>();
        location.put("desc",locationElem.getDesc());
        location.put("latitude",locationElem.getLatitude());
        location.put("longitude",locationElem.getLongitude());
        return location;
    }

    public static  HashMap<String,Object> convertGroupTipsMessageElem(V2TIMGroupTipsElem groupTipsElem) {
        HashMap<String,Object> groupTips = new HashMap<String,Object>();

        List<V2TIMGroupChangeInfo> groupChangeInfoList = groupTipsElem.getGroupChangeInfoList();
        LinkedList<HashMap<String,Object>> gchangeInfoList = new LinkedList<HashMap<String,Object>>();

        for (int i = 0; i < groupChangeInfoList.size(); i++) {

            String key = groupChangeInfoList.get(i).getKey();
            int types = groupChangeInfoList.get(i).getType();
            String value = groupChangeInfoList.get(i).getValue();
            Boolean boolValue = groupChangeInfoList.get(i).getBoolValue();
            HashMap<String,Object> item = new HashMap<String,Object>();
            item.put("key", key);
            item.put("type", types);
            item.put("value", value);
            item.put("boolValue", boolValue);
            gchangeInfoList.add(item);
        }

        groupTips.put("groupChangeInfoList", gchangeInfoList);

        groupTips.put("groupID", groupTipsElem.getGroupID());
        groupTips.put("memberCount", groupTipsElem.getMemberCount());
        groupTips.put("type", groupTipsElem.getType());

        List<V2TIMGroupMemberChangeInfo> mlist =  groupTipsElem.getMemberChangeInfoList();
        LinkedList<Object> memberChangeInfoList = new LinkedList<Object>();
        for(int i=0;i<mlist.size();i++){
            HashMap<String,Object> item = new HashMap<String,Object>();
            item.put("userID",mlist.get(i).getUserID());
            item.put("muteTime",mlist.get(i).getMuteTime());
            memberChangeInfoList.add(item);
        }
        groupTips.put("memberChangeInfoList", memberChangeInfoList);

        List<V2TIMGroupMemberInfo> memberlist =  groupTipsElem.getMemberList();
        LinkedList<Object> memberInfoList = new LinkedList<Object>();
        for(int i=0;i<memberlist.size();i++){
            HashMap<String,Object> item = new HashMap<String,Object>();
            item.put("userID",memberlist.get(i).getUserID());
            item.put("faceUrl",memberlist.get(i).getFaceUrl());
            item.put("friendRemark",memberlist.get(i).getFriendRemark());
            item.put("nameCard",memberlist.get(i).getNameCard());
            item.put("nickName",memberlist.get(i).getNickName());
            memberInfoList.add(item);
        }
        groupTips.put("memberList", memberInfoList);

        V2TIMGroupMemberInfo opmember =  groupTipsElem.getOpMember();
        HashMap<String,Object> opmemberItem = new HashMap<String,Object>();
        opmemberItem.put("userID",opmember.getUserID());
        opmemberItem.put("faceUrl",opmember.getFaceUrl());
        opmemberItem.put("friendRemark",opmember.getFriendRemark());
        opmemberItem.put("nameCard",opmember.getNameCard());
        opmemberItem.put("nickName",opmember.getNickName());

        groupTips.put("opMember",opmemberItem);
        return  groupTips;
    }

    public static  HashMap<String,Object> convertMergerMessageElem(V2TIMMergerElem mergerElem) {
        HashMap<String,Object> elem = new HashMap<String,Object>();
        elem.put("isLayersOverLimit",mergerElem.isLayersOverLimit());
        elem.put("abstractList",mergerElem.getAbstractList());
        elem.put("title",mergerElem.getTitle());
        return elem;
    }
    public static HashMap<String,Object> convertMessageElem(V2TIMElem elem) {
        HashMap<String,Object> messageElem = new HashMap<String, Object>();
        if (elem != null) {
            if(elem instanceof V2TIMCustomElem) {
                messageElem = CommonUtil.convertCustomMessageElem((V2TIMCustomElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM);
            } else if (elem instanceof V2TIMTextElem) {
                messageElem = CommonUtil.convertTextMessageElem((V2TIMTextElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_TEXT);
            } else if (elem instanceof  V2TIMImageElem) {
                messageElem = CommonUtil.convertImageMessageElem((V2TIMImageElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE);
            } else if (elem instanceof  V2TIMSoundElem) {
                messageElem = CommonUtil.convertSoundMessageElem((V2TIMSoundElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_SOUND);
            } else if (elem instanceof  V2TIMVideoElem) {
                messageElem = CommonUtil.convertVideoMessageElem((V2TIMVideoElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO);
            } else if (elem instanceof  V2TIMFileElem) {
                messageElem = CommonUtil.convertFileMessageElem((V2TIMFileElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_FILE);
            } else if (elem instanceof  V2TIMFaceElem) {
                messageElem = CommonUtil.convertFaceMessageElem((V2TIMFaceElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_FACE);
            } else if (elem instanceof  V2TIMLocationElem) {
                messageElem = CommonUtil.convertLocationMessageElem((V2TIMLocationElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION);
            } else if (elem instanceof V2TIMGroupTipsElem) {
                messageElem = CommonUtil.convertGroupTipsMessageElem((V2TIMGroupTipsElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS);
            } else if (elem instanceof V2TIMMergerElem) {
                messageElem = CommonUtil.convertMergerMessageElem((V2TIMMergerElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_MERGER);
            }
            if(elem.getNextElem() != null) {
                messageElem.put("nextElem", CommonUtil.convertMessageElem(elem.getNextElem()));
            }
        }
        return messageElem;
    }
    public static HashMap<String,Object> convertV2TIMGroupMemberChangeInfoToMap(V2TIMGroupMemberChangeInfo info){
        HashMap<String,Object> cinfo =  new HashMap<String,Object>();
        cinfo.put("muteTime",info.getMuteTime());
        cinfo.put("userID",info.getUserID());
        return cinfo;
    }

    public static HashMap<String,Object> convertV2TIMGroupChangeInfoToMap(V2TIMGroupChangeInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("boolValue", info.getBoolValue());
        rinfo.put("value", info.getValue());
        rinfo.put("type", info.getType());
        rinfo.put("key", info.getKey());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMReceiveMessageOptInfoToMap(V2TIMReceiveMessageOptInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("c2CReceiveMessageOpt", info.getC2CReceiveMessageOpt());
        rinfo.put("userID", info.getUserID());
        return rinfo;
    }

    public static HashMap<String,Object> convertV2TIMFriendInfoToMap(V2TIMFriendInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        List<String> ulists = info.getFriendGroups();
        rinfo.put("friendGroups",ulists);
        rinfo.put("friendRemark", info.getFriendRemark());
        rinfo.put("userID", info.getUserID());
        rinfo.put("userProfile", CommonUtil.convertV2TIMUserFullInfoToMap(info.getUserProfile()));
        HashMap<String,byte[]> customInfo = info.getFriendCustomInfo();
        HashMap<String,String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
             Map.Entry entry =(Map.Entry) it.next();
             String key = (String) entry.getKey();
             String value = (byte[])entry.getValue() ==null ? "": new String((byte[])entry.getValue());
            customInfoTypeString.put(key,value);
        }
        rinfo.put("friendCustomInfo",customInfoTypeString);
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMFriendInfoResultToMap(V2TIMFriendInfoResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("friendInfo",CommonUtil.convertV2TIMFriendInfoToMap(info.getFriendInfo()));
        rinfo.put("relation", info.getRelation());
        rinfo.put("resultCode", info.getResultCode());
        rinfo.put("resultInfo", info.getResultInfo());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMFriendOperationResultToMap(V2TIMFriendOperationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("resultCode",info.getResultCode());
        rinfo.put("resultInfo",info.getResultInfo());
        rinfo.put("userID",info.getUserID());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMFriendCheckResultToMap(V2TIMFriendCheckResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("resultType",info.getResultType());
        rinfo.put("resultCode",info.getResultCode());
        rinfo.put("resultInfo",info.getResultInfo());
        rinfo.put("userID",info.getUserID());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMFriendApplicationResultToMap(V2TIMFriendApplicationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        LinkedList<Object> list  = new LinkedList<Object>();
        List<V2TIMFriendApplication> ulist =  info.getFriendApplicationList();
        for(int i = 0;i<ulist.size();i++){
            V2TIMFriendApplication item = ulist.get(i);
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("addSource",item.getAddSource());
            data.put("addTime",item.getAddTime());
            data.put("addWording",item.getAddWording());
            data.put("faceUrl",item.getFaceUrl());
            data.put("nickname",item.getNickname());
            data.put("type",item.getType());
            data.put("userID",item.getUserID());
            list.add(data);
        }
        rinfo.put("friendApplicationList",list);
        rinfo.put("unreadCount",info.getUnreadCount());

        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMFriendGroupToMap(V2TIMFriendGroup info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("friendCount",info.getFriendCount());
        rinfo.put("friendIDList",info.getFriendIDList());
        rinfo.put("name",info.getName());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMMessageReceiptToMap(V2TIMMessageReceipt info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("timestamp",info.getTimestamp());
        rinfo.put("userID",info.getUserID());
        rinfo.put("unreadCount",info.getUnreadCount());
        rinfo.put("readCount",info.getReadCount());
        rinfo.put("msgID",info.getMsgID());
        rinfo.put("groupID",info.getGroupID());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupMemberInfoResultToMap(V2TIMGroupMemberInfoResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
        for(int i=0;i<info.getMemberInfoList().size();i++){
            list.add(CommonUtil.convertV2TIMGroupMemberFullInfoToMap(info.getMemberInfoList().get(i)));
        }
        rinfo.put("memberInfoList",list);
        rinfo.put("nextSeq",String.valueOf(info.getNextSeq()));

        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupMemberFullInfoToMap(V2TIMGroupMemberFullInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("userID",info.getUserID ());
        rinfo.put("role",info.getRole ());
        rinfo.put("muteUntil",info.getMuteUntil ());
        rinfo.put("joinTime",info.getJoinTime ());
        rinfo.put("nickName",info.getNickName ());
        rinfo.put("nameCard",info.getNameCard ());
        rinfo.put("friendRemark",info.getFriendRemark ());
        rinfo.put("faceUrl",info.getFaceUrl ());
        Map<String,byte[]> custinfo =  info.getCustomInfo();
        HashMap<String,String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = custinfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry =(Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[])entry.getValue() ==null ? "": new String((byte[])entry.getValue());
            customInfoTypeString.put(key,value);
        }
        rinfo.put("customInfo",customInfoTypeString);
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupMemberOperationResultToMap(V2TIMGroupMemberOperationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("memberID",info.getMemberID());
        rinfo.put("result",info.getResult());

        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupApplicationResultToMap(V2TIMGroupApplicationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
        for(int i=0;i<info.getGroupApplicationList().size();i++){
            list.add(CommonUtil.convertV2TimGroupApplicationToMap(info.getGroupApplicationList().get(i)));
        }
        rinfo.put("groupApplicationList",list);
        rinfo.put("unreadCount",info.getUnreadCount());

        return rinfo;
    }
    public static HashMap<String,Object> convertV2TimGroupApplicationToMap(V2TIMGroupApplication info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();


        rinfo.put("addTime",info.getAddTime());
        rinfo.put("fromUser",info.getFromUser());
        rinfo.put("fromUserFaceUrl",info.getFromUserFaceUrl());
        rinfo.put("fromUserNickName",info.getFromUserNickName());
        rinfo.put("groupID",info.getGroupID());
        rinfo.put("handledMsg",info.getHandledMsg());
        rinfo.put("handleResult",info.getHandleResult());
        rinfo.put("handleStatus",info.getHandleStatus());
        rinfo.put("requestMsg",info.getRequestMsg());
        rinfo.put("toUser",info.getToUser());
        rinfo.put("type",info.getType());

        return rinfo;
    }

    public static HashMap<String,Object> convertV2TIMFriendApplicationToMap(V2TIMFriendApplication info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("userID",info.getUserID());
        rinfo.put("type",info.getType());
        rinfo.put("nickname",info.getNickname());
        rinfo.put("faceUrl",info.getFaceUrl());
        rinfo.put("addWording",info.getAddWording());
        rinfo.put("addTime",info.getAddTime());
        rinfo.put("addSource",info.getAddSource());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMConversationToMap(V2TIMConversation info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("conversationID",info.getConversationID());
        rinfo.put("draftText",info.getDraftText());
        rinfo.put("draftTimestamp",info.getDraftTimestamp());
        rinfo.put("faceUrl",info.getFaceUrl());
        rinfo.put("groupID",info.getGroupID());
        rinfo.put("groupType",info.getGroupType());
        rinfo.put("lastMessage",CommonUtil.convertV2TIMMessageToMap(info.getLastMessage()));
        rinfo.put("showName",info.getShowName());
        rinfo.put("type",info.getType());
        rinfo.put("unreadCount",info.getUnreadCount());
        rinfo.put("userID",info.getUserID());
        rinfo.put("isPinned",info.isPinned());
        rinfo.put("recvOpt",info.getRecvOpt());
        rinfo.put("orderkey",info.getOrderKey());
        rinfo.put("customData",info.getCustomData());
        rinfo.put("conversationGroupList",info.getConversationGroupList());
        List<Integer> mli = new LinkedList<>();
        for(int i = 0;i<info.getMarkList().size();i++){
            mli.add(info.getMarkList().get(i).intValue());
        }
        rinfo.put("markList",mli);
        List<V2TIMGroupAtInfo> atList =  info.getGroupAtInfoList();
        List<Map<String,Object>> groupAtInfoList = new LinkedList<Map<String,Object>>();
        for(int i = 0;i<atList.size();i++){
            V2TIMGroupAtInfo item =   atList.get(i);
            Map<String,Object> itemMap = new HashMap<String,Object>();
            itemMap.put("atType",item.getAtType());
            itemMap.put("seq",String.valueOf(item.getSeq()));
            groupAtInfoList.add(itemMap);
        }
        rinfo.put("groupAtInfoList",groupAtInfoList);

        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupInfoToMap(V2TIMGroupInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("createTime",info.getCreateTime());
        rinfo.put("faceUrl",info.getFaceUrl());
        rinfo.put("groupAddOpt",info.getGroupAddOpt());
        rinfo.put("groupID",info.getGroupID());
        rinfo.put("groupName",info.getGroupName());
        rinfo.put("groupType",info.getGroupType());
        rinfo.put("introduction",info.getIntroduction());
        rinfo.put("joinTime",info.getJoinTime());
        rinfo.put("lastInfoTime",info.getLastInfoTime());
        rinfo.put("lastMessageTime",info.getLastMessageTime());
        rinfo.put("memberCount",info.getMemberCount());
        rinfo.put("notification",info.getNotification());
        rinfo.put("onlineCount",info.getOnlineCount());
        rinfo.put("owner",info.getOwner());
        rinfo.put("recvOpt",info.getRecvOpt());
        rinfo.put("role",info.getRole());
        rinfo.put("isAllMuted",info.isAllMuted());
        rinfo.put("isSupportTopic",info.isSupportTopic());
        Map<String,byte[]> customInfo = info.getCustomInfo();

        HashMap<String,String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry =(Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[])entry.getValue() ==null ? "": new String((byte[])entry.getValue());
            customInfoTypeString.put(key,value);
        }
        rinfo.put("customInfo",customInfoTypeString);
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupInfoResultToMap(V2TIMGroupInfoResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("groupInfo",CommonUtil.convertV2TIMGroupInfoToMap(info.getGroupInfo()));
        rinfo.put("resultCode",info.getResultCode());
        rinfo.put("resultMessage",info.getResultMessage());
        return rinfo;
    }

    public static HashMap<String,Object> convertV2TIMConversationResultToMap(V2TIMConversationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("nextSeq",String.valueOf(info.getNextSeq()));
        rinfo.put("isFinished",info.isFinished());
        List<V2TIMConversation> list = info.getConversationList();
        LinkedList<Object> clist = new LinkedList<Object>();
        for(int i = 0;i<list.size();i++){
            V2TIMConversation item = list.get(i);
            HashMap<String,Object> citem  = CommonUtil.convertV2TIMConversationToMap(item);
            clist.add(citem);
        }
        rinfo.put("conversationList",clist);
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMMessageSearchResultItemToMap(V2TIMMessageSearchResultItem info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        List<V2TIMMessage> messages =  info.getMessageList();
        LinkedList<HashMap<String,Object>> messageList = new LinkedList<>();

        rinfo.put("conversationID",info.getConversationID());
        rinfo.put("messageCount",info.getMessageCount());
        for(int i = 0;i<messages.size();i++){
            messageList.add(CommonUtil.convertV2TIMMessageToMap(messages.get(i)));
        }
        rinfo.put("messageList",messageList);
        return  rinfo;
    }
    public static HashMap<String,Object> convertV2TIMMessageSearchResultToMap(V2TIMMessageSearchResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("totalCount",info.getTotalCount());
        LinkedList<HashMap<String,Object>> searchList = new LinkedList<>();
        List<V2TIMMessageSearchResultItem> sList = info.getMessageSearchResultItems();
        for(int i = 0;i<sList.size();i++){
            searchList.add(CommonUtil.convertV2TIMMessageSearchResultItemToMap(sList.get(i)));
        }
        rinfo.put("messageSearchResultItems",searchList);
        return  rinfo;
    }
    public static HashMap<String,Object> convertV2TIMSignalingInfoToMap(V2TIMSignalingInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("actionType",info.getActionType());
        rinfo.put("businessID",info.getBusinessID());
        rinfo.put("data",info.getData());
        rinfo.put("groupID",info.getGroupID());
        rinfo.put("inviteeList",info.getInviteeList());
        rinfo.put("inviteID",info.getInviteID());
        rinfo.put("inviter",info.getInviter());
        rinfo.put("timeout",info.getTimeout());
        if(info.getOfflinePushInfo() != null)
        rinfo.put("offlinePushInfo",CommonUtil.converV2TIMOfflinePushInfoToMap(info.getOfflinePushInfo()));
        return rinfo;
    }
    public static HashMap<String,Object> converV2TIMOfflinePushInfoToMap(V2TIMOfflinePushInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("title",info.getTitle());
        rinfo.put("desc",info.getDesc());
        rinfo.put("ext",info.getExt());

        return rinfo;
    }
     public static HashMap<String,Object> converV2TIMGroupMessageReadMemberListToMap(V2TIMGroupMessageReadMemberList info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();

        rinfo.put("nextSeq",info.getNextSeq());
        rinfo.put("isFinished",info.isFinished());
        
        LinkedList<HashMap<String,Object>> searchList = new LinkedList<>();
        List< V2TIMGroupMemberInfo > sList = info.getMemberInfoList();
        for(int i = 0;i<sList.size();i++){
            searchList.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(sList.get(i)));
        }
        rinfo.put("memberInfoList",searchList);

        return rinfo;
    }

    public static HashMap<String,Object> convertV2TIMTopicOperationResultToMap(V2TIMTopicOperationResult info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("errorCode",info.getErrorCode());
        rinfo.put("errorMessage",info.getErrorMessage());
        rinfo.put("topicID",info.getTopicID());
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMTopicInfoResultToMap(V2TIMTopicInfoResult info){
        System.out.println("hahhh");
        System.out.println(info);
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("errorCode",info.getErrorCode());
        rinfo.put("errorMessage",info.getErrorMessage());
        rinfo.put("topicInfo", CommonUtil.convertV2TIMTopicInfoToMap(info.getTopicInfo()) );
        return rinfo;
    }
    public static HashMap<String,Object> convertV2TIMGroupAtInfoToMap(V2TIMGroupAtInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("atType",info.getAtType());
        rinfo.put("seq",info.getSeq());
        return rinfo;
    }

    public static HashMap<String,Object> convertV2TIMTopicInfoToMap(V2TIMTopicInfo info){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("topicID",info.getTopicID());
        rinfo.put("lastMessage",CommonUtil.convertV2TIMMessageToMap(info.getLastMessage()));
        rinfo.put("draftText",info.getDraftText());
        rinfo.put("introduction",info.getIntroduction());
        List<V2TIMGroupAtInfo> atInfos = info.getGroupAtInfoList();
        LinkedList<Map<String,Object>> atlist = new LinkedList();
        for(int i = 0;i<atInfos.size();i++){
            atlist.add(CommonUtil.convertV2TIMGroupAtInfoToMap(atInfos.get(i)));
        }
        rinfo.put("groupAtInfoList",atlist);
        rinfo.put("notification",info.getNotification());
        rinfo.put("customString",info.getCustomString());
        rinfo.put("recvOpt",info.getRecvOpt());
        rinfo.put("selfMuteTime",info.getSelfMuteTime());
        rinfo.put("topicFaceUrl",info.getTopicFaceUrl());
        rinfo.put("topicName",info.getTopicName());
        rinfo.put("unreadCount",info.getUnreadCount());
        return rinfo;
    }

    public static HashMap<String,Object>  convertV2TIMUserStatusToMap(V2TIMUserStatus status){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("customStatus",status.getCustomStatus());
        rinfo.put("statusType",status.getStatusType());
        rinfo.put("userID",status.getUserID());
        return  rinfo;
    }
    public static HashMap<String,Object>  convertV2TIMConversationOperationResultToMap(V2TIMConversationOperationResult status){
        HashMap<String,Object> rinfo = new HashMap<String,Object>();
        rinfo.put("conversationID",status.getConversationID());
        rinfo.put("resultCode",status.getResultCode());
        rinfo.put("resultInfo",status.getResultInfo());
        return  rinfo;
    }

    /**
     * Running the main thread returns an error result execution
     *
     * @param result       return result object
     * @param errorCode    error code
     * @param errorMessage error message
     * @param errorDetails Error content
     */
    public static void runMainThreadReturnError(final MethodChannel.Result result, final String errorCode, final String errorMessage, final Object errorDetails) {
        MAIN_HANDLER.post(new Runnable() {
            @Override
            public void run() {
                result.error(errorCode, errorMessage, errorDetails);
            }
        });
    }
}
