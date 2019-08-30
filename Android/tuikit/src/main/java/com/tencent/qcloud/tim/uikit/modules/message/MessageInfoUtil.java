package com.tencent.qcloud.tim.uikit.modules.message;

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
import com.tencent.imsdk.TIMGroupTipsElemMemberInfo;
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
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.ImageUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


public class MessageInfoUtil {

    private static final String TAG = MessageInfoUtil.class.getSimpleName();

    public static final String GROUP_CREATE = "group_create";
    public static final String GROUP_DELETE = "group_delete";

    /**
     * 创建一条文本消息
     *
     * @param message 消息内容
     * @return
     */
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

    /**
     * 创建一条自定义表情的消息
     *
     * @param groupId  自定义表情所在的表情组id
     * @param faceName 表情的名称
     * @return
     */
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

    /**
     * 创建一条图片消息
     *
     * @param uri        图片URI
     * @param compressed 是否压缩
     * @return
     */
    public static MessageInfo buildImageMessage(final Uri uri, boolean compressed) {
        final MessageInfo info = new MessageInfo();
        final TIMImageElem ele = new TIMImageElem();
        info.setDataUri(uri);
        int size[] = ImageUtil.getImageSize(uri);
        String path = FileUtil.getPathFromUri(uri);
        ele.setPath(path);
        info.setDataPath(path);
        info.setImgWidth(size[0]);
        info.setImgHeight(size[1]);

        TIMMessage TIMMsg = new TIMMessage();
        TIMMsg.setSender(TIMManager.getInstance().getLoginUser());
        TIMMsg.setTimestamp(System.currentTimeMillis());
        if (!compressed) {
            ele.setLevel(0);
        }
        TIMMsg.addElement(ele);
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setExtra("[图片]");
        info.setMsgTime(System.currentTimeMillis());
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_IMAGE);
        return info;
    }

    /**
     * 创建一条视频消息
     *
     * @param imgPath   视频缩略图路径
     * @param videoPath 视频路径
     * @param width     视频的宽
     * @param height    视频的高
     * @param duration  视频的时长
     * @return
     */
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
        info.setImgWidth(width);
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

    /**
     * 创建一条音频消息
     *
     * @param recordPath 音频路径
     * @param duration   音频的时长
     * @return
     */
    public static MessageInfo buildAudioMessage(String recordPath, int duration) {
        MessageInfo info = new MessageInfo();
        info.setDataPath(recordPath);
        TIMMessage TIMMsg = new TIMMessage();
        TIMMsg.setSender(TIMManager.getInstance().getLoginUser());
        TIMMsg.setTimestamp(System.currentTimeMillis() / 1000);
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

    /**
     * 创建一条文件消息
     *
     * @param fileUri 文件路径
     * @return
     */
    public static MessageInfo buildFileMessage(Uri fileUri) {
        String filePath = FileUtil.getPathFromUri(fileUri);
        File file = new File(filePath);
        if (file.exists()) {
            MessageInfo info = new MessageInfo();
            info.setDataPath(filePath);
            TIMMessage TIMMsg = new TIMMessage();
            TIMFileElem ele = new TIMFileElem();
            TIMMsg.setSender(TIMManager.getInstance().getLoginUser());
            TIMMsg.setTimestamp(System.currentTimeMillis() / 1000);
            ele.setPath(filePath);
            ele.setFileName(file.getName());
            TIMMsg.addElement(ele);
            info.setSelf(true);
            info.setTIMMessage(TIMMsg);
            info.setExtra("[文件]");
            info.setMsgTime(System.currentTimeMillis());
            info.setFromUser(TIMManager.getInstance().getLoginUser());
            info.setMsgType(MessageInfo.MSG_TYPE_FILE);
            return info;
        }
        return null;
    }

    /**
     * 创建一条自定义消息
     *
     * @param data 自定义消息内容，可以是任何内容
     * @return
     */
    public static MessageInfo buildCustomMessage(String data) {
        MessageInfo info = new MessageInfo();
        TIMMessage TIMMsg = new TIMMessage();
        TIMCustomElem ele = new TIMCustomElem();
        ele.setData(data.getBytes());
        TIMMsg.addElement(ele);
        info.setSelf(true);
        info.setTIMMessage(TIMMsg);
        info.setMsgTime(System.currentTimeMillis());
        info.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
        info.setFromUser(TIMManager.getInstance().getLoginUser());
        return info;
    }

    /**
     * 创建一条群消息自定义内容
     *
     * @param action  群消息类型，比如建群等
     * @param message 消息内容
     * @return
     */
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

    /**
     * 把SDK的消息bean列表转化为TUIKit的消息bean列表
     *
     * @param timMessages SDK的群消息bean列表
     * @param isGroup     是否是群消息
     * @return
     */
    public static List<MessageInfo> TIMMessages2MessageInfos(List<TIMMessage> timMessages, boolean isGroup) {
        if (timMessages == null) {
            return null;
        }
        List<MessageInfo> messageInfos = new ArrayList<>();
        for (int i = 0; i < timMessages.size(); i++) {
            TIMMessage timMessage = timMessages.get(i);
            List<MessageInfo> info = TIMMessage2MessageInfo(timMessage, isGroup);
            if (info != null) {
                messageInfos.addAll(info);
            }
        }
        return messageInfos;
    }

    /**
     * 把SDK的消息bean转化为TUIKit的消息bean
     *
     * @param timMessage SDK的群消息bean
     * @param isGroup    是否是群消息
     * @return
     */
    public static List<MessageInfo> TIMMessage2MessageInfo(TIMMessage timMessage, boolean isGroup) {
        if (timMessage == null || timMessage.status() == TIMMessageStatus.HasDeleted || timMessage.getElementCount() == 0) {
            return null;
        }
        List<MessageInfo> list = new ArrayList<>();
        for (int i = 0; i < timMessage.getElementCount(); i++) {
            final MessageInfo msgInfo = new MessageInfo();
            if (ele2MessageInfo(msgInfo, timMessage, timMessage.getElement(i), isGroup) != null) {
                list.add(msgInfo);
            }
        }
        return list;
    }

    private static MessageInfo ele2MessageInfo(final MessageInfo msgInfo, TIMMessage timMessage, TIMElem ele, boolean isGroup) {
        if (msgInfo == null
                || timMessage == null
                || timMessage.status() == TIMMessageStatus.HasDeleted
                || timMessage.getElementCount() == 0
                || ele == null
                || ele.getType() == TIMElemType.Invalid) {
            TUIKitLog.e(TAG, "ele2MessageInfo parameters error");
            return null;
        }
        String sender = timMessage.getSender();
        msgInfo.setTIMMessage(timMessage);
        msgInfo.setGroup(isGroup);
        msgInfo.setId(timMessage.getMsgId());
        if (isGroup) {
            TIMGroupMemberInfo memberInfo = timMessage.getSenderGroupMemberProfile();
            if (memberInfo != null && !TextUtils.isEmpty(memberInfo.getNameCard())) {
                msgInfo.setFromUser(memberInfo.getNameCard());
            } else {
                msgInfo.setFromUser(sender);
            }
        } else {
            msgInfo.setFromUser(sender);
        }
        msgInfo.setMsgTime(timMessage.timestamp() * 1000);
        msgInfo.setSelf(sender.equals(TIMManager.getInstance().getLoginUser()));

        TIMElemType type = ele.getType();
        if (type == TIMElemType.Custom) {
            TIMCustomElem customElem = (TIMCustomElem) ele;
            String data = new String(customElem.getData());
            if (data.equals(GROUP_CREATE)) {
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_CREATE);
                String message = wrapperColor(msgInfo.getFromUser()) + "创建群组";
                msgInfo.setExtra(message);
            } else if (data.equals(GROUP_DELETE)) {
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_DELETE);
                msgInfo.setExtra(new String(customElem.getExt()));
            } else {
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
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

            } else {
                user = groupTips.getOpUserInfo().getIdentifier();
            }
            String message = wrapperColor(user);
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
            if (tipsType == TIMGroupTipsType.SetAdmin) {
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                message = message + "被设置管理员";
            }
            if (tipsType == TIMGroupTipsType.CancelAdmin) {
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                message = message + "被取消管理员";
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
                    } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyOwner) {
                        msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                        message = message + "转让群主给\"" + modifyInfo.getContent() + "\"";
                    } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyFaceUrl) {
                        msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                        message = message + "修改群头像";
                    } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyIntroduction) {
                        msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                        message = message + "修改群介绍";
                    }
                }
            }
            if (tipsType == TIMGroupTipsType.ModifyMemberInfo) {
                List<TIMGroupTipsElemMemberInfo> modifyList = groupTips.getMemberInfoList();
                if (modifyList.size() > 0) {
                    long shutupTime = modifyList.get(0).getShutupTime();
                    if (shutupTime > 0) {
                        msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                        message = message + "被禁言\"" + DateTimeUtil.formatSeconds(shutupTime) + "\"";
                    } else {
                        msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                        message = message + "被取消禁言";
                    }
                }
            }
            if (TextUtils.isEmpty(message)) {
                return null;
            }
            msgInfo.setExtra(message);
        } else {
            if (type == TIMElemType.Text) {
                TIMTextElem txtEle = (TIMTextElem) ele;
                msgInfo.setExtra(txtEle.getText());
            } else if (type == TIMElemType.Face) {
                TIMFaceElem txtEle = (TIMFaceElem) ele;
                if (txtEle.getIndex() < 1 || txtEle.getData() == null) {
                    TUIKitLog.e("MessageInfoUtil", "txtEle data is null or index<1");
                    return null;
                }
                msgInfo.setExtra("[自定义表情]");


            } else if (type == TIMElemType.Sound) {
                TIMSoundElem soundElemEle = (TIMSoundElem) ele;
                if (msgInfo.isSelf()) {
                    msgInfo.setDataPath(soundElemEle.getPath());
                } else {
                    final String path = TUIKitConstants.RECORD_DOWNLOAD_DIR + soundElemEle.getUuid();
                    File file = new File(path);
                    if (!file.exists()) {
                        soundElemEle.getSoundToFile(path, new TIMCallBack() {
                            @Override
                            public void onError(int code, String desc) {
                                TUIKitLog.e("MessageInfoUtil getSoundToFile", code + ":" + desc);
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
                    msgInfo.setImgWidth(size[0]);
                    msgInfo.setImgHeight(size[1]);
                }
                //本地路径为空，可能为更换手机或者是接收的消息
                else {
                    List<TIMImage> imgs = imageEle.getImageList();
                    for (int i = 0; i < imgs.size(); i++) {
                        TIMImage img = imgs.get(i);
                        if (img.getType() == TIMImageType.Thumb) {
                            final String path = TUIKitConstants.IMAGE_DOWNLOAD_DIR + img.getUuid();
                            msgInfo.setImgWidth((int) img.getWidth());
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
                    msgInfo.setImgWidth(size[0]);
                    msgInfo.setImgHeight(size[1]);
                    msgInfo.setDataPath(videoEle.getSnapshotPath());
                    msgInfo.setDataUri(FileUtil.getUriFromPath(videoEle.getVideoPath()));
                } else {
                    TIMVideo video = videoEle.getVideoInfo();
                    final String videoPath = TUIKitConstants.VIDEO_DOWNLOAD_DIR + video.getUuid();
                    Uri uri = Uri.parse(videoPath);
                    msgInfo.setDataUri(uri);
                    TIMSnapshot snapshot = videoEle.getSnapshotInfo();
                    msgInfo.setImgWidth((int) snapshot.getWidth());
                    msgInfo.setImgHeight((int) snapshot.getHeight());
                    final String snapPath = TUIKitConstants.IMAGE_DOWNLOAD_DIR + snapshot.getUuid();
                    //判断快照是否存在,不存在自动下载
                    if (new File(snapPath).exists()) {
                        msgInfo.setDataPath(snapPath);
                    }
                }

                msgInfo.setExtra("[视频]");
            } else if (type == TIMElemType.File) {
                TIMFileElem fileElem = (TIMFileElem) ele;
                final String path = TUIKitConstants.FILE_DOWNLOAD_DIR + fileElem.getUuid();
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
                                TUIKitLog.e("MessageInfoUtil getToFile", code + ":" + desc);
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

        if (timMessage.status() == TIMMessageStatus.HasRevoked) {
            msgInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
            msgInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
            if (msgInfo.isSelf()) {
                msgInfo.setExtra("您撤回了一条消息");
            } else if (msgInfo.isGroup()) {
                String message = wrapperColor(msgInfo.getFromUser());
                msgInfo.setExtra(message + "撤回了一条消息");
            } else {
                msgInfo.setExtra("对方撤回了一条消息");
            }
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

    private static String wrapperColor(String raw) {
        return "\"<font color=\"#338BFF\">" + raw + "</font>\"";
    }

    private static int TIMElemType2MessageInfoType(TIMElemType type) {
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
}
