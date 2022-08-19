package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.text.TextUtils;
import android.util.Base64;

import com.tencent.qcloud.tuicore.util.SPUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Collection;


public class RecentEmojiManager {
    public static final String PREFERENCE_NAME = "recentFace";//"preference";

    private static final RecentEmojiManager instance = new RecentEmojiManager();

    private RecentEmojiManager() {}

    public static RecentEmojiManager getInstance() {
        return instance;
    }

    public String getString(String key) {
        return SPUtils.getInstance(PREFERENCE_NAME).getString(key);
    }

    public RecentEmojiManager putString(String key, String value) {
        SPUtils.getInstance(PREFERENCE_NAME).put(key, value);
        return this;
    }


    public RecentEmojiManager putCollection(String key, Collection collection) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(collection);
        String collectionString = new String(Base64.encode(byteArrayOutputStream.toByteArray(), Base64.DEFAULT));
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
