package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.List;

public abstract class BaseSettingItem {
    protected Context        mContext;
    protected LayoutInflater mInflater;
    protected ItemText       mItemText;

    public BaseSettingItem(Context context,
                           @NonNull ItemText itemText) {
        mContext = context;
        mItemText = itemText;
        mInflater = LayoutInflater.from(context);
    }

    public abstract View getView();

    public static class ItemText {
        public String       title;
        public List<String> contentText;

        public ItemText(String title, String... textList) {
            this.title = title;
            this.contentText = Arrays.asList(textList);
        }
    }
}
