package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ChatInfo implements Serializable {
    public static final int TYPE_C2C = V2TIMConversation.V2TIM_C2C;
    public static final int TYPE_GROUP = V2TIMConversation.V2TIM_GROUP;
    public static final int TYPE_INVALID = V2TIMConversation.CONVERSATION_TYPE_INVALID;

    private static List<V2TIMGroupAtInfo> atInfoList;

    protected String chatName;
    // other's face url
    protected String faceUrl;
    private List<Object> iconUrlList = new ArrayList<>();
    private int type = V2TIMConversation.V2TIM_C2C;
    private String id;
    private String groupType;
    private boolean isTopChat;
    private TUIMessageBean locateMessage;
    boolean enableAudioCall = true;
    boolean enableVideoCall = true;
    boolean enableRoom = true;
    boolean enableCustomHelloMessage = true;
    boolean enablePoll = true;
    boolean enableGroupNote = true;
    private boolean enableTakePhoto = true;
    private boolean enableRecordVideo = true;
    private boolean enableFile = true;
    private boolean enableAlbum = true;
    boolean needReadReceipt = true;
    private DraftInfo draft;


    public ChatInfo() {}

    /**
     *
     * Get the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @return
     */
    public String getChatName() {
        return chatName;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    /**
     *
     * Set the title of the chat, usually the name of the other party for a single chat, and the group name for a group chat
     *
     * @param chatName
     */
    public void setChatName(String chatName) {
        this.chatName = chatName;
    }

    /**
     *
     * Get the chat type, C2C is a single chat, Group is a group chat
     *
     * @return
     */
    public int getType() {
        return type;
    }

    /**
     *
     * Set the chat type, C2C is a single chat, Group is a group chat
     *
     * @param type
     */
    public void setType(int type) {
        this.type = type;
    }

    /**
     *
     * get chat id
     *
     * @return
     */
    public String getId() {
        return id;
    }

    /**
     *
     * set chat id
     *
     * @param id
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     *
     * get group type
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     *
     * set group type
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     *
     * Is it a pinned conversation
     *
     * @return
     */
    public boolean isTopChat() {
        return isTopChat;
    }

    /**
     *
     * Set whether the conversation is sticky
     *
     * @param topChat
     */
    public void setTopChat(boolean topChat) {
        isTopChat = topChat;
    }

    public List<V2TIMGroupAtInfo> getAtInfoList() {
        return atInfoList;
    }

    public void setAtInfoList(List<V2TIMGroupAtInfo> atInfoList) {
        this.atInfoList = atInfoList;
    }

    public void setLocateMessage(TUIMessageBean locateMessage) {
        this.locateMessage = locateMessage;
    }

    public TUIMessageBean getLocateMessage() {
        return locateMessage;
    }

    public void setDraft(DraftInfo draft) {
        this.draft = draft;
    }

    public DraftInfo getDraft() {
        return this.draft;
    }

    public List<Object> getIconUrlList() {
        return iconUrlList;
    }

    public void setIconUrlList(List<Object> iconUrlList) {
        this.iconUrlList = iconUrlList;
    }

    public boolean isEnableAudioCall() {
        return enableAudioCall;
    }

    public void setEnableAudioCall(boolean enableAudioCall) {
        this.enableAudioCall = enableAudioCall;
    }

    public boolean isEnableRoom() {
        return enableRoom;
    }

    public void setEnableRoom(boolean enableRoom) {
        this.enableRoom = enableRoom;
    }

    public boolean isEnableVideoCall() {
        return enableVideoCall;
    }

    public void setEnableVideoCall(boolean enableVideoCall) {
        this.enableVideoCall = enableVideoCall;
    }

    public boolean isEnableCustomHelloMessage() {
        return enableCustomHelloMessage;
    }

    public void setEnableCustomHelloMessage(boolean enableCustomHelloMessage) {
        this.enableCustomHelloMessage = enableCustomHelloMessage;
    }

    public void setEnablePoll(boolean enablePoll) {
        this.enablePoll = enablePoll;
    }

    public boolean isEnablePoll() {
        return enablePoll;
    }

    public void setEnableGroupNote(boolean enableGroupNote) {
        this.enableGroupNote = enableGroupNote;
    }

    public boolean isEnableGroupNote() {
        return enableGroupNote;
    }

    public void setEnableRecordVideo(boolean enableRecordVideo) {
        this.enableRecordVideo = enableRecordVideo;
    }

    public boolean isEnableRecordVideo() {
        return enableRecordVideo;
    }

    public void setEnableTakePhoto(boolean enableTakePhoto) {
        this.enableTakePhoto = enableTakePhoto;
    }

    public boolean isEnableTakePhoto() {
        return enableTakePhoto;
    }

    public void setEnableAlbum(boolean enableAlbum) {
        this.enableAlbum = enableAlbum;
    }

    public boolean isEnableAlbum() {
        return enableAlbum;
    }

    public void setEnableFile(boolean enableFile) {
        this.enableFile = enableFile;
    }

    public boolean isEnableFile() {
        return enableFile;
    }

    public boolean isNeedReadReceipt() {
        return needReadReceipt;
    }

    public void setNeedReadReceipt(boolean needReadReceipt) {
        this.needReadReceipt = needReadReceipt;
    }
}
