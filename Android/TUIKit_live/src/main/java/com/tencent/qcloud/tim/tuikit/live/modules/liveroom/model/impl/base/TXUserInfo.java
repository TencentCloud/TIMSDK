package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

public class TXUserInfo {
    public String userId;
    public String userName;
    public String avatarURL;

    @Override
    public String toString() {
        return "TXUserInfo{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", avatarURL='" + avatarURL + '\'' +
                '}';
    }
}
