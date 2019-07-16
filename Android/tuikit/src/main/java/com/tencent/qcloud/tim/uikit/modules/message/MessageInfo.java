package com.tencent.qcloud.tim.uikit.modules.message;

import android.net.Uri;

import com.tencent.imsdk.TIMMessage;

import java.util.UUID;


public class MessageInfo {

    public static final int MSG_TYPE_MIME = 0x1;

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
     * 自定义消息
     */
    public static final int MSG_TYPE_CUSTOM = 0x80;

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

    private String id = UUID.randomUUID().toString();
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

    /**
     * 获取消息唯一标识
     *
     * @return
     */
    public String getId() {
        return id;
    }

    /**
     * 设置消息唯一标识
     *
     * @param id
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * 获取消息发送方
     *
     * @return
     */
    public String getFromUser() {
        return fromUser;
    }

    /**
     * 设置消息发送方
     *
     * @param fromUser
     */
    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }

    /**
     * 获取消息类型
     *
     * @return
     */
    public int getMsgType() {
        return msgType;
    }

    /**
     * 获取消息发送状态
     *
     * @return
     */
    public int getStatus() {
        return status;
    }

    /**
     * 设置消息发送状态
     *
     * @param status
     */
    public void setStatus(int status) {
        this.status = status;
    }

    /**
     * 设置消息类型
     *
     * @param msgType
     */
    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }

    /**
     * 获取消息是否为登录用户发送
     *
     * @return
     */
    public boolean isSelf() {
        return self;
    }

    /**
     * 设置消息是否是登录用户发送
     *
     * @param self
     */
    public void setSelf(boolean self) {
        this.self = self;
    }

    /**
     * 获取消息是否已读
     *
     * @return
     */
    public boolean isRead() {
        return read;
    }

    /**
     * 设置消息已读
     *
     * @param read
     */
    public void setRead(boolean read) {
        this.read = read;
    }

    /**
     * 获取消息是否为群消息
     *
     * @return
     */
    public boolean isGroup() {
        return group;
    }

    /**
     * 设置消息是否为群消息
     *
     * @param group
     */
    public void setGroup(boolean group) {
        this.group = group;
    }

    /**
     * 获取多媒体消息的数据源
     *
     * @return
     */
    public Uri getDataUri() {
        return dataUri;
    }

    /**
     * 设置多媒体消息的数据源
     *
     * @param dataUri
     */
    public void setDataUri(Uri dataUri) {
        this.dataUri = dataUri;
    }

    /**
     * 获取多媒体消息的保存路径
     *
     * @return
     */
    public String getDataPath() {
        return dataPath;
    }

    /**
     * 设置多媒体消息的保存路径
     *
     * @param dataPath
     */
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    /**
     * 获取SDK的消息bean
     *
     * @return
     */
    public TIMMessage getTIMMessage() {
        return TIMMessage;
    }

    /**
     * 设置SDK的消息bean
     *
     * @param TIMMessage
     */
    public void setTIMMessage(TIMMessage TIMMessage) {
        this.TIMMessage = TIMMessage;
    }

    /**
     * 非文字消息在会话列表时展示的文字说明，比如照片在会话列表展示为“[图片]”
     *
     * @return
     */
    public Object getExtra() {
        return extra;
    }

    /**
     * 设置非文字消息在会话列表时展示的文字说明，比如照片在会话列表展示为“[图片]”
     *
     * @param extra
     */
    public void setExtra(Object extra) {
        this.extra = extra;
    }

    /**
     * 获取图片或者视频缩略图的图片宽
     *
     * @return
     */
    public int getImgWidth() {
        return imgWithd;
    }

    /**
     * 设置图片或者视频缩略图的图片宽
     *
     * @param imgWidth
     */
    public void setImgWidth(int imgWidth) {
        this.imgWithd = imgWidth;
    }

    /**
     * 获取图片或者视频缩略图的图片高
     *
     * @return
     */
    public int getImgHeight() {
        return imgHeight;
    }

    /**
     * 设置图片或者视频缩略图的图片高
     *
     * @param imgHeight
     */
    public void setImgHeight(int imgHeight) {
        this.imgHeight = imgHeight;
    }

    /**
     * 获取消息发送时间
     *
     * @return
     */
    public long getMsgTime() {
        return msgTime;
    }

    /**
     * 设置消息发送时间
     *
     * @param msgTime
     */
    public void setMsgTime(long msgTime) {
        this.msgTime = msgTime;
    }

}
