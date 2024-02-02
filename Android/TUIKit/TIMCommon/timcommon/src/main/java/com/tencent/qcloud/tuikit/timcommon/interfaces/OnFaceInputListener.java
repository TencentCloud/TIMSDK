package com.tencent.qcloud.tuikit.timcommon.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;

public interface OnFaceInputListener {

    void onEmojiClicked(String emojiKey);

    void onDeleteClicked();

    void onSendClicked();

    void onFaceClicked(ChatFace chatFace);
}
