package com.tencent.cloud.tuikit.roomkit.state.entity;

import android.view.View;

import androidx.annotation.DrawableRes;

public class BottomItemData {
    private boolean enable;

    @DrawableRes
    private int iconId;

    @DrawableRes
    private int disableIconId;

    @DrawableRes
    private int backgroundIconId;

    private int width;

    private int height;

    private String name;

    private BottomSelectItemData selectItemData;

    private Type type;

    private View view;

    private OnItemClickListener onItemClickListener;

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public void setView(View view) {
        this.view = view;
    }

    public View getView() {
        return view;
    }

    public int getBackground() {
        return backgroundIconId;
    }

    public void setBackground(int backgroundIconId) {
        this.backgroundIconId = backgroundIconId;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public OnItemClickListener getOnItemClickListener() {
        return onItemClickListener;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }


    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }

    public int getIconId() {
        return iconId;
    }

    public void setIconId(int iconId) {
        this.iconId = iconId;
    }

    public int getDisableIconId() {
        return disableIconId;
    }

    public void setDisableIconId(int disableIconId) {
        this.disableIconId = disableIconId;
    }

    public BottomSelectItemData getSelectItemData() {
        return selectItemData;
    }

    public void setSelectItemData(BottomSelectItemData selectItemData) {
        this.selectItemData = selectItemData;
    }

    public interface OnItemClickListener {
        void onItemClick();
    }

    public enum Type {
        EXIT,
        AUDIO,
        VIDEO,
        RAISE_HAND,
        OFF_STAGE,
        APPLY,
        BEAUTY,
        BARRAGE,
        MEMBER_LIST,
        EXTENSION,
        CHAT,
        SHARE,
        INVITE,
        MINIMIZE,
        RECORD,
        AI,
        SETTING
    }
}
