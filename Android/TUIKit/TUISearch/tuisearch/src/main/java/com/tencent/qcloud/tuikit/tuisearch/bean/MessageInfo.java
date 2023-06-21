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

    public long getUniqueId() {
        return uniqueId;
    }

    public void setUniqueId(long uniqueId) {
        this.uniqueId = uniqueId;
    }

    /**
     * 获取消息发送方 ID
     *
     * Get message sender ID
     *
     * @return
     */
    public String getFromUser() {
        return fromUser;
    }

    /**
     * 设置消息发送方 ID
     *
     * Set message sender ID
     *
     * @param fromUser
     */
    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }

    /**
     * 获取群名片
     *
     * Get Group NameCard
     *
     * @return
     */
    public String getGroupNameCard() {
        return groupNameCard;
    }

    /**
     * 设置群名片
     *
     * Set Group NameCard
     *
     * @param groupNameCard
     */
    public void setGroupNameCard(String groupNameCard) {
        this.groupNameCard = groupNameCard;
    }

    /**
     * 获取消息类型
     *
     * Get message type
     *
     * @return
     */
    public int getMsgType() {
        return msgType;
    }

    /**
     * 设置消息类型
     *
     * Set message type
     *
     * @param msgType
     */
    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }

    /**
     * 获取消息发送状态
     *
     * Get Message Status
     *
     * @return
     */
    public int getStatus() {
        return status;
    }

    /**
     * 设置消息发送状态
     *
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
     * 获取消息是否为登录用户发送
     *
     * Get whether the message was sent for yourself
     *
     * @return
     */
    public boolean isSelf() {
        return self;
    }

    /**
     * 设置消息是否是登录用户发送
     *
     * Set whether the message was sent for yourself
     *
     * @param self
     */
    public void setSelf(boolean self) {
        this.self = self;
    }

    /**
     * 获取消息是否已读
     *
     * Get whether the message has been read
     *
     * @return
     */
    public boolean isRead() {
        return read;
    }

    /**
     * 设置消息已读
     *
     * Set whether the message has been read
     *
     * @param read
     */
    public void setRead(boolean read) {
        this.read = read;
    }

    /**
     * 获取消息是否为群消息
     *
     * Get whether the message is a group message
     *
     * @return
     */
    public boolean isGroup() {
        return group;
    }

    /**
     * 设置消息是否为群消息
     *
     * Set whether the message is a group message
     *
     * @param group
     */
    public void setGroup(boolean group) {
        this.group = group;
    }

    /**
     * 获取多媒体消息的数据源
     *
     * Get the data source of the multimedia message
     *
     * @return
     */
    public String getDataUri() {
        return dataUri;
    }

    /**
     * 获取多媒体消息的数据源
     *
     * Get the data source of the multimedia message
     *
     * @return
     */
    public Uri getDataUriObj() {
        if (!TextUtils.isEmpty(dataUri)) {
            return Uri.parse(dataUri);
        } else {
            return null;
        }
    }

    /**
     * 设置多媒体消息的数据源
     *
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
     * 设置多媒体消息的数据源
     *
     * Set the data source of the multimedia message
     *
     * @param dataUri
     */
    public void setDataUri(String dataUri) {
        this.dataUri = dataUri;
    }

    /**
     * 获取多媒体消息的保存路径
     *
     * Get the save path of multimedia messages
     *
     * @return
     */
    public String getDataPath() {
        return dataPath;
    }

    /**
     * 设置多媒体消息的保存路径
     *
     * Set the save path of multimedia messages
     *
     * @param dataPath
     */
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    public int getCustomInt() {
        if (timMessage == null) {
            return 0;
        }
        return timMessage.getLocalCustomInt();
    }

    public void setCustomInt(int value) {
        if (timMessage == null) {
            return;
        }
        timMessage.setLocalCustomInt(value);
    }

    public boolean checkEquals(String msgID) {
        if (TextUtils.isEmpty(msgID)) {
            return false;
        }
        return timMessage.getMsgID().equals(msgID);
    }

    public boolean remove() {
        if (timMessage == null) {
            return false;
        }
        V2TIMManager.getMessageManager().deleteMessageFromLocalStorage(timMessage, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUISearchLog.e(TAG, "deleteMessageFromLocalStorage error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {}
        });
        return true;
    }

    public V2TIMMessage getTimMessage() {
        return timMessage;
    }

    public void setTimMessage(V2TIMMessage timMessage) {
        this.timMessage = timMessage;
    }

    /**
     * 非文字消息在会话列表时展示的文字说明，比如照片在会话列表展示为“[图片]”
     *
     * Text description for non-text messages in the conversation list
     *
     * @return
     */
    public Object getExtra() {
        return extra;
    }

    /**
     * 设置非文字消息在会话列表时展示的文字说明，比如照片在会话列表展示为“[图片]”
     *
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
