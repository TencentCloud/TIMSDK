package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu;

import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;

import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;

import java.lang.ref.WeakReference;
import java.util.List;

public class ChatPopDataHolder {
    private static final ChatPopDataHolder instance = new ChatPopDataHolder();

    private ChatPopDataHolder() {}

    private WeakReference<ChatPopActivity.EmojiOnClickListener> emojiOnClickListener;

    private WeakReference<Bitmap> chatPopBgBitmap;
    private WeakReference<List<ChatPopActivity.ChatPopMenuAction>> actionList;
    private WeakReference<Drawable> msgAreaBackground;
    private WeakReference<RoundCornerImageView> imageMessageView;
    private Rect messageViewGlobalRect;

    public static void setActionList(List<ChatPopActivity.ChatPopMenuAction> actionList) {
        instance.actionList = new WeakReference<>(actionList);
    }

    public static void setChatPopBgBitmap(Bitmap chatPopBgBitmap) {
        instance.chatPopBgBitmap = new WeakReference<>(chatPopBgBitmap);
    }

    public static Bitmap getChatPopBgBitmap() {
        if (instance.chatPopBgBitmap == null) {
            return null;
        }
        return instance.chatPopBgBitmap.get();
    }

    public static List<ChatPopActivity.ChatPopMenuAction> getActionList() {
        if (instance.actionList == null) {
            return null;
        }
        return instance.actionList.get();
    }

    public static void setEmojiOnClickListener(ChatPopActivity.EmojiOnClickListener emojiOnClickListener) {
        instance.emojiOnClickListener = new WeakReference<>(emojiOnClickListener);
    }

    public static ChatPopActivity.EmojiOnClickListener getEmojiOnClickListener() {
        if (instance.emojiOnClickListener != null) {
            return instance.emojiOnClickListener.get();
        } else {
            return null;
        }
    }

    public static void setMsgAreaBackground(Drawable msgAreaBackground) {
        instance.msgAreaBackground = new WeakReference<>(msgAreaBackground);
    }

    public static Drawable getMsgAreaBackground() {
        if (instance.msgAreaBackground == null) {
            return null;
        }
        return instance.msgAreaBackground.get();
    }

    public static void setImageMessageView(RoundCornerImageView imageMessageView) {
        instance.imageMessageView = new WeakReference<>(imageMessageView);
    }

    public static RoundCornerImageView getImageMessageView() {
        if (instance.imageMessageView == null) {
            return null;
        }
        return instance.imageMessageView.get();
    }

    public static void setMessageViewGlobalRect(Rect messageViewGlobalRect) {
        instance.messageViewGlobalRect = messageViewGlobalRect;
    }

    public static Rect getMessageViewGlobalRect() {
        return instance.messageViewGlobalRect;
    }
}
