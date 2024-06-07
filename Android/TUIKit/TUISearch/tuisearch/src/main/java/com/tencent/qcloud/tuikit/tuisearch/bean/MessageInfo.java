package com.tencent.qcloud.tuikit.tuisearch.bean;

import android.net.Uri;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuisearch.util.MessageInfoUtil;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchLog;
import java.io.Serializable;
import java.util.UUID;

public class MessageInfo implements Serializable {
    private static final String TAG = "MessageInfo";

    public static final int MSG_TYPE_MIME = 0x1;
    public static final int MSG_TYPE_TEXT = 0x00;
    public static final int MSG_TYPE_IMAGE = 0x20;
    public static final int MSG_TYPE_AUDIO = 0x30;
    public static final int MSG_TYPE_VIDEO = 0x40;
    public static final int MSG_TYPE_FILE = 0x50;
    public static final int MSG_TYPE_LOCATION = 0x60;
    public static final int MSG_TYPE_CUSTOM_FACE = 0x70;
    public static final int MSG_TYPE_CUSTOM = 0x80;
    public static final int MSG_TYPE_MERGE = 0x81;
    public static final int MSG_TYPE_TIPS = 0x100;
    public static final int MSG_TYPE_GROUP_CREATE = 0x101;
    public static final int MSG_TYPE_GROUP_DELETE = 0x102;
    public static final int MSG_TYPE_GROUP_JOIN = 0x103;
    public static final int MSG_TYPE_GROUP_QUITE = 0x104;
    public static final int MSG_TYPE_GROUP_KICK = 0x105;
    public static final int MSG_TYPE_GROUP_MODIFY_NAME = 0x106;
    public static final int MSG_TYPE_GROUP_MODIFY_NOTICE = 0x107;
    public static final int MSG_STATUS_READ = 0x111;
    public static final int MSG_STATUS_DELETE = 0x112;
    public static final int MSG_STATUS_REVOKE = 0x113;
    public static final int MSG_STATUS_NORMAL = 0;
    public static final int MSG_STATUS_SENDING = 1;
    public static final int MSG_STATUS_SEND_SUCCESS = 2;
    public static final int MSG_STATUS_SEND_FAIL = 3;
    public static final int MSG_STATUS_DOWNLOADING = 4;
    public static final int MSG_STATUS_UN_DOWNLOAD = 5;
    public static final int MSG_STATUS_DOWNLOADED = 6;

    private String id = UUID.randomUUID().toString();
    private long uniqueId = 0;
    private String fromUser;
    private String groupNameCard;
    private int msgType;
    private int status = MSG_STATUS_NORMAL;
    private boolean self;
    private boolean read;
    private boolean group;
    private String dataUri;
    private String dataPath;
    private Object extra;
    private long msgTime;
    private int imgWidth;
    private int imgHeight;
    private boolean peerRead;
    private boolean isIgnoreShow = false;
    private V2TIMMessage timMessage;

    private String nameCard;
    private String friendRemark;
    private String nickName;
    private String faceUrl;

    private String userId;
    private String groupId;
    private int downloadStatus;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    /**
     * Get message sender ID
     *
     * @return
     */
    public String getFromUser() {
        return fromUser;
    }

    /**
     * Set message sender ID
     *
     * @param fromUser
     */
    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }

    /**
     * Get Group NameCard
     *
     * @return
     */
    public String getGroupNameCard() {
        return groupNameCard;
    }

    /**
     * Set Group NameCard
     *
     * @param groupNameCard
     */
    public void setGroupNameCard(String groupNameCard) {
        this.groupNameCard = groupNameCard;
    }

    /**
     * Get message type
     *
     * @return
     */
    public int getMsgType() {
        return msgType;
    }

    /**
     * Set message type
     *
     * @param msgType
     */
    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }

    /**
     * Get Message Status
     *
     * @return
     */
    public int getStatus() {
        return status;
    }

    /**
     * Set Message Status
     *
     * @param status
     */
    public void setStatus(int status) {
        this.status = status;
    }

    public int getDownloadStatus() {
        return downloadStatus;
    }

    public void setDownloadStatus(int downloadStatus) {
        this.downloadStatus = downloadStatus;
    }

    /**
     * Get whether the message was sent for yourself
     *
     * @return
     */
    public boolean isSelf() {
        return self;
    }

    /**
     * Set whether the message was sent for yourself
     *
     * @param self
     */
    public void setSelf(boolean self) {
        this.self = self;
    }

    /**
     * Get whether the message is a group message
     *
     * @return
     */
    public boolean isGroup() {
        return group;
    }

    /**
     * Set whether the message is a group message
     *
     * @param group
     */
    public void setGroup(boolean group) {
        this.group = group;
    }

    /**
     * Set the data source of the multimedia message
     *
     * @param dataUri
     */
    public void setDataUri(Uri dataUri) {
        if (dataUri != null) {
            this.dataUri = dataUri.toString();
        }
    }

    /**
     * Set the save path of multimedia messages
     *
     * @param dataPath
     */
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    public V2TIMMessage getTimMessage() {
        return timMessage;
    }

    public void setTimMessage(V2TIMMessage timMessage) {
        this.timMessage = timMessage;
    }

    /**
     * Text description for non-text messages in the conversation list
     *
     * @return
     */
    public Object getExtra() {
        return extra;
    }

    /**
     * Set text description for non-text messages in the conversation list
     *
     * @param extra
     */
    public void setExtra(Object extra) {
        this.extra = extra;
    }

    public int getImgWidth() {
        return imgWidth;
    }

    public void setImgWidth(int imgWidth) {
        this.imgWidth = imgWidth;
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

    public boolean isPeerRead() {
        return peerRead;
    }

    public void setPeerRead(boolean peerRead) {
        this.peerRead = peerRead;
    }

    public void setIgnoreShow(boolean ignoreShow) {
        isIgnoreShow = ignoreShow;
    }

    public boolean getIsIgnoreShow() {
        return isIgnoreShow;
    }

    public String getNameCard() {
        return nameCard;
    }

    public void setNameCard(String nameCard) {
        this.nameCard = nameCard;
    }

    public String getFriendRemark() {
        return friendRemark;
    }

    public void setFriendRemark(String friendRemark) {
        this.friendRemark = friendRemark;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public String getUserId() {
        return userId;
    }

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getElemType() {
        if (timMessage != null) {
            return timMessage.getElemType();
        } else {
            return V2TIMMessage.V2TIM_ELEM_TYPE_NONE;
        }
    }

    public int getMessageInfoElemType() {
        return MessageInfoUtil.convertTIMElemType2MessageInfoType(getElemType());
    }

    public byte[] getCustomElemData() {
        if (timMessage != null) {
            return timMessage.getCustomElem().getData();
        } else {
            return new byte[0];
        }
    }
}
