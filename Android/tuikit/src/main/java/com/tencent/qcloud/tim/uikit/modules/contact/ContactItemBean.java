package com.tencent.qcloud.tim.uikit.modules.contact;

import android.text.TextUtils;

import com.tencent.imsdk.ext.group.TIMGroupBaseInfo;
import com.tencent.imsdk.friendship.TIMFriend;
import com.tencent.qcloud.tim.uikit.component.indexlib.IndexBar.bean.BaseIndexPinyinBean;

public class ContactItemBean extends BaseIndexPinyinBean {

    public static final String INDEX_STRING_TOP = "↑";
    private String id;
    private boolean isTop;//是否是最上面的 不需要被转化成拼音的
    private boolean isSelected;
    private boolean isBlackList;
    private String remark;
    private String nickname;
    private String avatarurl;
    private boolean isGroup;
    private boolean isFriend = true;
    private boolean isEnable = true;

    public ContactItemBean() {
    }

    public ContactItemBean(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public ContactItemBean setId(String id) {
        this.id = id;
        return this;
    }

    public boolean isTop() {
        return isTop;
    }

    public ContactItemBean setTop(boolean top) {
        isTop = top;
        return this;
    }

    @Override
    public String getTarget() {
        if (!TextUtils.isEmpty(remark)) {
            return remark;
        }
        if (!TextUtils.isEmpty(nickname)) {
            return nickname;
        }
        return id;
    }

    @Override
    public boolean isNeedToPinyin() {
        return !isTop;
    }

    @Override
    public boolean isShowSuspension() {
        return !isTop;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public boolean isEnable() {
        return isEnable;
    }

    public void setEnable(boolean enable) {
        isEnable = enable;
    }

    public boolean isBlackList() {
        return isBlackList;
    }

    public void setBlackList(boolean blacklist) {
        isBlackList = blacklist;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public ContactItemBean covertTIMFriend(TIMFriend friend) {
        if (friend == null) {
            return this;
        }
        setId(friend.getIdentifier());
        setRemark(friend.getRemark());
        setNickname(friend.getTimUserProfile().getNickName());
        setAvatarurl(friend.getTimUserProfile().getFaceUrl());
        return this;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public boolean isGroup() {
        return isGroup;
    }

    public void setGroup(boolean group) {
        isGroup = group;
    }

    public boolean isFriend() {
        return isFriend;
    }

    public String getAvatarurl() {
        return avatarurl;
    }

    public void setAvatarurl(String avatarurl) {
        this.avatarurl = avatarurl;
    }

    public void setFriend(boolean friend) {
        isFriend = friend;
    }

    public ContactItemBean covertTIMGroupBaseInfo(TIMGroupBaseInfo group) {
        if (group == null) {
            return this;
        }
        setId(group.getGroupId());
        setRemark(group.getGroupName());
        setAvatarurl(group.getFaceUrl());
        setGroup(true);
        return this;
    }
}
