package com.tencent.qcloud.tuikit.tuisearch.bean;

import android.os.Parcel;
import android.os.Parcelable;

import com.tencent.imsdk.v2.V2TIMMessage;

public class SearchDataBean implements Parcelable {
    private String title;
    private String subTitle;
    private String subTitleLabel = "";
    private String iconPath;
    private int type;
    private int isSubTextMatch;

    private String userID;
    private String nickName;
    private String remark;

    private String groupID;
    private String groupName;
    private String groupType;
    private boolean isGroup;

    private String conversationID;

    private V2TIMMessage locateTimMessage;

    public SearchDataBean(){}


    protected SearchDataBean(Parcel in) {
        title = in.readString();
        subTitle = in.readString();
        iconPath = in.readString();
        type = in.readInt();
        isSubTextMatch = in.readInt();
        userID = in.readString();
        nickName = in.readString();
        remark = in.readString();
        groupID = in.readString();
        groupName = in.readString();
        groupType = in.readString();
        isGroup = in.readByte() != 0;
        conversationID = in.readString();
        locateTimMessage = (V2TIMMessage) in.readSerializable();
    }

    public static final Creator<SearchDataBean> CREATOR = new Creator<SearchDataBean>() {
        @Override
        public SearchDataBean createFromParcel(Parcel in) {
            return new SearchDataBean(in);
        }

        @Override
        public SearchDataBean[] newArray(int size) {
            return new SearchDataBean[size];
        }
    };

    public String getSubTitle() {
        return this.subTitle;
    }

    public void setSubTitle(String subTitle) {
        this.subTitle = subTitle;
    }

    public void setSubTitleLabel(String subTitleLabel) {
        this.subTitleLabel = subTitleLabel;
    }

    public String getSubTitleLabel() {
        return subTitleLabel;
    }

    public String getIconPath()
    {
        return this.iconPath;
    }

    public void setIconPath(String iconPath)
    {
        this.iconPath = iconPath;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getUserID() {
        return userID;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickname) {
        this.nickName = nickname;
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

    public String getGroupID() {
        return groupID;
    }

    public void setGroupID(String groupID) {
        this.groupID = groupID;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    public int getIsSubTextMatch() {
        return isSubTextMatch;
    }

    public void setSubTextMatch(int isSubTextMatch) {
        this.isSubTextMatch = isSubTextMatch;
    }

    public String getConversationID() {
        return conversationID;
    }

    public void setConversationID(String conversationID) {
        this.conversationID = conversationID;
    }

    public V2TIMMessage getLocateTimMessage() {
        return locateTimMessage;
    }

    public void setLocateTimMessage(V2TIMMessage locateTimMessage) {
        this.locateTimMessage = locateTimMessage;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(title);
        dest.writeString(subTitle);
        dest.writeString(iconPath);
        dest.writeInt(type);
        dest.writeInt(isSubTextMatch);
        dest.writeString(userID);
        dest.writeString(nickName);
        dest.writeString(remark);
        dest.writeString(groupID);
        dest.writeString(groupName);
        dest.writeString(groupType);
        dest.writeByte((byte) (isGroup ? 1 : 0));
        dest.writeString(conversationID);
        dest.writeSerializable(locateTimMessage);
    }
}
