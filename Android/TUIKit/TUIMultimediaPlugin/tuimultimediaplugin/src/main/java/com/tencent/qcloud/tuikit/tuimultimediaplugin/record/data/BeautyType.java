package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data;

import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.util.LinkedList;
import java.util.List;

public class BeautyType {

    @SerializedName("beauty_type_name")
    private String mTabName;
    @SerializedName("beauty_item_list")
    private List<BeautyItem> mBeautyItemList = new LinkedList<>();

    private int mSelectedItemIndex = 1;

    public BeautyItem getSelectBeautyItem() {
        if (mBeautyItemList == null || mSelectedItemIndex >= mBeautyItemList.size()) {
            return null;
        }

        return mBeautyItemList.get(mSelectedItemIndex);
    }

    public String getName() {
        return TUIMultimediaResourceUtils.getString(mTabName);
    }

    public int getItemSize() {
        return mBeautyItemList != null ? mBeautyItemList.size() : 0;
    }

    public BeautyItem getItem(int index) {
        if (mBeautyItemList == null || index >= mBeautyItemList.size()) {
            return null;
        }
        return mBeautyItemList.get(index);
    }

    public int getSelectedItemIndex() {
        return mSelectedItemIndex;
    }

    public void setSelectedItemIndex(int index) {
        mSelectedItemIndex = index;
    }

    public BeautyItem getSelectedItem() {
        return getItem(mSelectedItemIndex);
    }

    public boolean isContainItem(BeautyItem item) {
        return mBeautyItemList != null && mBeautyItemList.contains(item);
    }
}
