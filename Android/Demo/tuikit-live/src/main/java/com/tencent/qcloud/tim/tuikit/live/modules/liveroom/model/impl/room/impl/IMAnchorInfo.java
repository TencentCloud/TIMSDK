package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl;

public class IMAnchorInfo {
    public String userId;
    public String streamId;
//    public String avatar;
    public String name;

    public IMAnchorInfo() {
        clean();
    }

    public void clean() {
        userId = "";
        streamId = "";
//        avatar = "";
        name = "";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        IMAnchorInfo info = (IMAnchorInfo) o;
        return info.userId != null && this.userId != null && info.userId.equals(this.userId);
    }

    @Override
    public String toString() {
        return "IMAnchorInfo{" +
                "userId='" + userId + '\'' +
                ", streamId='" + streamId + '\'' +
//                ", avatar='" + avatar + '\'' +
                ", name='" + name + '\'' +
                '}';
    }
}
