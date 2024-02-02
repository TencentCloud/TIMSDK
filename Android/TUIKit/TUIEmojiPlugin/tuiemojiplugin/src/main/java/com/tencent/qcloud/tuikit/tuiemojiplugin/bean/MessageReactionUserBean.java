package com.tencent.qcloud.tuikit.tuiemojiplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;

import java.util.List;

public class MessageReactionUserBean {
    private List<UserBean> userBeanList;
    private int nextSeq;
    private boolean isFinished;

    public void setUserBeanList(List<UserBean> userBeanList) {
        this.userBeanList = userBeanList;
    }

    public List<UserBean> getUserBeanList() {
        return userBeanList;
    }

    public void setFinished(boolean finished) {
        isFinished = finished;
    }

    public boolean isFinished() {
        return isFinished;
    }

    public void setNextSeq(int nextSeq) {
        this.nextSeq = nextSeq;
    }

    public int getNextSeq() {
        return nextSeq;
    }
}
