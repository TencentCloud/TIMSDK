package com.tencent.qcloud.tuikit.timcommon.util;

import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;

public class FaceUtil {
    public static void handlerEmojiText(TextView textView, CharSequence charSequence) {
        FaceManager.handlerEmojiText(textView, charSequence, false);
    }

    public static void handlerEmojiText(TextView textView, CharSequence charSequence, boolean needSetSelection) {
        FaceManager.handlerEmojiText(textView, charSequence, needSetSelection);
    }

    public static String emojiJudge(String text) {
        return FaceManager.emojiJudge(text);
    }
}
