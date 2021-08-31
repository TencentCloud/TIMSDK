package com.tencent.qcloud.tim.uikit.modules.forward.base;

import android.os.Parcel;
import android.os.Parcelable;

public class ConversationBean implements Parcelable {
    private String conversationID;
    private int isGroup;
    private String title;

    public ConversationBean()
    {}

    public ConversationBean(String conversationID, int isGroup, String title)
    {
        this.conversationID = conversationID;
        this.isGroup = isGroup;
        this.title = title;
    }
    public String getConversationID()
    {
        return this.conversationID;
    }

    public void setConversationID(String conversationID)
    {
        this.conversationID = conversationID;
    }

    public int getIsGroup()
    {
        return this.isGroup;
    }

    public void setIsGroup(int isGroup)
    {
        this.isGroup = isGroup;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    @Override public int describeContents() {

        return 0;
    }
    //2、实现Parcelable接口的public void writeToParcel(Parcel dest, int flags)方法
    //通常进行重写
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        //把数据写入Parcel
        dest.writeString(conversationID);
        dest.writeInt(isGroup);
        dest.writeString(title);
    }
    //3、自定义类型中必须含有一个名称为CREATOR的静态成员，该成员对象要求实现Parcelable.Creator接口及其方法
    public static final Parcelable.Creator<ConversationBean> CREATOR = new Parcelable.Creator<ConversationBean>() {
        @Override
        public ConversationBean createFromParcel(Parcel source) {
            //从Parcel中读取数据
            //此处read顺序依据write顺序
            return new ConversationBean(source.readString(), source.readInt(),source.readString());
        }
        @Override
        public ConversationBean[] newArray(int size) {

            return new ConversationBean[size];
        }

    };
}
