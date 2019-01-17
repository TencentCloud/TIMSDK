package com.tencent.qcloud.uikit.business.chat.model;

import android.net.Uri;

import com.tencent.imsdk.TIMMessage;

import java.util.UUID;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class MessageInfo {
    /**
     * 文本类型消息
     */
    public static final int MSG_TYPE_TEXT = 0x00;
    /**
     * 图片类型消息
     */
    public static final int MSG_TYPE_IMAGE = 0x20;
    /**
     * 语音类型消息
     */
    public static final int MSG_TYPE_AUDIO = 0x30;
    /**
     * 视频类型消息
     */
    public static final int MSG_TYPE_VIDEO = 0x40;
    /**
     * 文件类型消息
     */
    public static final int MSG_TYPE_FILE = 0x50;
    /**
     * 位置类型消息
     */
    public static final int MSG_TYPE_LOCATION = 0x60;

    /**
     * 自定义图片类型消息
     */
    public static final int MSG_TYPE_CUSTOM_FACE = 0x70;

    /**
     * 提示类信息
     */
    public static final int MSG_TYPE_TIPS = 0x100;
    /**
     * 群创建提示消息
     */
    public static final int MSG_TYPE_GROUP_CREATE = 0x101;
    /**
     * 群创建提示消息
     */
    public static final int MSG_TYPE_GROUP_DELETE = 0x102;
    /**
     * 群成员加入提示消息
     */
    public static final int MSG_TYPE_GROUP_JOIN = 0x103;
    /**
     * 群成员退群提示消息
     */
    public static final int MSG_TYPE_GROUP_QUITE = 0x104;
    /**
     * 群成员被踢出群提示消息
     */
    public static final int MSG_TYPE_GROUP_KICK = 0x105;
    /**
     * 群名称修改提示消息
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NAME = 0x106;
    /**
     * 群通知更新提示消息
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NOTICE = 0x107;

    /**
     * 消息未读状态
     */
    public static final int MSG_STATUS_READ = 0x111;
    /**
     * 消息删除状态
     */
    public static final int MSG_STATUS_DELETE = 0x112;
    /**
     * 消息撤回状态
     */
    public static final int MSG_STATUS_REVOKE = 0x113;
    /**
     * 消息正常状态
     */
    public static final int MSG_STATUS_NORMAL = 0;
    /**
     * 消息发送中状态
     */
    public static final int MSG_STATUS_SENDING = 1;
    /**
     * 消息发送成功状态
     */
    public static final int MSG_STATUS_SEND_SUCCESS = 2;
    /**
     * 消息发送失败状态
     */
    public static final int MSG_STATUS_SEND_FAIL = 3;
    /**
     * 消息内容下载中状态
     */
    public static final int MSG_STATUS_DOWNLOADING = 4;
    /**
     * 消息内容未下载状态
     */
    public static final int MSG_STATUS_UN_DOWNLOAD = 5;
    /**
     * 消息内容已下载状态
     */
    public static final int MSG_STATUS_DOWNLOADED = 6;


    private String peer;
    private String msgId = UUID.randomUUID().toString();
    private String fromUser;
    private int msgType;
    private int status = MSG_STATUS_NORMAL;
    private boolean self;
    private boolean read;
    private boolean group;
    private Uri dataUri;
    private String dataPath;
    private Object extra;
    private long msgTime;
    private int imgWithd;
    private int imgHeight;

    private TIMMessage TIMMessage;

    public String getPeer() {
        return peer;
    }

    public void setPeer(String peer) {
        this.peer = peer;
    }

    public String getMsgId() {
        return msgId;
    }

    public void setMsgId(String msgId) {
        this.msgId = msgId;
    }

    public String getFromUser() {
        return fromUser;
    }

    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }

    public int getMsgType() {
        return msgType;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }


    public boolean isSelf() {
        return self;
    }

    public void setSelf(boolean self) {
        this.self = self;
    }


    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }


    public boolean isGroup() {
        return group;
    }

    public void setGroup(boolean group) {
        this.group = group;
    }


    public Uri getDataUri() {
        return dataUri;
    }

    public void setDataUri(Uri dataUri) {
        this.dataUri = dataUri;
    }

    public String getDataPath() {
        return dataPath;
    }

    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    public TIMMessage getTIMMessage() {
        return TIMMessage;
    }

    public void setTIMMessage(TIMMessage TIMMessage) {
        this.TIMMessage = TIMMessage;
    }

    public Object getExtra() {
        return extra;
    }

    public void setExtra(Object extra) {
        this.extra = extra;
    }


    public int getImgWithd() {
        return imgWithd;
    }

    public void setImgWithd(int imgWithd) {
        this.imgWithd = imgWithd;
    }

    public int getImgHeight() {
        return imgHeight;
    }

    public void setImgHeight(int imgHeight) {
        this.imgHeight = imgHeight;
    }

    public long getMsgTime() {
        return msgTime;
    }

    public void setMsgTime(long msgTime) {
        this.msgTime = msgTime;
    }


    public boolean isSame(MessageInfo other) {
        if (TIMMessage != null && other.TIMMessage != null) {
            if (TIMMessage.getMsgId().equals(other.TIMMessage.getMsgId())) {
                return true;
            } else {
                return TIMMessage.timestamp() == other.TIMMessage.timestamp();
            }
        }

        return false;
    }
}
