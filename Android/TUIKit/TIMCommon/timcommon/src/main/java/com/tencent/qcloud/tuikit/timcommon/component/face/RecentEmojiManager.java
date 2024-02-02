package com.tencent.qcloud.tuikit.timcommon.component.face;

import android.text.TextUtils;
import android.util.Base64;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.List;

public class RecentEmojiManager {
    public static final String PREFERENCE_NAME = "recentFace";
    public static final int DEFAULT_RECENT_NUM = 10;
    private static final String DEFAULT_RECENT_EMOJI_KEY = "recentEmoji";

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

    public static void putCollection(List<String> emojiList) {
        getInstance().putCollection(DEFAULT_RECENT_EMOJI_KEY, emojiList);
    }

    public RecentEmojiManager putCollection(String key, List<String> emojiList) {
        try {
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
            objectOutputStream.writeObject(emojiList);
            String collectionString = new String(Base64.encode(byteArrayOutputStream.toByteArray(), Base64.DEFAULT));
            objectOutputStream.close();
            return putString(key, collectionString);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return this;
    }

    public List<String> getCollection(String key) {
        try {
            String collectionString = getString(key);
            if (TextUtils.isEmpty(collectionString) || TextUtils.isEmpty(collectionString.trim())) {
                return null;
            }
            byte[] mobileBytes = Base64.decode(collectionString.getBytes(), Base64.DEFAULT);
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(mobileBytes);
            ObjectInputStream objectInputStream = new ObjectInputStream(byteArrayInputStream);
            Object collectionObj = objectInputStream.readObject();
            List<String> collection = null;
            if (collectionObj instanceof List) {
                collection = (List<String>) collectionObj;
            }
            return collection;
        } catch (Exception e) {
            return null;
        }
    }

    public static List<String> getCollection() {
        return getInstance().getCollection(DEFAULT_RECENT_EMOJI_KEY);
    }

    public static void updateRecentUseEmoji(String emojiKey) {
        List<String> recentList = getCollection();
        recentList.remove(emojiKey);
        recentList.add(0, emojiKey);
        if (recentList.size() > DEFAULT_RECENT_NUM) {
            recentList.remove(recentList.size() - 1);
        }
        putCollection(recentList);
    }
}
