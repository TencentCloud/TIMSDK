package com.tencent.qcloud.tim.uikit.component.face;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Collection;


//SharedPerferences工具

public class RecentEmojiManager {
    public static final String PREFERENCE_NAME = "recentFace";//"preference";

    private SharedPreferences mPreferences;
    private SharedPreferences.Editor mEditor;

    private RecentEmojiManager(Context context) {
        mPreferences = context.getSharedPreferences(RecentEmojiManager.PREFERENCE_NAME, Context.MODE_PRIVATE);
        mEditor = mPreferences.edit();
    }

    public static RecentEmojiManager make(Context context) {
        return new RecentEmojiManager(context);
    }


    public String getString(String key) {
        return mPreferences.getString(key, "");
    }

    public RecentEmojiManager putString(String key, String value) {
        mEditor.putString(key, value).apply();
        return this;
    }


    public RecentEmojiManager putCollection(String key, Collection collection) throws IOException {
        // 实例化一个ByteArrayOutputStream对象，用来装载压缩后的字节文件。
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        // 然后将得到的字符数据装载到ObjectOutputStream
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        // writeObject 方法负责写入特定类的对象的状态，以便相应的 readObject 方法可以还原它
        objectOutputStream.writeObject(collection);
        // 最后，用Base64.encode将字节文件转换成Base64编码保存在String中
        String collectionString = new String(Base64.encode(byteArrayOutputStream.toByteArray(), Base64.DEFAULT));
        // 关闭objectOutputStream
        objectOutputStream.close();
        return putString(key, collectionString);
    }

    public Collection getCollection(String key) throws IOException, ClassNotFoundException {
        String collectionString = getString(key);
        if (TextUtils.isEmpty(collectionString) || TextUtils.isEmpty(collectionString.trim())) {
            return null;
        }
        byte[] mobileBytes = Base64.decode(collectionString.getBytes(), Base64.DEFAULT);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(mobileBytes);
        ObjectInputStream objectInputStream = new ObjectInputStream(byteArrayInputStream);
        Collection collection = (Collection) objectInputStream.readObject();
        objectInputStream.close();
        return collection;
    }
}
