package com.tencent.qcloud.tuikit.tuiemojiplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;

import java.util.List;

public class ReactionBean {
    private String reactionID;
    private int totalUserCount;
    private boolean isByMySelf;
    private List<UserBean> partialUserList;

    public void setByMySelf(boolean byMySelf) {
        isByMySelf = byMySelf;
    }

    public void setReactionID(String reactionID) {
        this.reactionID = reactionID;
    }

    public void setPartialUserList(List<UserBean> partialUserList) {
        this.partialUserList = partialUserList;
    }

    public void setTotalUserCount(int totalUserCount) {
        this.totalUserCount = totalUserCount;
    }

    public int getTotalUserCount() {
        return totalUserCount;
    }

    public List<UserBean> getPartialUserList() {
        return partialUserList;
    }

    public String getReactionID() {
        return reactionID;
    }

    public boolean isByMySelf() {
        return isByMySelf;
    }
}
