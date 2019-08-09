package com.tencent.qcloud.tim.uikit.component.face;

import android.graphics.Bitmap;

import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

import java.io.Serializable;

public class Emoji implements Serializable {

    private static final int deaultSize = ScreenUtil.getPxByDp(32);

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getFilter() {
        return filter;
    }

    public void setFilter(String filter) {
        this.filter = filter;
    }

    public Bitmap getIcon() {
        return icon;
    }

    public void setIcon(Bitmap icon) {
        this.icon = icon;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    private String desc;
    private String filter;
    private Bitmap icon;
    private int width = deaultSize;
    private int height = deaultSize;

}
