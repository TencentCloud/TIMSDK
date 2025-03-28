package com.tencent.cloud.tuikit.roomkit.state.entity;

import androidx.annotation.DrawableRes;

public class BottomSelectItemData {
    private boolean isSelected;

    @DrawableRes
    private int unSelectedIconId;

    @DrawableRes
    private int selectedIconId;

    private String unSelectedName;

    private String selectedName;

    private OnItemSelectListener mOnItemSelectListener;

    public OnItemSelectListener getOnItemSelectListener() {
        return mOnItemSelectListener;
    }

    public void setOnItemSelectListener(OnItemSelectListener listener) {
        this.mOnItemSelectListener = listener;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public int getUnSelectedIconId() {
        return unSelectedIconId;
    }

    public void setUnSelectedIconId(int unSelectedIconId) {
        this.unSelectedIconId = unSelectedIconId;
    }

    public String getSelectedName() {
        return selectedName;
    }

    public void setSelectedName(String selectedName) {
        this.selectedName = selectedName;
    }

    public String getUnSelectedName() {
        return unSelectedName;
    }

    public void setUnSelectedName(String unSelectedName) {
        this.unSelectedName = unSelectedName;
    }

    public int getSelectedIconId() {
        return selectedIconId;
    }

    public void setSelectedIconId(int selectedIconId) {
        this.selectedIconId = selectedIconId;
    }

    public interface OnItemSelectListener {
        void onItemSelected(boolean isSelected);
    }
}
