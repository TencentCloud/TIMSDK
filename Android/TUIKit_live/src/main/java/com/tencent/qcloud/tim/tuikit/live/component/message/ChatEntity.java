package com.tencent.qcloud.tim.tuikit.live.component.message;


/**
 * Module:   TCChatEntity
 * <p>
 * Function: 消息载体类。
 */
public class ChatEntity {
    private String grpSendName;    // 发送者的名字
    private String content;        // 消息内容
    private int    type;            // 消息类型

    public String getSenderName() {
        return grpSendName != null ? grpSendName : "";
    }

    public void setSenderName(String grpSendName) {
        this.grpSendName = grpSendName;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String context) {
        this.content = context;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    @Override
    public boolean equals(Object object) {
        if (this == object) return true;
        if (!(object instanceof ChatEntity)) return false;

        ChatEntity that = (ChatEntity) object;

        if (getType() != that.getType()) return false;
        if (grpSendName != null ? !grpSendName.equals(that.grpSendName) : that.grpSendName != null)
            return false;
        return getContent() != null ? getContent().equals(that.getContent()) : that.getContent() == null;

    }

    @Override
    public int hashCode() {
        int result = grpSendName != null ? grpSendName.hashCode() : 0;
        result = 31 * result + (getContent() != null ? getContent().hashCode() : 0);
        result = 31 * result + getType();
        return result;
    }
}
