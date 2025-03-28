package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;

import java.util.List;

public interface IEmojiResource {
    int getResId(String key);

    List<Integer> getResIds();

    String getEncodeValue(int resId);

    String getEncodePattern();

    Drawable getDrawable(Context context, int resId, Rect bounds);
}
