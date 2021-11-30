package com.tencent.liteav.trtccalling.model.impl;

public class UserModel {
    public String userId;
    public String userAvatar;
    public String userName;

    @Override
    public String toString() {
        return "UserModel{"
                + "userId= '" + userId + '\''
                + ", userAvatar= '" + userAvatar + '\''
                + ", userName= '" + userName + '\''
                + '}';
    }
}
