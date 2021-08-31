package com.tencent.liteav.login;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String phone;
    public String userId;
    public String userSig;
    public String userName;
    public String userAvatar;

    @java.lang.Override
    public java.lang.String toString() {
        return "UserModel{" +
                "phone='" + phone + '\'' +
                ", userId='" + userId + '\'' +
                ", userSig='" + userSig + '\'' +
                ", userName='" + userName + '\'' +
                ", userAvatar='" + userAvatar + '\'' +
                '}';
    }
}
