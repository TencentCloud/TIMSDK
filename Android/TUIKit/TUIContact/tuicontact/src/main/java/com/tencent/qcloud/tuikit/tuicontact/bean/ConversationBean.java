package com.tencent.qcloud.tuikit.tuicontact.bean;

import android.os.Parcel;
import android.os.Parcelable;

public class ConversationBean implements Parcelable {
    private String conversationID;
    private int isGroup;
    private String title;

    public ConversationBean() {}

    public ConversationBean(String conversationID, int isGroup, String title) {
        this.conversationID = conversationID;
        this.isGroup = isGroup;
        this.title = title;
    }

    public String getConversationID() {
        return this.conversationID;
    }

    public void setConversationID(String conversationID) {
        this.conversationID = conversationID;
    }

    public int getIsGroup() {
        return this.isGroup;
    }

    public void setIsGroup(int isGroup) {
        this.isGroup = isGroup;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(conversationID);
        dest.writeInt(isGroup);
        dest.writeString(title);
    }

    public static final Creator<ConversationBean> CREATOR = new Creator<ConversationBean>() {
        @Override
        public ConversationBean createFromParcel(Parcel source) {
            return new ConversationBean(source.readString(), source.readInt(), source.readString());
        }

        @Override
        public ConversationBean[] newArray(int size) {
            return new ConversationBean[size];
        }
    };
}
