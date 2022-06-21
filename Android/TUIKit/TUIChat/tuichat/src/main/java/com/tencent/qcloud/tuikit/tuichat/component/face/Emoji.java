package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.graphics.Bitmap;

import java.io.Serializable;

public class Emoji implements Serializable {

    private String desc;
    private String filter;
    private Bitmap icon;
    private int width;
    private int height;

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

}
