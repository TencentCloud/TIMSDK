package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.store;

import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.DefaultEmojiResource;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service.IEmojiResource;
import com.trtc.tuikit.common.livedata.LiveData;

import java.util.ArrayList;

public class FloatChatStore {
    private static FloatChatStore sInstance;

    public LiveData<TUIFloatChat> mSendBarrage = new LiveData<>();

    public final IEmojiResource          mEmojiResource;
    public       ArrayList<TUIFloatChat> mRecordedMessage;

    public static FloatChatStore sharedInstance() {
        if (sInstance == null) {
            synchronized (FloatChatStore.class) {
                if (sInstance == null) {
                    sInstance = new FloatChatStore();
                }
            }
        }
        return sInstance;
    }

    private FloatChatStore() {
        mEmojiResource = new DefaultEmojiResource();
        mRecordedMessage = new ArrayList<>();
    }

    public void destroyInstance() {
        sInstance = null;
    }
}
