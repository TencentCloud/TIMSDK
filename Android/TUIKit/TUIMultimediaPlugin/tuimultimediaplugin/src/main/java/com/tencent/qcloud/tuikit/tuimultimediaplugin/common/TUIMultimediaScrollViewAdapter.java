package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.widget.BaseAdapter;

public abstract class TUIMultimediaScrollViewAdapter extends BaseAdapter {

    protected int mSelectPosition = -1;

    public int getSelectPosition() {
        return mSelectPosition;
    }

    public void setSelectPosition(int position) {
        mSelectPosition = position;
    }
}
