package com.reactnativetimjs.util;

import android.content.Context;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.NoSuchKeyException;

import com.tencent.imsdk.v2.V2TIMConversation;
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

import com.reactnativetimjs.TimJsModule;

import java.lang.reflect.Array;
import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import androidx.annotation.Nullable;

public class CommonUtils {
    public static Context context;

    public static <T> void returnSuccess(Promise promise, T data) {
        HashMap<String, Object> succ = new HashMap<String, Object>();
        succ.put("code", 0);
        succ.put("desc", "ok");
        if (data != null) {
            succ.put("data", data);
        }
        WritableMap result = convertJsonObjectToMap(new JSONObject(succ));
        logFromNative("Response: " + result);
        promise.resolve(result);
    }

    public static void returnError(Promise promise, int code, String desc) {
        WritableMap err = Arguments.createMap();
        err.putInt("code", code);
        err.putString("desc", desc);
        logFromNative("Response: " + err);
        promise.resolve(err);
    }

    public static void logFromNative(String msg) {
        WritableMap params = Arguments.createMap();
        params.putString("logs", msg);
        TimJsModule.sendEvent("logFromNative", params);
    }

    public static <T> void emmitEvent(String eventName, String eventType, T data) {
        HashMap<String, Object> succ = new HashMap<String, Object>();
        succ.put("eventName", eventName);
        succ.put("type", eventType);
        succ.put("data", data);
        WritableMap result = convertJsonObjectToMap(new JSONObject(succ));
        TimJsModule.sendEvent(eventName, result);
    }

    public static WritableMap convertJsonObjectToMap(JSONObject jsonObject) {
        WritableMap map = Arguments.createMap();
        try {
            Iterator<String> iterator = jsonObject.keys();
            while (iterator.hasNext()) {
                String key = iterator.next();
                Object value = jsonObject.get(key);
                if (value instanceof JSONObject) {
                    map.putMap(key, convertJsonObjectToMap((JSONObject) value));
                } else if (value instanceof JSONArray) {
                    map.putArray(key, convertJsonToArray((JSONArray) value));
                    if (("option_values").equals(key)) {
                        map.putArray("options", convertJsonToArray((JSONArray) value));
                    }
                } else if (value instanceof Boolean) {
                    map.putBoolean(key, (Boolean) value);
                } else if (value instanceof Integer) {
                    map.putInt(key, (Integer) value);
                } else if (value instanceof Double) {
                    map.putDouble(key, (Double) value);
                } else if (value instanceof String) {
                    map.putString(key, (String) value);
                } else {
                    map.putString(key, value.toString());
                }
            }
        } catch (Exception e) {
            logFromNative("convertJsonObjectToMap error:" + e);
        }
        return map;
    }

    public static WritableArray convertJsonToArray(JSONArray jsonArray) {
        WritableArray array = Arguments.createArray();

        try {
            for (int i = 0; i < jsonArray.length(); i++) {
                Object value = jsonArray.get(i);
                if (value instanceof JSONObject) {
                    array.pushMap(convertJsonObjectToMap((JSONObject) value));
                } else if (value instanceof JSONArray) {
                    array.pushArray(convertJsonToArray((JSONArray) value));
                } else if (value instanceof Boolean) {
                    array.pushBoolean((Boolean) value);
                } else if (value instanceof Integer) {
                    array.pushInt((Integer) value);
                } else if (value instanceof Double) {
                    array.pushDouble((Double) value);
                } else if (value instanceof String) {
                    array.pushString((String) value);
                } else {
                    array.pushString(value.toString());
                }
            }
        } catch (Exception e) {
            logFromNative("convertJsonToArray error:" + e);
        }
        return array;
    }

    public static HashMap<String, Object> convertV2TIMUserFullInfoToMap(V2TIMUserFullInfo info) {
        HashMap<String, Object> userInfo = new HashMap<String, Object>();
        userInfo.put("userID", info.getUserID());
        userInfo.put("nickName", info.getNickName());
        userInfo.put("faceUrl", info.getFaceUrl());
        userInfo.put("selfSignature", info.getSelfSignature());
        userInfo.put("gender", info.getGender());
        userInfo.put("allowType", info.getAllowType());
        userInfo.put("birthday", info.getBirthday());
        HashMap<String, byte[]> customInfo = info.getCustomInfo();
        HashMap<String, String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[]) entry.getValue() == null ? "" : new String((byte[]) entry.getValue());
            customInfoTypeString.put(key, value);
        }
        userInfo.put("customInfo", customInfoTypeString);
        userInfo.put("role", info.getRole());
        userInfo.put("level", info.getLevel());
        return userInfo;
    }

    public static HashMap<String, Object> convertV2TIMMessageToMap(V2TIMMessage msg, Object... progress) {
        final HashMap<String, Object> message = new HashMap<String, Object>();
        if (msg == null) {
            return null;
        }
        message.put("elemType", msg.getElemType());
        message.put("msgID", msg.getMsgID());
        message.put("timestamp", msg.getTimestamp());

        if (progress.length == 0) {
            message.put("progress", 100);
        } else {
            message.put("progress", progress[0]);
        }
        // onProgress listener will return id
        if (progress.length == 2) {
            message.put("id", progress[1]);
        }

        message.put("sender", msg.getSender());
        message.put("nickName", msg.getNickName());
        message.put("friendRemark", msg.getFriendRemark());
        message.put("faceUrl", msg.getFaceUrl());
        message.put("nameCard", msg.getNameCard());
        message.put("groupID", msg.getGroupID());
        message.put("userID", msg.getUserID());
        message.put("status", msg.getStatus());
        message.put("localCustomData", msg.getLocalCustomData());
        message.put("localCustomInt", msg.getLocalCustomInt());
        message.put("cloudCustomData", msg.getCloudCustomData());
        message.put("isSelf", msg.isSelf());
        message.put("isRead", msg.isRead());
        message.put("isPeerRead", msg.isPeerRead());
        message.put("priority", msg.getPriority());
        message.put("seq", String.valueOf(msg.getSeq()));
        message.put("groupAtUserList", msg.getGroupAtUserList());
        message.put("random", msg.getRandom());
        message.put("isExcludedFromUnreadCount", msg.isExcludedFromUnreadCount());
        message.put("isExcludedFromLastMessage", msg.isExcludedFromLastMessage());
        message.put("needReadReceipt", true);
        V2TIMOfflinePushInfo info = msg.getOfflinePushInfo();

        HashMap<String, Object> offlinePushInfo = new HashMap<String, Object>();
        try {
            offlinePushInfo.put("desc", info.getDesc());
            offlinePushInfo.put("title", info.getTitle());
            offlinePushInfo.put("disablePush", info.isDisablePush());
            offlinePushInfo.put("ext", new String(info.getExt()));
        } catch (Exception e) {

        }
        message.put("offlinePushInfo", offlinePushInfo);

        int type = msg.getElemType();
        if (type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
            V2TIMTextElem element = msg.getTextElem();
            V2TIMElem nextElem = element.getNextElem();
            HashMap<String, Object> textMap = CommonUtils.convertTextMessageElem(element);
            if (nextElem != null) {
                textMap.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("textElem", textMap);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            V2TIMCustomElem elem = msg.getCustomElem();
            V2TIMElem nextElem = elem.getNextElem();
            HashMap<String, Object> customMap = CommonUtils.convertCustomMessageElem(msg.getCustomElem());
            if (elem != null) {
                customMap.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("customElem", customMap);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
            V2TIMImageElem imageElem = msg.getImageElem();
            V2TIMElem nextElem = imageElem.getNextElem();
            HashMap<String, Object> img = CommonUtils.convertImageMessageElem(msg.getImageElem());
            if (nextElem != null) {
                img.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("imageElem", img);

        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
            final V2TIMSoundElem soundElem = msg.getSoundElem();
            V2TIMElem nextElem = soundElem.getNextElem();
            final HashMap<String, Object> sound = CommonUtils.convertSoundMessageElem(soundElem);
            if (nextElem != null) {
                sound.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("soundElem", sound);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
            V2TIMVideoElem videoElem = msg.getVideoElem();
            V2TIMElem nextElem = videoElem.getNextElem();
            final HashMap<String, Object> video = CommonUtils.convertVideoMessageElem(videoElem);
            if (nextElem != null) {
                video.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("videoElem", video);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
            final V2TIMFileElem fileElem = msg.getFileElem();
            V2TIMElem nextElem = fileElem.getNextElem();
            final HashMap<String, Object> file = CommonUtils.convertFileMessageElem(fileElem);
            if (nextElem != null) {
                file.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("fileElem", file);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
            V2TIMFaceElem faceElem = msg.getFaceElem();
            V2TIMElem nextElem = faceElem.getNextElem();
            HashMap<String, Object> face = CommonUtils.convertFaceMessageElem(faceElem);
            if (nextElem != null) {
                face.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("faceElem", face);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION) {
            V2TIMLocationElem locationElem = msg.getLocationElem();
            V2TIMElem nextElem = locationElem.getNextElem();
            HashMap<String, Object> location = CommonUtils.convertLocationMessageElem(locationElem);
            if (nextElem != null) {
                location.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("locationElem", location);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            V2TIMGroupTipsElem groupTipsElem = msg.getGroupTipsElem();
            V2TIMElem nextElem = groupTipsElem.getNextElem();
            HashMap<String, Object> groupTips = CommonUtils.convertGroupTipsMessageElem(groupTipsElem);
            if (nextElem != null) {
                groupTips.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("groupTipsElem", groupTips);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER) {
            V2TIMMergerElem mergerElem = msg.getMergerElem();
            V2TIMElem nextElem = mergerElem.getNextElem();
            HashMap<String, Object> elem = CommonUtils.convertMergerMessageElem(mergerElem);
            if (elem != null) {
                elem.put("nextElem", CommonUtils.convertMessageElem(nextElem));
            }
            message.put("mergerElem", elem);
        }

        return message;
    }

    public static HashMap<String, Object> convertTextMessageElem(V2TIMTextElem elem) {
        HashMap<String, Object> messageElem = new HashMap<String, Object>();
        V2TIMTextElem textElem = (V2TIMTextElem) elem;
        messageElem.put("text", textElem.getText());
        return messageElem;
    }

    public static HashMap<String, Object> convertMessageElem(V2TIMElem elem) {
        HashMap<String, Object> messageElem = new HashMap<String, Object>();
        if (elem != null) {
            if (elem instanceof V2TIMCustomElem) {
                messageElem = CommonUtils.convertCustomMessageElem((V2TIMCustomElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM);
            } else if (elem instanceof V2TIMTextElem) {
                messageElem = CommonUtils.convertTextMessageElem((V2TIMTextElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_TEXT);
            } else if (elem instanceof V2TIMImageElem) {
                messageElem = CommonUtils.convertImageMessageElem((V2TIMImageElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE);
            } else if (elem instanceof V2TIMSoundElem) {
                messageElem = CommonUtils.convertSoundMessageElem((V2TIMSoundElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_SOUND);
            } else if (elem instanceof V2TIMVideoElem) {
                messageElem = CommonUtils.convertVideoMessageElem((V2TIMVideoElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO);
            } else if (elem instanceof V2TIMFileElem) {
                messageElem = CommonUtils.convertFileMessageElem((V2TIMFileElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_FILE);
            } else if (elem instanceof V2TIMFaceElem) {
                messageElem = CommonUtils.convertFaceMessageElem((V2TIMFaceElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_FACE);
            } else if (elem instanceof V2TIMLocationElem) {
                messageElem = CommonUtils.convertLocationMessageElem((V2TIMLocationElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION);
            } else if (elem instanceof V2TIMGroupTipsElem) {
                messageElem = CommonUtils.convertGroupTipsMessageElem((V2TIMGroupTipsElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS);
            } else if (elem instanceof V2TIMMergerElem) {
                messageElem = CommonUtils.convertMergerMessageElem((V2TIMMergerElem) elem);
                messageElem.put("elemType", V2TIMMessage.V2TIM_ELEM_TYPE_MERGER);
            }
            if (elem.getNextElem() != null) {
                messageElem.put("nextElem", CommonUtils.convertMessageElem(elem.getNextElem()));
            }
        }
        return messageElem;
    }

    public static HashMap<String, Object> convertCustomMessageElem(V2TIMCustomElem elem) {
        HashMap<String, Object> messageElem = new HashMap<String, Object>();
        V2TIMCustomElem rawCustomMessage = (V2TIMCustomElem) elem;
        messageElem.put("data", rawCustomMessage.getData() == null ? "" : new String(rawCustomMessage.getData()));
        messageElem.put("desc", rawCustomMessage.getDescription());
        messageElem.put("extension",
                rawCustomMessage.getExtension() == null ? "" : new String(rawCustomMessage.getExtension()));

        return messageElem;
    }

    public static HashMap<String, Object> convertImageMessageElem(V2TIMImageElem elem) {
        final HashMap<String, Object> img = new HashMap<String, Object>();
        img.put("path", elem.getPath());
        LinkedList<Object> imgList = new LinkedList<Object>();
        for (int i = 0; i < elem.getImageList().size(); i++) {
            HashMap<String, Object> item = new HashMap<String, Object>();
            V2TIMImageElem.V2TIMImage imgInstance = elem.getImageList().get(i);
            item.put("size", imgInstance.getSize());
            item.put("height", imgInstance.getHeight());
            item.put("type", imgInstance.getType());
            item.put("url", imgInstance.getUrl());
            item.put("UUID", imgInstance.getUUID());
            item.put("width", imgInstance.getWidth());

            try {
                File cacheDir = context.getExternalCacheDir();
                if (cacheDir.exists()) {
                    String path = cacheDir.getPath() + "/" + imgInstance.getType() + "" + imgInstance.getSize() + ""
                            + imgInstance.getWidth() + imgInstance.getHeight() + "_" + imgInstance.getUUID();
                    File file = new File(path);
                    if (!file.exists()) {
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
                    } else {
                        item.put("localUrl", path);
                    }
                }
            } catch (Exception err) {
                System.out.println(err);
            }
            imgList.add(item);
        }
        img.put("imageList", imgList);
        System.out.println(img);
        return img;
    }

    public static HashMap<String, Object> convertSoundMessageElem(V2TIMSoundElem soundElem) {
        final HashMap<String, Object> sound = new HashMap<String, Object>();
        sound.put("dataSize", soundElem.getDataSize());
        sound.put("duration", soundElem.getDuration());
        sound.put("path", soundElem.getPath());
        sound.put("UUID", soundElem.getUUID());
        soundElem.getUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                sound.put("url", s);
            }
        });
        try {
            File cacheDir = context.getExternalCacheDir();

            if (cacheDir.exists()) {
                String path = cacheDir.getPath() + "/" + soundElem.getUUID();
                File file = new File(path);
                if (!file.exists()) {
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
                } else {
                    sound.put("localUrl", path);
                }
            }
        } catch (Exception errr) {

        }
        return sound;
    }

    public static HashMap<String, Object> convertVideoMessageElem(V2TIMVideoElem videoElem) {
        final HashMap<String, Object> video = new HashMap<String, Object>();
        videoElem.getVideoUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                video.put("videoUrl", s);
            }
        });
        videoElem.getSnapshotUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                video.put("snapshotUrl", s);
            }
        });
        video.put("duration", videoElem.getDuration());
        video.put("snapshotHeight", videoElem.getSnapshotHeight());
        video.put("snapshotPath", videoElem.getSnapshotPath());
        video.put("snapshotSize", videoElem.getSnapshotSize());
        video.put("snapshotUUID", videoElem.getSnapshotUUID());
        video.put("snapshotWidth", videoElem.getSnapshotWidth());
        video.put("videoPath", videoElem.getVideoPath());
        video.put("videoSize", videoElem.getVideoSize());
        video.put("UUID", videoElem.getVideoUUID());
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
                } else {
                    video.put("localVideoUrl", path);
                }
                if (!snip.exists()) {
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
                } else {
                    video.put("localSnapshotUrl", snipPath);
                }
            }
        } catch (Exception err) {

        }
        return video;
    }

    public static HashMap<String, Object> convertFileMessageElem(V2TIMFileElem fileElem) {
        final HashMap<String, Object> file = new HashMap<String, Object>();
        file.put("fileName", fileElem.getFileName());
        file.put("fileSize", fileElem.getFileSize());
        file.put("path", fileElem.getPath());
        file.put("UUID", fileElem.getUUID());
        fileElem.getUrl(new V2TIMValueCallback<String>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(String s) {
                file.put("url", s);
            }
        });
        try {
            File cacheDir = context.getExternalCacheDir();

            if (cacheDir.exists()) {
                String path = cacheDir.getPath() + "/" + fileElem.getUUID();
                File f = new File(path);
                if (!f.exists()) {
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
                } else {
                    file.put("localUrl", path);
                }
            }
        } catch (Exception errr) {

        }
        return file;
    }

    public static HashMap<String, Object> convertFaceMessageElem(V2TIMFaceElem faceElem) {
        HashMap<String, Object> face = new HashMap<String, Object>();
        face.put("data", faceElem.getData() == null ? "" : new String(faceElem.getData()));
        face.put("index", faceElem.getIndex());
        return face;
    }

    public static HashMap<String, Object> convertLocationMessageElem(V2TIMLocationElem locationElem) {
        HashMap<String, Object> location = new HashMap<String, Object>();
        location.put("desc", locationElem.getDesc());
        location.put("latitude", locationElem.getLatitude());
        location.put("longitude", locationElem.getLongitude());
        return location;
    }

    public static HashMap<String, Object> convertGroupTipsMessageElem(V2TIMGroupTipsElem groupTipsElem) {
        HashMap<String, Object> groupTips = new HashMap<String, Object>();

        List<V2TIMGroupChangeInfo> groupChangeInfoList = groupTipsElem.getGroupChangeInfoList();
        LinkedList<HashMap<String, Object>> gchangeInfoList = new LinkedList<HashMap<String, Object>>();

        for (int i = 0; i < groupChangeInfoList.size(); i++) {

            String key = groupChangeInfoList.get(i).getKey();
            int types = groupChangeInfoList.get(i).getType();
            String value = groupChangeInfoList.get(i).getValue();
            Boolean boolValue = groupChangeInfoList.get(i).getBoolValue();
            HashMap<String, Object> item = new HashMap<String, Object>();
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

        List<V2TIMGroupMemberChangeInfo> mlist = groupTipsElem.getMemberChangeInfoList();
        LinkedList<Object> memberChangeInfoList = new LinkedList<Object>();
        for (int i = 0; i < mlist.size(); i++) {
            HashMap<String, Object> item = new HashMap<String, Object>();
            item.put("userID", mlist.get(i).getUserID());
            item.put("muteTime", mlist.get(i).getMuteTime());
            memberChangeInfoList.add(item);
        }
        groupTips.put("memberChangeInfoList", memberChangeInfoList);

        List<V2TIMGroupMemberInfo> memberlist = groupTipsElem.getMemberList();
        LinkedList<Object> memberInfoList = new LinkedList<Object>();
        for (int i = 0; i < memberlist.size(); i++) {
            HashMap<String, Object> item = new HashMap<String, Object>();
            item.put("userID", memberlist.get(i).getUserID());
            item.put("faceUrl", memberlist.get(i).getFaceUrl());
            item.put("friendRemark", memberlist.get(i).getFriendRemark());
            item.put("nameCard", memberlist.get(i).getNameCard());
            item.put("nickName", memberlist.get(i).getNickName());
            memberInfoList.add(item);
        }
        groupTips.put("memberList", memberInfoList);

        V2TIMGroupMemberInfo opmember = groupTipsElem.getOpMember();
        HashMap<String, Object> opmemberItem = new HashMap<String, Object>();
        opmemberItem.put("userID", opmember.getUserID());
        opmemberItem.put("faceUrl", opmember.getFaceUrl());
        opmemberItem.put("friendRemark", opmember.getFriendRemark());
        opmemberItem.put("nameCard", opmember.getNameCard());
        opmemberItem.put("nickName", opmember.getNickName());

        groupTips.put("opMember", opmemberItem);
        return groupTips;
    }

    public static HashMap<String, Object> convertMergerMessageElem(V2TIMMergerElem mergerElem) {
        HashMap<String, Object> elem = new HashMap<String, Object>();
        elem.put("isLayersOverLimit", mergerElem.isLayersOverLimit());
        elem.put("abstractList", mergerElem.getAbstractList());
        elem.put("title", mergerElem.getTitle());
        return elem;
    }

    public static HashMap convertReadableMapToHashMap(@Nullable ReadableMap map) {
        HashMap<String, Object> hashMap = new HashMap<>();
        if (map == null) {
            return hashMap;
        }

        ReadableMapKeySetIterator iterator = map.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            switch (map.getType(key)) {
                case Null:
                    hashMap.put(key, null);
                    break;
                case Boolean:
                    hashMap.put(key, map.getBoolean(key));
                    break;
                case Number:
                    hashMap.put(key, map.getInt(key));
                    break;
                case String:
                    hashMap.put(key, map.getString(key));
                    break;
                case Map:
                    hashMap.put(key, convertReadableMapToHashMap(map.getMap(key)));
                    break;
                case Array:
                    hashMap.put(key, convertReadableArrayToList(map.getArray(key)));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " + key + ".");
            }
        }
        return hashMap;
    }

    public static List<String> convertReadableArrayToListString(@Nullable ReadableArray readableArray) {
        if (readableArray == null) {
            return null;
        }

        List<String> result = new ArrayList<String>(readableArray.size());

        for (int index = 0; index < readableArray.size(); index++) {
            ReadableType readableType = readableArray.getType(index);

            switch (readableType) {
                case Null:
                    break;
                case String:
                    result.add(readableArray.getString(index));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " + index + ".");
            }
        }

        return result;
    }

    public static List<HashMap<String, Object>> convertReadableArrayToListHashMap(
            @Nullable ReadableArray readableArray) {
        if (readableArray == null) {
            return null;
        }

        List<HashMap<String, Object>> result = new ArrayList<HashMap<String, Object>>(readableArray.size());

        for (int index = 0; index < readableArray.size(); index++) {
            ReadableType readableType = readableArray.getType(index);

            switch (readableType) {
                case Null:
                    break;
                case Map:
                    result.add(convertReadableMapToHashMap(readableArray.getMap(index)));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " + index + ".");
            }
        }

        return result;
    }

    public static List<Integer> convertReadableArrayToListInt(@Nullable ReadableArray readableArray) {
        if (readableArray == null) {
            return null;
        }

        List<Integer> result = new ArrayList<Integer>(readableArray.size());

        for (int index = 0; index < readableArray.size(); index++) {
            ReadableType readableType = readableArray.getType(index);

            switch (readableType) {
                case Null:
                    break;
                case Number:
                    // Can be int or double.
                    int tmp = readableArray.getInt(index);

                    if (tmp == (int) tmp) {
                        result.add((int) tmp);
                    } else {
                        result.add(tmp);
                    }

                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " + index + ".");
            }
        }

        return result;
    }

    public static List<Object> convertReadableArrayToList(@Nullable ReadableArray readableArray) {
        if (readableArray == null) {
            return null;
        }

        List<Object> result = new ArrayList<Object>(readableArray.size());

        for (int index = 0; index < readableArray.size(); index++) {
            ReadableType readableType = readableArray.getType(index);

            switch (readableType) {
                case Null:
                    break;
                case Boolean:
                    result.add(readableArray.getBoolean(index));
                    break;
                case Number:
                    // Can be int or double.
                    double tmp = readableArray.getDouble(index);

                    if (tmp == (int) tmp) {
                        result.add((int) tmp);
                    } else {
                        result.add(tmp);
                    }

                    break;
                case String:
                    result.add(readableArray.getString(index));
                    break;
                case Map:
                    result.add(convertReadableMapToHashMap(readableArray.getMap(index)));
                    break;
                case Array:
                    result = convertReadableArrayToList(readableArray.getArray(index));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with key: " +
                            index + ".");
            }
        }

        return result;
    }

    public static HashMap<String, Object> convertV2TIMUserInfotoMap(V2TIMUserInfo userInfo) {
        HashMap<String, Object> info = new HashMap<String, Object>();
        info.put("userID", userInfo.getUserID());
        info.put("nickName", userInfo.getNickName());
        info.put("faceUrl", userInfo.getFaceUrl());
        return info;
    }

    public static HashMap<String, Object> convertV2TIMGroupMemberInfoToMap(V2TIMGroupMemberInfo info) {
        HashMap<String, Object> ginfo = new HashMap<String, Object>();
        ginfo.put("faceUrl", info.getFaceUrl());
        ginfo.put("friendRemark", info.getFriendRemark());
        ginfo.put("nameCard", info.getNameCard());
        ginfo.put("nickName", info.getNickName());
        ginfo.put("userID", info.getUserID());
        return ginfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupMemberChangeInfoToMap(V2TIMGroupMemberChangeInfo info) {
        HashMap<String, Object> cinfo = new HashMap<String, Object>();
        cinfo.put("muteTime", info.getMuteTime());
        cinfo.put("userID", info.getUserID());
        return cinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendApplicationToMap(V2TIMFriendApplication info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("userID", info.getUserID());
        rinfo.put("type", info.getType());
        rinfo.put("nickname", info.getNickname());
        rinfo.put("faceUrl", info.getFaceUrl());
        rinfo.put("addWording", info.getAddWording());
        rinfo.put("addTime", info.getAddTime());
        rinfo.put("addSource", info.getAddSource());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendInfoToMap(V2TIMFriendInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        List<String> ulists = info.getFriendGroups();
        rinfo.put("friendGroups", ulists);
        rinfo.put("friendRemark", info.getFriendRemark());
        rinfo.put("userID", info.getUserID());
        rinfo.put("userProfile", CommonUtils.convertV2TIMUserFullInfoToMap(info.getUserProfile()));
        HashMap<String, byte[]> customInfo = info.getFriendCustomInfo();
        HashMap<String, String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[]) entry.getValue() == null ? "" : new String((byte[]) entry.getValue());
            customInfoTypeString.put(key, value);
        }
        rinfo.put("friendCustomInfo", customInfoTypeString);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendInfoResultToMap(V2TIMFriendInfoResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("friendInfo", CommonUtils.convertV2TIMFriendInfoToMap(info.getFriendInfo()));
        rinfo.put("relation", info.getRelation());
        rinfo.put("resultCode", info.getResultCode());
        rinfo.put("resultInfo", info.getResultInfo());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendOperationResultToMap(V2TIMFriendOperationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("resultCode", info.getResultCode());
        rinfo.put("resultInfo", info.getResultInfo());
        rinfo.put("userID", info.getUserID());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendCheckResultToMap(V2TIMFriendCheckResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("resultType", info.getResultType());
        rinfo.put("resultCode", info.getResultCode());
        rinfo.put("resultInfo", info.getResultInfo());
        rinfo.put("userID", info.getUserID());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendApplicationResultToMap(V2TIMFriendApplicationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        LinkedList<Object> list = new LinkedList<Object>();
        List<V2TIMFriendApplication> ulist = info.getFriendApplicationList();
        for (int i = 0; i < ulist.size(); i++) {
            V2TIMFriendApplication item = ulist.get(i);
            HashMap<String, Object> data = new HashMap<String, Object>();
            data.put("addSource", item.getAddSource());
            data.put("addTime", item.getAddTime());
            data.put("addWording", item.getAddWording());
            data.put("faceUrl", item.getFaceUrl());
            data.put("nickname", item.getNickname());
            data.put("type", item.getType());
            data.put("userID", item.getUserID());
            list.add(data);
        }
        rinfo.put("friendApplicationList", list);
        rinfo.put("unreadCount", info.getUnreadCount());

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupInfoToMap(V2TIMGroupInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("createTime", info.getCreateTime());
        rinfo.put("faceUrl", info.getFaceUrl());
        rinfo.put("groupAddOpt", info.getGroupAddOpt());
        rinfo.put("groupID", info.getGroupID());
        rinfo.put("groupName", info.getGroupName());
        rinfo.put("groupType", info.getGroupType());
        rinfo.put("introduction", info.getIntroduction());
        rinfo.put("joinTime", info.getJoinTime());
        rinfo.put("lastInfoTime", info.getLastInfoTime());
        rinfo.put("lastMessageTime", info.getLastMessageTime());
        rinfo.put("memberCount", info.getMemberCount());
        rinfo.put("notification", info.getNotification());
        rinfo.put("onlineCount", info.getOnlineCount());
        rinfo.put("owner", info.getOwner());
        rinfo.put("recvOpt", info.getRecvOpt());
        rinfo.put("role", info.getRole());
        rinfo.put("isAllMuted", info.isAllMuted());
        rinfo.put("isSupportTopic", info.isSupportTopic());
        Map<String, byte[]> customInfo = info.getCustomInfo();

        HashMap<String, String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = customInfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[]) entry.getValue() == null ? "" : new String((byte[]) entry.getValue());
            customInfoTypeString.put(key, value);
        }
        rinfo.put("customInfo", customInfoTypeString);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupInfoResultToMap(V2TIMGroupInfoResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("groupInfo", CommonUtils.convertV2TIMGroupInfoToMap(info.getGroupInfo()));
        rinfo.put("resultCode", info.getResultCode());
        rinfo.put("resultMessage", info.getResultMessage());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMTopicOperationResultToMap(V2TIMTopicOperationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("errorCode", info.getErrorCode());
        rinfo.put("errorMessage", info.getErrorMessage());
        rinfo.put("topicID", info.getTopicID());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMTopicInfoResultToMap(V2TIMTopicInfoResult info) {
        System.out.println("hahhh");
        System.out.println(info);
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("errorCode", info.getErrorCode());
        rinfo.put("errorMessage", info.getErrorMessage());
        rinfo.put("topicInfo", CommonUtils.convertV2TIMTopicInfoToMap(info.getTopicInfo()));
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupAtInfoToMap(V2TIMGroupAtInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("atType", info.getAtType());
        rinfo.put("seq", info.getSeq());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMTopicInfoToMap(V2TIMTopicInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("topicID", info.getTopicID());
        rinfo.put("lastMessage", CommonUtils.convertV2TIMMessageToMap(info.getLastMessage()));
        rinfo.put("draftText", info.getDraftText());
        rinfo.put("introduction", info.getIntroduction());
        List<V2TIMGroupAtInfo> atInfos = info.getGroupAtInfoList();
        LinkedList<Map<String, Object>> atlist = new LinkedList();
        for (int i = 0; i < atInfos.size(); i++) {
            atlist.add(CommonUtils.convertV2TIMGroupAtInfoToMap(atInfos.get(i)));
        }
        rinfo.put("groupAtInfoList", atlist);
        rinfo.put("notification", info.getNotification());
        rinfo.put("customString", info.getCustomString());
        rinfo.put("recvOpt", info.getRecvOpt());
        rinfo.put("selfMuteTime", info.getSelfMuteTime());
        rinfo.put("topicFaceUrl", info.getTopicFaceUrl());
        rinfo.put("topicName", info.getTopicName());
        rinfo.put("unreadCount", info.getUnreadCount());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupMemberInfoResultToMap(V2TIMGroupMemberInfoResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
        for (int i = 0; i < info.getMemberInfoList().size(); i++) {
            list.add(CommonUtils.convertV2TIMGroupMemberFullInfoToMap(info.getMemberInfoList().get(i)));
        }
        rinfo.put("memberInfoList", list);
        rinfo.put("nextSeq", String.valueOf(info.getNextSeq()));

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupMemberFullInfoToMap(V2TIMGroupMemberFullInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("userID", info.getUserID());
        rinfo.put("role", info.getRole());
        rinfo.put("muteUntil", info.getMuteUntil());
        rinfo.put("joinTime", info.getJoinTime());
        rinfo.put("nickName", info.getNickName());
        rinfo.put("nameCard", info.getNameCard());
        rinfo.put("friendRemark", info.getFriendRemark());
        rinfo.put("faceUrl", info.getFaceUrl());
        Map<String, byte[]> custinfo = info.getCustomInfo();
        HashMap<String, String> customInfoTypeString = new HashMap<String, String>();
        Iterator it = custinfo.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String key = (String) entry.getKey();
            String value = (byte[]) entry.getValue() == null ? "" : new String((byte[]) entry.getValue());
            customInfoTypeString.put(key, value);
        }
        rinfo.put("customInfo", customInfoTypeString);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupMemberOperationResultToMap(
            V2TIMGroupMemberOperationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("memberID", info.getMemberID());
        rinfo.put("result", info.getResult());

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupApplicationResultToMap(V2TIMGroupApplicationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
        for (int i = 0; i < info.getGroupApplicationList().size(); i++) {
            list.add(CommonUtils.convertV2TimGroupApplicationToMap(info.getGroupApplicationList().get(i)));
        }
        rinfo.put("groupApplicationList", list);
        rinfo.put("unreadCount", info.getUnreadCount());

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TimGroupApplicationToMap(V2TIMGroupApplication info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("addTime", info.getAddTime());
        rinfo.put("fromUser", info.getFromUser());
        rinfo.put("fromUserFaceUrl", info.getFromUserFaceUrl());
        rinfo.put("fromUserNickName", info.getFromUserNickName());
        rinfo.put("groupID", info.getGroupID());
        rinfo.put("handledMsg", info.getHandledMsg());
        rinfo.put("handleResult", info.getHandleResult());
        rinfo.put("handleStatus", info.getHandleStatus());
        rinfo.put("requestMsg", info.getRequestMsg());
        rinfo.put("toUser", info.getToUser());
        rinfo.put("type", info.getType());

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMReceiveMessageOptInfoToMap(V2TIMReceiveMessageOptInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("c2CReceiveMessageOpt", info.getC2CReceiveMessageOpt());
        rinfo.put("userID", info.getUserID());
        return rinfo;
    }

    public static HashMap<String, Object> converV2TIMGroupMessageReadMemberListToMap(
            V2TIMGroupMessageReadMemberList info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("nextSeq", info.getNextSeq());
        rinfo.put("isFinished", info.isFinished());

        LinkedList<HashMap<String, Object>> searchList = new LinkedList<>();
        List<V2TIMGroupMemberInfo> sList = info.getMemberInfoList();
        for (int i = 0; i < sList.size(); i++) {
            searchList.add(CommonUtils.convertV2TIMGroupMemberInfoToMap(sList.get(i)));
        }
        rinfo.put("memberInfoList", searchList);

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMMessageSearchResultToMap(V2TIMMessageSearchResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("totalCount", info.getTotalCount());
        LinkedList<HashMap<String, Object>> searchList = new LinkedList<>();
        List<V2TIMMessageSearchResultItem> sList = info.getMessageSearchResultItems();
        for (int i = 0; i < sList.size(); i++) {
            searchList.add(CommonUtils.convertV2TIMMessageSearchResultItemToMap(sList.get(i)));
        }
        rinfo.put("messageSearchResultItems", searchList);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMMessageSearchResultItemToMap(V2TIMMessageSearchResultItem info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        List<V2TIMMessage> messages = info.getMessageList();
        LinkedList<HashMap<String, Object>> messageList = new LinkedList<>();

        rinfo.put("conversationID", info.getConversationID());
        rinfo.put("messageCount", info.getMessageCount());
        for (int i = 0; i < messages.size(); i++) {
            messageList.add(CommonUtils.convertV2TIMMessageToMap(messages.get(i)));
        }
        rinfo.put("messageList", messageList);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMConversationToMap(V2TIMConversation info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("conversationID", info.getConversationID());
        rinfo.put("draftText", info.getDraftText());
        rinfo.put("draftTimestamp", info.getDraftTimestamp());
        rinfo.put("faceUrl", info.getFaceUrl());
        rinfo.put("groupID", info.getGroupID());
        rinfo.put("groupType", info.getGroupType());
        rinfo.put("lastMessage", CommonUtils.convertV2TIMMessageToMap(info.getLastMessage()));
        rinfo.put("showName", info.getShowName());
        rinfo.put("type", info.getType());
        rinfo.put("unreadCount", info.getUnreadCount());
        rinfo.put("userID", info.getUserID());
        rinfo.put("isPinned", info.isPinned());
        rinfo.put("recvOpt", info.getRecvOpt());
        rinfo.put("orderkey", info.getOrderKey());
        List<V2TIMGroupAtInfo> atList = info.getGroupAtInfoList();
        List<Map<String, Object>> groupAtInfoList = new LinkedList<Map<String, Object>>();
        for (int i = 0; i < atList.size(); i++) {
            V2TIMGroupAtInfo item = atList.get(i);
            Map<String, Object> itemMap = new HashMap<String, Object>();
            itemMap.put("atType", item.getAtType());
            itemMap.put("seq", String.valueOf(item.getSeq()));
            groupAtInfoList.add(itemMap);
        }
        rinfo.put("groupAtInfoList", groupAtInfoList);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMConversationResultToMap(V2TIMConversationResult info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("nextSeq", String.valueOf(info.getNextSeq()));
        rinfo.put("isFinished", info.isFinished());
        List<V2TIMConversation> list = info.getConversationList();
        LinkedList<Object> clist = new LinkedList<Object>();
        for (int i = 0; i < list.size(); i++) {
            V2TIMConversation item = list.get(i);
            HashMap<String, Object> citem = CommonUtils.convertV2TIMConversationToMap(item);
            clist.add(citem);
        }
        rinfo.put("conversationList", clist);
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMSignalingInfoToMap(V2TIMSignalingInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("actionType", info.getActionType());
        rinfo.put("businessID", info.getBusinessID());
        rinfo.put("data", info.getData());
        rinfo.put("groupID", info.getGroupID());
        rinfo.put("inviteeList", info.getInviteeList());
        rinfo.put("inviteID", info.getInviteID());
        rinfo.put("inviter", info.getInviter());
        rinfo.put("timeout", info.getTimeout());
        if (info.getOfflinePushInfo() != null)
            rinfo.put("offlinePushInfo", CommonUtils.converV2TIMOfflinePushInfoToMap(info.getOfflinePushInfo()));
        return rinfo;
    }

    public static HashMap<String, Object> converV2TIMOfflinePushInfoToMap(V2TIMOfflinePushInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("title", info.getTitle());
        rinfo.put("desc", info.getDesc());
        rinfo.put("ext", info.getExt());

        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMUserStatusToMap(V2TIMUserStatus status) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();
        rinfo.put("customStatus", status.getCustomStatus());
        rinfo.put("statusType", status.getStatusType());
        rinfo.put("userID", status.getUserID());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMMessageReceiptToMap(V2TIMMessageReceipt info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("timestamp", info.getTimestamp());
        rinfo.put("userID", info.getUserID());
        rinfo.put("unreadCount", info.getUnreadCount());
        rinfo.put("readCount", info.getReadCount());
        rinfo.put("msgID", info.getMsgID());
        rinfo.put("groupID", info.getGroupID());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMGroupChangeInfoToMap(V2TIMGroupChangeInfo info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("value", info.getValue());
        rinfo.put("type", info.getType());
        rinfo.put("key", info.getKey());
        return rinfo;
    }

    public static HashMap<String, Object> convertV2TIMFriendGroupToMap(V2TIMFriendGroup info) {
        HashMap<String, Object> rinfo = new HashMap<String, Object>();

        rinfo.put("friendCount", info.getFriendCount());
        rinfo.put("friendIDList", info.getFriendIDList());
        rinfo.put("name", info.getName());
        return rinfo;
    }

    public static @Nullable Integer safeGetInt(ReadableMap arguments, String key) {
        try {
            return arguments.getInt(key);
        } catch (NoSuchKeyException ex) {
            return null;
        }
    }

    public static @Nullable String safeGetString(ReadableMap arguments, String key) {
        try {
            return arguments.getString(key);
        } catch (NoSuchKeyException ex) {
            return null;
        }
    }

    public static @Nullable ReadableMap safeGetMap(ReadableMap arguments, String key) {
        try {
            return arguments.getMap(key);
        } catch (NoSuchKeyException ex) {
            return null;
        }
    }

    public static @Nullable Boolean safeGetBoolean(ReadableMap arguments, String key) {
        try {
            return arguments.getBoolean(key);
        } catch (NoSuchKeyException ex) {
            return null;
        }
    }
}
