package com.tencent.qcloud.tuikit.timcommon.bean;

import java.io.Serializable;

/*
 *  Carrying function macros through messages，Mainly used to be compatible with old and new versions，Use the cloudCustomData field.
 *  Such as Typing function.
 */
public class MessageFeature implements Serializable {
    public static final int VERSION = 1;

    private int needTyping = 1; // message typing feature ...
    private int version = VERSION;

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public int getNeedTyping() {
        return needTyping;
    }

    public void setNeedTyping(int needTyping) {
        this.needTyping = needTyping;
    }
}
