package com.tencent.qcloud.uikit.business.chat.model;

import android.net.Uri;
import android.text.TextUtils;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMCustomElem;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMFaceElem;
import com.tencent.imsdk.TIMFileElem;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMGroupTipsElemGroupInfo;
import com.tencent.imsdk.TIMGroupTipsGroupInfoType;
import com.tencent.imsdk.TIMGroupTipsType;
import com.tencent.imsdk.TIMImage;
import com.tencent.imsdk.TIMImageElem;
import com.tencent.imsdk.TIMImageType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageStatus;
import com.tencent.imsdk.TIMSnapshot;
import com.tencent.imsdk.TIMSoundElem;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.imsdk.TIMVideo;
import com.tencent.imsdk.TIMVideoElem;
import com.tencent.imsdk.ext.message.TIMMessageExt;
import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.utils.FileUtil;
import com.tencent.qcloud.uikit.common.utils.ImageUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


public class MessageInfoUtil {

    public static final String GROUP_CREATE = "group_create";
    public static final String GROUP_DELETE = "group_delete";

    public static MessageInfo buildTextMessage(String message) {
        MessageInfo info = new MessageInfo();
        TIMMessage TIMMsg = new TIMMessage();
        TIMTextElem ele = new TIMTextElem();
        ele.setText(message);
        TIMMsg.addElement(ele);
        info.setExtra(message);
        info.setMsgTime(System.currentTimeMillis());
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_TEXT);
        return info;
    }

    public static MessageInfo buildCustomFaceMessage(int groupId, String faceName) {
        MessageInfo info = new MessageInfo();
        TIMMessage TIMMsg = new TIMMessage();
        TIMFaceElem ele = new TIMFaceElem();
        ele.setIndex(groupId);
        ele.setData(faceName.getBytes());
        TIMMsg.addElement(ele);
        info.setExtra("[自定义表情]");
        info.setMsgTime(System.currentTimeMillis());
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_CUSTOM_FACE);
        return info;
    }


    public static MessageInfo buildImageMessage(final Uri uri, boolean compressed, boolean appPohto) {
        final MessageInfo info = new MessageInfo();
        final TIMImageElem ele = new TIMImageElem();
        //不是应用自己拍摄的照片，先copy一份过来
        if (!appPohto) {
            ImageUtil.CopyImageInfo copInfo = ImageUtil.copyImage(uri, UIKitConstants.IMAGE_DOWNLOAD_DIR);
            if (copInfo == null)
                return null;
            ele.setPath(copInfo.getPath());
            info.setDataPath(copInfo.getPath());
            info.setImgWithd(copInfo.getWidth());
            info.setImgHeight(copInfo.getHeight());
            info.setDataUri(FileUtil.getUriFromPath(copInfo.getPath()));
        } else {
            info.setDataUri(uri);
            int size[] = ImageUtil.getImageSize(uri);
            String path = FileUtil.getPathFromUri(uri);
            ele.setPath(path);
            info.setDataPath(path);
            info.setImgWithd(size[0]);
            info.setImgHeight(size[1]);
        }

        TIMMessage TIMMsg = new TIMMessage();
        TIMMessageExt ext = new TIMMessageExt(TIMMsg);
        ext.setSender(TIMManager.getInstance().getLoginUser());
        ext.setTimestamp(System.currentTimeMillis());
        if (!compressed)
            ele.setLevel(0);
        TIMMsg.addElement(ele);
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setExtra("[图片]");
        info.setMsgTime(System.currentTimeMillis());
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_IMAGE);
        return info;
    }

    public static MessageInfo buildVideoMessage(String imgPath, String videoPath, int width, int height, long duration) {
        MessageInfo info = new MessageInfo();
        TIMMessage TIMMsg = new TIMMessage();
        TIMVideoElem ele = new TIMVideoElem();

        TIMVideo video = new TIMVideo();
        video.setDuaration(duration / 1000);
        video.setType("mp4");
        TIMSnapshot snapshot = new TIMSnapshot();

        snapshot.setWidth(width);
        snapshot.setHeight(height);
        ele.setSnapshot(snapshot);
        ele.setVideo(video);
        ele.setSnapshotPath(imgPath);
        ele.setVideoPath(videoPath);

        TIMMsg.addElement(ele);
        Uri videoUri = Uri.fromFile(new File(videoPath));
        info.setSelf(true);
        info.setImgWithd(width);
        info.setImgHeight(height);
        info.setDataPath(imgPath);
        info.setDataUri(videoUri);
        info.setTIMMessage(TIMMsg);
        info.setExtra("[视频]");
        info.setMsgTime(System.currentTimeMillis());
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_VIDEO);
        return info;
    }

    public static MessageInfo buildAudioMessage(String recordPath, int duration) {
        MessageInfo info = new MessageInfo();
        info.setDataPath(recordPath);
        TIMMessage TIMMsg = new TIMMessage();
        TIMMessageExt ext = new TIMMessageExt(TIMMsg);
        ext.setSender(TIMManager.getInstance().getLoginUser());
        ext.setTimestamp(System.currentTimeMillis() / 1000);
        TIMSoundElem ele = new TIMSoundElem();
        ele.setDuration(duration / 1000);
        ele.setPath(recordPath);
        TIMMsg.addElement(ele);
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setExtra("[语音]");
        info.setMsgTime(System.currentTimeMillis());
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_AUDIO);
        return info;
    }

    public static MessageInfo buildFileMessage(Uri fileUri) {
        String filePath = FileUtil.getPathFromUri(fileUri);
        File file = new File(filePath);
        if (file.exists()) {
            MessageInfo info = new MessageInfo();
            info.setDataPath(filePath);
            TIMMessage TIMMsg = new TIMMessage();
            TIMFileElem ele = new TIMFileElem();
            TIMMessageExt ext = new TIMMessageExt(TIMMsg);
            ext.setSender(TIMManager.getInstance().getLoginUser());
            ext.setTimestamp(System.currentTimeMillis() / 1000);
            ele.setPath(filePath);
            ele.setFileName(file.getName());
            TIMMsg.addElement(ele);
            info.setSelf(true);
            info.setTIMMessage(TIMMsg);
            info.setExtra("[文件]");
            info.setMsgTime(System.currentTimeMillis());
            info.setFromUser(TIMManager.getInstance().getLoginUser());
            info.setMsgType(MessageInfo.MSG_TYPE_FILE);
            info.setStatus(MessageInfo.MSG_STATUS_SENDING);
            return info;
        }
        return null;
    }

    public static MessageInfo buildReadNoticeMessage(String peer) {
        MessageInfo info = new MessageInfo();
        info.setPeer(peer);
        info.setMsgType(MessageInfo.MSG_STATUS_READ);
        return info;
    }

    public static MessageInfo buildGroupCustomMessage(String action, String message) {
        MessageInfo info = new MessageInfo();
        TIMMessage TIMMsg = new TIMMessage();
        TIMCustomElem ele = new TIMCustomElem();
        ele.setData(action.getBytes());
        ele.setExt(message.getBytes());
        TIMMsg.addElement(ele);
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setExtra(message);
        info.setMsgTime(System.currentTimeMillis());
        if (action.equals(GROUP_CREATE)) {
            info.setMsgType(MessageInfo.MSG_TYPE_GROUP_CREATE);
        } else if (action.equals(GROUP_DELETE)) {
            info.setMsgType(MessageInfo.MSG_TYPE_GROUP_DELETE);
        }
        return info;
    }

    public static MessageInfo buildGroupTipsMessage(String peer, int type, String message) {
        MessageInfo info = new MessageInfo();
        info.setSelf(true);
        info.setMsgType(type);
        info.setPeer(peer);
        info.setExtra(message);
        info.setMsgTime(System.currentTimeMillis());
        return info;
    }

    public static List<MessageInfo> TIMMessages2MessageInfos(List<TIMMessage> timMessages, boolean isGroup) {
        if (timMessages == null)
            return null;
        List<MessageInfo> messageInfos = new ArrayList<>();
        for (int i = 0; i < timMessages.size(); i++) {
            TIMMessage timMessage = timMessages.get(i);
            MessageInfo info = TIMMessage2MessageInfo(timMessage, isGroup);
            if (info != null)
                messageInfos.add(info);
        }
        return messageInfos;
    }


    public static MessageInfo TIMMessage2MessageInfo(TIMMessage timMessage, boolean isGroup) {
        if (timMessage == null || timMessage.status() == TIMMessageStatus.HasDeleted)
            return null;
        String sender = timMessage.getSender();
        final MessageInfo msgInfo = new MessageInfo();
        msgInfo.setTIMMessage(timMessage);
        msgInfo.setGroup(isGroup);
        msgInfo.setMsgId(timMessage.getMsgId());
        if (isGroup) {
            TIMGroupMemberInfo memberInfo = timMessage.getSenderGroupMemberProfile();
            if (memberInfo != null && !TextUtils.isEmpty(memberInfo.getNameCard()))
                msgInfo.setFromUser(memberInfo.getNameCard());
            else
                msgInfo.setFromUser(sender);
        } else {
            msgInfo.setFromUser(sender);
        }
        msgInfo.setMsgTime(timMessage.timestamp() * 1000);
        msgInfo.setPeer(timMessage.getConversation().getPeer());
        msgInfo.setSelf(sender.equals(TIMManager.getInstance().getLoginUser()));
        TIMConversation conversation = timMessage.getConversation();
        TIMConversationType conversationType = conversation.getType();
        if (timMessage.getElementCount() > 0) {
            TIMElem ele = timMessage.getElement(0);

            if (ele == null) {
                QLog.e("MessageInfoUtil", "msg found null elem");
                return null;
            }

            TIMElemType type = ele.getType();
            if (type == TIMElemType.Invalid) {
                QLog.e("MessageInfoUtil", "invalid");
                return null;
            }

            if (type == TIMElemType.Custom) {
                TIMCustomElem customElem = (TIMCustomElem) ele;
                String data = new String(customElem.getData());
                if (data.equals(GROUP_CREATE)) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_CREATE);
                    msgInfo.setExtra(new String(customElem.getExt()));
                } else if (data.equals(GROUP_DELETE)) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_DELETE);
                    msgInfo.setExtra(new String(customElem.getExt()));
                } else {
                    msgInfo.setExtra("[自定义消息]");
                }
            } else if (type == TIMElemType.GroupTips) {
                TIMGroupTipsElem groupTips = (TIMGroupTipsElem) ele;
                TIMGroupTipsType tipsType = groupTips.getTipsType();
                String user = "";
                if (groupTips.getChangedGroupMemberInfo().size() > 0) {
                    Object ids[] = groupTips.getChangedGroupMemberInfo().keySet().toArray();
                    for (int i = 0; i < ids.length; i++) {
                        user = user + ids[i].toString();
                        if (i != 0)
                            user = "，" + user;
                        if (i == 2 && ids.length > 3) {
                            user = user + "等";
                            break;
                        }
                    }

                } else
                    user = groupTips.getOpUserInfo().getIdentifier();
                String message = user;
                if (tipsType == TIMGroupTipsType.Join) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_JOIN);
                    message = message + "加入群组";
                }
                if (tipsType == TIMGroupTipsType.Quit) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_QUITE);
                    message = message + "退出群组";
                }
                if (tipsType == TIMGroupTipsType.Kick) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_KICK);
                    message = message + "被踢出群组";
                }
                if (tipsType == TIMGroupTipsType.ModifyGroupInfo) {
                    List<TIMGroupTipsElemGroupInfo> modifyList = groupTips.getGroupInfoList();
                    if (modifyList.size() > 0) {
                        TIMGroupTipsElemGroupInfo modifyInfo = modifyList.get(0);
                        TIMGroupTipsGroupInfoType modifyType = modifyInfo.getType();
                        if (modifyType == TIMGroupTipsGroupInfoType.ModifyName) {
                            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME);
                            message = message + "修改群名称为\"" + modifyInfo.getContent() + "\"";
                        } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyNotification) {
                            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                            message = message + "修改群公告";
                        }
                    }
                }
                msgInfo.setExtra(message);
            } else {
                if (type == TIMElemType.Text) {
                    TIMTextElem txtEle = (TIMTextElem) ele;
                    msgInfo.setExtra(txtEle.getText());
                } else if (type == TIMElemType.Face) {
                    TIMFaceElem txtEle = (TIMFaceElem) ele;
                    if (txtEle.getIndex() < 1 || txtEle.getData() == null) {
                        QLog.e("MessageInfoUtil", "txtEle data is null or index<1");
                        return null;
                    }
                    msgInfo.setExtra("[自定义表情]");


                } else if (type == TIMElemType.Sound) {
                    TIMSoundElem soundElemEle = (TIMSoundElem) ele;
                    if (msgInfo.isSelf()) {
                        msgInfo.setDataPath(soundElemEle.getPath());
                    } else {
                        final String path = UIKitConstants.RECORD_DOWNLOAD_DIR + soundElemEle.getUuid();
                        File file = new File(path);
                        if (!file.exists()) {
                            soundElemEle.getSoundToFile(path, new TIMCallBack() {
                                @Override
                                public void onError(int code, String desc) {
                                    QLog.e("MessageInfoUtil getSoundToFile", code + ":" + desc);
                                }

                                @Override
                                public void onSuccess() {
                                    msgInfo.setDataPath(path);
                                }
                            });
                        } else {
                            msgInfo.setDataPath(path);
                        }
                    }
                    msgInfo.setExtra("[语音]");
                } else if (type == TIMElemType.Image) {
                    TIMImageElem imageEle = (TIMImageElem) ele;
                    String localPath = imageEle.getPath();
                    if (msgInfo.isSelf() && !TextUtils.isEmpty(localPath)) {
                        msgInfo.setDataPath(localPath);
                        int size[] = ImageUtil.getImageSize(localPath);
                        msgInfo.setImgWithd(size[0]);
                        msgInfo.setImgHeight(size[1]);
                    }
                    //本地路径为空，可能为更换手机或者是接收的消息
                    else {
                        List<TIMImage> imgs = imageEle.getImageList();
                        for (int i = 0; i < imgs.size(); i++) {
                            TIMImage img = imgs.get(i);
                            if (img.getType() == TIMImageType.Thumb) {
                                final String path = UIKitConstants.IMAGE_DOWNLOAD_DIR + img.getUuid();
                                msgInfo.setImgWithd((int) img.getWidth());
                                msgInfo.setImgHeight((int) img.getHeight());
                                File file = new File(path);
                                if (file.exists()) {
                                    msgInfo.setDataPath(path);
                                }
                            }
                        }
                    }

                    msgInfo.setExtra("[图片]");
                } else if (type == TIMElemType.Video) {
                    TIMVideoElem videoEle = (TIMVideoElem) ele;
                    if (msgInfo.isSelf() && !TextUtils.isEmpty(videoEle.getSnapshotPath())) {
                        int size[] = ImageUtil.getImageSize(videoEle.getSnapshotPath());
                        msgInfo.setImgWithd(size[0]);
                        msgInfo.setImgHeight(size[1]);
                        msgInfo.setDataPath(videoEle.getSnapshotPath());
                        msgInfo.setDataUri(FileUtil.getUriFromPath(videoEle.getVideoPath()));
                    } else {
                        TIMVideo video = videoEle.getVideoInfo();
                        final String videoPath = UIKitConstants.VIDEO_DOWNLOAD_DIR + video.getUuid();
                        Uri uri = Uri.parse(videoPath);
                        msgInfo.setDataUri(uri);
                        TIMSnapshot snapshot = videoEle.getSnapshotInfo();
                        msgInfo.setImgWithd((int) snapshot.getWidth());
                        msgInfo.setImgHeight((int) snapshot.getHeight());
                        final String snapPath = UIKitConstants.IMAGE_DOWNLOAD_DIR + snapshot.getUuid();
                        //判断快照是否存在,不存在自动下载
                        if (new File(snapPath).exists()) {
                            msgInfo.setDataPath(snapPath);
                        }
                    }

                    msgInfo.setExtra("[视频]");
                } else if (type == TIMElemType.File) {
                    TIMFileElem fileElem = (TIMFileElem) ele;
                    final String path = UIKitConstants.FILE_DOWNLOAD_DIR + fileElem.getUuid();
                    if (!msgInfo.isSelf()) {
                        File file = new File(path);
                        if (!file.exists()) {
                            msgInfo.setStatus(MessageInfo.MSG_STATUS_UN_DOWNLOAD);
                        } else {
                            msgInfo.setStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
                        }
                        msgInfo.setDataPath(path);
                    } else {
                        if (TextUtils.isEmpty(fileElem.getPath())) {
                            fileElem.getToFile(path, new TIMCallBack() {
                                @Override
                                public void onError(int code, String desc) {
                                    QLog.e("MessageInfoUtil getToFile", code + ":" + desc);
                                }

                                @Override
                                public void onSuccess() {
                                    msgInfo.setDataPath(path);
                                }
                            });
                        } else {
                            msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                            msgInfo.setDataPath(fileElem.getPath());
                        }

                    }
                    msgInfo.setExtra("[文件]");
                }
                msgInfo.setMsgType(TIMElemType2MessageInfoType(type));
            }

        } else {
            QLog.e("MessageInfoUtil", "msg elecount is 0");
            return null;
        }

        if (timMessage.status() == TIMMessageStatus.HasRevoked) {
            msgInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
            msgInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
        } else {
            if (msgInfo.isSelf()) {
                if (timMessage.status() == TIMMessageStatus.SendFail) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_FAIL);
                } else if (timMessage.status() == TIMMessageStatus.SendSucc) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                } else if (timMessage.status() == TIMMessageStatus.Sending) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SENDING);
                }
            }
        }
        return msgInfo;
    }

    public static boolean checkMessage(TIMMessage msg, TIMCallBack callBack) {
        if (msg.getElementCount() > 0) {
            TIMElem ele = msg.getElement(0);
            if (ele.getType() == TIMElemType.Video) {
                TIMVideoElem videoEle = (TIMVideoElem) ele;
                TIMVideo video = (TIMVideo) videoEle.getVideoInfo();
                TIMSnapshot snapshot = videoEle.getSnapshotInfo();
                final String snapPath = UIKitConstants.IMAGE_DOWNLOAD_DIR + video.getUuid();
                //判断快照是否存在,不存在自动下载
                if (!new File(snapPath).exists()) {
                    snapshot.getImage(snapPath, callBack);
                }
                return true;
            } else if (ele.getType() == TIMElemType.Image) {
                TIMImageElem imageEle = (TIMImageElem) ele;
                List<TIMImage> imgs = imageEle.getImageList();
                for (int i = 0; i < imgs.size(); i++) {
                    TIMImage img = imgs.get(i);
                    if (img.getType() == TIMImageType.Thumb) {
                        final String path = UIKitConstants.IMAGE_DOWNLOAD_DIR + img.getUuid();
                        File file = new File(path);
                        if (!file.exists()) {
                            img.getImage(path, callBack);
                        }
                        return true;
                    }
                }
            }
            return false;

        }
        return true;
    }

    public static int TIMElemType2MessageInfoType(TIMElemType type) {
        switch (type) {
            case Text:
                return MessageInfo.MSG_TYPE_TEXT;
            case Image:
                return MessageInfo.MSG_TYPE_IMAGE;
            case Sound:
                return MessageInfo.MSG_TYPE_AUDIO;
            case Video:
                return MessageInfo.MSG_TYPE_VIDEO;
            case File:
                return MessageInfo.MSG_TYPE_FILE;
            case Location:
                return MessageInfo.MSG_TYPE_LOCATION;
            case Face:
                return MessageInfo.MSG_TYPE_CUSTOM_FACE;
            case GroupTips:
                return MessageInfo.MSG_TYPE_TIPS;
        }

        return -1;
    }

    public static interface CopyHandler {
        void copyComplete(MessageInfo messageInfo);
    }
}
